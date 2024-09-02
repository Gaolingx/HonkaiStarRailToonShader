// For more information, visit -> https://github.com/ChillyHub/Unity_StarRail_CRP_Sample/blob/main/Assets/Unity_StarRail_CRP_Sample/Shaders/Character/HLSL/CharacterFunction.hlsl

#ifndef Include_NiloOutlineUtil
#define Include_NiloOutlineUtil

// Vertex Utils --------------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------------- //
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

#endif

