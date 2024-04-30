#include "../ShaderLibrary/SRUniversalLibrary.hlsl"

struct CharCoreAttributes
{
    float3 positionOS   : POSITION;
    half3 normalOS      : NORMAL;
    half4 tangentOS     : TANGENT;
    float2 uv           : TEXCOORD0;
};

struct CharCoreVaryings
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


CharCoreVaryings SRUniversalVertex(CharCoreAttributes input)
{
    CharCoreVaryings output = (CharCoreVaryings)0;

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
    output.SH = SampleSH(lerp(vertexNormalInputs.normalWS, float3(0, 0, 0), _IndirectLightFlattenNormal));

    output.positionCS = vertexPositionInputs.positionCS;

    return output;
}

float4 colorFragmentTarget(inout CharCoreVaryings input, bool isFrontFace)
{
    //片元世界空间位置
    float3 positionWS = input.positionWSAndFogFactor.xyz;

    //阴影坐标
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);

    //获取主光源，传入shadowCoord是为了让mainLight获取阴影衰减，也就是实时阴影（shadowCoord为灯光空间坐标，xy采样shadowmap然后与z对比）
    Light mainLight = GetCharacterMainLightStruct(shadowCoord, positionWS);
    //获取主光源颜色
    float4 LightColor = GetMainLightBrightness(mainLight.color.rgb, _MainLightBrightnessFactor);
    #if _AUTO_Brightness_ON
        if (LightColor.r <= 1 || LightColor.g <= 1 || LightColor.b <= 1) //仅限SDR
        {
            LightColor = clamp(pow(LightColor, 0.5), _AutoBrightnessThresholdMin, _AutoBrightnessThresholdMax) + _AutoBrightnessOffset;
        }
        else
        {
            LightColor += _AutoBrightnessOffset;
        }
    #endif
    //使用一个参数_MainLightColorUsage控制主光源颜色的使用程度
    float3 mainLightColor = GetMainLightColor(LightColor.rgb, _MainLightColorUsage);

    //获取主光源方向
    float3 lightDirectionWS = normalize(mainLight.direction);

    //获取世界空间法线，如果要采样NormalMap，要使用TBN矩阵变换
    #if _USE_NORMAL_MAP
        float3x3 tangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
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
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
    _HairColorMap, _HairColorMapColor,
    _UpperBodyColorMap, _UpperBodyColorMapColor,
    _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);
    
    //对有LightMap的部位，采样 LightMap
    float4 lightMap = 0;
    lightMap = GetLightMapTex(input.uv, _HairLightMap, _UpperBodyLightMap, _LowerBodyLightMap);

    //对脸部采样 faceMap，脸部的LightMap就是这张FaceMap
    float4 faceMap = 0;
    #if _AREA_FACE
        faceMap = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.uv);
    #endif

    // LightMap
    float specularIntensity = lightMap.r;
    float diffuseThreshold = lightMap.g;
    float specularThreshold = lightMap.b;
    float materialId = lightMap.a;

    // Expression
    #if _AREA_FACE && _Expression_ON
        {
            float4 exprMap = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, input.uv.xy);
            float3 exCheek = lerp(baseColor.rgb, baseColor.rgb * _ExCheekColor.rgb, exprMap.r);
            baseColor.rgb = lerp(baseColor.rgb, exCheek, _ExCheekIntensity);
            float3 exShy = lerp(baseColor.rgb, baseColor.rgb * _ExShyColor.rgb, exprMap.g);
            baseColor.rgb = lerp(baseColor.rgb, exShy, _ExShyIntensity);
            float3 exShadow = lerp(baseColor.rgb, baseColor.rgb * _ExShadowColor.rgb, exprMap.b);
            baseColor.rgb = lerp(baseColor.rgb, exShadow, _ExShadowIntensity);
            float3 exEyeShadow = lerp(baseColor.rgb, baseColor.rgb * _ExEyeColor.rgb, faceMap.r);
            baseColor.rgb = lerp(baseColor.rgb, exEyeShadow, _ExShadowIntensity);
        }
    #endif

    float3 indirectLightColor = 0;
    //float3 indirectLightColor = input.SH.rgb * _IndirectLightUsage;
    indirectLightColor = CalculateGI(baseColor, diffuseThreshold, input.SH.rgb, _IndirectLightIntensity, _IndirectLightUsage);
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        //lightmap的R通道是AO，也就是静态阴影，根据AO，来影响环境光照
        indirectLightColor *= lerp(1, specularIntensity, _IndirectLightOcclusionUsage); // 加个 Ambient Occlusion
    #elif _AREA_FACE
        indirectLightColor *= lerp(1, lerp(faceMap.g, 1, step(faceMap.r, 0.5)), _IndirectLightOcclusionUsage);
    #endif
    indirectLightColor *= lerp(1, baseColor, _IndirectLightMixBaseColor);


    float mainLightShadow = 1;
    int rampRowIndex = 0;
    int rampRowNum = 1;
    //lightmap的G通道直接光阴影的形状，值越小，越容易进入阴影，有些刺的效果就是这里出来的
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            float NoL = dot(normalWS, lightDirectionWS);
            float remappedNoL = NoL * 0.5 + 0.5;
            float shadowThreshold = diffuseThreshold;
            //加个过渡，这里_ShadowThresholdSoftness=0.1
            mainLightShadow = smoothstep(
            1.0 - shadowThreshold - _ShadowThresholdSoftness,
            1.0 - shadowThreshold + _ShadowThresholdSoftness,
            remappedNoL + _ShadowThresholdCenter) + _MainLightShadowOffset;
            //应用AO
            mainLightShadow *= lerp(1, specularIntensity, _LerpAOIntensity);
            mainLightShadow = lerp(0.20, mainLightShadow, saturate(mainLight.shadowAttenuation + HALF_EPS));
        }
    #elif _AREA_FACE
        {
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
            float sdfValue = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, sdfUV).a;
            sdfValue += _FaceShadowOffset;
            //dot(lightDir,headForward)的范围是[1,-1]映射到[0,1]
            float sdfThreshold = 1 - (dot(lightDir, headForward) * 0.5 + 0.5);
            //采样结果大于点乘结果，不在阴影，小于则处于阴影
            float sdf = smoothstep(sdfThreshold - _FaceShadowTransitionSoftness, sdfThreshold + _FaceShadowTransitionSoftness, sdfValue);
            //AO中常暗的区域，step提取大于0.5的部分，使用g通道的阴影形状（常亮/常暗），其他部分使用sdf贴图
            mainLightShadow = lerp(faceMap.g, sdf, step(faceMap.r, 0.5));
            mainLightShadow *= mainLight.shadowAttenuation;
        }
    #endif

    float diffuseFac = mainLightShadow;
    float3 coolRampCol = 1;
    float3 warmRampCol = 1;
    float2 rampUV;

    float rampU = diffuseFac * (1 - _ShadowRampOffset) + _ShadowRampOffset;
    rampUV = float2(rampU, GetRampV(materialId));

    //Ramp Color
    RampColor RC = RampColorConstruct(rampUV, _HairCoolRamp, _HairCoolRampColor, _HairCoolRampColorMixFactor,
    _HairWarmRamp, _HairWarmRampColor, _HairWarmRampColorMixFactor,
    _BodyCoolRamp, _BodyCoolRampColor, _BodyCoolRampColorMixFactor,
    _BodyWarmRamp, _BodyWarmRampColor, _BodyWarmRampColorMixFactor);
    coolRampCol = RC.coolRampCol;
    warmRampCol = RC.warmRampCol;
    //根据白天夜晚，插值获得最终的rampColor，_DayTime也可以用变量由C#脚本传入Shader
    float DayTime = 0;
    #if _DayTime_MANUAL_ON
        DayTime = _DayTime;
    #else
        DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    #endif
    
    float3 rampColor = LerpRampColor(coolRampCol, warmRampCol, DayTime);
    rampColor = lerp(f3one, rampColor, _ShadowBoost);
    float3 FinalDiffuse = mainLightColor * baseColor * rampColor;

    #if defined(_ADDITIONAL_LIGHTS)
        #if _AdditionalLighting_ON
            CHAR_LIGHT_LOOP_BEGIN(positionWS, input.positionCS)
                Light lightAdd = GetCharacterAdditionalLight(lightIndex, positionWS);
                FinalDiffuse = CombineColorPreserveLuminance(FinalDiffuse, GetAdditionalLightDiffuse(baseColor.rgb, lightAdd));
            CHAR_LIGHT_LOOP_END
        #endif
    #endif

    //Specular
    half3 specularColor = 0;
    half3 viewDirWS = normalize(GetWorldSpaceViewDir(positionWS));

    #if _SPECULAR_ON
        #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
            {
                SpecularAreaData specularAreaData = GetSpecularAreaData(materialId, _SpecularColor.rgb);
                float3 SpecularColor = specularAreaData.color;
                float SpecularIntensity = specularAreaData.intensity;
                float SpecularShininess = specularAreaData.shininess;
                float SpecularRoughness = specularAreaData.roughness;

                SpecularData specularData;
                specularData.color = baseColor;
                specularData.specularIntensity = specularIntensity;
                specularData.specularThreshold = specularThreshold;
                specularData.materialId = materialId;
                specularData.SpecularKsNonMetal = _SpecularKsNonMetal;
                specularData.SpecularKsMetal = _SpecularKsMetal;
                //specularData.MetalSpecularMetallic = _MetalSpecularMetallic;

                specularColor = CalculateBaseSpecular(specularData, mainLight, viewDirWS, normalWS, SpecularColor, SpecularShininess, SpecularRoughness, SpecularIntensity, diffuseFac);

                //specularColor *= mainLight.shadowAttenuation;
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
                    stockingsMapRG = SAMPLE_TEXTURE2D(_UpperBodyStockings, sampler_UpperBodyStockings, input.uv).rg;
                    stockingsMapB = SAMPLE_TEXTURE2D(_UpperBodyStockings, sampler_UpperBodyStockings, input.uv * _stockingsMapBChannelUVScale).b;
                #elif _AREA_LOWERBODY
                    stockingsMapRG = SAMPLE_TEXTURE2D(_LowerBodyStockings, sampler_LowerBodyStockings, input.uv).rg;
                    stockingsMapB = SAMPLE_TEXTURE2D(_LowerBodyStockings, sampler_LowerBodyStockings, input.uv * _stockingsMapBChannelUVScale).b;
                #endif
                //用法线点乘视角向量模拟皮肤透过丝袜
                float NoV = dot(normalWS, viewDirectionWS);
                float fac = NoV;
                //做一次幂运算，调整亮区大小
                fac = pow(saturate(fac), _StockingsTransitionPower);
                //调整亮暗过渡的硬度
                fac = saturate((fac - _StockingsTransitionHardness / 2) / (1 - _StockingsTransitionHardness));
                fac = fac * (stockingsMapB * _StockingsTextureUsage + (1 - _StockingsTextureUsage)); // 细节纹理
                fac = lerp(fac, 1, stockingsMapRG.g); // 厚度插值亮区
                Gradient curve = GradientConstruct();
                curve.colorsLength = 3;
                curve.colors[0] = float4(_StockingsDarkColor, 0);
                curve.colors[1] = float4(_StockingsTransitionColor, _StockingsTransitionThreshold);
                curve.colors[2] = float4(_StockingsLightColor, 1);
                float3 stockingsColor = SampleGradient(curve, fac); // 将亮区的系数映射成颜色

                stockingsEffect = lerp(f3one, stockingsColor, stockingsMapRG.r);

            }
        #endif
    #else
        stockingsEffect = 1;
    #endif
    
    //Rim Light
    float3 rimLightColor = 0;
    float3 rimLightMask;
    float rimNoV = dot(normalize(normalWS), normalize(GetWorldSpaceViewDir(positionWS)));
    float rimNoL = dot(normalize(normalWS), normalize(mainLight.direction));

    #if _RIM_LIGHTING_ON
        {
            RimLightAreaData rimLightAreaData = GetRimLightAreaData(materialId, _RimColor.rgb);
            float3 rimLightAreaColor = rimLightAreaData.color;
            float rimLightAreaWidth = rimLightAreaData.width;
            float rimLightAreaDark = rimLightAreaData.rimDark;
            float rimLightAreaEdgeSoftnesses = rimLightAreaData.edgeSoftness;

            RimLightMaskData rimLightMaskData;
            rimLightMaskData.color = rimLightAreaColor;
            rimLightMaskData.width = rimLightAreaWidth;
            rimLightMaskData.edgeSoftness = rimLightAreaEdgeSoftnesses;
            rimLightMaskData.thresholdMin = _RimThresholdMin;
            rimLightMaskData.thresholdMax = _RimThresholdMax;
            rimLightMaskData.modelScale = _ModelScale;
            rimLightMaskData.ditherAlpha = _DitherAlpha;
            rimLightMaskData.NoV = rimNoV;
        
            RimLightData rimLightData;
            rimLightData.darkenValue = rimLightAreaDark;
            rimLightData.intensityFrontFace = _RimIntensity;
            rimLightData.intensityBackFace = _RimIntensityBackFace;

            rimLightMask = GetRimLightMask(rimLightMaskData, input.positionCS, normalWS, lightMap);
            rimLightColor = GetRimLight(rimLightData, rimLightMask, rimNoL, mainLight, isFrontFace);
        }
    #endif

    //Rim Shadow
    float3 rimShadowColor = 1;
    #if _RIM_SHADOW_ON
        {
            RimShadowAreaData rimShadowAreaData = GetRimShadowAreaData(materialId, _RimShadowColor.rgb);
            float3 rimAreaShadowColor = rimShadowAreaData.color;
            float rimAreaShadowWidth = rimShadowAreaData.width;
            float rimAreaShadowFeather = rimShadowAreaData.feather;

            RimShadowData rimShadowData;
            rimShadowData.ct = _RimShadowCt;
            rimShadowData.intensity = _RimShadowIntensity;
            rimShadowData.offset = _RimShadowOffset.xyz;
            rimShadowData.color = rimAreaShadowColor.rgb;
            rimShadowData.width = rimAreaShadowWidth;
            rimShadowData.feather = rimAreaShadowFeather;

            rimShadowColor = GetRimShadow(rimShadowData, viewDirWS, normalWS);
        }
    #endif

    float3 emissionColor = 0;
    #if _EMISSION_ON
        {
            float4 mainTex = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
            _HairColorMap, _HairColorMapColor,
            _UpperBodyColorMap, _UpperBodyColorMapColor,
            _LowerBodyColorMap, _LowerBodyColorMapColor);

            EmissionData emissionData;
            emissionData.color = LinearColorMix(f3one, baseColor, _EmissionMixBaseColorFac);
            emissionData.tintColor = _EmissionTintColor.rgb;
            emissionData.prevPassColor = _EmissionPrevPassColor.rgb;
            emissionData.intensity = _EmissionIntensity;
            emissionData.threshold = _EmissionThreshold;

            emissionColor = CalculateBaseEmission(emissionData, mainTex);
        }
    #endif

    float fakeOutlineEffect = 0;
    float3 fakeOutlineColor = 0;
    #if _AREA_FACE && _OUTLINE_ON && _FAKE_OUTLINE_ON
        {
            float fakeOutline = faceMap.b;
            float3 headForward = normalize(_HeadForward);
            fakeOutlineEffect = smoothstep(0.0, 0.25, pow(saturate(dot(headForward, viewDirectionWS)), 20) * fakeOutline);

            float3 OutlineRamp = 0;
            #ifdef _CUSTOMOUTLINEVARENUM_CUSTOM
                OutlineRamp = _FakeOutlineColor.rgb;
            #else
                OutlineRamp = rampColor;
            #endif
            fakeOutlineColor = OutlineRamp;
        }
    #endif

    float3 albedo = 0;
    albedo += indirectLightColor;
    albedo += FinalDiffuse;
    albedo += specularColor;
    albedo *= stockingsEffect;
    albedo += rimLightColor;
    albedo += emissionColor;
    albedo *= rimShadowColor;
    albedo = lerp(albedo, fakeOutlineColor, fakeOutlineEffect);

    float alpha = _Alpha;

    #if _DRAW_OVERLAY_ON
        {
            float3 headForward = normalize(_HeadForward);
            alpha = lerp(1, alpha, saturate(dot(headForward, viewDirectionWS)));
        }
    #endif

    float4 FinalColor = float4(albedo, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

    return FinalColor;
}

void SRUniversalFragment(
CharCoreVaryings input,
bool isFrontFace            : SV_IsFrontFace,
out float4 colorTarget      : SV_Target0)
{
    float4 outputColor = colorFragmentTarget(input, isFrontFace);

    float4 lightMap = GetLightMapTex(input.uv, _HairLightMap, _UpperBodyLightMap, _LowerBodyLightMap);

    BloomAreaData bloomAreaData = GetBloomAreaData(lightMap.a, outputColor.rgb);
    float3 bloomColor = bloomAreaData.color;
    float bloomIntensity = bloomAreaData.intensity;

    colorTarget.rgb = MixBloomColor(outputColor.rgb, bloomColor, bloomIntensity);
    colorTarget.a = outputColor.a;
}

CharShadowVaryings CharacterShadowVertex(CharShadowAttributes input)
{
    return CharShadowVertex(input);
}

void CharacterShadowFragment(
CharShadowVaryings input,
bool isFrontFace            : SV_IsFrontFace)
{
    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
    _HairColorMap, _HairColorMapColor,
    _UpperBodyColorMap, _UpperBodyColorMapColor,
    _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);
}

CharDepthOnlyVaryings CharacterDepthOnlyVertex(CharDepthOnlyAttributes input)
{
    return CharDepthOnlyVertex(input);
}

float4 CharacterDepthOnlyFragment(
CharDepthOnlyVaryings input,
bool isFrontFace            : SV_IsFrontFace) : SV_Target
{
    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
    _HairColorMap, _HairColorMapColor,
    _UpperBodyColorMap, _UpperBodyColorMapColor,
    _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);

    return CharDepthOnlyFragment(input);
}

CharDepthNormalsVaryings CharacterDepthNormalsVertex(CharDepthNormalsAttributes input)
{
    return CharDepthNormalsVertex(input);
}

float4 CharacterDepthNormalsFragment(
CharDepthNormalsVaryings input,
bool isFrontFace            : SV_IsFrontFace) : SV_Target
{
    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
    _HairColorMap, _HairColorMapColor,
    _UpperBodyColorMap, _UpperBodyColorMapColor,
    _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);

    return CharDepthNormalsFragment(input);
}

CharMotionVectorsVaryings CharacterMotionVectorsVertex(CharMotionVectorsAttributes input)
{
    return CharMotionVectorsVertex(input);
}

half4 CharacterMotionVectorsFragment(
CharMotionVectorsVaryings input,
bool isFrontFace            : SV_IsFrontFace) : SV_Target
{
    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
    _HairColorMap, _HairColorMapColor,
    _UpperBodyColorMap, _UpperBodyColorMapColor,
    _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);

    return CharMotionVectorsFragment(input);
}
