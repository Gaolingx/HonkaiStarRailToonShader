#include "../ShaderLibrary/SRUniversalLibrary.hlsl"
#include "../ShaderLibrary/NiloZOffset.hlsl"

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


CharOutlineVaryings CharacterOutlinePassVertex(CharOutlineAttributes input)
{
    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 smoothNormalWS = GetSmoothNormalWS(input);
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

    float outlineWidth = input.color.a;
    
    positionWS = ExtendOutline(positionWS, smoothNormalWS,
        _OutlineWidth * outlineWidth, _OutlineWidthMin * outlineWidth, _OutlineWidthMax * outlineWidth);

    float3 positionVS = TransformWorldToView(positionWS);
    float4 positionCS = TransformWorldToHClip(positionWS);

    #if defined(_IS_FACE)
    positionCS = NiloGetNewClipPosWithZOffset(positionCS, _OutlineZOffset + 0.03 * _IsFace);
    #endif

    CharOutlineVaryings output = (CharOutlineVaryings)0;
    output.positionCS = positionCS;
    output.positionVS = positionVS;
    output.positionWS = positionWS;
    //output.positionNDC = positionNDC;
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
        color = GetLUTMapOutlineColor(materialId).rgb;
    #else
        half3 coolColor = SampleCoolRampMapOutline(float2(0, GetRampV(materialId))).rgb;
        half3 warmColor = SampleWarmRampMapOutline(float2(0, GetRampV(materialId))).rgb;
        color = mainColor * LerpRampColor(coolColor, warmColor, DayTime);
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
        outlineColor = color * _OutlineColor;
    #elif _CUSTOMOUTLINEVARENUM_OVERLAY
        outlineColor = overlayColor;
    #elif _CUSTOMOUTLINEVARENUM_CUSTOM
        outlineColor = _OutlineDefaultColor;
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
            mainTex = SAMPLE_TEXTURE2D(_HairColorMap, sampler_HairColorMap, input.baseUV);
            lightMap = SAMPLE_TEXTURE2D(_HairLightMap, sampler_HairLightMap, input.baseUV);
        }
    #elif _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            #if _AREA_UPPERBODY
                mainTex = SAMPLE_TEXTURE2D(_UpperBodyColorMap, sampler_UpperBodyColorMap, input.baseUV);
                lightMap = SAMPLE_TEXTURE2D(_UpperBodyLightMap, sampler_UpperBodyLightMap, input.baseUV);
            #elif _AREA_LOWERBODY
                mainTex = SAMPLE_TEXTURE2D(_LowerBodyColorMap, sampler_LowerBodyColorMap, input.baseUV);
                lightMap = SAMPLE_TEXTURE2D(_LowerBodyLightMap, sampler_LowerBodyLightMap, input.baseUV);
            #endif
        }
    #elif _AREA_FACE
        {
            mainTex = SAMPLE_TEXTURE2D(_FaceColorMap, sampler_FaceColorMap, input.baseUV);
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