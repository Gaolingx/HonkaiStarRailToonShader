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
float4 _RimColor;
float _RimWidth;
float _RimDark;
float _RimEdgeSoftness;
float4 _RimColor0;
float _RimWidth0;
float _RimDark0;
float _RimEdgeSoftness0;
float4 _RimColor1;
float _RimWidth1;
float _RimDark1;
float _RimEdgeSoftness1;
float4 _RimColor2;
float _RimWidth2;
float _RimDark2;
float _RimEdgeSoftness2;
float4 _RimColor3;
float _RimWidth3;
float _RimDark3;
float _RimEdgeSoftness3;
float4 _RimColor4;
float _RimWidth4;
float _RimDark4;
float _RimEdgeSoftness4;
float4 _RimColor5;
float _RimWidth5;
float _RimDark5;
float _RimEdgeSoftness5;
float4 _RimColor6;
float _RimWidth6;
float _RimDark6;
float _RimEdgeSoftness6;
float4 _RimColor7;
float _RimWidth7;
float _RimDark7;
float _RimEdgeSoftness7;


// RimShadow
float _RimShadowCt;
float _RimShadowIntensity;
float4 _RimShadowOffset;
float4 _RimShadowColor;
float4 _RimShadowColor0;
float4 _RimShadowColor1;
float4 _RimShadowColor2;
float4 _RimShadowColor3;
float4 _RimShadowColor4;
float4 _RimShadowColor5;
float4 _RimShadowColor6;
float4 _RimShadowColor7;
float _RimShadowWidth;
float _RimShadowWidth0;
float _RimShadowWidth1;
float _RimShadowWidth2;
float _RimShadowWidth3;
float _RimShadowWidth4;
float _RimShadowWidth5;
float _RimShadowWidth6;
float _RimShadowWidth7;
float _RimShadowFeather;
float _RimShadowFeather0;
float _RimShadowFeather1;
float _RimShadowFeather2;
float _RimShadowFeather3;
float _RimShadowFeather4;
float _RimShadowFeather5;
float _RimShadowFeather6;
float _RimShadowFeather7;

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
float _IsFace;
float _OutlineZOffset;


// Bloom
float _mmBloomIntensity0;
float4 _BloomColor0;

CBUFFER_END
