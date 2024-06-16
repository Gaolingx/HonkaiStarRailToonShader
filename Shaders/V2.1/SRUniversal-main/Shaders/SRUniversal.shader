Shader "Custom/SRUniversal"
{
    Properties
    {
        [KeywordEnum(None, Face, Hair, UpperBody, LowerBody)] _Area("Material area", Float) = 0
        [HideInInspector] _MMDHeadBoneForward("", Float) = (0, 0, 0, 0)
        [HideInInspector] _MMDHeadBoneUp("", Float) = (0, 0, 0, 0)
        [HideInInspector] _MMDHeadBoneRight("", Float) = (0, 0, 0, 0)

        [Header(Base Color)]
        [HideinInspector] _BaseMap("", 2D) = "white" { }
        [NoScaleOffset] _FaceColorMap("Face color map (Default white)", 2D) = "white" { }
        [HDR] _FaceColorMapColor("Face color map color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _HairColorMap("Hair color map (Default white)", 2D) = "white" { }
        [HDR] _HairColorMapColor("Hair color map color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _UpperBodyColorMap("Upper body color map (Default white)", 2D) = "white" { }
        [HDR] _UpperBodyColorMapColor("Upper body color map color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _LowerBodyColorMap("Lower body color map (Default white)", 2D) = "white" { }
        [HDR] _LowerBodyColorMapColor("Lower body color map color (Default white)", Color) = (1, 1, 1, 1)
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

        [Header(Head Bone)]
        [KeywordEnum(Default, Game, MMD)] _CustomHeadBoneModeVarEnum("Custom Specular Color State", Float) = 1

        [Header(Light Map)]
        [NoScaleOffset] _HairLightMap("Hair light map (Default black)", 2D) = "black" { }
        [NoScaleOffset] _UpperBodyLightMap("Upper body map (Default black)", 2D) = "black" { }
        [NoScaleOffset] _LowerBodyLightMap("Lower body map (Default black)", 2D) = "black" { }

        [Header(Ramp Map)]
        [NoScaleOffset] _HairCoolRamp("Hair cool ramp (Default white)", 2D) = "white" { }
        _HairCoolRampColorMixFactor("Hair cool ramp color mix factor (Default 0)", Range(0, 1)) = 0
        _HairCoolRampColor("Hair cool ramp color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _HairWarmRamp("Hair warm ramp (Default white)", 2D) = "white" { }
        _HairWarmRampColorMixFactor("Hair warm ramp color mix factor (Default 0)", Range(0, 1)) = 0
        _HairWarmRampColor("Hair warm ramp color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _BodyCoolRamp("Body cool ramp (Default white)", 2D) = "white" { }
        _BodyCoolRampColorMixFactor("Body cool ramp color mix factor (Default 0)", Range(0, 1)) = 0
        _BodyCoolRampColor("Body cool ramp color (Default white)", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _BodyWarmRamp("Body warm ramp (Default white)", 2D) = "white" { }
        _BodyWarmRampColorMixFactor("Body warm ramp color mix factor (Default 0)", Range(0, 1)) = 0
        _BodyWarmRampColor("Body warm ramp color (Default white)", Color) = (1, 1, 1, 1)
        [Toggle(_DayTime_MANUAL_ON)] _DayTimeManualON("Use Day Time Manual (Default NO)", Float) = 0
        _DayTime("Day Time value (Default 12)", Range(0, 24)) = 12

        [Header(LutMap)]
        [Toggle(_USE_LUT_MAP)] _UseLutMapToggle("Use LUT Map (Default NO)", Float) = 0
        _MaterialValuesPackLUT("LUT Map (Default black)", 2D) = "black" { }

        [Header(Normal)]
        [Toggle(_USE_NORMAL_MAP)] _UseNormalMap("Use Normal Map (Default NO)", Float) = 0
        _BumpFactor("Bump Scale", Float) = 1.0
        [Normal] _NormalMap("Normal Map (Default black)", 2D) = "bump" { }

        [Header(Ramp Settings)][Space]
        [Toggle(_CUSTOM_RAMP_MAPPING)] _CustomRampMappingToggle("Use Custom ramp mapping (Default YES)", Float) = 1
        [ToggleUI] _SingleMaterial("Is Single Material (Use Ramp Line of Mat0)", Float) = 0
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
        [Toggle(_AUTO_Brightness_ON)] _UseAutoBrightness("Use Auto Brightness (Default NO)", Float) = 0
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
        _ShadowBoost("Shadow Boost (Default 1)", Range(0.0, 1.0)) = 1.0

        [Header(Additional Lighting)]
        [Toggle(_AdditionalLighting_ON)] _UseAdditionalLighting("Use Additional Lighting (Default NO)", Float) = 0

        [Header(Face)]
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
        _ExShadowColor("Shadow Color (Default white)", Color) = (1, 1, 1, 1)
        _ExEyeColor("Eye Color (Default white)", Color) = (1, 1, 1, 1)
        _ExShadowIntensity("Shadow Intensity (Default 0)", Range(0, 1)) = 0

        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular("Enable Specular (Default YES)", Float) = 1
        [Toggle(_ANISOTROPY_SPECULAR)] _AnisotropySpecularToggle("Is Anisotropy Specular (Default NO)", Float) = 0
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
        _UpperBodyStockings("Upper body stockings (Default black)", 2D) = "black" { }
        _LowerBodyStockings("Lower body stockings (Default black)", 2D) = "black" { }
        _stockingsMapBChannelUVScale("Stockings texture channel B UV Scale (Default 20)", Range(1, 50)) = 20
        _StockingsDarkColor("Stockings dark color (Default black)", Color) = (0, 0, 0, 1)
        [HDR] _StockingsLightColor("Stockings light color (Default 1.8, 1.48299, 0.856821)", Color) = (1.8, 1.48299, 0.856821)
        _StockingsTransitionColor("Stockings transition color (Default 0.360381, 0.242986, 0.358131)", Color) = (0.360381, 0.242986, 0.358131)
        _StockingsTransitionThreshold("Stockings transition threshold (Default 0.58)", Range(0, 1)) = 0.58
        _StockingsTransitionPower("Stockings transition power (Default 1)", Range(0, 50)) = 1
        _StockingsTransitionHardness("Stockings transition hardness (Default 0.4)", Range(0, 1)) = 0.4
        _StockingsTextureUsage("Stockings texture usage (Default 0.1)", Range(0, 1)) = 0.1

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)", Float) = 1
        _ModelScale("Model Scale (Default 1)", Float) = 1
        _RimIntensity("Rim Intensity (Front Face)", Float) = 0.5
        _RimIntensityBackFace("Rim Intensity (Back Face)", Float) = 0
        [KeywordEnum(Disable, Tint, Overlay)] _CustomRimLightColorVarEnum("Custom Rim Light Color State", Float) = 0
        [KeywordEnum(Disable, Multiply, Overlay)] _CustomRimLightVarEnum("Custom Rim Light Var State", Float) = 0
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth("Rim Width", Float) = 1
        _RimDark("Rim Darken Value", Range(0, 1)) = 0.5
        _RimEdgeSoftness("Rim Edge Softness", Float) = 0.05
        _RimColor0("Rim Color 0", Color) = (1, 1, 1, 1)
        _RimWidth0("Rim Width 0", Float) = 1
        _RimDark0("Rim Darken Value 0", Range(0, 1)) = 0.5
        _RimEdgeSoftness0("Rim Edge Softness 0", Float) = 0.05
        _RimColor1("Rim Color 1", Color) = (1, 1, 1, 1)
        _RimWidth1("Rim Width 1", Float) = 1
        _RimDark1("Rim Darken Value 1", Range(0, 1)) = 0.5
        _RimEdgeSoftness1("Rim Edge Softness 1", Float) = 0.05
        _RimColor2("Rim Color 2", Color) = (1, 1, 1, 1)
        _RimWidth2("Rim Width 2", Float) = 1
        _RimDark2("Rim Darken Value 2", Range(0, 1)) = 0.5
        _RimEdgeSoftness2("Rim Edge Softness 2", Float) = 0.05
        _RimColor3("Rim Color 3", Color) = (1, 1, 1, 1)
        _RimWidth3("Rim Width 3", Float) = 1
        _RimDark3("Rim Darken Value 3", Range(0, 1)) = 0.5
        _RimEdgeSoftness3("Rim Edge Softness 3", Float) = 0.05
        _RimColor4("Rim Color 4", Color) = (1, 1, 1, 1)
        _RimWidth4("Rim Width 4", Float) = 1
        _RimDark4("Rim Darken Value 4", Range(0, 1)) = 0.5
        _RimEdgeSoftness4("Rim Edge Softness 4", Float) = 0.05
        _RimColor5("Rim Color 5", Color) = (1, 1, 1, 1)
        _RimWidth5("Rim Width 5", Float) = 1
        _RimDark5("Rim Darken Value 5", Range(0, 1)) = 0.5
        _RimEdgeSoftness5("Rim Edge Softness 5", Float) = 0.05
        _RimColor6("Rim Color 6", Color) = (1, 1, 1, 1)
        _RimWidth6("Rim Width 6", Float) = 1
        _RimDark6("Rim Darken Value 6", Range(0, 1)) = 0.5
        _RimEdgeSoftness6("Rim Edge Softness 6", Float) = 0.05
        _RimColor7("Rim Color 7", Color) = (1, 1, 1, 1)
        _RimWidth7("Rim Width 7", Float) = 1
        _RimDark7("Rim Darken Value 7", Range(0, 1)) = 0.5
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
        [Toggle(_ENABLE_OUTLINE)] _EnableOutlineToggle("Enable Outline (Default YES)", Float) = 1
        [ToggleUI] _UseSelfOutline("Outline Mode (Use Model Self Outline Setting)", Float) = 0
        [KeywordEnum(Normal, Tangent)] _OutlineNormalChannel("Outline Normal Channel", Float) = 0
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
        _OutlineWidth("Outline Width", Range(0, 0.1)) = 0.01
        _OutlineExtdStart("Outline Extd Start", Range(0, 10)) = 6.5
        _OutlineExtdMax("Outline Extd Max", Range(0, 30)) = 18.0
        _OutlineScale("Outline Scale", Range(0, 1)) = 0.015
        _OutlineOffset("Outline Offset", Range(0, 10)) = 0
        [ToggleUI] _IsFace("Use Clip Pos With ZOffset (face material)", Float) = 0
        _OutlineZOffset("_OutlineZOffset (View Space)", Range(0, 1)) = 0.0001

        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode (Default Back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColor("Core Pass src blend mode color (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColor("Core Pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlpha("Core Pass src blend mode alpha (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlpha("Core Pass dst blend mode alpha (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("BlendOp (Default Add)", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite (Default On)", Float) = 1
        _StencilRef("Stencil reference (Default 0)", Range(0, 255)) = 0
        _StencilReadMask("Stencil Read Mask (Default 255)", Range(0, 255)) = 255
        _StencilWriteMask("Stencil Write Mask (Default 255)", Range(0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil comparison (Default disabled)", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil pass comparison (Default keep)", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil fail comparison (Default keep)", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil z fail comparison (Default keep)", Int) = 0

        [Header(Draw Overlay)]
        [Toggle(_DRAW_OVERLAY_ON)] _UseDrawOverlay("Use draw overlay (Default NO)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColorOverlay("Overlay Pass src blend mode color (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColorOverlay("Overlay Pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlphaOverlay("Overlay Pass src blend mode alpha (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlphaOverlay("Overlay Pass dst blend mode alpha (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOpOverlay("Overlay Pass blend operation (Default Add)", Float) = 0
        _StencilRefOverlay("Overlay Pass stencil reference (Default 0)", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompOverlay("Overlay Pass stencil comparison (Default disabled)", Int) = 0

    }
    SubShader
    {
        LOD 100
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "ComplexLit"
        }

        HLSLINCLUDE
        #pragma shader_feature_local _AREA_FACE
        #pragma shader_feature_local _AREA_HAIR
        #pragma shader_feature_local _AREA_UPPERBODY
        #pragma shader_feature_local _AREA_LOWERBODY
        #pragma shader_feature_local _DayTime_MANUAL_ON
        #pragma shader_feature_local _AUTO_Brightness_ON
        #pragma shader_feature_local_fragment _USE_NORMAL_MAP
        #pragma shader_feature_local _CUSTOM_RAMP_MAPPING
        #pragma shader_feature_local _SPECULAR_ON
        #pragma shader_feature_local _STOCKINGS_ON
        #pragma shader_feature_local _RIM_LIGHTING_ON
        #pragma shader_feature_local _RIM_SHADOW_ON
        #pragma shader_feature _USE_LUT_MAP
        #pragma shader_feature _USE_LUT_MAP_OUTLINE
        #pragma shader_feature _CUSTOMHEADBONEMODEVARENUM_DEFAULT _CUSTOMHEADBONEMODEVARENUM_GAME _CUSTOMHEADBONEMODEVARENUM_MMD
        #pragma shader_feature _CUSTOMSPECULARCOLORVARENUM_DISABLE _CUSTOMSPECULARCOLORVARENUM_TINT _CUSTOMSPECULARCOLORVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMSPECULARVARENUM_DISABLE _CUSTOMSPECULARVARENUM_MULTIPLY _CUSTOMSPECULARVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMRIMLIGHTCOLORVARENUM_DISABLE _CUSTOMRIMLIGHTCOLORVARENUM_TINT _CUSTOMRIMLIGHTCOLORVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMRIMLIGHTVARENUM_DISABLE _CUSTOMRIMLIGHTVARENUM_MULTIPLY _CUSTOMRIMLIGHTVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMRIMSHADOWCOLORVARENUM_DISABLE _CUSTOMRIMSHADOWCOLORVARENUM_TINT _CUSTOMRIMSHADOWCOLORVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMRIMSHADOWVARENUM_DISABLE _CUSTOMRIMSHADOWVARENUM_MULTIPLY _CUSTOMRIMSHADOWVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMBLOOMVARENUM_DISABLE _CUSTOMBLOOMVARENUM_MULTIPLY _CUSTOMBLOOMVARENUM_OVERLAY
        #pragma shader_feature _CUSTOMBLOOMCOLORVARENUM_DISABLE _CUSTOMBLOOMCOLORVARENUM_TINT _CUSTOMBLOOMCOLORVARENUM_OVERLAY
        #pragma shader_feature _OUTLINENORMALCHANNEL_NORMAL _OUTLINENORMALCHANNEL_TANGENT
        #pragma shader_feature _CUSTOMOUTLINEVARENUM_DISABLE _CUSTOMOUTLINEVARENUM_MULTIPLY _CUSTOMOUTLINEVARENUM_TINT _CUSTOMOUTLINEVARENUM_OVERLAY _CUSTOMOUTLINEVARENUM_CUSTOM
        #pragma shader_feature_local _OUTLINE_VERTEX_COLOR_SMOOTH_NORMAL
        #pragma shader_feature_local _ENABLE_OUTLINE
        #pragma shader_feature_local _DRAW_OVERLAY_ON
        #pragma shader_feature_local _EMISSION_ON
        #pragma shader_feature_local _AdditionalLighting_ON

        ENDHLSL

        Pass
        {
            Name "CharDrawCore"
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "HSRForward2"
            }
            Cull [_CullMode]
            Stencil{
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
            }
            Blend [_SrcBlendModeColor] [_DstBlendModeColor], [_SrcBlendModeAlpha] [_DstBlendModeAlpha]
            BlendOp [_BlendOp]
            ZWrite [_ZWrite]
            

            HLSLPROGRAM
            #pragma multi_compile_fog

            #pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ _LIGHT_LAYERS

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON

            #pragma vertex SRUniversalVertex
            #pragma fragment SRUniversalFragment

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "CharDrawOverlay"
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "HSRForward3"
            }
            Cull [_CullMode]
            Stencil{
                Ref [_StencilRefOverlay]
                Comp [_StencilCompOverlay]
            }
            Blend [_SrcBlendModeColorOverlay] [_DstBlendModeColorOverlay], [_SrcBlendModeAlphaOverlay] [_DstBlendModeAlphaOverlay]
            BlendOp [_BlendOpOverlay]
            ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma multi_compile_fog

            #pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ _LIGHT_LAYERS

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON

            #pragma vertex SRUniversalVertex
            #pragma fragment SRUniversalFragment

            #if _DRAW_OVERLAY_ON
                #include "../ShaderLibrary/SRUniversalInput.hlsl"
                #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"
            #else
                struct Attributes {};
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                };
                Varyings SRUniversalVertex(Attributes input)
                {
                    return (Varyings)0;
                }
                float4 SRUniversalFragment(Varyings input) : SV_TARGET
                {
                    return 0;
                }
            #endif

            ENDHLSL
        }

        Pass 
        {
            Name "CharDrawOutline"
            Tags 
            {
                "RenderType" = "Opaque"
                "LightMode" = "HSROutline"

            }

            Cull Front // Cull Front is a must for extra pass outline method
            ZWrite [_ZWrite]

            HLSLPROGRAM

            // Direct copy all keywords from "ForwardLit" pass
            // ---------------------------------------------------------------------------------------------
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            // ---------------------------------------------------------------------------------------------
            #pragma multi_compile_fog
            // ---------------------------------------------------------------------------------------------

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON
            
            #pragma vertex CharacterOutlinePassVertex
            #pragma fragment CharacterOutlinePassFragment

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawOutline.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "PerObjectShadow"

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

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "CharDepthOnly"

            Tags
            {
                "LightMode" = "DepthOnly"
            }

            Cull [_CullMode]
            ZWrite On
            ColorMask R

            HLSLPROGRAM

            #pragma vertex CharacterDepthOnlyVertex
            #pragma fragment CharacterDepthOnlyFragment

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "CharDepthNormals"

            Tags
            {
                "LightMode" = "DepthNormals"
            }

            Cull [_CullMode]
            ZWrite On

            HLSLPROGRAM

            #pragma vertex CharacterDepthNormalsVertex
            #pragma fragment CharacterDepthNormalsFragment

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "CharMotionVectors"

            Tags
            {
                "LightMode" = "MotionVectors"
            }

            Cull [_CullMode]

            HLSLPROGRAM

            #pragma vertex CharacterMotionVectorsVertex
            #pragma fragment CharacterMotionVectorsFragment

            #pragma exclude_renderers d3d11_9x
            #pragma target 3.5

            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

    }
    Fallback Off
}
