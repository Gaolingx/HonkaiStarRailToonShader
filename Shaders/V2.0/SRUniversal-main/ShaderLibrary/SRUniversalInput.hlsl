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

// DayTime
float _DayTime;

TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_ExpressionMap);
SAMPLER(sampler_ExpressionMap);

// put all your uniforms(usually things inside .shader file's properties{}) inside this CBUFFER, in order to make SRP batcher compatible
// see -> https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/
CBUFFER_START(UnityPerMaterial);
float3 _HeadForward;
float3 _HeadRight;

sampler2D _BaseMap;
float4 _BaseMap_ST;


// MainTex
sampler2D _FaceColorMap;
float4 _FaceColorMapColor;
sampler2D _HairColorMap;
float4 _HairColorMapColor;
sampler2D _UpperBodyColorMap;
float4 _UpperBodyColorMapColor;
sampler2D _LowerBodyColorMap;
float4 _LowerBodyColorMapColor;


// FaceTintColor
float3 _FrontFaceTintColor;
float3 _BackFaceTintColor;


// Alpha
float _Alpha;
float _AlphaClip;


// LightMap
sampler2D _HairLightMap;
sampler2D _UpperBodyLightMap;
sampler2D _LowerBodyLightMap;


// RampColor
sampler2D _HairCoolRamp;
sampler2D _HairWarmRamp;
float3 _HairCoolRampColor;
float3 _HairWarmRampColor;
float _HairCoolRampColorMixFactor;
float _HairWarmRampColorMixFactor;

sampler2D _BodyCoolRamp;
sampler2D _BodyWarmRamp;
float3 _BodyCoolRampColor;
float3 _BodyWarmRampColor;
float _BodyCoolRampColorMixFactor;
float _BodyWarmRampColorMixFactor;


// Lighting
float _MainLightBrightnessFactor;
float _IndirectLightFlattenNormal;
float _IndirectLightUsage;
float _IndirectLightOcclusionUsage;
float _IndirectLightMixBaseColor;

float _MainLightColorUsage;
float _ShadowThresholdCenter;
float _ShadowThresholdSoftness;
float _ShadowRampOffset;
float _ShadowBoost;


// FaceShadow
sampler2D _FaceMap;
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
float _SpecularExpon;
float _SpecularKsNonMetal;
float _SpecularKsMetal;
float _MetalSpecularMetallic;
float3 _SpecularColor;
float _SpecularBrightness;


// Stockings
sampler2D _UpperBodyStockings;
sampler2D _LowerBodyStockings;
float3 _StockingsDarkColor;
float3 _StockingsLightColor;
float3 _StockingsTransitionColor;
float _StockingsTransitionThreshold;
float _StockingsTransitionPower;
float _StockingsTransitionHardness;
float _StockingsTextureUsage;


// RimLight
float _RimLightWidth;
float _RimLightThreshold;
float _RimLightFadeout;
float3 _RimLightTintColor;
float _RimLightBrightness;
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


float _BloomIntensity0;

CBUFFER_END
