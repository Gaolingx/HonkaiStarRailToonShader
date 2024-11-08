#ifndef _SR_UNIVERSAL_DRAW_CORE_PASS_INCLUDED
#define _SR_UNIVERSAL_DRAW_CORE_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "../ShaderLibrary/SRUniversalLibrary.hlsl"
#include "../ShaderLibrary/CharShadow.hlsl"
#include "../ShaderLibrary/CharDepthOnly.hlsl"
#include "../ShaderLibrary/CharDepthNormals.hlsl"
#include "../ShaderLibrary/CharMotionVectors.hlsl"
#include "../ShaderLibrary/CharShadowHelper.hlsl"


CharCoreVaryings SRUniversalCharVertex(CharCoreAttributes input)
{
    CharCoreVaryings output = (CharCoreVaryings)0;

    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.uv = CombineAndTransformDualFaceUV(input.uv1, input.uv2, _Maps_ST);
    // 世界空间
    output.positionWS = vertexPositionInputs.positionWS;
    // 世界空间法线、切线、副切线
    output.normalWS = vertexNormalInputs.normalWS;
    output.tangentWS = vertexNormalInputs.tangentWS;
    output.bitangentWS = vertexNormalInputs.bitangentWS;
    // 顶点色
    output.color = input.color;
    // 间接光 with 球谐函数
    output.SH = SampleSH(lerp(vertexNormalInputs.normalWS, float3(0,0,0), _IndirectLightFlattenNormal));
    output.positionCS = vertexPositionInputs.positionCS;

    output.fogFactor = ComputeFogFactor(vertexPositionInputs.positionCS.z);

    return output;
}

float4 colorFragmentTarget(inout CharCoreVaryings input, FRONT_FACE_TYPE isFrontFace)
{
    //片元世界空间位置
    float3 positionWS = input.positionWS;

    //阴影坐标
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    //获取主光源，传入shadowCoord是为了让mainLight获取阴影衰减，也就是实时阴影（shadowCoord为灯光空间坐标，xy采样shadowmap然后与z对比）
    Light mainLight = GetCharacterMainLightStruct(shadowCoord, positionWS);
    //获取主光源颜色
    //使用一个参数_MainLightColorUsage控制主光源颜色的使用程度
    float3 mainLightColor = GetMainLightDiffuse(mainLight, _MainLightBrightnessFactor, _AutoBrightnessThresholdMin, _AutoBrightnessThresholdMax, _BrightnessOffset, _MainLightColorUsage);
    //获取主光源方向
    float3 lightDirectionWS = normalize(mainLight.direction);

    // PerObjShadow
    #if _AREA_BODY
        mainLight = GetCharPerObjectShadow(mainLight, positionWS, _PerObjShadowCasterId);
    #endif

    //获取世界空间法线，如果要采样NormalMap，要使用TBN矩阵变换
    #if _NORMAL_MAP_ON
        float3x3 tangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
        float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv));
        float3 normalFactor = float3(_BumpFactor, _BumpFactor, 1);
        float3 normal = normalize(normalTS * normalFactor);
        float3 normalWS = TransformTangentToWorld(normal, tangentToWorld, true);
        input.normalWS = normalWS;
    #else
        float3 normalWS = normalize(input.normalWS);
    #endif

    //视线方向
    float3 viewDirectionWS = normalize(GetWorldSpaceViewDir(positionWS));

    float NoV = dot(normalize(normalWS), normalize(GetWorldSpaceViewDir(positionWS)));
    float NoL = dot(normalize(normalWS), normalize(mainLight.direction));

    // Head Vector
    HeadDirections headDirWS = WORLD_SPACE_CHAR_HEAD_DIRECTIONS();

    // BaseColor
    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy).rgb;
    baseColor = GetMainTexColor(input.uv.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;
    baseColor = ColorSaturationAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    //对有LightMap的部位，采样 LightMap
    // LightMap
    // lightMap.r: Specular Intensity
    // lightMap.b: Specular Threshold
    // lightMap.a: Material Index
    float4 lightMap = 0;
    lightMap = GetLightMapTex(input.uv.xy,
    TEXTURE2D_ARGS(_HairLightMap, sampler_HairLightMap),
    TEXTURE2D_ARGS(_BodyLightMap, sampler_BodyLightMap));

    //对脸部采样 faceMap，脸部的LightMap就是这张FaceMap
    float4 faceMap = 0;
    #if _AREA_FACE
        faceMap = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.uv.xy);
    #endif

    // Nose Line(Face Only)
    #if _AREA_FACE
        {
            float3 FdotV = pow(abs(dot(headDirWS.forward, viewDirectionWS)), _NoseLinePower);
            baseColor.rgb = lerp(baseColor.rgb, baseColor.rgb * _NoseLineColor.rgb, step(1.03 - faceMap.b, FdotV));
        }
    #endif

    // Expression(Face Only)
    #if _AREA_FACE
        {
            float4 exprMap = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, input.uv.xy);
            float3 exCheek = lerp(baseColor.rgb, baseColor.rgb * _ExCheekColor.rgb, exprMap.r);
            baseColor.rgb = lerp(baseColor.rgb, exCheek, _ExCheekIntensity);
            float3 exShy = lerp(baseColor.rgb, baseColor.rgb * _ExShyColor.rgb, exprMap.g);
            baseColor.rgb = lerp(baseColor.rgb, exShy, _ExShyIntensity);
            float3 exShadow = lerp(baseColor.rgb, baseColor.rgb * _ExShadowColor.rgb, exprMap.b);
            baseColor.rgb = lerp(baseColor.rgb, exShadow, _ExShadowIntensity);
            float3 exEyeShadow = lerp(baseColor.rgb * _ExEyeColor.rgb, baseColor.rgb, input.color.r);
            baseColor.rgb = lerp(baseColor.rgb, exEyeShadow, _ExEyeShadowIntensity);
        }
    #endif

    // GI
    //float3 indirectLightColor = input.SH.rgb * _IndirectLightUsage;
    float3 indirectLightColor = CalculateGI(baseColor, lightMap.g, input.SH.rgb, _IndirectLightIntensity, _IndirectLightUsage);

    // Front Hair Shadow(Face Only)
    #if defined(_MAIN_LIGHT_FRONT_HAIR_SHADOWS)
        mainLight.shadowAttenuation = min(mainLight.shadowAttenuation, GetFrontHairShadow(input.positionCS, lightDirectionWS, _HairShadowDistance));
    #endif

    // MainLight Shadow
    float mainLightShadow = 1;
    #if _AREA_HAIR || _AREA_BODY
        {
            BodyShadowData bodyShadowData;
            bodyShadowData.aoIntensity = _LerpAOIntensity;
            bodyShadowData.shadowSoftness = _ShadowThresholdSoftness;
            bodyShadowData.shadowCenterOffset = _ShadowThresholdCenter;
            bodyShadowData.mainLightShadowOffset = _MainLightShadowOffset;

            mainLightShadow = GetBodyMainLightShadow(bodyShadowData, mainLight, lightMap, input.color, NoL);
        }
    #elif _AREA_FACE
        {
            FaceShadowData faceShadowData;
            faceShadowData.faceShadowOffset = _FaceShadowOffset;
            faceShadowData.shadowTransitionSoftness = _FaceShadowTransitionSoftness;

            mainLightShadow = GetFaceMainLightShadow(faceShadowData, headDirWS, mainLight, TEXTURE2D_ARGS(_FaceMap, sampler_FaceMap), input.uv.xy, lightDirectionWS);
        }
    #endif

    // Ramp UV
    float diffuseFac = mainLightShadow;
    float2 rampUV = GetRampUV(diffuseFac, _ShadowRampOffset, lightMap, _SingleMaterial);

    // Ramp Color
    float3 coolRampCol = 1;
    float3 warmRampCol = 1;

    RampColor RC = RampColorConstruct(rampUV,
    TEXTURE2D_ARGS(_HairCoolRamp, sampler_HairCoolRamp),
    TEXTURE2D_ARGS(_HairWarmRamp, sampler_HairWarmRamp),
    TEXTURE2D_ARGS(_BodyCoolRamp, sampler_BodyCoolRamp),
    TEXTURE2D_ARGS(_BodyWarmRamp, sampler_BodyWarmRamp));
    coolRampCol = RC.coolRampCol;
    warmRampCol = RC.warmRampCol;

    RampColor RC1 = TintRampColor(coolRampCol, warmRampCol, lightMap.a);
    coolRampCol = RC1.coolRampCol;
    warmRampCol = RC1.warmRampCol;

    //根据白天夜晚，插值获得最终的rampColor，_DayTime也可以用变量由C#脚本传入Shader
    float DayTime = 0;

    [branch] if (_DayTime_MANUAL_ON)
    {
        DayTime = _DayTime;
    }
    else
    {
        DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    }

    float3 rampColor = LerpRampColor(coolRampCol, warmRampCol, DayTime, _ShadowBoost);

    float3 FinalDiffuse = mainLightColor * baseColor * rampColor;

    // Additional Lights
    float3 lightAdd = f3zero;
    #if _AdditionalLighting_ON
        GetAdditionalLightDiffuse(positionWS, input.positionCS, max(0, _AdditionalLightIntensity), lightAdd);
        FinalDiffuse = CombineColorPreserveLuminance(FinalDiffuse, lightAdd);
    #endif

    // Specular
    float3 specularColor = 0;
    #if _SPECULAR_ON
        #if _AREA_HAIR || _AREA_BODY
            {
                SpecularAreaData specularAreaData = GetSpecularAreaData(lightMap.a, _SpecularColor.rgb);
                float3 SpecularColor = specularAreaData.color;
                float SpecularIntensity = specularAreaData.intensity;
                float SpecularShininess = specularAreaData.shininess;
                float SpecularRoughness = specularAreaData.roughness;

                SpecularData specularData;
                specularData.color = SpecularColor;
                specularData.specularThreshold = lightMap.b;
                specularData.shininess = SpecularShininess;
                specularData.roughness = SpecularRoughness;
                specularData.intensity = SpecularIntensity;
                specularData.materialId = lightMap.a;

                specularColor = CalculateBaseSpecular(specularData, mainLight, viewDirectionWS, normalWS, diffuseFac);
            }
        #endif
    #else
        specularColor = 0;
    #endif

    //Stockings
    #if _STOCKINGS_ON
        #if _AREA_BODY
            {
                StockingsData stockingsData;
                stockingsData.StockRangeTex_ST = _StockRangeTex_ST;
                stockingsData.Stockcolor = _Stockcolor;
                stockingsData.StockDarkcolor = _StockDarkcolor;
                stockingsData.StockDarkWidth = _StockDarkWidth;
                stockingsData.Stockpower = _Stockpower;
                stockingsData.Stockpower1 = _Stockpower1;
                stockingsData.StockSP = _StockSP;
                stockingsData.StockRoughness = _StockRoughness;

                FinalDiffuse = CalculateStockingsEffect(stockingsData, FinalDiffuse, NoV, input.uv.xy, TEXTURE2D_ARGS(_StockRangeTex, sampler_StockRangeTex));
            }
        #endif
    #endif

    // Rim Light
    float3 rimLightColor = 0;
    #if _RIM_LIGHTING_ON
        {
            RimLightAreaData rimLightAreaData = GetRimLightAreaData(lightMap.a, _RimColor.rgb);
            float3 rimLightAreaColor = rimLightAreaData.color;
            float rimLightAreaWidth = rimLightAreaData.width;
            float rimLightAreaDark = rimLightAreaData.rimDark;
            float rimLightAreaEdgeSoftnesses = rimLightAreaData.edgeSoftness;

            RimLightMaskData rimLightMaskData;
            rimLightMaskData.color = rimLightAreaColor;
            rimLightMaskData.width = rimLightAreaWidth;
            rimLightMaskData.edgeSoftness = rimLightAreaEdgeSoftnesses;
            rimLightMaskData.modelScale = _ModelScale;
            rimLightMaskData.ditherAlpha = _DitherAlpha;

            RimLightData rimLightData;
            rimLightData.darkenValue = rimLightAreaDark;
            rimLightData.intensityFrontFace = _RimIntensity;
            rimLightData.intensityBackFace = _RimIntensityBackFace;

            float3 rimLightMask = GetRimLightMask(rimLightMaskData, normalWS, viewDirectionWS, NoV, input.positionCS, lightMap);
            rimLightColor = GetRimLight(rimLightData, rimLightMask, NoL, mainLight, isFrontFace);
        }
    #endif

    // Rim Shadow
    float3 rimShadowColor = 1;
    #if _RIM_SHADOW_ON
        {
            RimShadowAreaData rimShadowAreaData = GetRimShadowAreaData(lightMap.a, _RimShadowColor.rgb);
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

            rimShadowColor = GetRimShadow(rimShadowData, viewDirectionWS, normalWS);
        }
    #endif

    // Emission
    float3 emissionColor = 0;
    #if _EMISSION_ON
        {
            float4 mainTex = GetMainTexColor(input.uv.xy,
            TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
            TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
            TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor);

            EmissionData emissionData;
            emissionData.color = LinearColorMix(f3one, mainTex.rgb, _EmissionMixBaseColorFac);
            emissionData.tintColor = _EmissionTintColor.rgb;
            emissionData.intensity = _EmissionIntensity;
            emissionData.threshold = _EmissionThreshold;

            emissionColor = CalculateBaseEmission(emissionData, mainTex);
        }
    #endif


    // TotalColor
    float3 albedo = 0;
    albedo += indirectLightColor;
    albedo += FinalDiffuse;
    albedo += specularColor;
    albedo += rimLightColor;
    albedo += emissionColor;
    albedo *= rimShadowColor;

    float alpha = _Alpha;

    float4 FinalColor = float4(albedo, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);

    // Mix Fog
    real fogFactor = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
    FinalColor.rgb = MixFog(FinalColor.rgb, fogFactor);

    return FinalColor;
}

void SRUniversalCharCoreFragment(
CharCoreVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC,
out float4 colorTarget      : SV_Target0)
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float4 outputColor = colorFragmentTarget(input, isFrontFace);

    float4 lightMap = GetLightMapTex(input.uv.xy,
    TEXTURE2D_ARGS(_HairLightMap, sampler_HairLightMap),
    TEXTURE2D_ARGS(_BodyLightMap, sampler_BodyLightMap));

    BloomAreaData bloomAreaData = GetBloomAreaData(lightMap.a, outputColor.rgb);
    float3 bloomColor = bloomAreaData.color;
    float bloomIntensity = bloomAreaData.intensity;

    colorTarget.rgb = MixBloomColor(outputColor.rgb, bloomColor, bloomIntensity);
    colorTarget.a = outputColor.a;
}

void FaceWriteEyeStencilFragment(
CharCoreVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC)
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy).rgb;
    baseColor = GetMainTexColor(input.uv.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;
    baseColor = ColorSaturationAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);

    // （尽量）避免后一个角色的眼睛透过前一个角色的头发
    float sceneDepth = GetLinearEyeDepthAnyProjection(LoadSceneDepth(input.positionCS.xy - 0.5));
    float eyeDepth = GetLinearEyeDepthAnyProjection(input.positionCS);
    float depthMask = step(abs(sceneDepth - eyeDepth), _MaxEyeHairDistance * _ModelScale);

    // 眼睛、眼眶、眉毛的遮罩（不包括高光）
    #if defined(_CUSTOMHEADBONEMODEVARENUM_GAME)
        // 游戏模型使用 uv2 采样！！！景元和刃只有一边的眼睛需要写 Stencil，用 uv1 会把两只眼睛的都写进去
        float eyeMask = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.uv.zw).g;
    #else
        // MMD 模型没办法，不管上面两个角色了
        float eyeMask = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.uv.xy).g;
    #endif

    clip(eyeMask * depthMask - 0.5);
}

void HairFakeTransparentFragment(
CharCoreVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC,
out float4 colorTarget      : SV_Target0)
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    // 手动做一次深度测试，保证只有最上面一层头发和眼睛做 alpha 混合。这样看上去更加通透
    float sceneDepth = GetLinearEyeDepthAnyProjection(LoadSceneDepth(input.positionCS.xy - 0.5));
    float hairDepth = GetLinearEyeDepthAnyProjection(input.positionCS);
    // 部分安卓设备存在精度问题，加一个 EPSILON，避免 fighting
    // EPSILON 取稍大的 HALF_EPS 而不是 FLT_EPS，解决 MSAA 导致的 fighting（画面上表现为黑点）
    clip(sceneDepth - hairDepth + HALF_EPS); // if (hairDepth > sceneDepth) discard;

    float4 outputColor = colorFragmentTarget(input, isFrontFace);
    float alpha = GetTransparentFronHairAlphaValue(input.positionWS, _HairBlendAlpha);

    float4 lightMap = GetLightMapTex(input.uv.xy,
    TEXTURE2D_ARGS(_HairLightMap, sampler_HairLightMap),
    TEXTURE2D_ARGS(_BodyLightMap, sampler_BodyLightMap));

    BloomAreaData bloomAreaData = GetBloomAreaData(lightMap.a, outputColor.rgb);
    float3 bloomColor = bloomAreaData.color;
    float bloomIntensity = bloomAreaData.intensity;

    colorTarget.rgb = MixBloomColor(outputColor.rgb, bloomColor, bloomIntensity);
    colorTarget.a = alpha;
}

FragmentOutput SRUniversalCharGBufferFragment(
CharCoreVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC)
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float3 color = f3zero;
    float alpha = _Alpha;

    DoClipTestToTargetAlphaValue(alpha, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);

    InputData inputData;
    InitializeInputData(input, inputData);

    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = color;
    surfaceData.alpha = alpha;

    surfaceData.occlusion = 1;

    return SurfaceDataToGbuffer(surfaceData, inputData, float3(0,0,0), kLightingInvalid);
}

CharShadowVaryings CharacterShadowVertex(CharShadowAttributes input)
{
    return CharShadowVertex(input, _Maps_ST, _SelfShadowDepthBias, _SelfShadowNormalBias);
}

void CharacterShadowFragment(
CharShadowVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC)
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy).rgb;
    baseColor = GetMainTexColor(input.uv.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;
    baseColor = ColorSaturationAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);
}

CharDepthOnlyVaryings CharacterDepthOnlyVertex(CharDepthOnlyAttributes input)
{
    return CharDepthOnlyVertex(input, _Maps_ST);
}

float4 CharacterDepthOnlyFragment(
CharDepthOnlyVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC) : SV_Target
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy).rgb;
    baseColor = GetMainTexColor(input.uv.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;
    baseColor = ColorSaturationAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);

    return CharDepthOnlyFragment(input);
}

CharDepthNormalsVaryings CharacterDepthNormalsVertex(CharDepthNormalsAttributes input)
{
    return CharDepthNormalsVertex(input, _Maps_ST);
}

float4 CharacterDepthNormalsFragment(
CharDepthNormalsVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC) : SV_Target
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy).rgb;
    baseColor = GetMainTexColor(input.uv.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;
    baseColor = ColorSaturationAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);

    return CharDepthNormalsFragment(input);
}

CharMotionVectorsVaryings CharacterMotionVectorsVertex(CharMotionVectorsAttributes input)
{
    return CharMotionVectorsVertex(input, _Maps_ST);
}

half4 CharacterMotionVectorsFragment(
CharMotionVectorsVaryings input,
FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC) : SV_Target
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy).rgb;
    baseColor = GetMainTexColor(input.uv.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;
    baseColor = ColorSaturationAdjustment(baseColor, _ColorSaturation);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionHCS, _DitherAlpha);

    return CharMotionVectorsFragment(input);
}

#endif
