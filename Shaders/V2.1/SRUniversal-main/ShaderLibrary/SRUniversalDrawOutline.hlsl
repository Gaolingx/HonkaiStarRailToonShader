#include "../ShaderLibrary/SRUniversalLibrary.hlsl"
#include "../ShaderLibrary/NiloZOffset.hlsl"

struct CharOutlineAttributes
{
    float4 positionOS : POSITION;
    float4 color : COLOR;
    float3 normalOS : NORMAL;
    float3 tangentOS : TANGENT;
    float2 uv1 : TEXCOORD0;
    float2 uv2 : TEXCOORD1;
};

struct CharOutlineVaryings
{
    float4 positionCS : SV_POSITION;
    float4 baseUV : TEXCOORD0;
    float4 color : COLOR;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    float fogFactor : TEXCOORD3;
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

CharOutlineVaryings CharacterOutlinePassVertex(CharOutlineAttributes input)
{
    CharOutlineVaryings output;

    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

    if (_UseSelfOutline == 1)
    {
        float outlineWidth = _OutlineScale * _OutlineWidth * input.color.w;
        input.positionOS.xyz += normalize(GetSmoothNormalWS(input)) * outlineWidth;
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
        output.positionCS = NiloGetNewClipPosWithZOffset(output.positionCS, _OutlineZOffset + 0.03 * _IsFace);
    }
    else
    {
        //---------------! ! ! IMPORTANT:This Mode Only Working In Game Model ! ! !-----------------//
        float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, GetSmoothNormalWS(input));
        viewNormal.z = -0.1f;
        viewNormal = normalize(viewNormal);

        float3 positionVS = mul(UNITY_MATRIX_MV, float4(input.positionOS.xyz, 1)).xyz;

        float offset = input.color.z * _OutlineOffset;
        float offsetZ = positionVS.z - offset * 0.01;
        offset = offsetZ / unity_CameraProjection[1].y;
        offset = abs(offset) / _OutlineScale;
        offset = 1 / rsqrt(offset);

        float outlineWidth = _OutlineScale * _OutlineWidth * input.color.w;
        offset = offset * outlineWidth;

        float3 viewDir = vertexPositionInput.positionWS - GetCurrentViewPosition();
        float dist = length(viewDir);

        dist = smoothstep(_OutlineExtdStart, _OutlineExtdMax, dist);

        dist = min(dist, 0.5);
        dist = dist + 1.0;
        offset = offset * dist;

        viewNormal = viewNormal * offset.xxx + float3(positionVS.xy, offsetZ);
        output.positionCS = TransformWViewToHClip(viewNormal);
        // Apply ZOffset(for face material)
        output.positionCS = NiloGetNewClipPosWithZOffset(output.positionCS, _OutlineZOffset + 0.03 * _IsFace);
    }

    output.baseUV = CombineAndTransformDualFaceUV(input.uv1, input.uv2, _Maps_ST);
    output.color = input.color;
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionWS = positionWS;
    output.normalWS = normalInputs.normalWS;

    output.fogFactor = ComputeFogFactor(vertexPositionInput.positionCS.z);

    return output;
}

half4 SampleCoolRampMapOutline(float2 uv)
{
    half4 color = 0;
    #if _AREA_HAIR
        color = SAMPLE_TEXTURE2D(_HairCoolRamp, sampler_HairCoolRamp, uv);
    #elif _AREA_UPPERBODY || _AREA_LOWERBODY
        color = SAMPLE_TEXTURE2D(_BodyCoolRamp, sampler_BodyCoolRamp, uv);
    #elif _AREA_FACE
        color = SAMPLE_TEXTURE2D(_BodyCoolRamp, sampler_BodyCoolRamp, uv);
    #endif

    return color;
}

half4 SampleWarmRampMapOutline(float2 uv)
{
    half4 color = 0;
    #if _AREA_HAIR
        color = SAMPLE_TEXTURE2D(_HairWarmRamp, sampler_HairWarmRamp, uv);
    #elif _AREA_UPPERBODY || _AREA_LOWERBODY
        color = SAMPLE_TEXTURE2D(_BodyWarmRamp, sampler_BodyWarmRamp, uv);
    #elif _AREA_FACE
        color = SAMPLE_TEXTURE2D(_BodyWarmRamp, sampler_BodyWarmRamp, uv);
    #endif

    return color;
}

half3 GetOutlineColor(half materialId, half3 mainColor, half DayTime)
{
    half3 color = 0;
    #if _USE_LUT_MAP && _USE_LUT_MAP_OUTLINE
        color = GetLUTMapOutlineColor(GetRampLineIndex(materialId)).rgb;
    #else
        half3 coolColor = SampleCoolRampMapOutline(float2(0, GetRampV(materialId))).rgb;
        half3 warmColor = SampleWarmRampMapOutline(float2(0, GetRampV(materialId))).rgb;
        color = mainColor * LerpRampColor(coolColor, warmColor, DayTime, _ShadowBoost);
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
    #ifndef _ENABLE_OUTLINE
        clip(-1.0);
    #endif
    
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    float3 lightDirectionWS = normalize(mainLight.direction);

    float4 mainTex = 0;
    float4 lightMap = 0;
    #if _AREA_HAIR
        {
            mainTex = SAMPLE_TEXTURE2D(_HairColorMap, sampler_HairColorMap, input.baseUV.xy);
            lightMap = SAMPLE_TEXTURE2D(_HairLightMap, sampler_HairLightMap, input.baseUV.xy);
        }
    #elif _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            #if _AREA_UPPERBODY
                mainTex = SAMPLE_TEXTURE2D(_UpperBodyColorMap, sampler_UpperBodyColorMap, input.baseUV.xy);
                lightMap = SAMPLE_TEXTURE2D(_UpperBodyLightMap, sampler_UpperBodyLightMap, input.baseUV.xy);
            #elif _AREA_LOWERBODY
                mainTex = SAMPLE_TEXTURE2D(_LowerBodyColorMap, sampler_LowerBodyColorMap, input.baseUV.xy);
                lightMap = SAMPLE_TEXTURE2D(_LowerBodyLightMap, sampler_LowerBodyLightMap, input.baseUV.xy);
            #endif
        }
    #elif _AREA_FACE
        {
            mainTex = SAMPLE_TEXTURE2D(_FaceColorMap, sampler_FaceColorMap, input.baseUV.xy);
            lightMap = float4(1, 1, 1, 1);
        }
    #endif

    half DayTime = 0;
    #if _DayTime_MANUAL_ON
        DayTime = _DayTime;
    #else
        DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    #endif
    
    float4 FinalOutlineColor = float4(GetOutlineColor(lightMap.a, mainTex.rgb, DayTime), 1.0);
    FinalOutlineColor.rgb = MixFog(FinalOutlineColor.rgb, input.fogFactor);
    DoClipTestToTargetAlphaValue(mainTex.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);

    return FinalOutlineColor;
}

void CharacterOutlinePassFragment(
CharOutlineVaryings input,
out float4 colorTarget      : SV_Target0)
{
    float4 outputColor = colorFragmentTarget(input);

    colorTarget = float4(outputColor.rgb, 1);
}