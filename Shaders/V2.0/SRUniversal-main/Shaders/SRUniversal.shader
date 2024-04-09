Shader "Custom/SRUniversal"
{
    Properties
    {
        [KeywordEnum (None, Face, Hair, UpperBody, LowerBody)] _Area("Material area", float) = 0
        [HideInInspector] _HeadForward("", Vector) = (0,0,1)
        [HideInInspector] _HeadRight("", Vector) = (1,0,0)

        [Header (Base Color)]
        [HideinInspector] _BaseMap ("", 2D) = "white" {}
        [NoScaleOffset] _FaceColorMap ("Face color map (Default white)", 2D) = "white" {}
        [HDR] _FaceColorMapColor("Face color map color (Default white)",Color) = (1,1,1)
        [NoScaleOffset] _HairColorMap ("Hair color map (Default white)", 2D) = "white" {}
        [HDR] _HairColorMapColor("Hair color map color (Default white)",Color) = (1,1,1)
        [NoScaleOffset] _UpperBodyColorMap ("Upper body color map (Default white)", 2D) = "white" {}
        [HDR] _UpperBodyColorMapColor("Upper body color map color (Default white)",Color) = (1,1,1)
        [NoScaleOffset] _LowerBodyColorMap ("Lower body color map (Default white)", 2D) = "white" {}
        [HDR] _LowerBodyColorMapColor("Lower body color map color (Default white)",Color) = (1,1,1)
        _ColorSaturation("Base color saturation Adjust (Default 1)",Range(0,3)) = 1
        _FrontFaceTintColor("Front face tint color (Default white)",Color) = (1,1,1)
        _BackFaceTintColor("Back face tint color (Default white)",Color) = (1,1,1)
        [Toggle(_UseAlphaClipping)]_UseAlphaClipping("Use alpha clipping (Default NO)", Float) = 0
        _Alpha("Alpha (Default 1)", Range(0,1)) = 1
        _AlphaClip("Alpha clip (Default 0.333)", Range(0,1)) = 0.333

        [Header(Light Map)]
        [NoScaleOffset] _HairLightMap("Hair light map (Default black)",2D) = "black" {}
        [NoScaleOffset] _UpperBodyLightMap("Upper body map (Default black)",2D) = "black" {}
        [NoScaleOffset] _LowerBodyLightMap("Lower body map (Default black)",2D) = "black" {}

        [Header(Ramp Map)]
        [NoScaleOffset] _HairCoolRamp("Hair cool ramp (Default white)",2D) = "white" {}
        _HairCoolRampColorMixFactor("Hair cool ramp color mix factor (Default 0)",Range(0,1)) = 0
        _HairCoolRampColor("Hair cool ramp color (Default white)",Color) = (1,1,1)
        [NoScaleOffset] _HairWarmRamp("Hair warm ramp (Default white)",2D) = "white" {}
        _HairWarmRampColorMixFactor("Hair warm ramp color mix factor (Default 0)",Range(0,1)) = 0
        _HairWarmRampColor("Hair warm ramp color (Default white)",Color) = (1,1,1)
        [NoScaleOffset] _BodyCoolRamp("Body cool ramp (Default white)",2D) = "white" {}
        _BodyCoolRampColorMixFactor("Body cool ramp color mix factor (Default 0)",Range(0,1)) = 0
        _BodyCoolRampColor("Body cool ramp color (Default white)",Color) = (1,1,1)
        [NoScaleOffset] _BodyWarmRamp("Body warm ramp (Default white)",2D) = "white" {}
        _BodyWarmRampColorMixFactor("Body warm ramp color mix factor (Default 0)",Range(0,1)) = 0
        _BodyWarmRampColor("Body warm ramp color (Default white)",Color) = (1,1,1)
        [Toggle(_DayTime_MANUAL_ON)] _DayTimeManualON("Use Day Time Manual (Default NO)", float ) = 0
        _DayTime("Day Time value (Default 12)",Range(0,24)) = 12

        [Header(Normal)]
        [Toggle(_NORMAL_MAP_ON)] _UseNormalMap("Use Normal Map (Default NO)", float) = 0
        [Normal] _NormalMap("Normal Map", 2D) = "bump" {}

        [Header(Indirect Lighting)]
        _IndirectLightFlattenNormal("Indirect light flatten normal (Default 0)",Range(0,1)) = 0
        _IndirectLightIntensity("Indirect light intensity (Default 1)",Range(0,2)) = 1
        _IndirectLightUsage("Indirect light usage (Default 0.5)",Range(0,1)) = 0.5
        _IndirectLightOcclusionUsage("Indirect light occlusion usage (Default 0.5)",Range(0,1)) = 0.5
        _IndirectLightMixBaseColor("Indirect light mix base color (Default 1)",Range(0,1)) = 1

        [Header(Main Lighting)]
        [Toggle(_AUTO_Brightness_ON)] _UseAutoBrightness("Use Auto Brightness (Default NO)", float) = 0
        _AutoBrightnessThresholdMin("Auto Brightness Threshold Min (Default 0.5)", Float) = 0.5
        _AutoBrightnessThresholdMax("Auto Brightness Threshold Max (Default 1.0)", Float) = 1.0
        _AutoBrightnessOffset("Auto Brightness Offset (Default 0)",Range(-1,1)) = 0
        _MainLightBrightnessFactor("Main light brightness factor (Default 1)",Range(0,1)) = 1
        _MainLightColorUsage("Main light color usage (Default 1)",Range(0,1)) = 1
        _MainLightShadowOffset("Main light shadow offset (Default 0)",Range(-1,1)) = 0
        _LerpAOIntensity("Lerp AO Intensity (Default 1)",Range(0,1)) = 1
        _ShadowThresholdCenter("Shadow threshold center (Default 0)",Range(-1,1)) = 0
        _ShadowThresholdSoftness("Shadow threshold softness (Default 0.1)",Range(0,1)) = 0.1
        _ShadowRampOffset("Shadow ramp offset (Default 0.75)",Range(0,1)) = 0.75
        _ShadowBoost("Shadow Boost (Default 1)", Range(0.0, 1.0)) = 1.0

        [Header(Additional Lighting)]
        [Toggle(_AdditionalLighting_ON)] _UseAdditionalLighting("Use Additional Lighting (Default NO)", float) = 0

        [Header(Face)]
        [NoScaleOffset] _FaceMap("Face map (Default black)",2D) = "black" {}
        [NoScaleOffset] _ExpressionMap("Expression Map (Default white)", 2D) = "white" {}
        _FaceShadowOffset("Face shadow offset (Default -0.01)",Range(-1,1)) = -0.01
        _FaceShadowTransitionSoftness("Face shadow transition softness (Default 0.05)", Range(0,1)) = 0.05

        [Header(Expression)]
        [Toggle(_Expression_ON)] _UseFaceExpression("Use Face Expression (Default NO)", float) = 0
        _ExCheekColor("Cheek Color (Default white)", Color) = (1, 1, 1, 1)
        _ExCheekIntensity("Cheek Intensity (Default 0)", Range(0, 1)) = 0
        _ExShyColor("Shy Color (Default white)", Color) = (1, 1, 1, 1)
        _ExShyIntensity("Shy Intensity (Default 0)", Range(0, 1)) = 0
        _ExShadowColor("Shadow Color (Default white)", Color) = (1, 1, 1, 1)
        _ExEyeColor("Eye Color (Default white)", Color) = (1, 1, 1, 1)
        _ExShadowIntensity("Shadow Intensity (Default 0)", Range(0, 1)) = 0

        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular ("Enable Specular (Default YES)", float) = 1
        [Toggle(_ANISOTROPY_SPECULAR)] _AnisotropySpecularToggle("Is Anisotropy Specular (Default NO)", Float) = 0
        _SpecularColor("Spwcular Color (Default white)", Color) = (1, 1, 1, 1)
        _SpecularShininess("Specular Shininess (Default 10)", Range(0.1, 100)) = 10
        _SpecularRoughness("Specular Roughness (Default 0.1)", Range(0, 1)) = 0.1
        _SpecularIntensity("Specualr Intensity (Default 1)", Range(0, 50)) = 1
        _SpecularKsNonMetal("Specular KS non-metal (Default 0.04)",Range(0,1)) = 0.04
        _SpecularKsMetal("Specular KS metal (Default 1)",Range(0,1)) = 1
        _MetalSpecularMetallic("Metal Specular Metallic (Default 0.52)",Range(0,1)) = 0.52


        [Header(Stockings)]
        [Toggle(_STOCKINGS_ON)] _UseStockings("Use Stockings (Default NO)",float) = 0
        _UpperBodyStockings("Upper body stockings (Default black)",2D) = "black" {}
        _LowerBodyStockings("Lower body stockings (Default black)",2D) = "black" {}
        _stockingsMapBChannelUVScale("Stockings texture channel B UV Scale (Default 20)",Range(1,50)) = 20
        _StockingsDarkColor("Stockings dark color (Default black)",Color) = (0,0,0)
        [HDR] _StockingsLightColor("Stockings light color (Default 1.8, 1.48299, 0.856821)",Color) = (1.8, 1.48299, 0.856821)
        _StockingsTransitionColor("Stockings transition color (Default 0.360381, 0.242986, 0.358131)",Color) = (0.360381, 0.242986, 0.358131)
        _StockingsTransitionThreshold("Stockings transition Threshold (Default 0.58)",Range(0,1)) = 0.58
        _StockingsTransitionPower("Stockings transition power (Default 1)",Range(0,50)) = 1
        _StockingsTransitionHardness("Stockings transition hardness (Default 0.4)",Range(0,1)) = 0.4
        _StockingsTextureUsage("Stockings texture usage (Default 0.1)",Range(0,1)) = 0.1

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)",float) = 1
        _ModelScale("Model Scale (Default 1)", Float) = 1
        _RimIntensity("Intensity (Front Main) (Default 0.5)", Float) = 0.5
        _RimIntensityBackFace("Intensity (Back Main) (Default 0)", Float) = 0
        _RimThresholdMin("Threshold Min (Default 0.6)", Float) = 0.6
        _RimThresholdMax("Threshold Max (Default 0.9)", Float) = 0.9
        _RimWidth0("Width (Default 0.5)", Float) = 0.5
        _RimColor0("Color (Default white)", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimDark0("Darken Value (Default 0.5)", Range(0, 1)) = 0.5
        _RimEdgeSoftness("Edge Softness (Default 0.05)", Float) = 0.05

        [Header(Bloom)]
        _mmBloomIntensity0("Intensity (Default 0)", Float) = 0
        _BloomColor0("Color (Default white)", Color) = (1, 1, 1, 1)

        [Header(Emission)]
        [Toggle(_EMISSION_ON)] _UseEmission("Use emission (Default NO)",float) = 0
        _EmissionMixBaseColor("Emission mix base color (Default 1)", Range(0,1)) = 1
        _EmissionTintColor("Emission tint color (Default white)", Color) = (1,1,1) 
        _EmissionIntensity("Emission intensity (Default 1)", Range(0,100)) = 1

        [Header(Outline)]
        [Toggle(_OUTLINE_ON)] _UseOutline("Use outline (Default YES)", float ) = 1
        [ToggleUI]_IsFace("Is Face? (please turn on if this is a face material)", Float) = 0
        _OutlineZOffset("_OutlineZOffset (View Space)", Range(0,1)) = 0.0001
        [NoScaleOffset]_OutlineZOffsetMaskTex("_OutlineZOffsetMask (black is apply ZOffset)", 2D) = "black" {}
        _OutlineZOffsetMaskRemapStart("_OutlineZOffsetMaskRemapStart", Range(0,1)) = 0
        _OutlineZOffsetMaskRemapEnd("_OutlineZOffsetMaskRemapEnd", Range(0,1)) = 1
        [Toggle(_USE_RAMP_COLOR_ON)] _UseRampColor("Use Ramp Color (Default YES)", float ) = 1
        _OutlineColor("OutlineColor (Without Ramp Texture)", Color) = (0.5, 0.5, 0.5, 1)
        [Toggle(_OUTLINE_VERTEX_COLOR_SMOOTH_NORMAL)] _OutlineUseVertexColorSmoothNormal("Use vertex color smooth normal (Default NO)", float) = 0
        _OutlineWidth("Outline width (Default 1)", Range(0,10)) = 1
        _OutlineGamma("Outline gamma (Default 16)", Range(1,255)) = 16
        [Toggle(_FAKE_OUTLINE_ON)] _UseFakeOutline("Use face fake outline (Default YES)", float ) = 1

        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode (Default Back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColor ("Core pass src blend mode color (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColor ("Core pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlpha ("Core pass src blend mode alpha (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlpha ("Core pass dst blend mode alpha (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("BlendOp (Default Add)", Float) = 0
        [Enum(Off,0, On,1)] _ZWrite("ZWrite (Default On)",Float) = 1
        _StencilRef ("Stencil reference (Default 0)",Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil comparison (Default disabled)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil pass comparison (Default keep)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil fail comparison (Default keep)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil z fail comparison (Default keep)",Int) = 0
        _StencilReadMask("Stencil Read Mask (Default 255)",Range(0, 255)) = 255
        _StencilWriteMask("Stencil Write Mask (Default 255)",Range(0, 255)) = 255

        [Header(Draw Overlay)]
        [Toggle(_DRAW_OVERLAY_ON)] _UseDrawOverlay("Use draw overlay (Default NO)",float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColorOverlay("Overlay pass src blend mode color (Default One)",Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColorOverlay("Overlay pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlphaOverlay("Overlay pass src blend mode alpha (Default One)",Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlphaOverlay("Overlay pass dst blend mode alpha (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOpOverlay("Overlay pass blend operation (Default Add)", Float) = 0
        _StencilRefOverlay ("Overlay pass stencil reference (Default 0)", Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompOverlay("Overlay pass stencil comparison (Default disabled)",Int) = 0

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
        #pragma shader_feature_local_fragment _UseAlphaClipping
        #pragma shader_feature_local _DayTime_MANUAL_ON
        #pragma shader_feature_local _AUTO_Brightness_ON
        #pragma shader_feature_local_fragment _NORMAL_MAP_ON
        #pragma shader_feature_local _Expression_ON
        #pragma shader_feature_local _SPECULAR_ON
        #pragma shader_feature_local _STOCKINGS_ON
        #pragma shader_feature_local _RIM_LIGHTING_ON
        #pragma shader_feature_local _OUTLINE_ON
        #pragma shader_feature_local _FAKE_OUTLINE_ON
        #pragma shader_feature_local _USE_RAMP_COLOR_ON
        #pragma shader_feature_local _OUTLINE_VERTEX_COLOR_SMOOTH_NORMAL
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
            Cull[_CullMode]
            Stencil{
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
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
            Cull[_CullMode]
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

            #pragma vertex SRUniversalVertex
            #pragma fragment SRUniversalFragment

            // because this is an Outline pass, define "ToonShaderIsOutline" to inject outline related code into both VertexShaderWork() and ShadeFinalColor()
            #define ToonShaderIsOutline

            #if _OUTLINE_ON

                // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
                #include "../ShaderLibrary/SRUniversalInput.hlsl"
                #include "../ShaderLibrary/SRUniversalDrawOutline.hlsl"
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
