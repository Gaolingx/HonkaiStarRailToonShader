
const static float3 f3zero = float3(0.0, 0.0, 0.0);
const static float3 f3one = float3(1.0, 1.0, 1.0);
const static float4 f4zero = float4(0.0, 0.0, 0.0, 0.0);
const static float4 f4one = float4(1.0, 1.0, 1.0, 1.0);

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
    float3 bitangentWS              : TEXCOORD3;
    float3 tangentWS                : TEXCOORD4;
    float3 viewDirectionWS          : TEXCOORD5;
    float3 SH                       : TEXCOORD6;
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

float3 BrightnessFactor(float3 InputColor, float brightnessFactor)
{
    float3 scaledColor = InputColor.rgb * brightnessFactor;
    scaledColor = clamp(scaledColor, 0.0, 1.0);
    return scaledColor;
}

float3 LerpRampColor(float3 coolRamp, float3 warmRamp, float DayTime)
{
    return lerp(warmRamp, coolRamp, abs(DayTime - 12.0) * rcp(12.0));
}

float3 LinearColorMix(float3 OriginalColor, float3 EnhancedColor, float mixFactor)
{
    float3 finalColor = lerp(OriginalColor, EnhancedColor, mixFactor);
    return finalColor;
}

Varyings SRUniversalVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(input.normalOS,input.tangentOS);

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    // 世界空间
    output.positionWSAndFogFactor = float4(vertexPositionInputs.positionWS, ComputeFogFactor(vertexPositionInputs.positionCS.z));
    // 世界空间法线、切线、副切线
    output.normalWS = vertexNormalInputs.normalWS;
    output.tangentWS = vertexNormalInputs.tangentWS;
    output.bitangentWS = vertexNormalInputs.bitangentWS;
    // 世界空间相机向量
    output.viewDirectionWS = unity_OrthoParams.w == 0 ? GetCameraPositionWS() - vertexPositionInputs.positionWS : GetWorldToViewMatrix()[2].xyz;
    // 间接光 with 球谐函数
    output.SH = SampleSH(lerp(vertexNormalInputs.normalWS, float3(0,0,0), _IndirectLightFlattenNormal));

    output.positionCS = vertexPositionInputs.positionCS;

    return output;
}

float4 colorFragmentTarget(inout Varyings input, bool isFrontFace)
{
    //片元世界空间位置
    float3 positionWS = input.positionWSAndFogFactor.xyz;

    //阴影坐标
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);

    //获取主光源，传入shadowCoord是为了让mainLight获取阴影衰减，也就是实时阴影（shadowCoord为灯光空间坐标，xy采样shadowmap然后与z对比）
    Light mainLight = GetMainLight(shadowCoord);
    //获取主光源颜色
    float4 LightColor = float4(BrightnessFactor(mainLight.color.rgb, _MainLightBrightnessFactor), 1);
    //获取主光源方向
    float3 lightDirectionWS = normalize(mainLight.direction);

    //获取世界空间法线，如果要采样NormalMap，要使用TBN矩阵变换
    #if _NORMAL_MAP_ON
        float3x3 tangentToWorld = half3x3(input.tangentWS, input.bitangentWS, input.normalWS);
        float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
        float3 normalTS = UnpackNormal(normalMap);
        float3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld, true);
        input.normalWS = normalWS;
    #else
        float3 normalWS = normalize(input.normalWS);
    #endif
    
    //视线方向
    float3 viewDirectionWS = normalize(input.viewDirectionWS);

    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv);
    float4 areaMap = 0;
    float4 areaColor = 0;
    //根据不同的Keyword，采样不同的贴图，作为额漫反射颜色
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
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);
    //对有LightMap的部位，采样 LightMap
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
    //对脸部采样 faceMap，脸部的LightMap就是这张FaceMap
    float4 faceMap = 0;
    #if _AREA_FACE
        faceMap = tex2D(_FaceMap, input.uv);
    #endif

    // Expression
    #if _AREA_FACE && _Expression_ON
        float4 exprMap = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, input.uv.xy);
        float3 exCheek = lerp(baseColor.rgb, baseColor.rgb * _ExCheekColor.rgb, exprMap.r);
        baseColor.rgb = lerp(baseColor.rgb, exCheek, _ExCheekIntensity);
        float3 exShy = lerp(baseColor.rgb, baseColor.rgb * _ExShyColor.rgb, exprMap.g);
        baseColor.rgb = lerp(baseColor.rgb, exShy, _ExShyIntensity);
        float3 exShadow = lerp(baseColor.rgb, baseColor.rgb * _ExShadowColor.rgb, exprMap.b);
        baseColor.rgb = lerp(baseColor.rgb, exShadow, _ExShadowIntensity);
        float3 exEyeShadow = lerp(baseColor.rgb, baseColor.rgb * _ExEyeColor.rgb, faceMap.r);
        baseColor.rgb = lerp(baseColor.rgb, exEyeShadow, _ExShadowIntensity);
    #endif

    //lightmap的R通道是AO，也就是静态阴影，根据AO，来影响环境光照
    float3 indirectLightColor = input.SH.rgb * _IndirectLightUsage;
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        
        indirectLightColor *= lerp(1, lightMap.r, _IndirectLightOcclusionUsage); // 加个 Ambient Occlusion
    #elif _AREA_FACE
        indirectLightColor *= lerp(1, lerp(faceMap.g, 1, step(faceMap.r, 0.5)), _IndirectLightOcclusionUsage);
    #endif
    indirectLightColor *= lerp(1, baseColor, _IndirectLightMixBaseColor);
    
    //使用一个参数_MainLightColorUsage控制主光源颜色的使用程度
    float3 mainLightColor = lerp(Luminance(LightColor.rgb), LightColor.rgb, _MainLightColorUsage);
    //float3 mainLightColor = lerp(desaturation(mainLight.color), mainLight.color, _MainLightColorUsage);

    float mainLightShadow = 1;
    int rampRowIndex = 0;
    int rampRowNum = 1;
    //lightmap的G通道直接光阴影的形状，值越小，越容易进入阴影，有些刺的效果就是这里出来的
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            float NoL = dot(normalWS, lightDirectionWS);
            float remappedNoL = NoL * 0.5 + 0.5;
            float shadowThreshold = lightMap.g;
            //加个过渡，这里_ShadowThresholdSoftness=0.1
            mainLightShadow = smoothstep(
                1.0 - shadowThreshold - _ShadowThresholdSoftness,
                1.0 - shadowThreshold + _ShadowThresholdSoftness,
                remappedNoL + _ShadowThresholdCenter);
            //应用AO
            mainLightShadow *= lightMap.r;

            //头发的Ramp贴图只有一行，因此不用计算
            #if _AREA_HAIR
                rampRowIndex = 1;
                rampRowNum = 1;
                //rampRowIndex = 0;
                //rampRowNum = 1;
                //上下衣的Ramp贴图有8行
            #elif _AREA_UPPERBODY || _AREA_LOWERBODY
                int rawIndex = round(lightMap.a * 8.04 + 0.81);
                //int rawIndex = (round((lightMap.a + 0.0425)/0.0625) - 1)/2;
                //奇数行不变，偶数行先偏移4行，再对8取余
                rampRowIndex = lerp(fmod((rawIndex + 4), 8), rawIndex, fmod(rawIndex, 2));
                //rampRowIndex = lerp(rawIndex, rawIndex + 4 < 8 ? rawIndex + 4 : rawIndex + 4 - 8, fmod(rawIndex, 2));
                //身体的Ramp贴图有8行
                rampRowNum = 8;
                //rampRowNum = 0;
            #endif
        }
    #elif _AREA_FACE
        float3 headForward = normalize(_HeadForward).xyz;
        float3 headRight = normalize(_HeadRight).xyz;
        float3 headUp = normalize(cross(headForward, headRight));
        float3 lightDir = normalize(lightDirectionWS - dot(lightDirectionWS, headUp) * headUp);
        //光照在左脸的时候。左脸的uv采样左脸，右脸的uv采样右脸，而光照在右脸的时候，左脸的uv采样右脸，右脸的uv采样左脸，因为SDF贴图明暗变化在右脸
        float isRight = step(0, dot(lightDir, headRight));
        //相当于float sdfUVx=isRight?1-input.uv.x:input.uv.x;
        //即打在右脸的时候，反转uv的u坐标
        float sdfUVx = lerp(input.uv.x, 1 - input.uv.x, isRight);
        float2 sdfUV = float2(sdfUVx, input.uv.y);
        //使用uv采样面部贴图的a通道
        float sdfValue = tex2D(_FaceMap, sdfUV).a;
        sdfValue += _FaceShadowOffset;
        //dot(lightDir,headForward)的范围是[1,-1]映射到[0,1]
        float sdfThreshold = 1 - (dot(lightDir, headForward) * 0.5 + 0.5);
        //采样结果大于点乘结果，不在阴影，小于则处于阴影
        float sdf = smoothstep(sdfThreshold - _FaceShadowTransitionSoftness, sdfThreshold + _FaceShadowTransitionSoftness, sdfValue);
        //AO中常暗的区域，step提取大于0.5的部分，使用g通道的阴影形状（常亮/常暗），其他部分使用sdf贴图
        mainLightShadow = lerp(faceMap.g, sdf, step(faceMap.r, 0.5));
        //脸部ramp直接使用皮肤的行号即可
        rampRowIndex = 1;
        //rampRowIndex = 0;
        rampRowNum = 8;
    #endif

    //Ramp Color
    //根据NdotL计算UV的u，由于ramp贴图的变化主要集中在3/4的地方，把uv乘以0.25然后加上0.75
    //这里_ShadowRampOffset=0.75
    float rampUVx = mainLightShadow * (1 - _ShadowRampOffset) + _ShadowRampOffset;
    //计算uv的v
    float rampUVy = (2 * rampRowIndex - 1) * (1.0 / (rampRowNum * 2));
    //float rampUVy = (2 * rampRowIndex + 1) * (1.0 / (rampRowNum * 2));
    float2 rampUV = float2(rampUVx, rampUVy);
    float3 coolRamp = 1;
    float3 warmRamp = 1;
    float3 coolRampCol = 1;
    float3 warmRampCol = 1;

    //hair的Ramp贴图和身体或脸部的不一样，按照keyword采样
    #if _AREA_HAIR
        coolRamp = tex2D(_HairCoolRamp, rampUV).rgb;
        warmRamp = tex2D(_HairWarmRamp, rampUV).rgb;
        coolRampCol = LinearColorMix(coolRamp, _HairCoolRampColor, _HairCoolRampColorMixFactor);
        warmRampCol = LinearColorMix(warmRamp, _HairWarmRampColor, _HairWarmRampColorMixFactor);
    #elif _AREA_FACE || _AREA_UPPERBODY || _AREA_LOWERBODY
        coolRamp = tex2D(_BodyCoolRamp, rampUV).rgb;
        warmRamp = tex2D(_BodyWarmRamp, rampUV).rgb;
        coolRampCol = LinearColorMix(coolRamp, _BodyCoolRampColor, _BodyCoolRampColorMixFactor);
        warmRampCol = LinearColorMix(warmRamp, _BodyWarmRampColor, _BodyWarmRampColorMixFactor);
    #endif
    //根据白天夜晚，插值获得最终的rampColor，_DayTime也可以用变量由C#脚本传入Shader
    #if _DayTime_MANUAL_ON
        float DayTime = _DayTime;
    #else
        float DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    #endif
    float3 rampColor = LerpRampColor(coolRampCol, warmRampCol, DayTime);
    rampColor = lerp(f3one, rampColor, _ShadowBoost);
    mainLightColor *= baseColor * rampColor;


    //高光
    float3 specularColor = 0;
    #if _SPECULAR_ON
        #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
            {
                //计算半程向量
                float3 halfVectorWS = normalize(viewDirectionWS + lightDirectionWS);
                float NoH = dot(normalWS, halfVectorWS);
                float blinnPhong = pow(saturate(NoH), _SpecularExpon);
                //非金属的反射率一般为0.04
                float nonMetalSpecular = step(1.04 - blinnPhong, lightMap.b) * _SpecularKsNonMetal;
                //金属反射率取1
                float metalSpecular = blinnPhong * lightMap.b * _SpecularKsMetal;

                float metallic = 0;
                #if _METAL_SPECULAR_ON
                    #if  _AREA_UPPERBODY || _AREA_LOWERBODY
                        //金属部分的Alpha值为0.52，此时metallic为1，以0.1为插值范围，确定金属度
                        metallic = saturate((abs(lightMap.a - _MetalSpecularMetallic) - 0.1)/(0 - 0.1));
                    #endif
                #else
                    //因为头发没有金属，所以头发位置要关掉这个keyword
                    metallic = 0;
                #endif
                specularColor = lerp(nonMetalSpecular, metalSpecular * baseColor, metallic);
                #if _SPECULAR_COLOR_CUSTOM
                    //开启该keyword以使用自定义高光颜色
                    specularColor *= _SpecularColor;
                #else
                    //高光颜色与主光源的颜色同步
                    specularColor *= LightColor.rgb;
                #endif
                //强度系数
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
                fac = fac * (stockingsMapB * _StockingsTextureUsage + (1 - _StockingsTextureUsage)); // 细节纹理
                fac = lerp(fac, 1, stockingsMapRG.g); // 厚度插值亮区
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
    //边缘光部分
    float3 rimLightColor;
    #if _RIM_LIGHTING_ON
        //获取当前片元的深度
        float linearEyeDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
        //根据视线空间的法线采样左边或者右边的深度图
        float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
        //根据视线空间的法线采样左边或者右边的深度图，根据深度缩放，实现近大远小的效果
        float2 uvOffset = float2(sign(normalVS.x), 0) * _RimLightWidth / (1 + linearEyeDepth) / 100;
        int2 loadTexPos = input.positionCS.xy + uvOffset * _ScaledScreenParams.xy;
        //限制左右，不采样到边界
        loadTexPos = min(max(loadTexPos, 0), _ScaledScreenParams.xy - 1);
        //偏移后的片元深度
        float offsetSceneDepth = LoadSceneDepth(loadTexPos);
        //转换为LinearEyeDepth
        float offsetLinearEyeDepth = LinearEyeDepth(offsetSceneDepth, _ZBufferParams);
        //深度差超过阈值，表示是边界
        float rimLight = saturate(offsetLinearEyeDepth - (linearEyeDepth + _RimLightThreshold)) / _RimLightFadeout;
        rimLightColor = rimLight * LightColor.rgb;
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
    #if _AREA_FACE && _OUTLINE_ON && _FAKE_OUTLINE_ON
        {
            float fakeOutline = faceMap.b;
            float3 headForward = normalize(_HeadForward);
            fakeOutlineEffect = smoothstep(0.0, 0.25, pow(saturate(dot(headForward, viewDirectionWS)), 20) * fakeOutline);
            float2 outlineUV = float2(0, 0.0625);
            coolRamp = tex2D(_BodyCoolRamp, outlineUV).rgb;
            warmRamp = tex2D(_BodyWarmRamp, outlineUV).rgb;
            #if _USE_RAMP_COLOR_ON
                float3 OutlineRamp = abs(lerp(coolRamp, warmRamp, 0.5));
            #else
                float3 OutlineRamp = _OutlineColor.rgb;
            #endif
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

void SRUniversalFragment(
    Varyings input,
    bool isFrontFace            : SV_IsFrontFace,
    out float4 colorTarget      : SV_Target0,
    out float4 bloomTarget      : SV_Target1)
{
    float4 outputColor = colorFragmentTarget(input, isFrontFace);

    colorTarget = float4(outputColor.rgba);
    bloomTarget = float4(_BloomIntensity0, 0, 0, 0);
}

