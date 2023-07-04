struct Attributes
{
    float3 positionOS   : POSITION;
    half3 normalOS      : NORMAL;
    half4 tangentOS     : TANGENT;
    float2 uv           : TEXCOORD0;
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float4 positionWSAndFogFactor   : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    float3 viewDirectionWS         : TEXCOORD3;
    float3 SH                       : TEXCOORD4;
    float4 positionCS               : SV_POSITION;
};

struct Gradient
{
    int colorsLength;
    float4 colors[8];

};

Gradient GradientConstruct()
{
    Gradient g;
    g.colorsLength = 2;
    g.colors[0] = float4(1,1,1,0);
    g.colors[1] = float4(1,1,1,1);
    g.colors[2] = float4(0,0,0,0);
    g.colors[3] = float4(0,0,0,0);
    g.colors[4] = float4(0,0,0,0);
    g.colors[5] = float4(0,0,0,0);
    g.colors[6] = float4(0,0,0,0);
    g.colors[7] = float4(0,0,0,0);
    return g;
}

float3 SampleGradient(Gradient Gradient, float Time)
{
    float3 color = Gradient.colors[0].rgb;

    for (int c = 1; c < Gradient.colorsLength; c++)
    {
        float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
        color = lerp(color, Gradient.colors[c].rgb, colorPos);
    }
    #ifdef UNITY_COLORSPACE_GAMMA
        color = LinearToSRGB(color);
    #endif
    return color;

}

float3 desaturation(float3 color)
{
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    float grayf = dot(color, grayXfer);
    return float3(grayf, grayf, grayf);
}

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS,input.tangentOS);

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.positionWSAndFogFactor = float4(vertexInput.positionWS, ComputeFogFactor(vertexInput.positionCS.z));
    output.normalWS = vertexNormalInput.normalWS;
    output.viewDirectionWS = unity_OrthoParams.w == 0 ? GetCameraPositionWS() - vertexInput.positionWS : GetWorldToViewMatrix()[2].xyz;
    output.SH = SampleSH(lerp(vertexNormalInput.normalWS, float3(0,0,0), _IndirectLightFlattenNormal));
    output.positionCS = vertexInput.positionCS;

    return output;
}

float4 frag(Varyings input, bool isFrontFace : SV_IsFrontFace): SV_TARGET
{
    float3 positionWS = input.positionWSAndFogFactor.xyz;
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    float3 lightDirectionWS = normalize(mainLight.direction);

    float3 normalWS = normalize(input.normalWS);

    float3 viewDirectionWS = normalize(input.viewDirectionWS);

    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv);
    float4 areaMap = 0;
    float4 areaColor = 0;
    #if _AREA_FACE
        areaMap = tex2D(_FaceColorMap, input.uv);
        areaColor = areaMap * _FaceColorMapColor;
    #elif _AREA_HAIR
        areaMap = tex2D(_HairColorMap, input.uv);
        areaColor = areaMap * _HairColorMapColor;
    #elif _AREA_UPPERBODY
        areaMap = tex2D(_UpperBodyColorMap, input.uv);
        areaColor = areaMap * _UpperBodyColorMapColor;
    #elif _AREA_LOWERBODY
        areaMap = tex2D(_LowerBodyColorMap, input.uv);
        areaColor = areaMap * _LowerBodyColorMapColor;
    #endif
    baseColor = areaColor.rgb;
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float4 lightMap = 0;

    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            #if _AREA_HAIR
                lightMap = tex2D(_HairLightMap, input.uv);
            #elif _AREA_UPPERBODY
                lightMap = tex2D(_UpperBodyLightMap, input.uv);
            #elif _AREA_LOWERBODY
                lightMap = tex2D(_LowerBodyLightMap, input.uv);
            #endif
        }
    #endif
    float4 faceMap = 0;
    #if _AREA_FACE
        faceMap = tex2D(_FaceMap, input.uv);
    #endif

    float3 indirectLightColor = input.SH.rgb * _IndirectLightUsage;
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        
        indirectLightColor *= lerp(1, lightMap.r, _IndirectLightOcclusionUsage);
    #else
        indirectLightColor *= lerp(1, lerp(faceMap.g, 1, step(faceMap.r, 0.5)), _IndirectLightOcclusionUsage);
    #endif
    indirectLightColor *= lerp(1, baseColor, _IndirectLightMixBaseColor);

    float3 mainLightColor = lerp(desaturation(mainLight.color), mainLight.color, _MainLightColorUsage);

    float mainLightShadow = 1;
    int rampRowIndex = 0;
    int rampRowNum = 1;
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            float NoL = dot(normalWS, lightDirectionWS);
            float remappedNoL = NoL * 0.5 + 0.5;
            mainLightShadow = smoothstep(1 - lightMap.g + _ShadowThresholdCenter - _ShadowThresholdSoftness, 1 - lightMap.g + _ShadowThresholdCenter + _ShadowThresholdSoftness, remappedNoL);
            mainLightShadow *= lightMap.r;

            #if _AREA_HAIR
                rampRowIndex = 0;
                rampRowNum = 1;
            #elif _AREA_UPPERBODY || _AREA_LOWERBODY
                int rawIndex = (round((lightMap.a + 0.0425)/0.0625) - 1)/2;
                rampRowIndex = lerp(rawIndex, rawIndex + 4 < 8 ? rawIndex + 4 : rawIndex + 4 - 8, fmod(rawIndex, 2));
                rampRowNum = 0;
            #endif
        }
    #elif _AREA_FACE
        {
            float3 headForward = normalize(_HeadForward);
            float3 headRight = normalize(_HeadRight);
            float3 headUp = cross(headForward, headRight);

            float3 fixedLightDirectionWS = normalize(lightDirectionWS - dot(lightDirectionWS, headUp) * headUp);
            float2 sdfUV = float2(sign(dot(fixedLightDirectionWS, headRight)), 1) * input.uv * float2(-1, 1);
            float sdfValue = tex2D(_FaceMap, sdfUV).a;
            sdfValue += _FaceShadowOffset;

            float sdfThreshold = 1 - (dot(fixedLightDirectionWS, headForward) * 0.5 + 0.5);
            float sdf = smoothstep(sdfThreshold - _FaceShadowTransitionSoftness, sdfThreshold + _FaceShadowTransitionSoftness, sdfValue);

            mainLightShadow = lerp(faceMap.g, sdf, step(faceMap.r, 0.5));

            rampRowIndex = 0;
            rampRowNum = 0;

        }
    #endif

    float rampUVx = mainLightShadow * (1 - _ShadowRampOffset) + _ShadowRampOffset;
    float rampUVy = (2 * rampRowIndex + 1) * (1.0 / (rampRowNum * 2));
    float2 rampUV = float2(rampUVx, rampUVy);
    float3 coolRamp = 1;
    float3 warmRamp = 1;

    #if _AREA_HAIR
        coolRamp = tex2D(_HairCoolRamp, rampUV).rgb;
        warmRamp = tex2D(_HairWarmRamp, rampUV).rgb;
    #elif _AREA_FACE || _AREA_UPPERBODY || _AREA_LOWERBODY
        coolRamp = tex2D(_BodyCoolRamp, rampUV).rgb;
        warmRamp = tex2D(_BodyWarmRamp, rampUV).rgb;
    #endif
    float isDay = lightDirectionWS.y * 0.5 + 0.5;
    float3 rampColor = lerp(coolRamp, warmRamp, isDay);
    mainLightColor *= baseColor * rampColor;


    float3 specularColor = 0;
    #if _SPECULAR_ON
        #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
            {
                float3 halfVectorWS = normalize(viewDirectionWS + lightDirectionWS);
                float NoH = dot(normalWS, halfVectorWS);
                float blinnPhong = pow(saturate(NoH), _SpecularExpon);

                float nonMetalSpecular = step(1.04 - blinnPhong, lightMap.b) * _SpecularKsNonMetal;
                float metalSpecular = blinnPhong * lightMap.b * _SpecularKsMetal;

                float metallic = 0;
                #if _METAL_SPECULAR_ON
                    #if  _AREA_UPPERBODY || _AREA_LOWERBODY
                        metallic = saturate((abs(lightMap.a - 0.52) - 0.1)/(0 - 0.1));
                    #endif
                #else
                    metallic = 0;
                #endif
                specularColor = lerp(nonMetalSpecular, metalSpecular * baseColor, metallic);
                specularColor *= mainLight.color;
                specularColor *= _SpecularBrightness;
            }
        #endif
    #else
        specularColor = 0;

    #endif

    float3 stockingsEffect = 1;
    #if _STOCKINGS_ON
        #if _AREA_UPPERBODY || _AREA_LOWERBODY
            {
                float2 stockingsMapRG = 0;
                float stockingsMapB = 0;
                #if _AREA_UPPERBODY
                    stockingsMapRG = tex2D(_UpperBodyStockings, input.uv).rg;
                    stockingsMapB = tex2D(_UpperBodyStockings, input.uv * 20).b;
                #elif _AREA_LOWERBODY
                    stockingsMapRG = tex2D(_LowerBodyStockings, input.uv).rg;
                    stockingsMapB = tex2D(_LowerBodyStockings, input.uv * 20).b;
                #endif
                float NoV = dot(normalWS, viewDirectionWS);
                float fac = NoV;
                fac = pow(saturate(fac), _StockingsTransitionPower);
                fac = saturate((fac - _StockingsTransitionHardness/2)/(1 - _StockingsTransitionHardness));
                fac = fac * (stockingsMapB * _StockingsTextureUsage + (1 - _StockingsTextureUsage));
                fac = lerp(fac, 1, stockingsMapRG.g);
                Gradient curve = GradientConstruct();
                curve.colorsLength = 3;
                curve.colors[0] = float4(_StockingsDarkColor, 0);
                curve.colors[1] = float4(_StockingsTransitionColor, _StockingsTransitionThreshold);
                curve.colors[2] = float4(_StockingsLightColor, 1);
                float3 stockingsColor = SampleGradient(curve, fac);

                stockingsEffect = lerp(1, stockingsColor, stockingsMapRG.r);

            }
        #endif
    #else
        stockingsEffect = 1;
    #endif

    float3 rimLightColor;
    #if _RIM_LIGHTING_ON
        float linearEyeDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
        float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
        float2 uvOffset = float2(sign(normalVS.x), 0) * _RimLightWidth / (1 + linearEyeDepth) / 100;
        int2 loadTexPos = input.positionCS.xy + uvOffset * _ScaledScreenParams.xy;
        loadTexPos = min(max(loadTexPos, 0), _ScaledScreenParams.xy - 1);
        float offsetSceneDepth = LoadSceneDepth(loadTexPos);
        float offsetLinearEyeDepth = LinearEyeDepth(offsetSceneDepth, _ZBufferParams);
        float rimLight = saturate(offsetLinearEyeDepth - (linearEyeDepth + _RimLightThreshold)) / _RimLightFadeout;
        rimLightColor = rimLight * mainLight.color.rgb;
        rimLightColor *= _RimLightTintColor;
        rimLightColor *= _RimLightBrightness;
        #else
        rimLightColor = 0;
    #endif

    float3 emissionColor = 0;
    #if _EMISSION_ON
        {
            emissionColor = areaMap.a;
            emissionColor *= lerp(1, baseColor, _EmissionMixBaseColor);
            emissionColor *= _EmissionTintColor;
            emissionColor *= _EmissionIntensity;
        }
    #endif

    float fakeOutlineEffect = 0;
    float3 fakeOutlineColor = 0;
    #if _AREA_FACE && _OUTLINE_ON
        {
            float fakeOutline = faceMap.b;
            float3 headForward = normalize(_HeadForward);
            fakeOutlineEffect = smoothstep(0.0, 0.25, pow(saturate(dot(headForward, viewDirectionWS)), 20) * fakeOutline);
            float2 outlineUV = float2(0, 0.0625);
            coolRamp = tex2D(_BodyCoolRamp, outlineUV).rgb;
            warmRamp = tex2D(_BodyWarmRamp, outlineUV).rgb;
            float3 OutlineRamp = lerp(coolRamp, warmRamp, 0.5);
            fakeOutlineColor = pow(OutlineRamp, _OutlineGamma);
        }
    #endif

    float3 albedo = 0;
    albedo += indirectLightColor;
    albedo += mainLightColor;
    albedo += specularColor;
    albedo *= stockingsEffect;
    albedo += rimLightColor * lerp(1, albedo, _RimLightMixAlbedo);
    albedo += emissionColor;
    albedo = lerp(albedo, fakeOutlineColor, fakeOutlineEffect);

    float alpha = _Alpha;

    #if _DRAW_OVERLAY_ON
    {
        float3 headForward = normalize(_HeadForward);
        alpha = lerp(1, alpha, saturate(dot(headForward, viewDirectionWS)));
    }
    #endif

    float4 FinalColor = float4(albedo, alpha);
    clip(FinalColor.a - _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

    return FinalColor;
}

