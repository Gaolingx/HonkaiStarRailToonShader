#ifndef _SR_UNIVERSAL_DRAW_OUTLINE_INCLUDED
#define _SR_UNIVERSAL_DRAW_OUTLINE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../ShaderLibrary/SRUniversalLibrary.hlsl"
#include "../ShaderLibrary/NiloOutlineUtil.hlsl"

struct CharOutlineAttributes
{
    float4 positionOS     : POSITION;
    float4 color          : COLOR;
    float3 normalOS       : NORMAL;
    float4 tangentOS      : TANGENT;
    float2 uv1            : TEXCOORD0;
    float2 uv2            : TEXCOORD1;
    float2 packSmoothNormal : TEXCOORD2;
};

struct CharOutlineVaryings
{
    float4 positionCS     : SV_POSITION;
    float4 baseUV         : TEXCOORD0;
    float4 color          : COLOR;
    float3 normalWS       : TEXCOORD1;
    float3 positionWS     : TEXCOORD2;
    real   fogFactor      : TEXCOORD3;
};

float3 GetSmoothNormalWS(CharOutlineAttributes input)
{
    float3 smoothNormalOS = input.normalOS;
    
    #ifdef _OUTLINENORMALCHANNEL_NORMAL
        smoothNormalOS = input.normalOS;
    #elif _OUTLINENORMALCHANNEL_TANGENT
        smoothNormalOS = input.tangentOS.xyz;
    #elif _OUTLINENORMALCHANNEL_UV2
        float3 normalOS = normalize(input.normalOS);
        float3 tangentOS = normalize(input.tangentOS.xyz);
        float3 bitangentOS = normalize(cross(normalOS, tangentOS) * (input.tangentOS.w * GetOddNegativeScale()));
        float3 smoothNormalTS = UnpackNormalOctQuadEncode(input.packSmoothNormal);
        smoothNormalOS = mul(smoothNormalTS, float3x3(tangentOS, bitangentOS, normalOS));
    #endif

    return TransformObjectToWorldNormal(smoothNormalOS);
}

CharOutlineVaryings CharacterOutlinePassVertex(CharOutlineAttributes input)
{
    CharOutlineVaryings output;

    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS);

    float3 smoothNormalWS = GetSmoothNormalWS(input);
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

    float outlineWidth = input.color.a;
    if (_FaceMaterial == 1)
    {
        outlineWidth *= lerp(1.0,
            saturate(0.4 - dot(_MMDHeadBoneForward.xz, normalize(GetCameraPositionWS() - positionWS).xz)), step(0.5, input.color.b));
    }

    positionWS = ExtendOutline(positionWS, smoothNormalWS,
        _OutlineWidth * outlineWidth, _OutlineWidthMin * outlineWidth, _OutlineWidthMax * outlineWidth);

    output.baseUV = CombineAndTransformDualFaceUV(input.uv1, input.uv2, _Maps_ST);
    output.color = input.color;
    output.positionWS = positionWS;
    output.normalWS = vertexNormalInput.normalWS;
    output.positionCS = TransformWorldToHClip(positionWS);

    output.fogFactor = ComputeFogFactor(vertexPositionInput.positionCS.z);

    return output;
}

half3 GetOutlineColor(half materialId, half3 mainColor, half DayTime)
{
    half3 color = 0;
    #if _USE_LUT_MAP && _USE_LUT_MAP_OUTLINE
        color = GetLUTMapOutlineColor(GetRampLineIndex(materialId)).rgb;
    #else
        float2 rampUV = float2(0, GetRampV(materialId));
        RampColor RC = RampColorConstruct(rampUV,
        TEXTURE2D_ARGS(_HairCoolRamp, sampler_HairCoolRamp),
        TEXTURE2D_ARGS(_HairWarmRamp, sampler_HairWarmRamp),
        TEXTURE2D_ARGS(_BodyCoolRamp, sampler_BodyCoolRamp),
        TEXTURE2D_ARGS(_BodyWarmRamp, sampler_BodyWarmRamp));

        half3 coolRampCol = RC.coolRampCol;
        half3 warmRampCol = RC.warmRampCol;
        color = mainColor * LerpRampColor(coolRampCol, warmRampCol, DayTime, 1);
    #endif

    const float4 overlayColors[8] = {
        _OutlineColor0,
        _OutlineColor1,
        _OutlineColor2,
        _OutlineColor3,
        _OutlineColor4,
        _OutlineColor5,
        _OutlineColor6,
        _OutlineColor7,
    };

    half3 overlayColor = overlayColors[GetRampLineIndex(materialId)].rgb;

    half3 outlineColor = 0;
    #ifdef _CUSTOMOUTLINEVARENUM_DISABLE
        outlineColor = color;
    #elif _CUSTOMOUTLINEVARENUM_MULTIPLY
        outlineColor = color * overlayColor;
    #elif _CUSTOMOUTLINEVARENUM_TINT
        outlineColor = color * _OutlineColor.rgb;
    #elif _CUSTOMOUTLINEVARENUM_OVERLAY
        outlineColor = overlayColor;
    #elif _CUSTOMOUTLINEVARENUM_CUSTOM
        outlineColor = _OutlineDefaultColor.rgb;
    #else
        outlineColor = color;
    #endif

    return outlineColor;
}

float4 colorFragmentTarget(inout CharOutlineVaryings input) 
{
    [branch] if (_EnableOutline == 0)
    {
        clip(-1.0);
    }

    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    float3 lightDirectionWS = normalize(mainLight.direction);

    float3 baseColor = 0;
    baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV.xy).rgb;
    baseColor = GetMainTexColor(input.baseUV.xy,
    TEXTURE2D_ARGS(_FaceColorMap, sampler_FaceColorMap), _FaceColorMapColor,
    TEXTURE2D_ARGS(_HairColorMap, sampler_HairColorMap), _HairColorMapColor,
    TEXTURE2D_ARGS(_BodyColorMap, sampler_BodyColorMap), _BodyColorMapColor).rgb;

    float4 lightMap = 0;
    lightMap = GetLightMapTex(input.baseUV.xy,
    TEXTURE2D_ARGS(_HairLightMap, sampler_HairLightMap),
    TEXTURE2D_ARGS(_BodyLightMap, sampler_BodyLightMap));

    float DayTime = 0;

    [branch] if (_DayTime_MANUAL_ON)
    {
        DayTime = _DayTime;
    }
    else
    {
        DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    }

    float alpha = _Alpha;
    float4 FinalOutlineColor = float4(GetOutlineColor(lightMap.a, baseColor.rgb, DayTime), alpha);

    DoClipTestToTargetAlphaValue(FinalOutlineColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);

    // Mix Fog
    real fogFactor = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
    FinalOutlineColor.rgb = MixFog(FinalOutlineColor.rgb, fogFactor);

    return FinalOutlineColor;
}

void CharacterOutlinePassFragment(
CharOutlineVaryings input,
out float4 colorTarget      : SV_Target0)
{
    float4 outputColor = colorFragmentTarget(input);

    colorTarget = float4(outputColor.rgb, 1);
}

#endif
