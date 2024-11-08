#ifndef _SR_UNIVERSAL_UTILS_INCLUDED
#define _SR_UNIVERSAL_UTILS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"


// const ---------------------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
const static float3 f3zero = float3(0.0, 0.0, 0.0);
const static float3 f3one = float3(1.0, 1.0, 1.0);
const static float4 f4zero = float4(0.0, 0.0, 0.0, 0.0);
const static float4 f4one = float4(1.0, 1.0, 1.0, 1.0);


// utils ---------------------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
float4 CombineAndTransformDualFaceUV(float2 uv1, float2 uv2, float4 mapST)
{
    return float4(uv1, uv2) * mapST.xyxy + mapST.zwzw;
}

void SetupDualFaceRendering(inout float3 normalWS, inout float4 uv, FRONT_FACE_TYPE isFrontFace)
{
    #if defined(_CUSTOMHEADBONEMODEVARENUM_GAME)
        if (IS_FRONT_VFACE(isFrontFace, 1, 0))
            return;

        // 游戏内的部分模型用了双面渲染
        // 渲染背面的时候需要调整一些值，这样就不需要修改之后的计算了

        // 反向法线
        normalWS *= -1;

        // 交换 uv1 和 uv2
        #if defined(_BACKFACEUV2_ON)
            uv.xyzw = uv.zwxy;
        #endif
    #endif
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

float3 ColorBrightnessAdjustment(float3 color, float brightnessAdd, float brightnessThresholdMin, float brightnessThresholdMax)
{
    float3 hsv = RgbToHsv(color);
    hsv.z = clamp(brightnessThresholdMin, brightnessThresholdMax, (hsv.z + brightnessAdd));
    return HsvToRgb(hsv);
}

float3 ColorSaturationAdjustment(float3 color, float ColorSaturation)
{
    float luminance = 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
    float3 luminanceColor = float3(luminance, luminance, luminance);
    float3 finalColor = lerp(luminanceColor, color, ColorSaturation);
    return finalColor;
}

float3 LinearColorMix(float3 OriginalColor, float3 EnhancedColor, float mixFactor)
{
    float3 finalColor = lerp(saturate(OriginalColor), saturate(EnhancedColor), mixFactor);
    return finalColor;
}

float3 LerpRampColor(float3 coolRamp, float3 warmRamp, float dayTime, float shadowBoost)
{
    float3 rampColor = 0;
    rampColor = lerp(warmRamp, coolRamp, abs(dayTime - 12.0) * rcp(12.0));
    rampColor = lerp(f3one, rampColor, shadowBoost);
    return rampColor;
}

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold)
{
    #if _ALPHATEST_ON
        clip(alpha - alphaTestThreshold);
    #endif
}

float3 MixBloomColor(float3 colorTarget, float3 bloomColor, float bloomIntensity)
{
    return colorTarget * (1 + max(0, bloomIntensity) * bloomColor);
}


// HeadDirections ------------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
struct HeadDirections
{
    float3 forward;
    float3 right;
    float3 up;
};

HeadDirections GetWorldSpaceCharHeadDirectionsImpl(
    float4 mmdHeadBoneForward,
    float4 mmdHeadBoneUp,
    float4 mmdHeadBoneRight)
{
    HeadDirections dirWS;

    #if defined(_CUSTOMHEADBONEMODEVARENUM_GAME)
        // 游戏模型的头骨骼是旋转过的
        dirWS.forward = normalize(UNITY_MATRIX_M._m01_m11_m21); // +Y 是 Forward
        dirWS.right = normalize(-UNITY_MATRIX_M._m02_m12_m22);  // -Z 是 Right
        dirWS.up = normalize(-UNITY_MATRIX_M._m00_m10_m20);     // -X 是 Up
    #elif defined(_CUSTOMHEADBONEMODEVARENUM_MMD)
        // MMD 模型只有一个根骨骼上的 Renderer，头骨骼信息需要额外获取
        dirWS.forward = mmdHeadBoneForward.xyz;
        dirWS.right = mmdHeadBoneRight.xyz;
        dirWS.up = mmdHeadBoneUp.xyz;
    #else
        dirWS.forward = normalize(UNITY_MATRIX_M._m02_m12_m22); // 其他情况下是 +Z
        dirWS.right = normalize(UNITY_MATRIX_M._m00_m10_m20);   // 其他情况下是 +X
        dirWS.up = normalize(UNITY_MATRIX_M._m01_m11_m21);      // 其他情况下是 +Y
    #endif

    return dirWS;
}

#define WORLD_SPACE_CHAR_HEAD_DIRECTIONS() \
    GetWorldSpaceCharHeadDirectionsImpl(_MMDHeadBoneForward, _MMDHeadBoneUp, _MMDHeadBoneRight)


// DitherAlpha ---------------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
void DoDitherAlphaEffect(float4 svPosition, float ditherAlpha)
{
    static const float4 thresholds[4] =
    {
        float4(01.0 / 17.0, 09.0 / 17.0, 03.0 / 17.0, 11.0 / 17.0),
        float4(13.0 / 17.0, 05.0 / 17.0, 15.0 / 17.0, 07.0 / 17.0),
        float4(04.0 / 17.0, 12.0 / 17.0, 02.0 / 17.0, 10.0 / 17.0),
        float4(16.0 / 17.0, 08.0 / 17.0, 14.0 / 17.0, 06.0 / 17.0)
    };

    uint xIndex = fmod(svPosition.x - 0.5, 4);
    uint yIndex = fmod(svPosition.y - 0.5, 4);
    clip(ditherAlpha - thresholds[yIndex][xIndex]);
}


// CharacterMainLight --------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
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

float4 GetMainLightBrightness(float3 inputMainLightColor, float brightnessFactor, float brightnessThresholdMin, float brightnessThresholdMax, float brightnessOffset)
{
    float3 LightColor = inputMainLightColor.rgb * brightnessFactor;
    #if _AUTO_Brightness_ON
        LightColor = ColorBrightnessAdjustment(LightColor, brightnessOffset, brightnessThresholdMin, brightnessThresholdMax);
    #endif
    return float4(LightColor, 1);
}

float3 GetMainLightDiffuse(Light light, float brightnessFactor, float brightnessThresholdMin, float brightnessThresholdMax, float brightnessOffset, float mainLightColorUsage)
{
    float3 color = light.color;
    color = GetMainLightBrightness(color, brightnessFactor, brightnessThresholdMin, brightnessThresholdMax, brightnessOffset).rgb;
    color = lerp(desaturation(color.rgb), color.rgb, mainLightColorUsage);
    return color * light.distanceAttenuation;
}


// CharacterAdditionalLight --------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
void GetAdditionalLightDiffuse(float3 positionWS, float4 positionCS, float strength, inout float3 lightColor)
{

    #if defined(_ADDITIONAL_LIGHTS) || defined(_ADDITIONAL_LIGHTS_VERTEX)
        uint lightsCount = GetAdditionalLightsCount();
        #if defined(LIGHT_LOOP_BEGIN)
            InputData inputData = (InputData)0;
            inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(positionCS);
            inputData.positionWS = positionWS;
            LIGHT_LOOP_BEGIN(lightsCount)
        #else
            for(uint lightIndex = 0; lightIndex < lightsCount; lightIndex++)
            {
        #endif

            Light light = GetAdditionalLight(lightIndex, positionWS);
            #if defined(_LIGHT_LAYERS)
                if (IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))
            #endif
            {
                lightColor += light.color.rgb * light.distanceAttenuation * strength;
            }

        #if defined(LIGHT_LOOP_END)
            LIGHT_LOOP_END
        #else
            }
        #endif
    #endif

    #if defined(_ADDITIONAL_LIGHTS) && USE_FORWARD_PLUS
        #if defined(URP_FP_DIRECTIONAL_LIGHTS_COUNT)
            for(uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
        #else
            for(uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
        #endif
        {
            Light light = GetAdditionalLight(lightIndex, positionWS);
            #if defined(_LIGHT_LAYERS)
                if (IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))
            #endif
            {
                lightColor += light.color.rgb * light.distanceAttenuation * strength;
            }
        }
    #endif
}


// GI ------------------------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
float3 CalculateGI(float3 baseColor, float diffuseThreshold, float3 sh, float intensity, float mainColorLerp)
{
    return intensity * lerp(f3one, baseColor, mainColorLerp) * lerp(desaturation(sh), sh, mainColorLerp) * diffuseThreshold;
}


// RampIndex ------------------------------------------------------------------------------------------------------ //
// ---------------------------------------------------------------------------------------------------------------- //
void OverrideRampLineIfNeed()
{
    #if !_CUSTOM_RAMP_MAPPING_ON
        _RampV0 = 0;
        _RampV1 = 1;
        _RampV2 = 2;
        _RampV3 = 3;
        _RampV4 = 4;
        _RampV5 = 5;
        _RampV6 = 6;
        _RampV7 = 7;
    #endif
}

half GetRampV(half matId)
{
    OverrideRampLineIfNeed();
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
    OverrideRampLineIfNeed();
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
    OverrideRampLineIfNeed();
    return _RampV4;
}


// NPR ------------------------------------------------------------------------------------------------------------ //
// ---------------------------------------------------------------------------------------------------------------- //
float2 GetRampUV(float diffuseFac, float shadowRampOffset, float4 lightMap, bool singleMaterial)
{
    float material = singleMaterial ? 0 : lightMap.a;

    float2 rampUV;
    float rampU = diffuseFac * (1 - shadowRampOffset) + shadowRampOffset;
    rampUV = float2(rampU, GetRampV(material));

    return rampUV;
}

// TransparentFronHair -------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
float GetTransparentFronHairAlphaValue(float3 positionWS, float blendAlpha)
{
    HeadDirections headDirWS = WORLD_SPACE_CHAR_HEAD_DIRECTIONS();
    float3 viewDirWS = GetWorldSpaceViewDir(positionWS);

    // Horizontal 70 度
    float3 viewDirXZ = normalize(viewDirWS - dot(viewDirWS, headDirWS.up) * headDirWS.up);
    float cosHorizontal = max(0, dot(viewDirXZ, headDirWS.forward));
    float alpha1 = saturate((1 - cosHorizontal) / 0.658); // 0.658: 1 - cos70°

    // Vertical 45 度
    float3 viewDirYZ = normalize(viewDirWS - dot(viewDirWS, headDirWS.right) * headDirWS.right);
    float cosVertical = max(0, dot(viewDirYZ, headDirWS.forward));
    float alpha2 = saturate((1 - cosVertical) / 0.293); // 0.293: 1 - cos45°

    return max(max(alpha1, alpha2), blendAlpha);
}

#endif
