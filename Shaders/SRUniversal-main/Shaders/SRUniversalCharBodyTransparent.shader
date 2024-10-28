Shader "HonkaiStarRailToon/Character/Body (Transparent)"
{
    Properties
    {
        [HideInInspector] [KeywordEnum(None, Face, Hair, Body)] _Area("Material area", Float) = 3
        [HideInInspector] _MMDHeadBoneForward("", Float) = (0, 0, 0, 0)
        [HideInInspector] _MMDHeadBoneUp("", Float) = (0, 0, 0, 0)
        [HideInInspector] _MMDHeadBoneRight("", Float) = (0, 0, 0, 0)

        [Header(Base Color)]
        [HideinInspector] _BaseMap("", 2D) = "white" { }
        [NoScaleOffset] _FaceColorMap("Face color map (Default white)", 2D) = "white" { }
        [HDR] _FaceColorMapColor("Face color map color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _HairColorMap("Hair color map (Default white)", 2D) = "white" { }
        [HDR] _HairColorMapColor("Hair color map color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _BodyColorMap("Body color map (Default white)", 2D) = "white" { }
        [HDR] _BodyColorMapColor("Body color map color (Default white)", Color) = (1, 1, 1, 1)
        _ColorSaturation("Base color saturation Adjust (Default 1)", Range(0, 3)) = 1
        _FrontFaceTintColor("Front face tint color (Default white)", Color) = (1, 1, 1, 1)
        _BackFaceTintColor("Back face tint color (Default white)", Color) = (1, 1, 1, 1)
        [Toggle(_BACKFACEUV2_ON)] _UseBackFaceUV2("Use Back Face UV2 (Default NO)", Float) = 0

        [Header(TextureScale Offset)]
        [TextureScaleOffset] _Maps_ST("Maps Scale Offset", Vector) = (1, 1, 0, 0)

        [Header(Alpha Test)]
        [Toggle(_ALPHATEST_ON)] _UseAlphaClipping("Use alpha clipping (Default NO)", Float) = 0
        _Alpha("Alpha (Default 1)", Range(0, 1)) = 1
        _AlphaTestThreshold("Alpha clip (Default 0.1)", Range(0, 1)) = 0.1

        [Header(Dither Alpha)]
        _DitherAlpha("Dither alpha (Default 1)", Range(0, 1)) = 1

        [Header(Transparent Fron Hair)]
        _HairBlendAlpha("Hair Blend Alpha (Default 0.6)", Range(0, 1)) = 0.6
        _MaxEyeHairDistance("Max Eye Hair Distance (Default 0.2)", Float) = 0.2

        [Header(Front Hair Shadow)]
        _HairShadowDistance("Hair Shadow Distance (Default 0.2)", Range(0, 1)) = 0.2

        [Header(Head Bone)]
        [KeywordEnum(Default, Game, MMD)] _CustomHeadBoneModeVarEnum("Custom Head Bone State", Float) = 1

        [Header(Light Map)]
        [NoScaleOffset] _HairLightMap("Hair light map (Default black)", 2D) = "black" { }
        [NoScaleOffset] _BodyLightMap("Body light map (Default black)", 2D) = "black" { }

        [Header(Ramp Map)]
        [NoScaleOffset] _HairCoolRamp("Hair cool ramp (Default white)", 2D) = "white" { }
        [NoScaleOffset] _HairWarmRamp("Hair warm ramp (Default white)", 2D) = "white" { }
        [NoScaleOffset] _BodyCoolRamp("Body cool ramp (Default white)", 2D) = "white" { }
        [NoScaleOffset] _BodyWarmRamp("Body warm ramp (Default white)", 2D) = "white" { }

        [Header(Ramp Color Mix)]
        [Toggle] _DayTime_MANUAL_ON("Use Day Time Manual (Default NO)", Float) = 0
        _DayTime("Day Time value (Default 12)", Range(0, 24)) = 12

        [Header(Ramp Color Tint)]
        _WarmShadowMultColorFac0("Warm Shadow Mult Color Factor 0", Range(0, 1)) = 0
        _WarmShadowMultColorFac1("Warm Shadow Mult Color Factor 1", Range(0, 1)) = 0
        _WarmShadowMultColorFac2("Warm Shadow Mult Color Factor 2", Range(0, 1)) = 0
        _WarmShadowMultColorFac3("Warm Shadow Mult Color Factor 3", Range(0, 1)) = 0
        _WarmShadowMultColorFac4("Warm Shadow Mult Color Factor 4", Range(0, 1)) = 0
        _WarmShadowMultColorFac5("Warm Shadow Mult Color Factor 5", Range(0, 1)) = 0
        _WarmShadowMultColorFac6("Warm Shadow Mult Color Factor 6", Range(0, 1)) = 0
        _WarmShadowMultColorFac7("Warm Shadow Mult Color Factor 7", Range(0, 1)) = 0

        _CoolShadowMultColorFac0("Cool Shadow Mult Color Factor 0", Range(0, 1)) = 0
        _CoolShadowMultColorFac1("Cool Shadow Mult Color Factor 1", Range(0, 1)) = 0
        _CoolShadowMultColorFac2("Cool Shadow Mult Color Factor 2", Range(0, 1)) = 0
        _CoolShadowMultColorFac3("Cool Shadow Mult Color Factor 3", Range(0, 1)) = 0
        _CoolShadowMultColorFac4("Cool Shadow Mult Color Factor 4", Range(0, 1)) = 0
        _CoolShadowMultColorFac5("Cool Shadow Mult Color Factor 5", Range(0, 1)) = 0
        _CoolShadowMultColorFac6("Cool Shadow Mult Color Factor 6", Range(0, 1)) = 0
        _CoolShadowMultColorFac7("Cool Shadow Mult Color Factor 7", Range(0, 1)) = 0

        _WarmShadowMultColor0("Warm Shadow Mult Color 0", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor1("Warm Shadow Mult Color 1", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor2("Warm Shadow Mult Color 2", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor3("Warm Shadow Mult Color 3", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor4("Warm Shadow Mult Color 4", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor5("Warm Shadow Mult Color 5", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor6("Warm Shadow Mult Color 6", Color) = (1, 1, 1, 1)
        _WarmShadowMultColor7("Warm Shadow Mult Color 7", Color) = (1, 1, 1, 1)

        _CoolShadowMultColor0("Cool Shadow Mult Color 0", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor1("Cool Shadow Mult Color 1", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor2("Cool Shadow Mult Color 2", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor3("Cool Shadow Mult Color 3", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor4("Cool Shadow Mult Color 4", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor5("Cool Shadow Mult Color 5", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor6("Cool Shadow Mult Color 6", Color) = (1, 1, 1, 1)
        _CoolShadowMultColor7("Cool Shadow Mult Color 7", Color) = (1, 1, 1, 1)

        [Header(LutMap)]
        [Toggle(_USE_LUT_MAP)] _UseLutMapToggle("Use LUT Map (Default NO)", Float) = 0
        [NoScaleOffset] _MaterialValuesPackLUT("LUT Map (Default black)", 2D) = "black" { }

        [Header(Normal)]
        [Toggle(_NORMAL_MAP_ON)] _UseNormalMap("Use Normal Map (Default NO)", Float) = 0
        _BumpFactor("Bump Scale (Default 1)", Float) = 1.0
        [Normal] _NormalMap("Normal Map (Default black)", 2D) = "bump" { }

        [Header(Self Shadow Caster)]
        _SelfShadowDepthBias("Self Shadow Depth Bias", Float) = -0.01
        _SelfShadowNormalBias("Self Shadow Normal Bias", Float) = 0

        [Header(Ramp Settings)]
        [Toggle(_CUSTOM_RAMP_MAPPING_ON)] _CustomRampMappingToggle("Use Custom ramp mapping (Default YES)", Float) = 1
        [Toggle] _SingleMaterial("Is Single Material (Use Ramp Line of Mat0)", Float) = 0
        [IntRange] _RampV0("Ramp Line of Mat0 (Default 0)", Range(0, 7)) = 0
        [IntRange] _RampV1("Ramp Line of Mat1 (Default 1)", Range(0, 7)) = 1
        [IntRange] _RampV2("Ramp Line of Mat2 (Default 2)", Range(0, 7)) = 2
        [IntRange] _RampV3("Ramp Line of Mat3 (Default 3)", Range(0, 7)) = 3
        [IntRange] _RampV4("Ramp Line of Mat4 (Default 4)", Range(0, 7)) = 4
        [IntRange] _RampV5("Ramp Line of Mat5 (Default 5)", Range(0, 7)) = 5
        [IntRange] _RampV6("Ramp Line of Mat6 (Default 6)", Range(0, 7)) = 6
        [IntRange] _RampV7("Ramp Line of Mat7 (Default 7)", Range(0, 7)) = 7

        [Header(Indirect Lighting)]
        _IndirectLightFlattenNormal("Indirect light flatten normal (Default 0)", Range(0, 1)) = 0
        _IndirectLightIntensity("Indirect light intensity (Default 1)", Range(0, 2)) = 1
        _IndirectLightUsage("Indirect light color usage (Default 0.5)", Range(0, 1)) = 0.5

        [Header(Main Lighting)]
        [Toggle(_AUTO_Brightness_ON)] _UseAutoBrightness("Use Auto Brightness (Default Yes)", Float) = 1
        _AutoBrightnessThresholdMin("Auto Brightness Threshold Min (Default 0.5)", Float) = 0.5
        _AutoBrightnessThresholdMax("Auto Brightness Threshold Max (Default 1.0)", Float) = 1.0
        _BrightnessOffset("Auto Brightness Offset (Default 0)", Float) = 0
        _MainLightBrightnessFactor("Main light brightness factor (Default 1)", Range(0, 1)) = 1
        _MainLightColorUsage("Main light color usage (Default 1)", Range(0, 1)) = 1
        _MainLightShadowOffset("Main light shadow offset (Default 0)", Range(-1, 1)) = 0
        _LerpAOIntensity("Lerp AO Intensity (Default 1)", Range(0, 1)) = 0
        _ShadowThresholdCenter("Shadow threshold center (Default 0)", Range(-1, 1)) = 0
        _ShadowThresholdSoftness("Shadow threshold softness (Default 0.1)", Range(0, 1)) = 0.1
        _ShadowRampOffset("Shadow ramp offset (Default 0.75)", Range(0, 1)) = 0.75
        _ShadowBoost("Shadow Boost (Default 1)", Range(0, 1)) = 1.0

        [Header(Additional Lighting)]
        [Toggle(_AdditionalLighting_ON)] _UseAdditionalLighting("Use Additional Lighting (Default NO)", Float) = 0
        _AdditionalLightIntensity("Additional Light Intensity (Default 1)", Float) = 1.0

        [Header(Face Lighting)]
        [NoScaleOffset] _FaceMap("Face map (Default black)", 2D) = "black" { }
        [NoScaleOffset] _ExpressionMap("Expression Map (Default white)", 2D) = "white" { }
        _FaceShadowOffset("Face shadow offset (Default -0.01)", Range(-1, 1)) = 0
        _FaceShadowTransitionSoftness("Face shadow transition softness (Default 0.05)", Range(0, 1)) = 0.05

        [Header(Nose Line)]
        _NoseLineColor("Nose Line Color", Color) = (1, 0.635, 0.635, 1)
        _NoseLinePower("Nose Line Power", Range(0, 8)) = 1

        [Header(Expression)]
        _ExCheekColor("Cheek Color (Default white)", Color) = (1, 1, 1, 1)
        _ExCheekIntensity("Cheek Intensity (Default 0)", Range(0, 1)) = 0
        _ExShyColor("Shy Color (Default white)", Color) = (1, 1, 1, 1)
        _ExShyIntensity("Shy Intensity (Default 0)", Range(0, 1)) = 0
        _ExShadowColor("Face Shadow Color (Default white)", Color) = (1, 1, 1, 1)
        _ExShadowIntensity("Face Shadow Intensity (Default 0)", Range(0, 1)) = 0
        _ExEyeColor("Eye Color (Default white)", Color) = (1, 1, 1, 1)
        _ExEyeShadowIntensity("Eye Shadow Intensity (Default 0)", Range(0, 1)) = 0

        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular("Enable Specular (Default YES)", Float) = 1
        [Toggle(_ANISOTROPY_SPECULAR_ON)] _AnisotropySpecularToggle("Is Anisotropy Specular (Default NO)", Float) = 0
        [KeywordEnum(Disable, Tint, Overlay)] _CustomSpecularColorVarEnum("Custom Specular Color State", Float) = 0
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularColor0("Specular Color 0", Color) = (1, 1, 1, 1)
        _SpecularColor1("Specular Color 1", Color) = (1, 1, 1, 1)
        _SpecularColor2("Specular Color 2", Color) = (1, 1, 1, 1)
        _SpecularColor3("Specular Color 3", Color) = (1, 1, 1, 1)
        _SpecularColor4("Specular Color 4", Color) = (1, 1, 1, 1)
        _SpecularColor5("Specular Color 5", Color) = (1, 1, 1, 1)
        _SpecularColor6("Specular Color 6", Color) = (1, 1, 1, 1)
        _SpecularColor7("Specular Color 7", Color) = (1, 1, 1, 1)
        [KeywordEnum(Disable, Multiply, Overlay)] _CustomSpecularVarEnum("Custom Specular Var State", Float) = 0
        _SpecularShininess("Specular Shininess", Float) = 10
        _SpecularShininess0("Specular Shininess 0", Range(0.1, 500)) = 10
        _SpecularShininess1("Specular Shininess 1", Range(0.1, 500)) = 10
        _SpecularShininess2("Specular Shininess 2", Range(0.1, 500)) = 10
        _SpecularShininess3("Specular Shininess 3", Range(0.1, 500)) = 10
        _SpecularShininess4("Specular Shininess 4", Range(0.1, 500)) = 10
        _SpecularShininess5("Specular Shininess 5", Range(0.1, 500)) = 10
        _SpecularShininess6("Specular Shininess 6", Range(0.1, 500)) = 10
        _SpecularShininess7("Specular Shininess 7", Range(0.1, 500)) = 10
        _SpecularIntensity("Specular Intensity", Float) = 1
        _SpecularIntensity0("Specular Intensity 0", Range(0, 100)) = 1
        _SpecularIntensity1("Specular Intensity 1", Range(0, 100)) = 1
        _SpecularIntensity2("Specular Intensity 2", Range(0, 100)) = 1
        _SpecularIntensity3("Specular Intensity 3", Range(0, 100)) = 1
        _SpecularIntensity4("Specular Intensity 4", Range(0, 100)) = 1
        _SpecularIntensity5("Specular Intensity 5", Range(0, 100)) = 1
        _SpecularIntensity6("Specular Intensity 6", Range(0, 100)) = 1
        _SpecularIntensity7("Specular Intensity 7", Range(0, 100)) = 1
        _SpecularRoughness("Specular Roughness", Float) = 0.02
        _SpecularRoughness0("Specular Roughness 0", Range(0, 1)) = 0.02
        _SpecularRoughness1("Specular Roughness 1", Range(0, 1)) = 0.02
        _SpecularRoughness2("Specular Roughness 2", Range(0, 1)) = 0.02
        _SpecularRoughness3("Specular Roughness 3", Range(0, 1)) = 0.02
        _SpecularRoughness4("Specular Roughness 4", Range(0, 1)) = 0.02
        _SpecularRoughness5("Specular Roughness 5", Range(0, 1)) = 0.02
        _SpecularRoughness6("Specular Roughness 6", Range(0, 1)) = 0.02
        _SpecularRoughness7("Specular Roughness 7", Range(0, 1)) = 0.02

        [Header(Stockings)]
        [Toggle(_STOCKINGS_ON)] _UseStockings("Use Stockings (Default NO)", Float) = 0
        [HideInInspector] m_start_stockings("Stockings", Float) = 0
        _StockRangeTex ("Stocking Range Texture", 2D) = "black" {}
        _Stockcolor ("Stocking Color", Color) = (1, 1, 1, 1)
        _StockDarkcolor ("Stocking Darkened Color", Color) = (1, 1, 1, 1)
        _Stockpower ("Stockings Power", Range(0.04, 1)) = 1
        _StockDarkWidth ("Stockings Rim Width", Range(0, 0.96)) = 0.5
        _StockSP ("Stockings Lighted Intensity", Range(0, 1)) = 0.25
        //_StockTransparency ("Stockings Transparency", Range(0, 1)) = 0
        _StockRoughness ("Stockings Texture Intensity", Range(0, 1)) = 1
        _Stockpower1 ("Stockings Lighted Width", Range(1, 32)) = 1
        // _Stockthickness ("Stockings Thickness", Range(0, 1)) = 0
        [HideInInspector] m_end_stockings("", Float) = 0

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)", Float) = 1
        _RimIntensity("Rim Intensity (Front Face)", Float) = 0.5
        _RimIntensityBackFace("Rim Intensity (Back Face)", Float) = 0
        [KeywordEnum(Disable, Tint, Overlay)] _CustomRimLightColorVarEnum("Custom Rim Light Color State", Float) = 0
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimColor0("Rim Color 0", Color) = (1, 1, 1, 1)
        _RimColor1("Rim Color 1", Color) = (1, 1, 1, 1)
        _RimColor2("Rim Color 2", Color) = (1, 1, 1, 1)
        _RimColor3("Rim Color 3", Color) = (1, 1, 1, 1)
        _RimColor4("Rim Color 4", Color) = (1, 1, 1, 1)
        _RimColor5("Rim Color 5", Color) = (1, 1, 1, 1)
        _RimColor6("Rim Color 6", Color) = (1, 1, 1, 1)
        _RimColor7("Rim Color 7", Color) = (1, 1, 1, 1)
        [KeywordEnum(Disable, Multiply, Overlay)] _CustomRimLightVarEnum("Custom Rim Light Var State", Float) = 0
        _RimWidth("Rim Width", Float) = 1
        _RimWidth0("Rim Width 0", Float) = 1
        _RimWidth1("Rim Width 1", Float) = 1
        _RimWidth2("Rim Width 2", Float) = 1
        _RimWidth3("Rim Width 3", Float) = 1
        _RimWidth4("Rim Width 4", Float) = 1
        _RimWidth5("Rim Width 5", Float) = 1
        _RimWidth6("Rim Width 6", Float) = 1
        _RimWidth7("Rim Width 7", Float) = 1
        _RimDark("Rim Darken Value", Range(0, 1)) = 0.5
        _RimDark0("Rim Darken Value 0", Range(0, 1)) = 0.5
        _RimDark1("Rim Darken Value 1", Range(0, 1)) = 0.5
        _RimDark2("Rim Darken Value 2", Range(0, 1)) = 0.5
        _RimDark3("Rim Darken Value 3", Range(0, 1)) = 0.5
        _RimDark4("Rim Darken Value 4", Range(0, 1)) = 0.5
        _RimDark5("Rim Darken Value 5", Range(0, 1)) = 0.5
        _RimDark6("Rim Darken Value 6", Range(0, 1)) = 0.5
        _RimDark7("Rim Darken Value 7", Range(0, 1)) = 0.5
        _RimEdgeSoftness("Rim Edge Softness", Float) = 0.05
        _RimEdgeSoftness0("Rim Edge Softness 0", Float) = 0.05
        _RimEdgeSoftness1("Rim Edge Softness 1", Float) = 0.05
        _RimEdgeSoftness2("Rim Edge Softness 2", Float) = 0.05
        _RimEdgeSoftness3("Rim Edge Softness 3", Float) = 0.05
        _RimEdgeSoftness4("Rim Edge Softness 4", Float) = 0.05
        _RimEdgeSoftness5("Rim Edge Softness 5", Float) = 0.05
        _RimEdgeSoftness6("Rim Edge Softness 6", Float) = 0.05
        _RimEdgeSoftness7("Rim Edge Softness 7", Float) = 0.05

        [Header(Rim Shadow)]
        [Toggle(_RIM_SHADOW_ON)] _UseRimShadow("Use Rim Shadow (Default NO)", Float) = 0
        _RimShadowCt("Rim Shadow Ct", Float) = 1
        _RimShadowIntensity("Rim Shadow Intensity", Float) = 1
        _RimShadowOffset("Rim Shadow Offset", Vector) = (0, 0, 0, 0)
        [KeywordEnum(Disable, Tint, Overlay)] _CustomRimShadowColorVarEnum("Custom Rim Shadow Color State", Float) = 0
        _RimShadowColor("Rim Shadow Color", Color) = (1, 1, 1, 1)
        _RimShadowColor0("Rim Shadow Color 0", Color) = (1, 1, 1, 1)
        _RimShadowColor1("Rim Shadow Color 1", Color) = (1, 1, 1, 1)
        _RimShadowColor2("Rim Shadow Color 2", Color) = (1, 1, 1, 1)
        _RimShadowColor3("Rim Shadow Color 3", Color) = (1, 1, 1, 1)
        _RimShadowColor4("Rim Shadow Color 4", Color) = (1, 1, 1, 1)
        _RimShadowColor5("Rim Shadow Color 5", Color) = (1, 1, 1, 1)
        _RimShadowColor6("Rim Shadow Color 6", Color) = (1, 1, 1, 1)
        _RimShadowColor7("Rim Shadow Color 7", Color) = (1, 1, 1, 1)
        [KeywordEnum(Disable, Multiply, Overlay)] _CustomRimShadowVarEnum("Custom Rim Shadow Var State", Float) = 0
        _RimShadowWidth("Rim Shadow Width", Float) = 1
        _RimShadowWidth0("Rim Shadow Width 0", Float) = 1
        _RimShadowWidth1("Rim Shadow Width 1", Float) = 1
        _RimShadowWidth2("Rim Shadow Width 2", Float) = 1
        _RimShadowWidth3("Rim Shadow Width 3", Float) = 1
        _RimShadowWidth4("Rim Shadow Width 4", Float) = 1
        _RimShadowWidth5("Rim Shadow Width 5", Float) = 1
        _RimShadowWidth6("Rim Shadow Width 6", Float) = 1
        _RimShadowWidth7("Rim Shadow Width 7", Float) = 1
        _RimShadowFeather("Rim Shadow Feather", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather0("Rim Shadow Feather 0", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather1("Rim Shadow Feather 1", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather2("Rim Shadow Feather 2", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather3("Rim Shadow Feather 3", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather4("Rim Shadow Feather 4", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather5("Rim Shadow Feather 5", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather6("Rim Shadow Feather 6", Range(0.01, 0.99)) = 0.01
        _RimShadowFeather7("Rim Shadow Feather 7", Range(0.01, 0.99)) = 0.01

        [Header(Bloom)]
        [KeywordEnum(Disable, Tint, Overlay)] _CustomBloomColorVarEnum("Custom Bloom Color State", Float) = 0
        _BloomColor("Bloom Color", Color) = (1, 1, 1, 1)
        _BloomColor0("Bloom Color 0", Color) = (1, 1, 1, 1)
        _BloomColor1("Bloom Color 1", Color) = (1, 1, 1, 1)
        _BloomColor2("Bloom Color 2", Color) = (1, 1, 1, 1)
        _BloomColor3("Bloom Color 3", Color) = (1, 1, 1, 1)
        _BloomColor4("Bloom Color 4", Color) = (1, 1, 1, 1)
        _BloomColor5("Bloom Color 5", Color) = (1, 1, 1, 1)
        _BloomColor6("Bloom Color 6", Color) = (1, 1, 1, 1)
        _BloomColor7("Bloom Color 7", Color) = (1, 1, 1, 1)
        [KeywordEnum(Disable, Multiply, Overlay)] _CustomBloomVarEnum("Custom Bloom Intensity State", Float) = 0
        _BloomIntensity("Bloom Intensity", Float) = 0
        _mmBloomIntensity0("Bloom Intensity 0", Float) = 0
        _mmBloomIntensity1("Bloom Intensity 1", Float) = 0
        _mmBloomIntensity2("Bloom Intensity 2", Float) = 0
        _mmBloomIntensity3("Bloom Intensity 3", Float) = 0
        _mmBloomIntensity4("Bloom Intensity 4", Float) = 0
        _mmBloomIntensity5("Bloom Intensity 5", Float) = 0
        _mmBloomIntensity6("Bloom Intensity 6", Float) = 0
        _mmBloomIntensity7("Bloom Intensity 7", Float) = 0

        [Header(Emission)]
        [Toggle(_EMISSION_ON)] _UseEmission("Use emission (Default NO)", Float) = 0
        _EmissionMixBaseColorFac("Emission mix base color factor (Default 1)", Range(0, 1)) = 1
        _EmissionTintColor("Emission tint color (Default white)", Color) = (1, 1, 1, 1)
        _EmissionIntensity("Emission intensity (Default 1)", Range(0, 10)) = 1
        _EmissionThreshold("Emission threshold (Default 0.5)", Range(0, 1)) = 0.5

        [Header(Outline)]
        [Toggle] _EnableOutline("Enable Outline (Default YES)", Float) = 1
        [KeywordEnum(Normal, Tangent, UV2)] _OutlineNormalChannel("Outline Normal Channel", Float) = 0
        _OutlineDefaultColor("Outline Default Color", Color) = (0.5, 0.5, 0.5, 1)
        [Toggle(_USE_LUT_MAP_OUTLINE)] _OutlineUseLutMapToggle("Outline Use LUT Map (Default NO)", Float) = 0
        [KeywordEnum(Disable, Multiply, Tint, Overlay, Custom)] _CustomOutlineVarEnum("Custom Outline Var State", Float) = 0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineColor0("Outline Color 0", Color) = (0, 0, 0, 1)
        _OutlineColor1("Outline Color 1", Color) = (0, 0, 0, 1)
        _OutlineColor2("Outline Color 2", Color) = (0, 0, 0, 1)
        _OutlineColor3("Outline Color 3", Color) = (0, 0, 0, 1)
        _OutlineColor4("Outline Color 4", Color) = (0, 0, 0, 1)
        _OutlineColor5("Outline Color 5", Color) = (0, 0, 0, 1)
        _OutlineColor6("Outline Color 6", Color) = (0, 0, 0, 1)
        _OutlineColor7("Outline Color 7", Color) = (0, 0, 0, 1)

        [Toggle] _FaceMaterial("Is Face Material Outline", Float) = 0
        _OutlineWidth("OutlineWidth (World Space)", Range(0, 1)) = 0.1
        _OutlineScale("OutlineScale (Default 0.001)", Float) = 0.001
        _OutlineDistanceAdjust("Outline Distance Adjust", Vector) = (1, 1, 1, 1)
        _OutlineScaleAdjust("Outline Scale Adjust", Vector) = (1, 1, 1, 1)
        _OutlineZOffset("Outline Z Offset", Float) = 0
        _ScreenOffset("Screen Offset", Vector) = (0, 0, 0, 0)

        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode (Default Back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColor("Core Pass src blend mode color (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColor("Core Pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlpha("Core Pass src blend mode alpha (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlpha("Core Pass dst blend mode alpha (Default Zero)", Float) = 0

        [HideInInspector] _ModelScale("Model Scale (Default 1)", Float) = 1
        [HideInInspector] _PerObjShadowCasterId("Per Object Shadow Caster Id", Float) = -1

    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "ComplexLit" // Packages/com.unity.render-pipelines.universal/Runtime/Passes/GBufferPass.cs: Fill GBuffer, but skip lighting pass for ComplexLit
            "Queue" = "Transparent"
        }

        HLSLINCLUDE

        #pragma shader_feature_local _AREA_FACE _AREA_HAIR _AREA_BODY
        #pragma shader_feature_local _ALPHATEST_ON
        #pragma shader_feature_local _BACKFACEUV2_ON
        #pragma shader_feature_local _AUTO_Brightness_ON
        #pragma shader_feature_local _CUSTOM_RAMP_MAPPING_ON
        #pragma shader_feature_local_fragment _NORMAL_MAP_ON
        #pragma shader_feature_local _SPECULAR_ON
        #pragma shader_feature_local _STOCKINGS_ON
        #pragma shader_feature_local _RIM_LIGHTING_ON
        #pragma shader_feature_local _RIM_SHADOW_ON
        #pragma shader_feature_local _USE_LUT_MAP
        #pragma shader_feature_local _USE_LUT_MAP_OUTLINE
        #pragma shader_feature_local _CUSTOMHEADBONEMODEVARENUM_DEFAULT _CUSTOMHEADBONEMODEVARENUM_GAME _CUSTOMHEADBONEMODEVARENUM_MMD
        #pragma shader_feature_local _CUSTOMSPECULARCOLORVARENUM_DISABLE _CUSTOMSPECULARCOLORVARENUM_TINT _CUSTOMSPECULARCOLORVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMSPECULARVARENUM_DISABLE _CUSTOMSPECULARVARENUM_MULTIPLY _CUSTOMSPECULARVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMRIMLIGHTCOLORVARENUM_DISABLE _CUSTOMRIMLIGHTCOLORVARENUM_TINT _CUSTOMRIMLIGHTCOLORVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMRIMLIGHTVARENUM_DISABLE _CUSTOMRIMLIGHTVARENUM_MULTIPLY _CUSTOMRIMLIGHTVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMRIMSHADOWCOLORVARENUM_DISABLE _CUSTOMRIMSHADOWCOLORVARENUM_TINT _CUSTOMRIMSHADOWCOLORVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMRIMSHADOWVARENUM_DISABLE _CUSTOMRIMSHADOWVARENUM_MULTIPLY _CUSTOMRIMSHADOWVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMBLOOMVARENUM_DISABLE _CUSTOMBLOOMVARENUM_MULTIPLY _CUSTOMBLOOMVARENUM_OVERLAY
        #pragma shader_feature_local _CUSTOMBLOOMCOLORVARENUM_DISABLE _CUSTOMBLOOMCOLORVARENUM_TINT _CUSTOMBLOOMCOLORVARENUM_OVERLAY
        #pragma shader_feature_local _OUTLINENORMALCHANNEL_NORMAL _OUTLINENORMALCHANNEL_TANGENT _OUTLINENORMALCHANNEL_UV2
        #pragma shader_feature_local _CUSTOMOUTLINEVARENUM_DISABLE _CUSTOMOUTLINEVARENUM_MULTIPLY _CUSTOMOUTLINEVARENUM_TINT _CUSTOMOUTLINEVARENUM_OVERLAY _CUSTOMOUTLINEVARENUM_CUSTOM
        #pragma shader_feature_local _OUTLINE_VERTEX_COLOR_SMOOTH_NORMAL
        #pragma shader_feature_local _EMISSION_ON
        #pragma shader_feature_local _AdditionalLighting_ON

        ENDHLSL

        Pass
        {
            Name "SRCharBodyTransparent"

            Tags
            {
                "LightMode" = "HSRTransparent"
            }

            // 透明部分和角色的 Stencil
            Stencil
            {
                Ref 5
                WriteMask 5  // 透明和角色位
                Comp Always
                Pass Replace // 写入透明和角色位
                Fail Keep
            }

            Cull [_CullMode]
            ZWrite On

            Blend 0 [_SrcBlendModeColor] [_DstBlendModeColor], [_SrcBlendModeAlpha] [_DstBlendModeAlpha]

            ColorMask RGBA 0

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex SRUniversalCharVertex
            #pragma fragment SRUniversalCharCoreFragment

            #pragma multi_compile_fog

            #pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SELF_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "SRCharBodyTransparentOutline"

            Tags
            {
                "LightMode" = "HSROutline"
            }

            Cull Front // Cull Front is a must for extra pass outline method
            ZTest LEqual
            ZWrite On

            ColorMask RGBA 0

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex CharacterOutlinePassVertex
            #pragma fragment CharacterOutlinePassFragment

            #pragma multi_compile_fog

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawOutline.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "SRCharBodyTransparentPerObjectShadow"

            Tags
            {
                "LightMode" = "HSRPerObjectShadowCaster"
            }

            Cull [_CullMode]
            ZWrite On
            ZTest LEqual

            ColorMask 0

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex CharacterShadowVertex
            #pragma fragment CharacterShadowFragment

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_vertex _ _CASTING_SELF_SHADOW

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }
        // Because of Transparent, no Depth, GBuffer and Motion Vectors

    }
    Fallback Off
}
