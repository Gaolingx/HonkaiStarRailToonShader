#include "../ShaderLibrary/SRUniversalLibrary.hlsl"

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


            float3 outline_normal;
            outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, GetSmoothNormalWS(input).xyz);
            outline_normal.z = -1;
            outline_normal.xyz = normalize(outline_normal.xyz);
            float4 wv_pos = mul(UNITY_MATRIX_MV, input.positionOS);
            float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
            if(!_EnableFOVWidth) fov_width = 1;
            wv_pos.xyz = wv_pos.xyz + (outline_normal * fov_width * tmp0.x);
            output.positionCS = mul(UNITY_MATRIX_P, wv_pos);
        }
        else
        {
            float3 outline_normal;
            outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, GetSmoothNormalWS(input).xyz);
            outline_normal.z = -1;
            outline_normal.xyz = normalize(outline_normal.xyz);
            float4 wv_pos = mul(UNITY_MATRIX_MV, input.positionOS);
            float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
            if(!_EnableFOVWidth)fov_width = 1;
            wv_pos.xyz = wv_pos.xyz + (outline_normal * fov_width * (input.color.w * _OutlineWidth * _OutlineScale));
            output.positionCS = mul(UNITY_MATRIX_P, wv_pos);
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
    #ifndef _OUTLINE_ON
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

    float DayTime = 0;
    if (_DayTime_MANUAL_ON)
    {
        DayTime = _DayTime;
    }
    else
    {
        DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    }
    
    float alpha = _Alpha;
    float4 FinalOutlineColor = float4(GetOutlineColor(lightMap.a, mainTex.rgb, DayTime), alpha);

    DoClipTestToTargetAlphaValue(FinalOutlineColor.a, _AlphaTestThreshold);
    DoDitherAlphaEffect(input.positionCS, _DitherAlpha);

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