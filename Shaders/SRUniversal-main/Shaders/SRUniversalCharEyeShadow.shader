Shader "HonkaiStarRailToon/Character/EyeShadow"
{
    Properties
    {
        _BodyColorMapColor("Color", Color) = (0.6770648, 0.7038123, 0.8018868, 0.7647059)

        [Header(TextureScale Offset)]
        [TextureScaleOffset] _Maps_ST("Maps Scale Offset", Vector) = (1, 1, 0, 0)

        [HideInInspector] _IndirectLightFlattenNormal("Indirect light flatten normal (Default 0)", Range(0, 1)) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Src Blend (A)", Float) = 0 // 默认 Zero
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Dst Blend (A)", Float) = 0 // 默认 Zero

        [HideInInspector] _DitherAlpha("Dither Alpha", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "ComplexLit" // Packages/com.unity.render-pipelines.universal/Runtime/Passes/GBufferPass.cs: Fill GBuffer, but skip lighting pass for ComplexLit
            "Queue" = "Geometry+10"  // 必须在脸之后绘制
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        ENDHLSL

        Pass
        {
            Name "SRCharEyeShadow"

            Tags
            {
                "LightMode" = "HSRForward2"
            }

            // 眼睛部分
            Stencil
            {
                Ref 2
                ReadMask 2   // 眼睛位
                Comp Equal
                Pass Keep
                Fail Keep
            }

            Cull Back
            ZWrite Off // 不写入深度，仅仅是附加在图像上面

            Blend DstColor Zero, [_SrcBlendAlpha] [_DstBlendAlpha]

            ColorMask RGBA 0
            ColorMask 0 1

            HLSLPROGRAM
            #pragma target 2.0

            #pragma multi_compile_fog

            #pragma vertex SRUniversalCharVertex
            #pragma fragment frag

            #include "../ShaderLibrary/SRUniversalInput.hlsl"
            #include "../ShaderLibrary/SRUniversalDrawCorePass.hlsl"

            float4 frag(CharCoreVaryings i) : SV_Target0
            {
                DoDitherAlphaEffect(i.positionCS, _DitherAlpha);

                float4 colorTarget = _BodyColorMapColor;

                // Fog
                real fogFactor = InitializeInputDataFog(float4(i.positionWS, 1.0), i.fogFactor);
                colorTarget.rgb = MixFog(colorTarget.rgb, fogFactor);

                return colorTarget;
            }

            ENDHLSL
        }

        Pass
        {
            Name "SRCharEyeShadowGBuffer"

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
            Name "SRCharEyeShadowMotionVectors"

            Tags
            {
                "LightMode" = "MotionVectors"
            }

            Cull Back
            ZWrite Off // 不写入深度，仅仅是附加在图像上面

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
        // No Shadow
        // No Depth
    }

    Fallback Off
}
