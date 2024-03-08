#include "../ShaderLibrary/NiloZOffset.hlsl"
#include "../ShaderLibrary/NiloInvLerpRemap.hlsl"
#include "../ShaderLibrary/NiloOutlineUtil.hlsl"


struct CharOutlineAttributes
{
    float3 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float4 color        : COLOR;
    float2 uv           : TEXCOORD0;
};

struct CharOutlineVaryings
{
    float4 positionCS               : SV_POSITION;
    float2 uv                       : TEXCOORD0;
    float fogFactor                 : TEXCOORD1;
    float4 color                    : TEXCOORD2;
};


void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold) 
{
#if _UseAlphaClipping
    clip(alpha - alphaTestThreshold);
#endif
}

CharOutlineVaryings SRUniversalVertex(CharOutlineAttributes input)
{
    CharOutlineVaryings output = (CharOutlineVaryings)0;

    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float width = _OutlineWidth;
    width *= GetOutlineCameraFovAndDistanceFixMultiplier(vertexPositionInput.positionVS.z);

    float3 positionWS = vertexPositionInput.positionWS;

#ifdef ToonShaderIsOutline
    #if _OUTLINE_VERTEX_COLOR_SMOOTH_NORMAL
        float3x3 tbn = float3x3(vertexNormalInput.tangentWS, vertexNormalInput.bitangentWS, vertexNormalInput.normalWS);
        positionWS += mul(input.color.rgb * 2 - 1, tbn) * width;
    #else
        positionWS += vertexNormalInput.normalWS * width;
    #endif
#endif

    output.positionCS = TransformWorldToHClip(positionWS);

#ifdef ToonShaderIsOutline
    // [Read ZOffset mask texture]
    // we can't use tex2D() in vertex shader because ddx & ddy is unknown before rasterization, 
    // so use tex2Dlod() with an explict mip level 0, put explict mip level 0 inside the 4th component of param uv)
    float outlineZOffsetMaskTexExplictMipLevel = 0;
    float outlineZOffsetMask = tex2Dlod(_OutlineZOffsetMaskTex, float4(input.uv,0,outlineZOffsetMaskTexExplictMipLevel)).r; //we assume it is a Black/White texture

    // [Remap ZOffset texture value]
    // flip texture read value so default black area = apply ZOffset, because usually outline mask texture are using this format(black = hide outline)
    outlineZOffsetMask = 1-outlineZOffsetMask;
    outlineZOffsetMask = invLerpClamp(_OutlineZOffsetMaskRemapStart,_OutlineZOffsetMaskRemapEnd,outlineZOffsetMask);// allow user to flip value or remap

    // [Apply ZOffset, Use remapped value as ZOffset mask]
    output.positionCS = NiloGetNewClipPosWithZOffset(output.positionCS, _OutlineZOffset * outlineZOffsetMask + 0.03 * _IsFace);
#endif

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    output.fogFactor = ComputeFogFactor(vertexPositionInput.positionCS.z);

    return output;
}

float4 colorFragmentTarget(inout CharOutlineVaryings input)
{
    float3 coolRamp = 0;
    float3 warmRamp = 0;
    #if _AREA_HAIR
        {
            float2 outlineUV = float2(0, 0.5);
            coolRamp = SAMPLE_TEXTURE2D(_HairCoolRamp, sampler_HairCoolRamp, outlineUV).rgb;
            warmRamp = SAMPLE_TEXTURE2D(_HairWarmRamp, sampler_HairWarmRamp, outlineUV).rgb;
        }
    #elif _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            float4 lightMap = 0;
            #if _AREA_UPPERBODY
                lightMap = SAMPLE_TEXTURE2D(_UpperBodyLightMap, sampler_UpperBodyLightMap, input.uv);
            #elif _AREA_LOWERBODY
                lightMap = SAMPLE_TEXTURE2D(_LowerBodyLightMap, sampler_LowerBodyLightMap, input.uv);
            #endif
            float materialEnum = lightMap.a;
            float materialEnumOffset = materialEnum + 0.0425;
            float outlineUVy = lerp(materialEnumOffset, materialEnumOffset + 0.5 > 1 ? materialEnumOffset + 0.5 - 1 : materialEnumOffset + 0.5, fmod((round(materialEnumOffset/0.0625) - 1)/2, 2));
            float2 outlineUV = float2(0, outlineUVy);
            coolRamp = SAMPLE_TEXTURE2D(_BodyCoolRamp, sampler_BodyCoolRamp, outlineUV).rgb;
            warmRamp = SAMPLE_TEXTURE2D(_BodyWarmRamp, sampler_BodyWarmRamp, outlineUV).rgb;
        }
    #elif _AREA_FACE
        {
            float2 outlineUV = float2(0, 0.0625);
            coolRamp = SAMPLE_TEXTURE2D(_BodyCoolRamp, sampler_BodyCoolRamp, outlineUV).rgb;
            warmRamp = SAMPLE_TEXTURE2D(_BodyWarmRamp, sampler_BodyWarmRamp, outlineUV).rgb;
        }
    #endif

    float3 OutlineRamp = lerp(coolRamp, warmRamp, 0.5);
    float3 OutlineAlbedo = 0; 
    #if _USE_RAMP_COLOR_ON
        OutlineAlbedo += pow(saturate(OutlineRamp), _OutlineGamma);
    #else
        OutlineAlbedo += pow(_OutlineColor, _OutlineGamma);
    #endif

    float alpha = _Alpha;

    float4 FinalOutlineColor = float4(OutlineAlbedo, alpha);
    DoClipTestToTargetAlphaValue(FinalOutlineColor.a, _AlphaClip);
    FinalOutlineColor.rgb = MixFog(FinalOutlineColor.rgb, input.fogFactor);

    return FinalOutlineColor;
}

void SRUniversalFragment(
    CharOutlineVaryings input,
    out float4 colorTarget      : SV_Target0,
    out float4 bloomTarget      : SV_Target1)
{
    float4 outputColor = colorFragmentTarget(input);

    colorTarget = float4(outputColor.rgb, 1);
    bloomTarget = 0;
}