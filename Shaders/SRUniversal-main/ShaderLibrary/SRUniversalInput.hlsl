#ifndef _SR_UNIVERSAL_INPUT_INCLUDED
#define _SR_UNIVERSAL_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
TEXTURE2D(_BodyColorMap);
SAMPLER(sampler_BodyColorMap);

TEXTURE2D(_HairLightMap);
SAMPLER(sampler_HairLightMap);
TEXTURE2D(_BodyLightMap);
SAMPLER(sampler_BodyLightMap);

TEXTURE2D(_HairCoolRamp);
SAMPLER(sampler_HairCoolRamp);
TEXTURE2D(_HairWarmRamp);
SAMPLER(sampler_HairWarmRamp);
TEXTURE2D(_BodyCoolRamp);
SAMPLER(sampler_BodyCoolRamp);
TEXTURE2D(_BodyWarmRamp);
SAMPLER(sampler_BodyWarmRamp);

TEXTURE2D(_StockRangeTex);
SAMPLER(sampler_StockRangeTex);

TEXTURE2D(_MaterialValuesPackLUT);
SAMPLER(sampler_MaterialValuesPackLUT);

// put all your uniforms(usually things inside .shader file's properties{}) inside this CBUFFER, in order to make SRP batcher compatible
// see -> https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/
CBUFFER_START(UnityPerMaterial);
float4 _MMDHeadBoneForward;
float4 _MMDHeadBoneUp;
float4 _MMDHeadBoneRight;

float4 _BaseMap_ST;

float4 _Maps_ST;

// MainTex
float4 _FaceColorMapColor;
float4 _HairColorMapColor;
float4 _BodyColorMapColor;


// NormalMap
float _BumpFactor;

// Self Shadow Caster
float _SelfShadowDepthBias;
float _SelfShadowNormalBias;


// ColorSaturation
float _ColorSaturation;

// FaceTintColor
float4 _FrontFaceTintColor;
float4 _BackFaceTintColor;


// Alpha
float _Alpha;
float _AlphaTestThreshold;


// DitherAlpha
float _DitherAlpha;


// Transparent Fron Hair
float _HairBlendAlpha;
float _MaxEyeHairDistance;


// Front Hair Shadow
float _HairShadowDistance;


// Setting
float _SingleMaterial;
float _RampV0;
float _RampV1;
float _RampV2;
float _RampV3;
float _RampV4;
float _RampV5;
float _RampV6;
float _RampV7;


// DayTime
float _DayTime_MANUAL_ON;
float _DayTime;


// RampColor
float _WarmShadowMultColorFac0;
float _WarmShadowMultColorFac1;
float _WarmShadowMultColorFac2;
float _WarmShadowMultColorFac3;
float _WarmShadowMultColorFac4;
float _WarmShadowMultColorFac5;
float _WarmShadowMultColorFac6;
float _WarmShadowMultColorFac7;

float _CoolShadowMultColorFac0;
float _CoolShadowMultColorFac1;
float _CoolShadowMultColorFac2;
float _CoolShadowMultColorFac3;
float _CoolShadowMultColorFac4;
float _CoolShadowMultColorFac5;
float _CoolShadowMultColorFac6;
float _CoolShadowMultColorFac7;

float4 _WarmShadowMultColor0;
float4 _WarmShadowMultColor1;
float4 _WarmShadowMultColor2;
float4 _WarmShadowMultColor3;
float4 _WarmShadowMultColor4;
float4 _WarmShadowMultColor5;
float4 _WarmShadowMultColor6;
float4 _WarmShadowMultColor7;

float4 _CoolShadowMultColor0;
float4 _CoolShadowMultColor1;
float4 _CoolShadowMultColor2;
float4 _CoolShadowMultColor3;
float4 _CoolShadowMultColor4;
float4 _CoolShadowMultColor5;
float4 _CoolShadowMultColor6;
float4 _CoolShadowMultColor7;


// Lighting
float _IndirectLightFlattenNormal;
float _IndirectLightIntensity;
float _IndirectLightUsage;


float _AutoBrightnessThresholdMin;
float _AutoBrightnessThresholdMax;
float _BrightnessOffset;
float _MainLightBrightnessFactor;
float _LerpAOIntensity;
float _MainLightColorUsage;
float _ShadowThresholdCenter;
float _MainLightShadowOffset;
float _ShadowThresholdSoftness;
float _ShadowRampOffset;
float _ShadowBoost;


// Additional Light
float _AdditionalLightIntensity;


// FaceShadow
float _FaceShadowOffset;
float _FaceShadowTransitionSoftness;


// Nose Line
float4 _NoseLineColor;
float _NoseLinePower;


// Expression
float4 _ExCheekColor;
float _ExCheekIntensity;
float4 _ExShyColor;
float _ExShyIntensity;
float4 _ExShadowColor;
float4 _ExEyeColor;
float _ExShadowIntensity;


// Specular
float4 _SpecularColor;
float4 _SpecularColor0;
float4 _SpecularColor1;
float4 _SpecularColor2;
float4 _SpecularColor3;
float4 _SpecularColor4;
float4 _SpecularColor5;
float4 _SpecularColor6;
float4 _SpecularColor7;

float _SpecularShininess;
float _SpecularShininess0;
float _SpecularShininess1;
float _SpecularShininess2;
float _SpecularShininess3;
float _SpecularShininess4;
float _SpecularShininess5;
float _SpecularShininess6;
float _SpecularShininess7;

float _SpecularRoughness;
float _SpecularRoughness0;
float _SpecularRoughness1;
float _SpecularRoughness2;
float _SpecularRoughness3;
float _SpecularRoughness4;
float _SpecularRoughness5;
float _SpecularRoughness6;
float _SpecularRoughness7;

float _SpecularIntensity;
float _SpecularIntensity0;
float _SpecularIntensity1;
float _SpecularIntensity2;
float _SpecularIntensity3;
float _SpecularIntensity4;
float _SpecularIntensity5;
float _SpecularIntensity6;
float _SpecularIntensity7;


// Stockings
float4 _StockRangeTex_ST;
float4 _Stockcolor;
float4 _StockDarkcolor;
float _StockTransparency;
float _StockDarkWidth;
float _Stockpower;
float _Stockpower1;
float _StockSP;
float _StockRoughness;
float _Stockthickness;


// RimLight
float _ModelScale;
float _RimIntensity;
float _RimIntensityBackFace;
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
float4 _EmissionTintColor;
float _EmissionIntensity;
float _EmissionThreshold;
float _EmissionMixBaseColorFac;


// Outline
float _EnableOutline;
float4 _OutlineDefaultColor;
float4 _OutlineColor;
float4 _OutlineColor0;
float4 _OutlineColor1;
float4 _OutlineColor2;
float4 _OutlineColor3;
float4 _OutlineColor4;
float4 _OutlineColor5;
float4 _OutlineColor6;
float4 _OutlineColor7;

float _FaceMaterial;
float _OutlineWidth;
float _OutlineScale;

// Bloom
float _BloomIntensity;
float _mmBloomIntensity0;
float _mmBloomIntensity1;
float _mmBloomIntensity2;
float _mmBloomIntensity3;
float _mmBloomIntensity4;
float _mmBloomIntensity5;
float _mmBloomIntensity6;
float _mmBloomIntensity7;

float4 _BloomColor;
float4 _BloomColor0;
float4 _BloomColor1;
float4 _BloomColor2;
float4 _BloomColor3;
float4 _BloomColor4;
float4 _BloomColor5;
float4 _BloomColor6;
float4 _BloomColor7;

float _PerObjShadowCasterId;

CBUFFER_END

#endif
