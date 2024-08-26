Shader "HonkaiStarRailToon/Character/FaceMask"
{
    Properties
    {
        _BodyColorMapColor("Color", Color) = (1, 1, 1, 1)

        [Header(TextureScale Offset)]
        [TextureScaleOffset] _Maps_ST("Maps Scale Offset", Vector) = (1, 1, 0, 0)

        [Header(Indirect Lighting)]
        _IndirectLightFlattenNormal("Indirect light flatten normal (Default 0)", Range(0, 1)) = 0
        _IndirectLightIntensity("Indirect light intensity (Default 1)", Range(0, 2)) = 1
        _IndirectLightUsage("Indirect light color usage (Default 0.5)", Range(0, 1)) = 0.5

        [Header(Self Shadow Caster)]
        _SelfShadowDepthBias("Depth Bias", Float) = -0.01
        _SelfShadowNormalBias("Normal Bias", Float) = 0

        [HideInInspector] _DitherAlpha("Alpha", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "ComplexLit" // Packages/com.unity.render-pipelines.universal/Runtime/Passes/GBufferPass.cs: Fill GBuffer, but skip lighting pass for ComplexLit
            "Queue" = "Geometry"
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        ENDHLSL

        Pass
        {
            Name "SRCharFaceMaskStencilClear"

            Tags
            {
                "LightMode" = "HSRForward1"
            }

            // 清除角色 Stencil
            Stencil
            {
                Ref 0
                WriteMask 7 // 后三位
                Comp Always
                Pass Zero
                Fail Keep
            }

            Cull Off
            ZWrite On

            ColorMask RGBA 0

            HLSLPROGRAM
            #pragma target 2.0

            #pragma multi_compile_fog

            #pragma vertex SRUniversalCharVertex
            #pragma fragment frag

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            void frag(CharCoreVaryings i,
                out float4 colorTarget : SV_Target0)
            {
                DoDitherAlphaEffect(i.positionCS, _DitherAlpha);

                colorTarget = _BodyColorMapColor;

                // Mix Fog
                real fogFactor = InitializeInputDataFog(float4(i.positionWS, 1.0), i.fogFactor);
                colorTarget.rgb = MixFog(colorTarget.rgb, fogFactor);
            }

            ENDHLSL
        }

        Pass
        {
            Name "SRCharFaceMaskGBuffer"

            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            Cull Back
            ZWrite On

            ColorMask RGBA 0

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            #pragma vertex SRUniversalCharVertex
            #pragma fragment SRUniversalCharGBufferFragment

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "SRCharFaceMaskShadow"

            Tags
            {
                "LightMode" = "HSRPerObjectShadowCaster"
            }

            Cull Off
            ZWrite On
            ZTest LEqual

            ColorMask 0

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex FaceMaskShadowVertex
            #pragma fragment FaceMaskShadowFragment

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_vertex _ _CASTING_SELF_SHADOW

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            CharShadowVaryings FaceMaskShadowVertex(CharShadowAttributes i)
            {
                return CharShadowVertex(i, 0, _SelfShadowDepthBias, _SelfShadowNormalBias);
            }

            void FaceMaskShadowFragment(CharShadowVaryings i)
            {
                DoDitherAlphaEffect(i.positionHCS, _DitherAlpha);
            }

            ENDHLSL
        }

        Pass
        {
            Name "SRCharFaceMaskDepthOnly"

            Tags
            {
                "LightMode" = "DepthOnly"
            }

            Cull Off
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex FaceMaskDepthOnlyVertex
            #pragma fragment FaceMaskDepthOnlyFragment

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            CharDepthOnlyVaryings FaceMaskDepthOnlyVertex(CharDepthOnlyAttributes i)
            {
                return CharDepthOnlyVertex(i, 0);
            }

            float4 FaceMaskDepthOnlyFragment(CharDepthOnlyVaryings i) : SV_Target
            {
                DoDitherAlphaEffect(i.positionHCS, _DitherAlpha);
                return CharDepthOnlyFragment(i);
            }

            ENDHLSL
        }

        Pass
        {
            Name "SRCharFaceMaskDepthNormalsOnly"

            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            Cull Off
            ZWrite On

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex FaceMaskDepthNormalsVertex
            #pragma fragment FaceMaskDepthNormalsFragment

            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT // forward-only variant

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            CharDepthNormalsVaryings FaceMaskDepthNormalsVertex(CharDepthNormalsAttributes i)
            {
                return CharDepthNormalsVertex(i, 0);
            }

            float4 FaceMaskDepthNormalsFragment(CharDepthNormalsVaryings i) : SV_Target
            {
                DoDitherAlphaEffect(i.positionHCS, _DitherAlpha);
                return CharDepthNormalsFragment(i);
            }

            ENDHLSL
        }

        Pass
        {
            Name "SRCharFaceMaskMotionVectors"

            Tags
            {
                "LightMode" = "MotionVectors"
            }

            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma exclude_renderers d3d11_9x
            #pragma target 3.5

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            CharMotionVectorsVaryings vert(CharMotionVectorsAttributes i)
            {
                return CharMotionVectorsVertex(i, 0);
            }

            half4 frag(CharMotionVectorsVaryings i) : SV_Target
            {
                DoDitherAlphaEffect(i.positionHCS, _DitherAlpha);
                return CharMotionVectorsFragment(i);
            }

            ENDHLSL
        }

        // No Outline
    }

    Fallback Off
}
