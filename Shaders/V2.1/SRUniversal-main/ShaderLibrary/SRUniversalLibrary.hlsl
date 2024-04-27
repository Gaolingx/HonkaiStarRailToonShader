// include
#include "../ShaderLibrary/CharShadow.hlsl"
#include "../ShaderLibrary/CharDepthOnly.hlsl"
#include "../ShaderLibrary/CharDepthNormals.hlsl"
#include "../ShaderLibrary/CharMotionVectors.hlsl"
#include "../ShaderLibrary/SRUniversalBloomHelper.hlsl"


// const
const static float3 f3zero = float3(0.0, 0.0, 0.0);
const static float3 f3one = float3(1.0, 1.0, 1.0);
const static float4 f4zero = float4(0.0, 0.0, 0.0, 0.0);
const static float4 f4one = float4(1.0, 1.0, 1.0, 1.0);


// Gradient
struct Gradient
{
    int colorsLength;
    float4 colors[8];

};

Gradient GradientConstruct()
{
    Gradient g;
    g.colorsLength = 2;
    g.colors[0] = float4(1,1,1,0); //第四位不是alpha，而是它在轴上的坐标
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


// utils
float3 desaturation(float3 color)
{
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    float grayf = dot(color, grayXfer);
    return float3(grayf, grayf, grayf);
}

float3 CombineColorPreserveLuminance(float3 color, float3 colorAdd)
{
    float3 hsv = RgbToHsv(color + colorAdd);
    hsv.z = max(RgbToHsv(color).z, RgbToHsv(colorAdd).z);
    return HsvToRgb(hsv);
}

float3 RGBAdjustment(float3 color, float ColorSaturation)
{
    float luminance = 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
    float3 luminanceColor = float3(luminance, luminance, luminance);
    float3 finalColor = lerp(luminanceColor, color, ColorSaturation);
    return finalColor;
}

float3 LinearColorMix(float3 OriginalColor, float3 EnhancedColor, float mixFactor)
{
    OriginalColor = clamp(OriginalColor, 0.0, 1.0);
    EnhancedColor = clamp(EnhancedColor, 0.0, 1.0);
    float3 finalColor = lerp(OriginalColor, EnhancedColor, mixFactor);
    return finalColor;
}

float3 LerpRampColor(float3 coolRamp, float3 warmRamp, float DayTime)
{
    return lerp(warmRamp, coolRamp, abs(DayTime - 12.0) * rcp(12.0));
}

float GetLinearEyeDepthAnyProjection(float depth)
{
    if (IsPerspectiveProjection())
    {
        return LinearEyeDepth(depth, _ZBufferParams);
    }

    return LinearDepthToEyeDepth(depth);
}

// works only in fragment shader
float GetLinearEyeDepthAnyProjection(float4 svPosition)
{
    // 透视投影时，Scene View 里直接返回 svPosition.w 会出问题，Game View 里没事

    return GetLinearEyeDepthAnyProjection(svPosition.z);
}

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold) 
{
    #if _UseAlphaClipping
        clip(alpha - alphaTestThreshold);
    #endif
}


// CharacterMainLight
Light GetCharacterMainLightStruct(float4 shadowCoord, float3 positionWS)
{
    Light light = GetMainLight();

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
        half4 shadowParams = GetMainLightShadowParams();

        // 我自己试下来，在角色身上 LowQuality 比 Medium 和 High 好
        // Medium 和 High 采样数多，过渡的区间大，在角色身上更容易出现 Perspective aliasing
        shadowSamplingData.softShadowQuality = SOFT_SHADOW_QUALITY_LOW;
        light.shadowAttenuation = SampleShadowmap(TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_LinearClampCompare), shadowCoord, shadowSamplingData, shadowParams, false);
        light.shadowAttenuation = lerp(light.shadowAttenuation, 1, GetMainLightShadowFade(positionWS));
    #endif

    #ifdef _LIGHT_LAYERS
        if (!IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))
        {
            // 偷个懒，直接把强度改成 0
            light.distanceAttenuation = 0;
            light.shadowAttenuation = 0;
        }
    #endif

    return light;
}

float4 GetMainLightBrightness(float3 inputMainLightColor, float brightnessFactor)
{
    float3 scaledMainLightColor = inputMainLightColor.rgb * brightnessFactor;
    float4 scaledMainLight = float4(scaledMainLightColor, 1);
    return scaledMainLight;
}

float3 GetMainLightColor(float3 inputMainLightColor, float mainLightColorUsage)
{
    return lerp(desaturation(inputMainLightColor.rgb), inputMainLightColor.rgb, mainLightColorUsage);
}


// CharacterAdditionalLight
float3 GetAdditionalLightDiffuse(float3 baseColor, Light light)
{
    float attenuation = light.shadowAttenuation * saturate(light.distanceAttenuation);
    return baseColor * light.color * attenuation;
}

Light GetCharacterAdditionalLight(uint lightIndex, float3 positionWS)
{
    Light light = GetAdditionalLight(lightIndex, positionWS);
    // light.distanceAttenuation = saturate(light.distanceAttenuation);

    #if defined(ADDITIONAL_LIGHT_CALCULATE_SHADOWS)
        light.shadowAttenuation = AdditionalLightRealtimeShadow(lightIndex, positionWS, light.direction);
        light.shadowAttenuation = lerp(light.shadowAttenuation, 1, GetAdditionalLightShadowFade(positionWS));
    #endif

    #ifdef _LIGHT_LAYERS
        if (!IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))
        {
            // 偷个懒，直接把强度改成 0
            light.distanceAttenuation = 0;
            light.shadowAttenuation = 0;
        }
    #endif

    return light;
}

#if USE_FORWARD_PLUS
    // Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl
    struct ForwardPlusDummyInputData
    {
        float3 positionWS;
        float2 normalizedScreenSpaceUV;
    };

    #define CHAR_LIGHT_LOOP_BEGIN(posWS, posHCS) { \
        uint pixelLightCount = GetAdditionalLightsCount(); \
        ForwardPlusDummyInputData inputData; \
        inputData.positionWS = posWS; \
        inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(posHCS); \
        LIGHT_LOOP_BEGIN(pixelLightCount)
#else
    #define CHAR_LIGHT_LOOP_BEGIN(posWS, posHCS) { \
        uint pixelLightCount = GetAdditionalLightsCount(); \
        LIGHT_LOOP_BEGIN(pixelLightCount)
#endif

#define CHAR_LIGHT_LOOP_END } LIGHT_LOOP_END


// GI
half3 CalculateGI(float3 baseColor, float diffuseThreshold, half3 sh, float intensity, float mainColorLerp)
{
    return intensity * lerp(f3one, baseColor, mainColorLerp) * lerp(desaturation(sh), sh, mainColorLerp) * diffuseThreshold;
}


// MainTex
float4 GetMainTexColor(float2 uv, TEXTURE2D(FaceColorMap), float4 FaceColorMapColor,
TEXTURE2D(HairColorMap), float4 HairColorMapColor,
TEXTURE2D(UpperBodyColorMap), float4 UpperBodyColorMapColor,
TEXTURE2D(LowerBodyColorMap), float4 LowerBodyColorMapColor)
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
    #elif _AREA_UPPERBODY
        areaMap = SAMPLE_TEXTURE2D(UpperBodyColorMap, sampler_UpperBodyColorMap, uv);
        areaColor = areaMap * UpperBodyColorMapColor;
    #elif _AREA_LOWERBODY
        areaMap = SAMPLE_TEXTURE2D(LowerBodyColorMap, sampler_LowerBodyColorMap, uv);
        areaColor = areaMap * LowerBodyColorMapColor;
    #endif
    return areaColor;
}


// RampColor
struct RampColor
{
    float3 coolRampCol;
    float3 warmRampCol;
};

RampColor RampColorConstruct(float2 rampUV, TEXTURE2D(HairCoolRamp), float3 HairCoolRampColor, float HairCoolRampColorMixFactor,
TEXTURE2D(HairWarmRamp), float3 HairWarmRampColor, float HairWarmRampColorMixFactor,
TEXTURE2D(BodyCoolRamp), float3 BodyCoolRampColor, float BodyCoolRampColorMixFactor,
TEXTURE2D(BodyWarmRamp), float3 BodyWarmRampColor, float BodyWarmRampColorMixFactor)
{
    RampColor R;
    float3 coolRampTexCol = 1;
    float3 warmRampTexCol = 1;
    float3 coolRampCol = 1;
    float3 warmRampCol = 1;
    //hair的Ramp贴图和身体或脸部的不一样，按照keyword采样
    #if _AREA_HAIR
        coolRampTexCol = SAMPLE_TEXTURE2D(HairCoolRamp, sampler_HairCoolRamp, rampUV).rgb;
        warmRampTexCol = SAMPLE_TEXTURE2D(HairWarmRamp, sampler_HairWarmRamp, rampUV).rgb;
        coolRampCol = LinearColorMix(coolRampTexCol, HairCoolRampColor, HairCoolRampColorMixFactor);
        warmRampCol = LinearColorMix(warmRampTexCol, HairWarmRampColor, HairWarmRampColorMixFactor);
    #elif _AREA_FACE || _AREA_UPPERBODY || _AREA_LOWERBODY
        coolRampTexCol = SAMPLE_TEXTURE2D(BodyCoolRamp, sampler_BodyCoolRamp, rampUV).rgb;
        warmRampTexCol = SAMPLE_TEXTURE2D(BodyWarmRamp, sampler_BodyWarmRamp, rampUV).rgb;
        coolRampCol = LinearColorMix(coolRampTexCol, BodyCoolRampColor, BodyCoolRampColorMixFactor);
        warmRampCol = LinearColorMix(warmRampTexCol, BodyWarmRampColor, BodyWarmRampColorMixFactor);
    #endif
    R.coolRampCol = coolRampCol;
    R.warmRampCol = warmRampCol;
    return R;
}


// LightMap
float4 GetLightMapTex(float2 uv, TEXTURE2D(HairLightMap), TEXTURE2D(UpperBodyLightMap), TEXTURE2D(LowerBodyLightMap))
{
    float4 lightMap = 0;
    #if _AREA_HAIR
        lightMap = SAMPLE_TEXTURE2D(HairLightMap, sampler_HairLightMap, uv);
    #elif _AREA_UPPERBODY
        lightMap = SAMPLE_TEXTURE2D(UpperBodyLightMap, sampler_UpperBodyLightMap, uv);
    #elif _AREA_LOWERBODY
        lightMap = SAMPLE_TEXTURE2D(LowerBodyLightMap, sampler_LowerBodyLightMap, uv);
    #endif
    return lightMap;
}


// RampIndex
half GetRampV(half matId)
{
    return 0.0625 + 0.125 * lerp(lerp(lerp(lerp(lerp(lerp(lerp(
        _RampV0,
        _RampV1, step(0.125, matId)),
        _RampV2, step(0.250, matId)),
        _RampV3, step(0.375, matId)),
        _RampV4, step(0.500, matId)),
        _RampV5, step(0.625, matId)),
        _RampV6, step(0.750, matId)),
        _RampV7, step(0.875, matId));
}

half GetRampLineIndex(half matId)
{
    return lerp(lerp(lerp(lerp(lerp(lerp(lerp(
        _RampV0,
        _RampV1, step(0.125, matId)),
        _RampV2, step(0.250, matId)),
        _RampV3, step(0.375, matId)),
        _RampV4, step(0.500, matId)),
        _RampV5, step(0.625, matId)),
        _RampV6, step(0.750, matId)),
        _RampV7, step(0.875, matId));
}

half GetMetalIndex()
{
    return _RampV4;
}


// RimLight
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
    
    half3 overlayColor = overlayColors[GetRampLineIndex(materialId)].rgb;

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
    
    float overlayWidth = overlayWidths[GetRampLineIndex(materialId)];

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
    
    float overlayDark = rimDarks[GetRampLineIndex(materialId)];

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
    
    float overlayEdgeSoftness = rimEdgeSoftnesses[GetRampLineIndex(materialId)];

    float3 finalRimColor = 0;
    #ifdef _CUSTOMRIMLIGHTVARENUM_DISABLE
        finalRimColor = color.rgb;
    #elif _CUSTOMRIMLIGHTVARENUM_MULTIPLY
        finalRimColor = color.rgb * overlayColor;
    #elif _CUSTOMRIMLIGHTVARENUM_OVERLAY
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
    float thresholdMin;
    float thresholdMax;
    float modelScale;
    float ditherAlpha;
    float NoV;
};

float3 GetRimLightMask(
    RimLightMaskData rlmData,
    float4 svPosition,
    float3 normalWS,
    float4 lightMap)
{
    float rimWidth = rlmData.width / 2000.0; // rimWidth 表示的是屏幕上像素的偏移量，和 modelScale 无关
    float rimThresholdMin = rlmData.thresholdMin * rlmData.modelScale * 10.0;
    float rimThresholdMax = rlmData.thresholdMax * rlmData.modelScale * 10.0;

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
    rimWidth *= 10.0 * rsqrt(depth / rlmData.modelScale); // 近大远小

    float3 normalVS = TransformWorldToViewNormal(normalWS);
    float2 indexOffset = float2(sign(normalVS.x), 0) * rimWidth; // 只横向偏移
    uint2 index = clamp(svPosition.xy - 0.5 + indexOffset, 0, _ScaledScreenParams.xy - 1); // 避免出界
    float offsetDepth = GetLinearEyeDepthAnyProjection(LoadSceneDepth(index));

    float depthDelta = (offsetDepth - depth) * 50; // 只有 depth 小于 offsetDepth 的时候再画
    float intensity = smoothstep(rimThresholdMin, rimThresholdMax, depthDelta);

    // 用于柔化边缘光，edgeSoftness 越大，越柔和
    float fresnel = pow(clamp(1 - rlmData.NoV, 0.01, 1), max(rlmData.edgeSoftness, 0.01));

    float ditherAlphaFadeOut = smoothstep(0.9, 1, rlmData.ditherAlpha);

    return rlmData.color * saturate(intensity * fresnel * ditherAlphaFadeOut);
}

struct RimLightData
{
    float darkenValue;
    float intensityFrontFace;
    float intensityBackFace;
};

float3 GetRimLight(RimLightData rimData, float3 rimMask, float NoL, Light light, bool isFrontFace)
{
    float attenuation = saturate(NoL * light.shadowAttenuation * light.distanceAttenuation);
    float intensity = lerp(rimData.intensityBackFace, rimData.intensityFrontFace, isFrontFace);
    return rimMask * light.color * (lerp(rimData.darkenValue, 1, attenuation) * intensity);
}


// RimShadow
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
    
    half3 overlayColor = overlayColors[GetRampLineIndex(materialId)].rgb;

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
    
    float overlayWidth = overlayWidths[GetRampLineIndex(materialId)];

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
    
    float overlayFeather = rimShadowFeather[GetRampLineIndex(materialId)];

    float3 finalRimShadowColor = 0;
    #ifdef _CUSTOMRIMSHADOWVARENUM_DISABLE
        finalRimShadowColor = color.rgb;
    #elif _CUSTOMRIMSHADOWVARENUM_MULTIPLY
        finalRimShadowColor = color.rgb * overlayColor;
    #elif _CUSTOMRIMSHADOWVARENUM_OVERLAY
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


// Specular
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
    
    half3 overlayColor = overlayColorArr[GetRampLineIndex(materialId)].rgb;

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
    
    float overlayIntensity = overlayIntensityArr[GetRampLineIndex(materialId)];

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
    
    float overlayShininess = overlayShininessArr[GetRampLineIndex(materialId)];

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
    
    float overlayRoughness = overlayRoughnessArr[GetRampLineIndex(materialId)];

    float3 finalSpecularColor = 0;
    #ifdef _CUSTOMSPECULARVARENUM_DISABLE
        finalSpecularColor = color.rgb;
    #elif _CUSTOMSPECULARVARENUM_MULTIPLY
        finalSpecularColor = color.rgb * overlayColor;
    #elif _CUSTOMSPECULARVARENUM_OVERLAY
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
    half3 color;
    half specularIntensity;
    half specularThreshold;
    half materialId;
    half SpecularKsNonMetal;
    half SpecularKsMetal;
};

half3 CalculateSpecular(SpecularData surface, Light light, float3 viewDirWS, half3 normalWS, 
half3 specColor, float shininess, float roughness, float intensity, float diffuseFac, float metallic = 0.0)
{
    //roughness = lerp(1.0, roughness * roughness, metallic);
    //float smoothness = exp2(shininess * (1.0 - roughness) + 1.0) + 1.0;
    float3 halfDirWS = normalize(light.direction + viewDirWS);
    float HoV = saturate(dot(viewDirWS, halfDirWS));
    float blinnPhong = pow(saturate(dot(halfDirWS, normalWS)), shininess);
    float threshold = 1.0 - surface.specularThreshold;
    float stepPhong = smoothstep(threshold - roughness, threshold + roughness, blinnPhong);

    float3 f0 = lerp(surface.SpecularKsNonMetal, surface.color, metallic);
    float3 fresnel = f0 + (1.0 - f0) * pow(1.0 - HoV, 5.0);

    half3 lightColor = light.color * light.shadowAttenuation;
    half3 specular = lightColor * specColor * fresnel * stepPhong * lerp(diffuseFac, surface.SpecularKsMetal, metallic);
    
    return specular * intensity * surface.specularIntensity;
}

half3 CalculateBaseSpecular(SpecularData surface, Light light, float3 viewDirWS, half3 normalWS, 
    half3 specColor, float shininess, float roughness, float intensity, float diffuseFac)
{
    float metallic = step(abs(GetRampLineIndex(surface.materialId) - GetMetalIndex()), 0.001);
    return CalculateSpecular(surface, light, viewDirWS, normalWS, specColor, shininess, roughness, intensity, diffuseFac, metallic);
}


// Bloom
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
    
    half3 overlayColor = overlayColorArr[GetRampLineIndex(materialId)].rgb;

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
    
    float overlayIntensity = overlayIntensityArr[GetRampLineIndex(materialId)];

    float3 finalBloomColor = 0;
    #ifdef _CUSTOMBLOOMCOLORVARENUM_DISABLE
        finalBloomColor = color.rgb;
    #elif _CUSTOMBLOOMCOLORVARENUM_TINT
        finalBloomColor = color.rgb * overlayColor * _BloomColor;
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
