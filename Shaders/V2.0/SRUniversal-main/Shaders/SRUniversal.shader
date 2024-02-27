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
        _BaseColorRPower ("Base color R Power (Default 1)", Range(-5, 5)) = 1.0  
        _BaseColorGPower ("Base color G Power (Default 1)", Range(-5, 5)) = 1.0  
        _BaseColorBPower ("Base color B Power (Default 1)", Range(-5, 5)) = 1.0  
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
        _IndirectLightUsage("Indirect light usage (Default 0.5)",Range(0,1)) = 0.5
        _IndirectLightOcclusionUsage("Indirect light occlusion usage (Default 0.5)",Range(0,1)) = 0.5
        _IndirectLightMixBaseColor("Indirect light mix base color (Default 1)",Range(0,1)) = 1

        [Header(Main Lighting)]
        _MainLightBrightnessFactor("Main light brightness factor (Default 1)",Range(0,1)) = 1
        _MainLightColorUsage("Main light color usage (Default 1)",Range(0,1)) = 1
        _ShadowThresholdCenter("Shadow threshold center (Default 0)",Range(-1,1)) = 0
        _ShadowThresholdSoftness("Shadow threshold softness (Default 0.1)",Range(0,1)) = 0.1
        _ShadowRampOffset("Shadow ramp offset (Default 0.75)",Range(0,1)) = 0.75
        _ShadowBoost("Shadow Boost (Default 1)", Range(0.0, 1.0)) = 1.0

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
        [Toggle(_METAL_SPECULAR_ON)] _EnableMetalSpecular ("Enable Metal Specular (Default YES)", float) = 1
        _SpecularExpon("Specular exponent (Default 50)",Range(0,100)) = 50
        _SpecularKsNonMetal("Specular KS non-metal (Default 0.04)",Range(0,1)) = 0.04
        _SpecularKsMetal("Specular KS metal (Default 1)",Range(0,1)) = 1
        _MetalSpecularMetallic("Metal Specular Metallic (Default 0.52)",Range(0,1)) = 0.52
        [Toggle(_SPECULAR_COLOR_CUSTOM)] _EnableCustomSpecularColor ("Enable Custom Specular Color (Default NO)", float) = 1
        _SpecularColor("Stockings dark color (Default white)",Color) = (1,1,1)
        _SpecularBrightness("Specular brightness (Default 1)",Range(0,10)) = 10

        [Header(Stockings)]
        [Toggle(_STOCKINGS_ON)] _UseStockings("Use Stockings (Default NO)",float) = 0
        _UpperBodyStockings("Upper body stockings (Default black)",2D) = "black" {}
        _LowerBodyStockings("Lower body stockings (Default black)",2D) = "black" {}
        _StockingsDarkColor("Stockings dark color (Default black)",Color) = (0,0,0)
        [HDR] _StockingsLightColor("Stockings light color (Default 1.8, 1.48299, 0.856821)",Color) = (1.8, 1.48299, 0.856821)
        _StockingsTransitionColor("Stockings transition color (Default 0.360381, 0.242986, 0.358131)",Color) = (0.360381, 0.242986, 0.358131)
        _StockingsTransitionThreshold("Stockings transition Threshold (Default 0.58)",Range(0,1)) = 0.58
        _StockingsTransitionPower("Stockings transition power (Default 1)",Range(0,50)) = 1
        _StockingsTransitionHardness("Stockings transition hardness (Default 0.4)",Range(0,1)) = 0.4
        _StockingsTextureUsage("Stockings texture usage (Default 0.1)",Range(0,1)) = 0.1

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)",float) = 1
        _RimLightWidth("Rim light width (Default 1)",Range(0, 10)) = 1
        _RimLightThreshold("Rin light threshold (Default 0.05)",Range(-1, 1)) = 0.05
        _RimLightFadeout("Rim light fadeout (Default 1)",Range(0.01, 1)) = 1
        [HDR] _RimLightTintColor("Rim light tint colar (Default white)",Color) = (1,1,1)
        _RimLightBrightness("Rim light brightness (Default 1)",Range(0, 10)) = 1
        _RimLightMixAlbedo("Rim light mix albedo (Default 0.9)",Range(0, 1)) = 0.9

        [Header(Bloom)]
        _BloomIntensity0("Intensity", Range(0, 1)) = 0.5
        _BloomColor0("Color", Color) = (1, 1, 1, 1)

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
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull (Default back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode ("Cull (Default back)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode ("Cull (Default back)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Cull (Default back)", Float) = 0
        [Enum(Off,0, On,1)] _ZWrite("ZWrite (Default On)",Float) = 1
        _StencilRef ("Stencil reference (Default 0)",Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil comparison (Default disabled)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil pass comparison (Default keep)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil fail comparison (Default keep)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil z fail comparison (Default keep)",Int) = 0

        [Header(Draw Overlay)]
        [Toggle(_DRAW_OVERLAY_ON)] _UseDrawOverlay("Use draw overlay (Default NO)",float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _ScrBlendModeOverlay("Overlay pass scr blend mode (Default One)",Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeOverlay("Overlay pass dst blend mode (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOpOverlay("Overlay pass blend operation (Default Add)", Float) = 0
        _StencilRefOverlay ("Overlay pass stencil reference (Default 0)", Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompOverlay("Overlay pass stencil comparison (Default disabled)",Int) = 0

    }
    SubShader
    {
        LOD 100

        HLSLINCLUDE
        #pragma shader_feature_local _AREA_FACE
        #pragma shader_feature_local _AREA_HAIR
        #pragma shader_feature_local _AREA_UPPERBODY
        #pragma shader_feature_local _AREA_LOWERBODY
        #pragma shader_feature_local_fragment _UseAlphaClipping
        #pragma shader_feature_local _DayTime_MANUAL_ON
        #pragma shader_feature_local_fragment _NORMAL_MAP_ON
        #pragma shader_feature_local _Expression_ON
        #pragma shader_feature_local _SPECULAR_ON
        #pragma shader_feature_local _METAL_SPECULAR_ON
        #pragma shader_feature_local _SPECULAR_COLOR_CUSTOM
        #pragma shader_feature_local _STOCKINGS_ON
        #pragma shader_feature_local _RIM_LIGHTING_ON
        #pragma shader_feature_local _OUTLINE_ON
        #pragma shader_feature_local _FAKE_OUTLINE_ON
        #pragma shader_feature_local _USE_RAMP_COLOR_ON
        #pragma shader_feature_local _OUTLINE_VERTEX_COLOR_SMOOTH_NORMAL
        #pragma shader_feature_local _DRAW_OVERLAY_ON
        #pragma shader_feature_local _EMISSION_ON

        ENDHLSL

        Pass
        {
            Name "DrawCore"
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
                "LightMode" = "HSRForward2"
            }
            Cull[_Cull]
            Stencil{
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
            }
            Blend [_SrcBlendMode] [_DstBlendMode]
            BlendOp [_BlendOp]
            ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma multi_compile _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _SHADOWS_SOFT

            #pragma vertex SRUniversalVertex
            #pragma fragment SRUniversalFragment

            #pragma multi_compile_fog

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DrawOverlay"
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
                "LightMode" = "HSRForward3"
            }
            Cull[_Cull]
            Stencil{
                Ref [_StencilRefOverlay]
                Comp [_StencilCompOverlay]
            }
            Blend [_ScrBlendModeOverlay] [_DstBlendModeOverlay]
            BlendOp [_BlendOpOverlay]
            ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma multi_compile _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _SHADOWS_SOFT

            #pragma vertex SRUniversalVertex
            #pragma fragment SRUniversalFragment

            #pragma multi_compile_fog

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
            Name "DrawOutline"
            Tags 
            {
                "RenderPipeline" = "UniversalPipeline"
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
                "LightMode" = "HSRShadowCaster"
            }

            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest LEqual

            ColorMask 0

            HLSLPROGRAM

            #pragma target 2.0

            #pragma vertex CharacterShadowVertex
            #pragma fragment CharacterShadowFragment

            //#pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "HairDepthOnly"

            Tags
            {
                "LightMode" = "DepthOnly"
            }

            Cull [_Cull]
            ZWrite [_ZWrite]
            ColorMask R

            HLSLPROGRAM

            #pragma vertex CharacterDepthOnlyVertex
            #pragma fragment CharacterDepthOnlyFragment

            //#pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "HairDepthNormals"

            Tags
            {
                "LightMode" = "DepthNormals"
            }

            Cull [_Cull]
            ZWrite [_ZWrite]

            HLSLPROGRAM

            #pragma vertex CharacterDepthNormalsVertex
            #pragma fragment CharacterDepthNormalsFragment

            //#pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
