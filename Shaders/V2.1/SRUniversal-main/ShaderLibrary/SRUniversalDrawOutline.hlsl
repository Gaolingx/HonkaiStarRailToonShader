
struct CharOutlineAttributes
{
    float3 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float4 color        : COLOR;
    float2 baseUV       : TEXCOORD0;
    float2 addUV        : TEXCOORD1;
    float2 packSmoothNormal : TEXCOORD2;
};

struct CharOutlineVaryings
{
    float4 positionCS : SV_POSITION;
    float3 positionVS : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float4 positionNDC : TEXCOORD2;
    float2 baseUV : TEXCOORD3;
    float2 addUV : TEXCOORD4;
    half3 color : TEXCOORD5;
    half3 normalWS : TEXCOORD6;
    half3 tangentWS : TEXCOORD7;
    half3 bitangentWS : TEXCOORD8;

    half3 sh : TEXCOORD9;

    float2 packSmoothNormal : TEXCOORD10;
    float4 positionCSNoJitter : TEXCOORD11;
    float4 previousPositionCSNoJitter : TEXCOORD12;
    float fogFactor : TEXCOORD13;
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

float CalculateExtendWidthWS(float3 positionWS, float3 extendVectorWS, float extendWS, float minExtendSS, float maxExtendSS)
{
    float4 positionCS = TransformWorldToHClip(positionWS);
    float4 extendPositionCS = TransformWorldToHClip(positionWS + extendVectorWS * extendWS);

    float2 delta = extendPositionCS.xy / extendPositionCS.w - positionCS.xy / positionCS.w;
    delta *= GetScaledScreenParams().xy / GetScaledScreenParams().y * 1080.0f;

    const float extendLen = length(delta);
    float width = extendWS * min(1.0, maxExtendSS / extendLen) * max(1.0, minExtendSS / extendLen);

    return width;
}

float3 ExtendOutline(float3 positionWS, float3 smoothNormalWS, float width, float widthMin, float widthMax)
{
    float offsetLen = CalculateExtendWidthWS(positionWS, smoothNormalWS, width, widthMin, widthMax);

    return positionWS + smoothNormalWS * offsetLen;
}

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold) 
{
#if _UseAlphaClipping
    clip(alpha - alphaTestThreshold);
#endif
}

CharOutlineVaryings CharacterOutlinePassVertex(CharOutlineAttributes input)
{
    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 smoothNormalWS = GetSmoothNormalWS(input);
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

    float outlineWidth = input.color.a;
    #if defined(_IS_FACE)
    outlineWidth *= lerp(1.0,
        saturate(0.4 - dot(_HeadForward.xz, normalize(GetCameraPositionWS() - positionWS).xz)), step(0.5, input.color.b));
    #endif
    
    positionWS = ExtendOutline(positionWS, smoothNormalWS,
        _OutlineWidth * outlineWidth, _OutlineWidthMin * outlineWidth, _OutlineWidthMax * outlineWidth);

    float3 positionVS = TransformWorldToView(positionWS);
    float4 positionCS = TransformWorldToHClip(positionWS);

    float4 positionNDC;
    float4 ndc = positionCS * 0.5f;
    positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    positionNDC.zw = positionCS.zw;

    CharOutlineVaryings output = (CharOutlineVaryings)0;
    output.positionCS = positionCS;
    output.positionVS = positionVS;
    output.positionWS = positionWS;
    output.positionNDC = positionNDC;
    output.baseUV = input.baseUV;
    output.color = input.color.rgb;
    output.normalWS = normalInput.normalWS;
    output.tangentWS = normalInput.tangentWS;
    output.bitangentWS = normalInput.bitangentWS;

    output.sh = 0;
    output.packSmoothNormal = input.packSmoothNormal;

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
                lightMap = SAMPLE_TEXTURE2D(_UpperBodyLightMap, sampler_UpperBodyLightMap, input.baseUV);
            #elif _AREA_LOWERBODY
                lightMap = SAMPLE_TEXTURE2D(_LowerBodyLightMap, sampler_LowerBodyLightMap, input.baseUV);
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

void CharacterOutlinePassFragment(
    CharOutlineVaryings input,
    out float4 colorTarget      : SV_Target0)
{
    float4 outputColor = colorFragmentTarget(input);

    colorTarget = float4(outputColor.rgb, 1);
}