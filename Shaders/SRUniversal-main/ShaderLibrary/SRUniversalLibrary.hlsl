#ifndef _SR_UNIVERSAL_LIBRARY_INCLUDED
#define _SR_UNIVERSAL_LIBRARY_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "../ShaderLibrary/SRUniversalUtils.hlsl"


// InputData ------------------------------------------------------------------------------------------------------ // 
// ---------------------------------------------------------------------------------------------------------------- //
struct CharCoreAttributes
{
    float3 positionOS   : POSITION;
    half3 normalOS      : NORMAL;
    half4 tangentOS     : TANGENT;
    float2 uv1          : TEXCOORD0;
    float2 uv2          : TEXCOORD1;
    float4 color        : COLOR;
};

struct CharCoreVaryings
{
    float4 uv                       : TEXCOORD0;
    float4 positionWSAndFogFactor   : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    float3 bitangentWS              : TEXCOORD3;
    float3 tangentWS                : TEXCOORD4;
    float3 SH                       : TEXCOORD5;
    float4 color                    : COLOR;
    float4 positionCS               : SV_POSITION;
};

void InitializeInputData(CharCoreVaryings input, out InputData inputData)
{
    inputData = (InputData)0;

    inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);

    inputData.positionWS = float3(0, 0, 0);
    inputData.viewDirectionWS = half3(0, 0, 1);
    inputData.shadowCoord = 0;
    inputData.fogCoord = 0;
    inputData.vertexLighting = half3(0, 0, 0);
    inputData.bakedGI = half3(0, 0, 0);
    inputData.normalizedScreenSpaceUV = 0;
    inputData.shadowMask = half4(1, 1, 1, 1);
}


// MainTex -------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
float4 GetMainTexColor(float2 uv,
TEXTURE2D_PARAM(FaceColorMap, sampler_FaceColorMap), float4 FaceColorMapColor,
TEXTURE2D_PARAM(HairColorMap, sampler_HairColorMap), float4 HairColorMapColor,
TEXTURE2D_PARAM(BodyColorMap, sampler_BodyColorMap), float4 BodyColorMapColor)
{
    float4 areaMap = 0;
    float4 areaColor = 0;
    //根据不同的Keyword，采样不同的贴图，作为额漫反射颜色
    #if _AREA_FACE
        areaMap = SAMPLE_TEXTURE2D(FaceColorMap, sampler_FaceColorMap, uv);
        areaColor = areaMap * FaceColorMapColor;
    #elif _AREA_HAIR
        areaMap = SAMPLE_TEXTURE2D(HairColorMap, sampler_HairColorMap, uv);
        areaColor = areaMap * HairColorMapColor;
    #elif _AREA_BODY
        areaMap = SAMPLE_TEXTURE2D(BodyColorMap, sampler_BodyColorMap, uv);
        areaColor = areaMap * BodyColorMapColor;
    #endif
    return areaColor;
}


// LightMap ------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
float4 GetLightMapTex(float2 uv,
TEXTURE2D_PARAM(HairLightMap, sampler_HairLightMap),
TEXTURE2D_PARAM(BodyLightMap, sampler_BodyLightMap))
{
    float4 lightMap = 0;
    #if _AREA_HAIR
        lightMap = SAMPLE_TEXTURE2D(HairLightMap, sampler_HairLightMap, uv);
    #elif _AREA_BODY
        lightMap = SAMPLE_TEXTURE2D(BodyLightMap, sampler_BodyLightMap, uv);
    #endif
    return lightMap;
}


// RampMap -------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct RampColor
{
    float3 coolRampCol;
    float3 warmRampCol;
};

RampColor RampColorConstruct(float2 rampUV,
TEXTURE2D_PARAM(HairCoolRamp, sampler_HairCoolRamp),
TEXTURE2D_PARAM(HairWarmRamp, sampler_HairWarmRamp),
TEXTURE2D_PARAM(BodyCoolRamp, sampler_BodyCoolRamp),
TEXTURE2D_PARAM(BodyWarmRamp, sampler_BodyWarmRamp))
{
    RampColor rampColor;
    float3 coolRampTexCol = 1;
    float3 warmRampTexCol = 1;

    //hair的Ramp贴图和身体或脸部的不一样，按照keyword采样
    #if _AREA_HAIR
        coolRampTexCol = SAMPLE_TEXTURE2D(HairCoolRamp, sampler_HairCoolRamp, rampUV).rgb;
        warmRampTexCol = SAMPLE_TEXTURE2D(HairWarmRamp, sampler_HairWarmRamp, rampUV).rgb;
    #elif _AREA_FACE || _AREA_BODY
        coolRampTexCol = SAMPLE_TEXTURE2D(BodyCoolRamp, sampler_BodyCoolRamp, rampUV).rgb;
        warmRampTexCol = SAMPLE_TEXTURE2D(BodyWarmRamp, sampler_BodyWarmRamp, rampUV).rgb;
    #endif
    rampColor.coolRampCol = coolRampTexCol;
    rampColor.warmRampCol = warmRampTexCol;
    return rampColor;
}


// RampColorTint -------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
RampColor TintRampColor(float3 coolRamp, float3 warmRamp, float materialId)
{
    RampColor rampColor;

    float warm_shadow_Factor_array[8] =
    {
        _WarmShadowMultColorFac0,
        _WarmShadowMultColorFac1,
        _WarmShadowMultColorFac2,
        _WarmShadowMultColorFac3,
        _WarmShadowMultColorFac4,
        _WarmShadowMultColorFac5,
        _WarmShadowMultColorFac6,
        _WarmShadowMultColorFac7,
    };
    float cool_shadow_Factor_array[8] =
    {
        _CoolShadowMultColorFac0,
        _CoolShadowMultColorFac1,
        _CoolShadowMultColorFac2,
        _CoolShadowMultColorFac3,
        _CoolShadowMultColorFac4,
        _CoolShadowMultColorFac5,
        _CoolShadowMultColorFac6,
        _CoolShadowMultColorFac7,
    };

    float4 warm_shadow_array[8] =
    {
        _WarmShadowMultColor0,
        _WarmShadowMultColor1,
        _WarmShadowMultColor2,
        _WarmShadowMultColor3,
        _WarmShadowMultColor4,
        _WarmShadowMultColor5,
        _WarmShadowMultColor6,
        _WarmShadowMultColor7,
    };
    float4 cool_shadow_array[8] =
    {
        _CoolShadowMultColor0,
        _CoolShadowMultColor1,
        _CoolShadowMultColor2,
        _CoolShadowMultColor3,
        _CoolShadowMultColor4,
        _CoolShadowMultColor5,
        _CoolShadowMultColor6,
        _CoolShadowMultColor7,
    };

    float warm_shadow_fac = warm_shadow_Factor_array[GetRampLineIndex(materialId)];
    float cool_shadow_fac = cool_shadow_Factor_array[GetRampLineIndex(materialId)];
    float3 warm_shadow_col = warm_shadow_array[GetRampLineIndex(materialId)].rgb;
    float3 cool_shadow_col = cool_shadow_array[GetRampLineIndex(materialId)].rgb;

    float3 cool_shadow = LinearColorMix(coolRamp, cool_shadow_col, cool_shadow_fac);
    float3 warm_shadow = LinearColorMix(warmRamp, warm_shadow_col, warm_shadow_fac);

    rampColor.coolRampCol = cool_shadow;
    rampColor.warmRampCol = warm_shadow;
    return rampColor;
}


// LutMap --------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct LutMapData
{
    float4 lut_speccol;
    float4 lut_specval;
    float4 lut_edgecol;
    float4 lut_rimcol;
    float4 lut_rimval;
    float4 lut_rimscol;
    float4 lut_rimsval;
    float4 lut_bloomval;
};

LutMapData GetMaterialValuesPackLUT(float material_ID)
{
    LutMapData data;
    // sample the various mluts
    float4 lut_speccol = _MaterialValuesPackLUT.Load(float3(material_ID, 0, 0)); // xyz : color
    float4 lut_specval = _MaterialValuesPackLUT.Load(float3(material_ID, 1, 0)); // x: shininess, y : roughness, z : intensity
    float4 lut_edgecol = _MaterialValuesPackLUT.Load(float3(material_ID, 2, 0)); // xyz : color
    float4 lut_rimcol  = _MaterialValuesPackLUT.Load(float3(material_ID, 3, 0)); // xyz : color
    float4 lut_rimval  = _MaterialValuesPackLUT.Load(float3(material_ID, 4, 0)); // x : rim type, y : softness , z : dark
    float4 lut_rimscol = _MaterialValuesPackLUT.Load(float3(material_ID, 5, 0)); // xyz : color
    float4 lut_rimsval = _MaterialValuesPackLUT.Load(float3(material_ID, 6, 0)); // x: rim shadow width, y: rim shadow feather z: bloom intensity
    float4 lut_bloomval = _MaterialValuesPackLUT.Load(float3(material_ID, 7, 0)); // xyz : color

    data.lut_speccol = lut_speccol;
    data.lut_specval = lut_specval;
    data.lut_edgecol = lut_edgecol;
    data.lut_rimcol = lut_rimcol;
    data.lut_rimval = lut_rimval;
    data.lut_rimscol = lut_rimscol;
    data.lut_rimsval = lut_rimsval;
    data.lut_bloomval = lut_bloomval;

    return data;
}

// LutMap Specular
half3 GetLUTMapSpecularColor(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_speccol.xyz;
}
half GetLUTMapSpecularShininess(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_specval.x;
}
half GetLUTMapSpecularRoughness(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_specval.y;
}
half GetLUTMapSpecularIntensity(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_specval.z;
}

// LutMap Outline
half3 GetLUTMapOutlineColor(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_edgecol.xyz;
}

// LutMap RimLight
half3 GetLUTMapRimLightColor(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimcol.xyz;
}
half GetLUTMapRimLightWidth(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimval.x;
}
half GetLUTMapRimLightEdgeSoftness(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimval.y;
}
half GetLUTMapRimLightDark(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimval.z;
}

// LutMap RimShadow
half3 GetLUTMapRimShadowColor(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimscol.xyz;
}
half GetLUTMapRimShadowWidth(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimsval.x;
}
half GetLUTMapRimShadowFeather(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimsval.y;
}

// LutMap Bloom
half GetLUTMapBloomIntensity(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_rimsval.z;
}
half3 GetLUTMapBloomColor(int materialId)
{
    LutMapData data = GetMaterialValuesPackLUT(materialId);
    return data.lut_bloomval.xyz;
}


// Shadow --------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct BodyShadowData
{
    float aoIntensity;
    float shadowSoftness;
    float shadowCenterOffset;
    float mainLightShadowOffset;
};

float GetBodyMainLightShadow(BodyShadowData shadowData, Light light, float4 lightMap, float4 vertexColor, float NoL)
{
    float mainLightShadow = 1;
    float remappedNoL = NoL * 0.5 + 0.5;
    //lightmap的G通道直接光阴影的形状，值越小，越容易进入阴影，有些刺的效果就是这里出来的
    float shadowThreshold = lightMap.g;
    //应用顶点色AO
    shadowThreshold *= lerp(1, vertexColor.r, shadowData.aoIntensity);
    //加个过渡，这里 shadowSoftness=0.1
    mainLightShadow = smoothstep(
    1.0 - shadowThreshold - shadowData.shadowSoftness,
    1.0 - shadowThreshold + shadowData.shadowSoftness,
    remappedNoL + shadowData.shadowCenterOffset) + shadowData.mainLightShadowOffset;

    mainLightShadow = lerp(0.20, mainLightShadow, saturate(light.shadowAttenuation + HALF_EPS));
    mainLightShadow = lerp(0, mainLightShadow, step(0.05, shadowThreshold));
    mainLightShadow = lerp(1, mainLightShadow, step(shadowThreshold, 0.95));

    return mainLightShadow;
}

struct FaceShadowData
{
    float faceShadowOffset;
    float shadowTransitionSoftness;
};

float GetFaceMainLightShadow(FaceShadowData shadowData, HeadDirections headDirWS, Light light, TEXTURE2D_PARAM(FaceMap, sampler_FaceMap), float2 uv, float3 lightDirWS)
{
    float mainLightShadow = 1;
    float3 lightDirProj = normalize(lightDirWS - dot(lightDirWS, headDirWS.up) * headDirWS.up); // 做一次投影
    //光照在左脸的时候。左脸的uv采样左脸，右脸的uv采样右脸，而光照在右脸的时候，左脸的uv采样右脸，右脸的uv采样左脸，因为SDF贴图明暗变化在右脸
    bool isRight = dot(lightDirProj, headDirWS.right) > 0;
    //相当于float sdfUVx=isRight?1-input.uv.x:input.uv.x;
    //即打在右脸的时候，反转uv的u坐标
    float sdfUVx = lerp(uv.x, 1 - uv.x, isRight);
    float2 sdfUV = float2(sdfUVx, uv.y);
    //使用uv采样面部贴图的a通道
    float sdfValue = SAMPLE_TEXTURE2D(FaceMap, sampler_FaceMap, sdfUV).a;
    sdfValue += shadowData.faceShadowOffset;
    //dot(lightDir,headForward)的范围是[1,-1]映射到[0,1]
    float FoL01 = (dot(headDirWS.forward, lightDirProj) * 0.5 + 0.5);
    //采样结果大于点乘结果，不在阴影，小于则处于阴影
    float sdfShadow = smoothstep(FoL01 - shadowData.shadowTransitionSoftness, FoL01 + shadowData.shadowTransitionSoftness, 1 - sdfValue);

    float4 faceMap = SAMPLE_TEXTURE2D(FaceMap, sampler_FaceMap, uv);
    //AO中常暗的区域，step提取大于0.5的部分，使用g通道的阴影形状（常亮/常暗），其他部分使用sdf贴图
    float faceShadow = (1 - sdfShadow) * light.shadowAttenuation;

    //Eye shadow
    float eyeShadow = smoothstep(0.3, 0.5, FoL01) * light.shadowAttenuation;

    mainLightShadow = lerp(faceShadow, eyeShadow, faceMap.r);
    return mainLightShadow;
}


// RimLight ------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct RimLightAreaData
{
    float3 color;
    float width;
    float rimDark;
    float edgeSoftness;
};

RimLightAreaData GetRimLightAreaData(half materialId, half3 rimLightColor)
{
    RimLightAreaData rimLightAreaData;

    half3 color = rimLightColor;
    
    const float4 overlayColors[8] = {
        _RimColor0,
        _RimColor1,
        _RimColor2,
        _RimColor3,
        _RimColor4,
        _RimColor5,
        _RimColor6,
        _RimColor7,
    };
    
    half3 overlayColor = 0;
    #if _USE_LUT_MAP
        overlayColor = GetLUTMapRimLightColor(GetRampLineIndex(materialId)).rgb;
    #else
        overlayColor = overlayColors[GetRampLineIndex(materialId)].rgb;
    #endif

    const float overlayWidths[8] = {
        _RimWidth0,
        _RimWidth1,
        _RimWidth2,
        _RimWidth3,
        _RimWidth4,
        _RimWidth5,
        _RimWidth6,
        _RimWidth7,
    };
    
    float overlayWidth = 0;
    #if _USE_LUT_MAP
        overlayWidth = GetLUTMapRimLightWidth(GetRampLineIndex(materialId));
    #else
        overlayWidth = overlayWidths[GetRampLineIndex(materialId)];
    #endif
    
    const float rimDarks[8] = {
        _RimDark0,
        _RimDark1,
        _RimDark2,
        _RimDark3,
        _RimDark4,
        _RimDark5,
        _RimDark6,
        _RimDark7,
    };
    
    float overlayDark = 0;
    #if _USE_LUT_MAP
        overlayDark = GetLUTMapRimLightDark(GetRampLineIndex(materialId));
    #else
        overlayDark = rimDarks[GetRampLineIndex(materialId)];
    #endif

    const float rimEdgeSoftnesses[8] = {
        _RimEdgeSoftness0,
        _RimEdgeSoftness1,
        _RimEdgeSoftness2,
        _RimEdgeSoftness3,
        _RimEdgeSoftness4,
        _RimEdgeSoftness5,
        _RimEdgeSoftness6,
        _RimEdgeSoftness7,
    };
    
    float overlayEdgeSoftness = 0;
    #if _USE_LUT_MAP
        overlayEdgeSoftness = GetLUTMapRimLightEdgeSoftness(GetRampLineIndex(materialId));
    #else
        overlayEdgeSoftness = rimEdgeSoftnesses[GetRampLineIndex(materialId)];
    #endif

    float3 finalRimColor = 0;
    #ifdef _CUSTOMRIMLIGHTCOLORVARENUM_DISABLE
        finalRimColor = color.rgb;
    #elif _CUSTOMRIMLIGHTCOLORVARENUM_TINT
        finalRimColor = color.rgb * overlayColor;
    #elif _CUSTOMRIMLIGHTCOLORVARENUM_OVERLAY
        finalRimColor = overlayColor;
    #else
        finalRimColor = color.rgb;
    #endif
    
    float finalRimWidth = 0;
    #ifdef _CUSTOMRIMLIGHTVARENUM_DISABLE
        finalRimWidth = _RimWidth;
    #elif _CUSTOMRIMLIGHTVARENUM_MULTIPLY
        finalRimWidth = _RimWidth * overlayWidth;
    #elif _CUSTOMRIMLIGHTVARENUM_OVERLAY
        finalRimWidth = overlayWidth;
    #else
        finalRimWidth = _RimWidth;
    #endif

    float finalRimDark = 0;
    #ifdef _CUSTOMRIMLIGHTVARENUM_DISABLE
        finalRimDark = _RimDark;
    #elif _CUSTOMRIMLIGHTVARENUM_MULTIPLY
        finalRimDark = _RimDark * overlayDark;
    #elif _CUSTOMRIMLIGHTVARENUM_OVERLAY
        finalRimDark = overlayDark;
    #else
        finalRimDark = _RimDark;
    #endif

    float finalRimEdgeSoftness = 0;
    #ifdef _CUSTOMRIMLIGHTVARENUM_DISABLE
        finalRimEdgeSoftness = _RimEdgeSoftness;
    #elif _CUSTOMRIMLIGHTVARENUM_MULTIPLY
        finalRimEdgeSoftness = _RimEdgeSoftness * overlayEdgeSoftness;
    #elif _CUSTOMRIMLIGHTVARENUM_OVERLAY
        finalRimEdgeSoftness = overlayEdgeSoftness;
    #else
        finalRimEdgeSoftness = _RimEdgeSoftness;
    #endif

    rimLightAreaData.color = finalRimColor.rgb;
    rimLightAreaData.width = finalRimWidth;
    rimLightAreaData.rimDark = finalRimDark;
    rimLightAreaData.edgeSoftness = finalRimEdgeSoftness;

    return rimLightAreaData;
}

struct RimLightMaskData
{
    float3 color;
    float width;
    float edgeSoftness;
    float modelScale;
    float ditherAlpha;
};

float3 GetRimLightMask(
    RimLightMaskData rlmData,
    float3 normalWS,
    float3 viewDirWS,
    float NoV,
    float4 svPosition,
    float4 lightMap)
{
    float invModelScale = rcp(rlmData.modelScale);
    float rimWidth = rlmData.width / 2000.0; // rimWidth 表示的是屏幕上像素的偏移量，和 modelScale 无关

    rimWidth *= lightMap.r; // 有些地方不要边缘光
    rimWidth *= _ScaledScreenParams.y; // 在不同分辨率下看起来等宽

    if (IsPerspectiveProjection())
    {
        // unity_CameraProjection._m11: cot(FOV / 2)
        // 2.414 是 FOV 为 45 度时的值
        rimWidth *= unity_CameraProjection._m11 / 2.414; // FOV 越小，角色越大，边缘光越宽
    }
    else
    {
        // unity_CameraProjection._m11: (1 / Size)
        // 1.5996 纯 Magic Number
        rimWidth *= unity_CameraProjection._m11 / 1.5996; // Size 越小，角色越大，边缘光越宽
    }

    float depth = GetLinearEyeDepthAnyProjection(svPosition);
    rimWidth *= 10.0 * rsqrt(depth * invModelScale); // 近大远小

    float indexOffsetX = -sign(cross(viewDirWS, normalWS).y) * rimWidth;
    uint2 index = clamp(svPosition.xy - 0.5 + float2(indexOffsetX, 0), 0, _ScaledScreenParams.xy - 1); // 避免出界
    float offsetDepth = GetLinearEyeDepthAnyProjection(LoadSceneDepth(index));

    // 只有 depth 小于 offsetDepth 的时候再画
    float intensity = smoothstep(0.12, 0.18, (offsetDepth - depth) * invModelScale);

    // 用于柔化边缘光，edgeSoftness 越大，越柔和
    float fresnel = pow(max(1 - NoV, 0.01), max(rlmData.edgeSoftness, 0.01));

    // Dither Alpha 效果会扣掉角色的一部分像素，导致角色身上出现不该有的边缘光
    // 所以这里在 ditherAlpha 较强时隐去边缘光
    float ditherAlphaFadeOut = smoothstep(0.9, 1, rlmData.ditherAlpha);

    return rlmData.color * saturate(intensity * fresnel * ditherAlphaFadeOut);
}

struct RimLightData
{
    float darkenValue;
    float intensityFrontFace;
    float intensityBackFace;
};

float3 GetRimLight(RimLightData rimData, float3 rimMask, float NoL, Light light, FRONT_FACE_TYPE isFrontFace)
{
    float attenuation = saturate(NoL * light.shadowAttenuation * light.distanceAttenuation);
    float intensity = IS_FRONT_VFACE(isFrontFace, rimData.intensityFrontFace, rimData.intensityBackFace);
    return rimMask * (lerp(rimData.darkenValue, 1, attenuation) * max(0, intensity));
}


// RimShadow ------------------------------------------------------------------------------------------------------ // 
// ---------------------------------------------------------------------------------------------------------------- //
struct RimShadowAreaData
{
    float3 color;
    float width;
    float feather;
};

RimShadowAreaData GetRimShadowAreaData(half materialId, half3 rimShadowColor)
{
    RimShadowAreaData rimShadowAreaData;

    half3 color = rimShadowColor;
    
    const float4 overlayColors[8] = {
        _RimShadowColor0,
        _RimShadowColor1,
        _RimShadowColor2,
        _RimShadowColor3,
        _RimShadowColor4,
        _RimShadowColor5,
        _RimShadowColor6,
        _RimShadowColor7,
    };
    
    half3 overlayColor = 0;
    #if _USE_LUT_MAP
        overlayColor = GetLUTMapRimShadowColor(GetRampLineIndex(materialId)).rgb;
    #else
        overlayColor = overlayColors[GetRampLineIndex(materialId)].rgb;
    #endif

    const float overlayWidths[8] = {
        _RimShadowWidth0,
        _RimShadowWidth1,
        _RimShadowWidth2,
        _RimShadowWidth3,
        _RimShadowWidth4,
        _RimShadowWidth5,
        _RimShadowWidth6,
        _RimShadowWidth7,
    };
    
    float overlayWidth = 0;
    #if _USE_LUT_MAP
        overlayWidth = GetLUTMapRimShadowWidth(GetRampLineIndex(materialId));
    #else
        overlayWidth = overlayWidths[GetRampLineIndex(materialId)];
    #endif

    const float rimShadowFeather[8] = {
        _RimShadowFeather0,
        _RimShadowFeather1,
        _RimShadowFeather2,
        _RimShadowFeather3,
        _RimShadowFeather4,
        _RimShadowFeather5,
        _RimShadowFeather6,
        _RimShadowFeather7,
    };
    
    float overlayFeather = 0;
    #if _USE_LUT_MAP
        overlayFeather = GetLUTMapRimShadowFeather(GetRampLineIndex(materialId));
    #else
        overlayFeather = rimShadowFeather[GetRampLineIndex(materialId)];
    #endif

    float3 finalRimShadowColor = 0;
    #ifdef _CUSTOMRIMSHADOWCOLORVARENUM_DISABLE
        finalRimShadowColor = color.rgb;
    #elif _CUSTOMRIMSHADOWCOLORVARENUM_TINT
        finalRimShadowColor = color.rgb * overlayColor;
    #elif _CUSTOMRIMSHADOWCOLORVARENUM_OVERLAY
        finalRimShadowColor = overlayColor;
    #else
        finalRimShadowColor = color.rgb;
    #endif
    
    float finalRimShadowWidth = 0;
    #ifdef _CUSTOMRIMSHADOWVARENUM_DISABLE
        finalRimShadowWidth = _RimShadowWidth;
    #elif _CUSTOMRIMSHADOWVARENUM_MULTIPLY
        finalRimShadowWidth = _RimShadowWidth * overlayWidth;
    #elif _CUSTOMRIMSHADOWVARENUM_OVERLAY
        finalRimShadowWidth = overlayWidth;
    #else
        finalRimShadowWidth = _RimShadowWidth;
    #endif

    float finalRimShadowFeather = 0;
    #ifdef _CUSTOMRIMSHADOWVARENUM_DISABLE
        finalRimShadowFeather = _RimShadowFeather;
    #elif _CUSTOMRIMSHADOWVARENUM_MULTIPLY
        finalRimShadowFeather = _RimShadowFeather * overlayFeather;
    #elif _CUSTOMRIMSHADOWVARENUM_OVERLAY
        finalRimShadowFeather = overlayFeather;
    #else
        finalRimShadowFeather = _RimShadowFeather;
    #endif

    rimShadowAreaData.color = finalRimShadowColor.rgb;
    rimShadowAreaData.width = finalRimShadowWidth;
    rimShadowAreaData.feather = finalRimShadowFeather;

    return rimShadowAreaData;
}

struct RimShadowData
{
    float ct;
    float intensity;
    float3 offset;
    float3 color;
    float width;
    float feather;
};

float3 GetRimShadow(RimShadowData data, float3 viewDirWS, float3 normalWS)
{
    float3 viewDirVS = TransformWorldToViewDir(viewDirWS);
    float3 normalVS = TransformWorldToViewNormal(normalWS);
    float rim = saturate(dot(normalize(viewDirVS - data.offset), normalVS));
    float rimShadow = saturate(pow(max(1 - rim, 0.001), data.ct) * data.width);
    rimShadow = smoothstep(data.feather, 1, rimShadow) * data.intensity * 0.25;
    return lerp(1, data.color * 2, max(rimShadow, 0));
}


// Specular ------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct SpecularAreaData
{
    float3 color;
    float intensity;
    float shininess;
    float roughness;
};

SpecularAreaData GetSpecularAreaData(half materialId, half3 specularColor)
{
    SpecularAreaData specularAreaData;

    half3 color = specularColor;
    
    const float4 overlayColorArr[8] = {
        _SpecularColor0,
        _SpecularColor1,
        _SpecularColor2,
        _SpecularColor3,
        _SpecularColor4,
        _SpecularColor5,
        _SpecularColor6,
        _SpecularColor7,
    };
    
    half3 overlayColor = 0;
    #if _USE_LUT_MAP
        overlayColor = GetLUTMapSpecularColor(GetRampLineIndex(materialId)).rgb;
    #else
        overlayColor = overlayColorArr[GetRampLineIndex(materialId)].rgb;
    #endif

    const float overlayIntensityArr[8] = {
        _SpecularIntensity0,
        _SpecularIntensity1,
        _SpecularIntensity2,
        _SpecularIntensity3,
        _SpecularIntensity4,
        _SpecularIntensity5,
        _SpecularIntensity6,
        _SpecularIntensity7,
    };
    
    float overlayIntensity = 0;
    #if _USE_LUT_MAP
        overlayIntensity = GetLUTMapSpecularIntensity(GetRampLineIndex(materialId));
    #else
        overlayIntensity = overlayIntensityArr[GetRampLineIndex(materialId)];
    #endif

    const float overlayShininessArr[8] = {
        _SpecularShininess0,
        _SpecularShininess1,
        _SpecularShininess2,
        _SpecularShininess3,
        _SpecularShininess4,
        _SpecularShininess5,
        _SpecularShininess6,
        _SpecularShininess7,
    };
    
    float overlayShininess = 0;
    #if _USE_LUT_MAP
        overlayShininess = GetLUTMapSpecularShininess(GetRampLineIndex(materialId));
    #else
        overlayShininess = overlayShininessArr[GetRampLineIndex(materialId)];
    #endif

    const float overlayRoughnessArr[8] = {
        _SpecularRoughness0,
        _SpecularRoughness1,
        _SpecularRoughness2,
        _SpecularRoughness3,
        _SpecularRoughness4,
        _SpecularRoughness5,
        _SpecularRoughness6,
        _SpecularRoughness7,
    };
    
    float overlayRoughness = 0;
    #if _USE_LUT_MAP
        overlayRoughness = GetLUTMapSpecularRoughness(GetRampLineIndex(materialId));
    #else
        overlayRoughness = overlayRoughnessArr[GetRampLineIndex(materialId)];
    #endif

    float3 finalSpecularColor = 0;
    #ifdef _CUSTOMSPECULARCOLORVARENUM_DISABLE
        finalSpecularColor = color.rgb;
    #elif _CUSTOMSPECULARCOLORVARENUM_TINT
        finalSpecularColor = color.rgb * overlayColor;
    #elif _CUSTOMSPECULARCOLORVARENUM_OVERLAY
        finalSpecularColor = overlayColor;
    #else
        finalSpecularColor = color.rgb;
    #endif

    float finalSpecularIntensity = 0;
    #ifdef _CUSTOMSPECULARVARENUM_DISABLE
        finalSpecularIntensity = _SpecularIntensity;
    #elif _CUSTOMSPECULARVARENUM_MULTIPLY
        finalSpecularIntensity = _SpecularIntensity * overlayIntensity;
    #elif _CUSTOMSPECULARVARENUM_OVERLAY
        finalSpecularIntensity = overlayIntensity;
    #else
        finalSpecularIntensity = _SpecularIntensity;
    #endif
    
    float finalSpecularShininess = 0;
    #ifdef _CUSTOMSPECULARVARENUM_DISABLE
        finalSpecularShininess = _SpecularShininess;
    #elif _CUSTOMSPECULARVARENUM_MULTIPLY
        finalSpecularShininess = _SpecularShininess * overlayShininess;
    #elif _CUSTOMSPECULARVARENUM_OVERLAY
        finalSpecularShininess = overlayShininess;
    #else
        finalSpecularShininess = _SpecularShininess;
    #endif

    float finalSpecularRoughness = 0;
    #ifdef _CUSTOMSPECULARVARENUM_DISABLE
        finalSpecularRoughness = _SpecularRoughness;
    #elif _CUSTOMSPECULARVARENUM_MULTIPLY
        finalSpecularRoughness = _SpecularRoughness * overlayRoughness;
    #elif _CUSTOMSPECULARVARENUM_OVERLAY
        finalSpecularRoughness = overlayRoughness;
    #else
        finalSpecularRoughness = _SpecularRoughness;
    #endif

    specularAreaData.color = finalSpecularColor.rgb;
    specularAreaData.intensity = finalSpecularIntensity;
    specularAreaData.shininess = finalSpecularShininess;
    specularAreaData.roughness = finalSpecularRoughness;

    return specularAreaData;
}

struct SpecularData
{
    float3 color;
    float specularThreshold;
    float shininess;
    float roughness;
    float intensity;
    float materialId;
};

float3 specular_base(Light light, float shadow_area, float ndoth, float lightmap_spec, float3 specular_color, float3 specular_values)
{
    float specular = ndoth;
    specular = pow(max(specular, 0.01f), specular_values.x);
    specular_values.y = max(specular_values.y, 0.001f);

    float specular_thresh = 1.0f - lightmap_spec;
    float rough_thresh = specular_thresh - specular_values.y;
    specular_thresh = (specular_values.y + specular_thresh) - rough_thresh;
    specular = shadow_area * specular - rough_thresh; 
    specular_thresh = saturate((1.0f / specular_thresh) * specular);
    specular = (specular_thresh * - 2.0f + 3.0f) * pow(specular_thresh, 2.0f);
    float3 specularColor = specular_color * specular * (specular_values.z * 0.35f);

    float attenuation = light.shadowAttenuation * saturate(light.distanceAttenuation);
    float3 lightColor = light.color * attenuation;

    float3 FinalSpecular = specularColor * lightColor;
    return FinalSpecular;
}

float3 CalculateBaseSpecular(SpecularData surface, Light light, float3 viewDirWS, float3 normalWS, float diffuseFac)
{
    float3 half_vector = normalize(viewDirWS + light.direction);
    float ndoth = dot(normalWS, half_vector);
    float metallic = step(abs(GetRampLineIndex(surface.materialId) - GetMetalIndex()), 0.001);
    return specular_base(light, metallic, ndoth, surface.specularThreshold, surface.color, float3(surface.shininess, surface.roughness, surface.intensity));
}

// Stockings ------------------------------------------------------------------------------------------------------ // 
// ---------------------------------------------------------------------------------------------------------------- //
struct StockingsData
{
    float4 StockRangeTex_ST;
    float4 Stockcolor;
    float4 StockDarkcolor;
    float StockDarkWidth;
    float Stockpower;
    float Stockpower1;
    float StockSP;
    float StockRoughness;
};

float3 CalculateStockingsEffect(StockingsData stockingsData, float3 diffuse, float ndotv, float2 uv, TEXTURE2D_PARAM(StockRangeTex, sampler_StockRangeTex))
{
    float2 tile_uv = uv.xy * stockingsData.StockRangeTex_ST.xy + stockingsData.StockRangeTex_ST.zw;

    float stock_tile = SAMPLE_TEXTURE2D(StockRangeTex, sampler_StockRangeTex, tile_uv).z; 
    // blue channel is a tiled texture that when used adds the rough mesh textured feel
    stock_tile = stock_tile * 0.5f - 0.5f;
    stock_tile = stockingsData.StockRoughness * stock_tile + 1.0f;
    // extract and remap 

    // sample untiled texture 
    float4 stocking_tex = SAMPLE_TEXTURE2D(StockRangeTex, sampler_StockRangeTex, uv.xy);
    // determine which areas area affected by the stocking
    float stock_area = (stocking_tex.x > 0.001f) ? 1.0f : 0.0f;

    //float offset_ndotv = dot(normal, normalize(view - _RimOffset));
    // i dont remember where i got this from but its in my mmd shader so it must be right... right? 
    float stock_rim = max(0.001f, ndotv);

    stockingsData.Stockpower = max(0.039f, stockingsData.Stockpower);
        
    stock_rim = smoothstep(stockingsData.Stockpower, stockingsData.StockDarkWidth * stockingsData.Stockpower, stock_rim) * stockingsData.StockSP;

    stocking_tex.x = stocking_tex.x * stock_area * stock_rim;
    float3 stock_dark_area = (float3)-1.0f * stockingsData.StockDarkcolor.rgb;
    stock_dark_area = stocking_tex.x * stock_dark_area + (float3)1.0f;
    stock_dark_area = diffuse.xyz * stock_dark_area + (float3)-1.0f;
    stock_dark_area = stocking_tex.x * stock_dark_area + (float3)1.0f;
    float3 stock_darkened = stock_dark_area * diffuse.xyz;

    float stock_spec = (1.0f - stockingsData.StockSP) * (stocking_tex.y * stock_tile);

    stock_rim = saturate(max(0.004f, pow(ndotv, stockingsData.Stockpower1)) * stock_spec);

    float3 stocking = -diffuse.xyz * stock_dark_area + stockingsData.Stockcolor.rgb;
    stocking = stock_rim * stocking + stock_darkened;

    return stocking;
}


// Emission ------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct EmissionData
{
    float3 color;
    float3 tintColor;
    float intensity;
    float threshold;
};

half3 CalculateBaseEmission(EmissionData emissionData, float4 albedo)
{
    half emissionThreshold = albedo.a - emissionData.threshold;
    half emissionThresholdInv = max(1 - emissionData.threshold, 0.001);
    half3 emissionFactor = saturate(emissionThreshold / emissionThresholdInv);
    emissionFactor = emissionData.threshold < albedo.a ? emissionFactor : 0;

    half3 emissionTintColor = emissionData.color * emissionData.tintColor * emissionData.intensity;
    half3 emissionColor = lerp(f3zero, emissionTintColor, emissionFactor);

    return emissionColor;
}


// Bloom ---------------------------------------------------------------------------------------------------------- // 
// ---------------------------------------------------------------------------------------------------------------- //
struct BloomAreaData
{
    float3 color;
    float intensity;
};

BloomAreaData GetBloomAreaData(half materialId, half3 mainColor)
{
    BloomAreaData bloomAreaData;

    half3 color = mainColor;
    
    const float4 overlayColorArr[8] = {
        _BloomColor0,
        _BloomColor1,
        _BloomColor2,
        _BloomColor3,
        _BloomColor4,
        _BloomColor5,
        _BloomColor6,
        _BloomColor7,
    };
    
    half3 overlayColor = 0;
    #if _USE_LUT_MAP
        overlayColor = GetLUTMapBloomColor(GetRampLineIndex(materialId)).rgb;
    #else
        overlayColor = overlayColorArr[GetRampLineIndex(materialId)].rgb;
    #endif

    const float overlayIntensityArr[8] = {
        _mmBloomIntensity0,
        _mmBloomIntensity1,
        _mmBloomIntensity2,
        _mmBloomIntensity3,
        _mmBloomIntensity4,
        _mmBloomIntensity5,
        _mmBloomIntensity6,
        _mmBloomIntensity7,
    };
    
    float overlayIntensity = 0;
    #if _USE_LUT_MAP
        overlayIntensity = GetLUTMapBloomIntensity(GetRampLineIndex(materialId));
    #else
        overlayIntensity = overlayIntensityArr[GetRampLineIndex(materialId)];
    #endif

    float3 finalBloomColor = 0;
    #ifdef _CUSTOMBLOOMCOLORVARENUM_DISABLE
        finalBloomColor = color.rgb;
    #elif _CUSTOMBLOOMCOLORVARENUM_TINT
        finalBloomColor = color.rgb * overlayColor * _BloomColor.rgb;
    #elif _CUSTOMBLOOMCOLORVARENUM_OVERLAY
        finalBloomColor = overlayColor;
    #else
        finalBloomColor = color.rgb;
    #endif

    float finalBloomIntensity = 0;
    #ifdef _CUSTOMBLOOMVARENUM_DISABLE
        finalBloomIntensity = _BloomIntensity;
    #elif _CUSTOMBLOOMVARENUM_MULTIPLY
        finalBloomIntensity = overlayIntensity * _BloomIntensity;
    #elif _CUSTOMBLOOMVARENUM_OVERLAY
        finalBloomIntensity = overlayIntensity;
    #else
        finalBloomIntensity = _BloomIntensity;
    #endif

    bloomAreaData.color = finalBloomColor.rgb;
    bloomAreaData.intensity = finalBloomIntensity;

    return bloomAreaData;
}

#endif
