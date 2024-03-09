#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"


///////////////////////////////////////////////////////////////////////////////////////
// CBUFFER and Uniforms 
// (you should put all uniforms of all passes inside this single UnityPerMaterial CBUFFER! else SRP batching is not possible!)
///////////////////////////////////////////////////////////////////////////////////////

// all sampler2D don't need to put inside CBUFFER 
sampler2D _OutlineZOffsetMaskTex;

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

// put all your uniforms(usually things inside .shader file's properties{}) inside this CBUFFER, in order to make SRP batcher compatible
// see -> https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/
CBUFFER_START(UnityPerMaterial);
float3 _HeadForward;
float3 _HeadRight;

//sampler2D _BaseMap;
float4 _BaseMap_ST;


// MainTex
//sampler2D _FaceColorMap;
float4 _FaceColorMapColor;
//sampler2D _HairColorMap;
float4 _HairColorMapColor;
//sampler2D _UpperBodyColorMap;
float4 _UpperBodyColorMapColor;
//sampler2D _LowerBodyColorMap;
float4 _LowerBodyColorMapColor;

// ColorPower
float _BaseColorRPower;
float _BaseColorGPower;
float _BaseColorBPower;

// FaceTintColor
float3 _FrontFaceTintColor;
float3 _BackFaceTintColor;


// Alpha
float _Alpha;
float _AlphaClip;


// LightMap
//sampler2D _HairLightMap;
//sampler2D _UpperBodyLightMap;
//sampler2D _LowerBodyLightMap;


// DayTime
float _DayTime;


// RampColor
//sampler2D _HairCoolRamp;
//sampler2D _HairWarmRamp;
float3 _HairCoolRampColor;
float3 _HairWarmRampColor;
float _HairCoolRampColorMixFactor;
float _HairWarmRampColorMixFactor;

//sampler2D _BodyCoolRamp;
//sampler2D _BodyWarmRamp;
float3 _BodyCoolRampColor;
float3 _BodyWarmRampColor;
float _BodyCoolRampColorMixFactor;
float _BodyWarmRampColorMixFactor;


// Lighting
float _IndirectLightFlattenNormal;
float _IndirectLightUsage;
float _IndirectLightOcclusionUsage;
float _IndirectLightMixBaseColor;

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
//sampler2D _UpperBodyStockings;
//sampler2D _LowerBodyStockings;
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
float _RimLightMixMainLightColor;
float _RimLightMixAlbedo;

// Emission
float _EmissionMixBaseColor;
float3 _EmissionTintColor;
float _EmissionIntensity;


// Outline
float   _IsFace;
float   _OutlineZOffset;
float   _OutlineZOffsetMaskRemapStart;
float   _OutlineZOffsetMaskRemapEnd;
float3  _OutlineColor;
float _OutlineWidth;
float _OutlineGamma;


// Bloom
float _mBloomIntensity0;
float4 _BloomColor0;

CBUFFER_END
