#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"


///////////////////////////////////////////////////////////////////////////////////////
// CBUFFER and Uniforms 
// (you should put all uniforms of all passes inside this single UnityPerMaterial CBUFFER! else SRP batching is not possible!)
///////////////////////////////////////////////////////////////////////////////////////

// all sampler2D don't need to put inside CBUFFER 

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);

TEXTURE2D(_FaceMap);
SAMPLER(sampler_FaceMap);
TEXTURE2D(_ExpressionMap);
SAMPLER(sampler_ExpressionMap);

TEXTURE2D(_FaceColorMap);
SAMPLER(sampler_FaceColorMap);
TEXTURE2D(_HairColorMap);
SAMPLER(sampler_HairColorMap);
TEXTURE2D(_UpperBodyColorMap);
SAMPLER(sampler_UpperBodyColorMap);
TEXTURE2D(_LowerBodyColorMap);
SAMPLER(sampler_LowerBodyColorMap);

TEXTURE2D(_HairLightMap);
SAMPLER(sampler_HairLightMap);
TEXTURE2D(_UpperBodyLightMap);
SAMPLER(sampler_UpperBodyLightMap);
TEXTURE2D(_LowerBodyLightMap);
SAMPLER(sampler_LowerBodyLightMap);

TEXTURE2D(_HairCoolRamp);
SAMPLER(sampler_HairCoolRamp);
TEXTURE2D(_HairWarmRamp);
SAMPLER(sampler_HairWarmRamp);
TEXTURE2D(_BodyCoolRamp);
SAMPLER(sampler_BodyCoolRamp);
TEXTURE2D(_BodyWarmRamp);
SAMPLER(sampler_BodyWarmRamp);

TEXTURE2D(_UpperBodyStockings);
SAMPLER(sampler_UpperBodyStockings);
TEXTURE2D(_LowerBodyStockings);
SAMPLER(sampler_LowerBodyStockings);

TEXTURE2D(_LUTMap);
SAMPLER(sampler_LUTMap);

// put all your uniforms(usually things inside .shader file's properties{}) inside this CBUFFER, in order to make SRP batcher compatible
// see -> https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/
CBUFFER_START(UnityPerMaterial);
float3 _HeadForward;
float3 _HeadRight;

float4 _BaseMap_ST;


// MainTex
float4 _FaceColorMapColor;
float4 _HairColorMapColor;
float4 _UpperBodyColorMapColor;
float4 _LowerBodyColorMapColor;

// ColorSaturation
float _ColorSaturation;

// FaceTintColor
float3 _FrontFaceTintColor;
float3 _BackFaceTintColor;


// Alpha
float _Alpha;
float _AlphaClip;


// Setting
float _RampV0;
float _RampV1;
float _RampV2;
float _RampV3;
float _RampV4;
float _RampV5;
float _RampV6;
float _RampV7;


// DayTime
float _DayTime;


// RampColor
float3 _HairCoolRampColor;
float3 _HairWarmRampColor;
float _HairCoolRampColorMixFactor;
float _HairWarmRampColorMixFactor;

float3 _BodyCoolRampColor;
float3 _BodyWarmRampColor;
float _BodyCoolRampColorMixFactor;
float _BodyWarmRampColorMixFactor;


// Lighting
float _IndirectLightFlattenNormal;
float _IndirectLightIntensity;
float _IndirectLightUsage;
float _IndirectLightOcclusionUsage;
float _IndirectLightMixBaseColor;


float _AutoBrightnessThresholdMin;
float _AutoBrightnessThresholdMax;
float _AutoBrightnessOffset;
float _MainLightBrightnessFactor;
float _LerpAOIntensity;
float _MainLightColorUsage;
float _ShadowThresholdCenter;
float _MainLightShadowOffset;
float _ShadowThresholdSoftness;
float _ShadowRampOffset;
float _ShadowBoost;


// FaceShadow
float _FaceShadowOffset;
float _FaceShadowTransitionSoftness;


// Expression
float4 _ExCheekColor;
float _ExCheekIntensity;
float4 _ExShyColor;
float _ExShyIntensity;
float4 _ExShadowColor;
float4 _ExEyeColor;
float _ExShadowIntensity;


// Specular
half3 _SpecularColor;
half _SpecularShininess;
half _SpecularRoughness;
half _SpecularIntensity;
half _SpecularKsNonMetal;
half _SpecularKsMetal;
half _MetalSpecularMetallic;


// Stockings
float _stockingsMapBChannelUVScale;
float3 _StockingsDarkColor;
float3 _StockingsLightColor;
float3 _StockingsTransitionColor;
float _StockingsTransitionThreshold;
float _StockingsTransitionPower;
float _StockingsTransitionHardness;
float _StockingsTextureUsage;


// RimLight
float _ModelScale;
float _RimIntensity;
float _RimIntensityBackFace;
float _RimThresholdMin;
float _RimThresholdMax;
float _RimEdgeSoftness;
float _RimWidth0;
float4 _RimColor0;
float _RimDark0;


// Emission
float _EmissionMixBaseColor;
float3 _EmissionTintColor;
float _EmissionIntensity;


// Outline
float4 _OutlineColor;
float4 _OutlineColor0;
float4 _OutlineColor1;
float4 _OutlineColor2;
float4 _OutlineColor3;
float4 _OutlineColor4;
float4 _OutlineColor5;
float4 _OutlineColor6;
float4 _OutlineColor7;
float _OutlineWidth;
float _OutlineWidthMin;
float _OutlineWidthMax;


// Bloom
float _mmBloomIntensity0;
float4 _BloomColor0;

CBUFFER_END
