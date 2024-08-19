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
    float3 tangentOS      : TANGENT;
    float2 uv1            : TEXCOORD0;
    float2 uv2            : TEXCOORD1;
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
    #endif

    return smoothNormalOS;
}

float3 TransformPositionWSToOutlinePositionWS(float3 positionWS, float positionVS_Z, float3 normalWS, float outlineWidth)
{
    //you can replace it to your own method! Here we will write a simple world space method for tutorial reason, it is not the best method!
    float outlineExpandAmount = outlineWidth * GetOutlineCameraFovAndDistanceFixMultiplier(positionVS_Z);
    return positionWS + normalWS * outlineExpandAmount; 
}

CharOutlineVaryings CharacterOutlinePassVertex(CharOutlineAttributes input)
{
    CharOutlineVaryings output;

    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(GetSmoothNormalWS(input));

    if(_FaceMaterial) // sigh is this even going to work in vr? 
        {
            float4 tmp0;
            float4 tmp1;
            float4 tmp2;
            float4 tmp3;
            tmp0.xy = float2(-0.206, 0.961);
            tmp0.z = _OutlineFixSide;
            tmp1.xyz = mul(input.positionOS.xyz, (float3x3)unity_ObjectToWorld).xyz;
            tmp2.xyz = _WorldSpaceCameraPos - tmp1.xyz;
            tmp1.xyz = mul(tmp1.xyz, (float3x3)unity_ObjectToWorld).xyz;
            tmp0.w = length(tmp1.xyz);
            tmp1.yzw = tmp0.w * tmp1.xyz;
            tmp0.w = tmp1.x * tmp0.w + -0.1;
            tmp0.x = dot(tmp0.xyz, tmp1.xyz); 
            tmp2.yz = float2(-0.206, 0.961);
            tmp2.xw = -float2(_OutlineFixSide.x, _OutlineFixFront.x);
            tmp0.y = dot(tmp2.xyz, tmp1.xyz);
            tmp0.z = dot(float2(0.076, 0.961), tmp1.xy);
            tmp0.x = max(tmp0.y, tmp0.x);
            tmp0.x = 0.1 - tmp0.x;
            tmp0.x = tmp0.x * 9.999998;
            tmp0.x = max(tmp0.x, 0.0);
            tmp0.y = tmp0.x * -2.0 + 3.0;
            tmp0.x = tmp0.x * tmp0.x;
            tmp0.x = tmp0.x * tmp0.y;
            tmp0.x = min(tmp0.x, 1.0);
            tmp0.y = saturate(tmp0.z);
            tmp0.z = 1.0 - tmp0.z;
            tmp0.y = tmp2.x + tmp0.y;
            tmp0.yw = saturate(tmp0.yw * float2(20.0, 5.0));
            tmp1.x = tmp0.y * -2.0 + 3.0;
            tmp0.y = tmp0.y * tmp0.y;
            tmp0.y = tmp0.y * tmp1.x;
            tmp0.x = max(tmp0.x, tmp0.y);
            tmp0.x = min(tmp0.x, 1.0);
            tmp0.x = tmp0.x - 1.0;
            tmp0.x = input.color.y * tmp0.x + 1.0;
            tmp0.x = tmp0.x * _OutlineWidth;
            tmp0.x = tmp0.x * _OutlineScale;
            tmp0.y = tmp0.w * -2.0 + 3.0;
            tmp0.w = tmp0.w * tmp0.w;
            tmp0.y = tmp0.w * tmp0.y;
            tmp1.xy = -float2(_OutlineFixRange1.x, _OutlineFixRange2.x) + float2(_OutlineFixRange3.x, _OutlineFixRange4.x);
            tmp0.yw = tmp0.yy * tmp1.xy + float2(_OutlineFixRange1.x, _OutlineFixRange2.x);

            tmp0.y = smoothstep(tmp0.y, tmp0.w, tmp0.z);

            tmp0.y = tmp0.y * input.color.z;
            tmp0.zw = input.color.zy > float2(0.0, 0.0);
            tmp0.y = tmp0.z ? tmp0.y : input.color.w;
            tmp0.z = input.color.y < 1.0;
            tmp0.z = tmp0.w ? tmp0.z : 0.0;
            tmp0.z = tmp0.z ? 1.0 : 0.0;
            tmp0.y = tmp0.z * _FixLipOutline + tmp0.y;
            tmp0.x = tmp0.y * tmp0.x;

            float3 positionWS = vertexPositionInput.positionWS;
            positionWS = TransformPositionWSToOutlinePositionWS(vertexPositionInput.positionWS, vertexPositionInput.positionVS.z, vertexNormalInput.normalWS, (tmp0.x * 100));
            output.positionCS = TransformWorldToHClip(positionWS);
        }
        else
        {
            float3 positionWS = vertexPositionInput.positionWS;
            positionWS = TransformPositionWSToOutlinePositionWS(vertexPositionInput.positionWS, vertexPositionInput.positionVS.z, vertexNormalInput.normalWS, (_OutlineWidth * _OutlineScale * input.color.w * 100));
            output.positionCS = TransformWorldToHClip(positionWS);
        }

    output.baseUV = CombineAndTransformDualFaceUV(input.uv1, input.uv2, _Maps_ST);
    output.color = input.color;
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionWS = positionWS;
    output.normalWS = vertexNormalInput.normalWS;

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
