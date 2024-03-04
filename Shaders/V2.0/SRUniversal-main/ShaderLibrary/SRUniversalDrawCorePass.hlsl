#include "../ShaderLibrary/CharShadow.hlsl"
#include "../ShaderLibrary/CharDepthOnly.hlsl"
#include "../ShaderLibrary/CharDepthNormals.hlsl"
#include "../ShaderLibrary/CharMotionVectors.hlsl"
#include "../ShaderLibrary/SRUniversalBloomHelper.hlsl"

const static float3 f3zero = float3(0.0, 0.0, 0.0);
const static float3 f3one = float3(1.0, 1.0, 1.0);
const static float4 f4zero = float4(0.0, 0.0, 0.0, 0.0);
const static float4 f4one = float4(1.0, 1.0, 1.0, 1.0);

struct CharCoreAttributes
{
    float3 positionOS   : POSITION;
    half3 normalOS      : NORMAL;
    half4 tangentOS     : TANGENT;
    float2 uv           : TEXCOORD0;
};

struct CharCoreVaryings
{
    float2 uv                       : TEXCOORD0;
    float4 positionWSAndFogFactor   : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    float3 bitangentWS              : TEXCOORD3;
    float3 tangentWS                : TEXCOORD4;
    float3 viewDirectionWS          : TEXCOORD5;
    float3 SH                       : TEXCOORD6;
    float4 positionCS               : SV_POSITION;
};

struct Gradient
{
    int colorsLength;
    float4 colors[8];

};

Gradient GradientConstruct()
{
    Gradient g;
    g.colorsLength = 2;
    g.colors[0] = float4(1,1,1,0);
    g.colors[1] = float4(1,1,1,1);
    g.colors[2] = float4(0,0,0,0);
    g.colors[3] = float4(0,0,0,0);
    g.colors[4] = float4(0,0,0,0);
    g.colors[5] = float4(0,0,0,0);
    g.colors[6] = float4(0,0,0,0);
    g.colors[7] = float4(0,0,0,0);
    return g;
}

float3 SampleGradient(Gradient Gradient, float Time)
{
    float3 color = Gradient.colors[0].rgb;

    for (int c = 1; c < Gradient.colorsLength; c++)
    {
        float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
        color = lerp(color, Gradient.colors[c].rgb, colorPos);
    }
    #ifdef UNITY_COLORSPACE_GAMMA
        color = LinearToSRGB(color);
    #endif
    return color;

}

float3 desaturation(float3 color)
{
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    float grayf = dot(color, grayXfer);
    return float3(grayf, grayf, grayf);
}

float3 RGBAdjustment(float3 inputColor, float RPower, float GPower, float BPower)
{
    inputColor.r = pow(clamp(inputColor.r, 0.0, 1.0), RPower);
    inputColor.g = pow(clamp(inputColor.g, 0.0, 1.0), GPower);
    inputColor.b = pow(clamp(inputColor.b, 0.0, 1.0), BPower);
    float3 finalColor = clamp(inputColor, 0.0, 1.0);
    return finalColor;
}

Light GetCharacterMainLightStruct(float4 shadowCoord)
{
    Light light = GetMainLight();

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
        half4 shadowParams = GetMainLightShadowParams();

        // 我自己试下来，在角色身上 LowQuality 比 Medium 和 High 好
        // Medium 和 High 采样数多，过渡的区间大，在角色身上更容易出现 Perspective aliasing
        shadowSamplingData.softShadowQuality = SOFT_SHADOW_QUALITY_LOW;
        light.shadowAttenuation = SampleShadowmap(TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_LinearClampCompare), shadowCoord, shadowSamplingData, shadowParams, false);
    #endif

    return light;
}

float4 GetMainLightBrightness(float3 inputMainLightColor, float brightnessFactor)
{
    float3 scaledMainLightColor = inputMainLightColor.rgb * brightnessFactor;
    float4 scaledMainLight = float4(scaledMainLightColor, 1);
    return scaledMainLight;
}

float3 GetMainLightColor(float3 inputMainLightColor, float mainLightColorUsage)
{
    return lerp(Luminance(inputMainLightColor.rgb), inputMainLightColor.rgb, mainLightColorUsage);
}

float3 LerpRampColor(float3 coolRamp, float3 warmRamp, float DayTime)
{
    return lerp(warmRamp, coolRamp, abs(DayTime - 12.0) * rcp(12.0));
}

float3 LinearColorMix(float3 OriginalColor, float3 EnhancedColor, float mixFactor)
{
    OriginalColor = clamp(OriginalColor, 0.0, 1.0);
    EnhancedColor = clamp(EnhancedColor, 0.0, 1.0);
    float3 finalColor = lerp(OriginalColor, EnhancedColor, mixFactor);
    return finalColor;
}

float4 GetMainTexColor(float2 uv, sampler2D FaceColorMap, float4 FaceColorMapColor,
    sampler2D HairColorMap, float4 HairColorMapColor,
    sampler2D UpperBodyColorMap, float4 UpperBodyColorMapColor,
    sampler2D LowerBodyColorMap, float4 LowerBodyColorMapColor)
{
    float4 areaMap = 0;
    float4 areaColor = 0;
    //根据不同的Keyword，采样不同的贴图，作为额漫反射颜色
    #if _AREA_FACE
        areaMap = tex2D(FaceColorMap, uv);
        areaColor = areaMap * FaceColorMapColor;
    #elif _AREA_HAIR
        areaMap = tex2D(HairColorMap, uv);
        areaColor = areaMap * HairColorMapColor;
    #elif _AREA_UPPERBODY
        areaMap = tex2D(UpperBodyColorMap, uv);
        areaColor = areaMap * UpperBodyColorMapColor;
    #elif _AREA_LOWERBODY
        areaMap = tex2D(LowerBodyColorMap, uv);
        areaColor = areaMap * LowerBodyColorMapColor;
    #endif
    return areaColor;
}

struct RampColor
{
    float3 coolRampCol;
    float3 warmRampCol;
};

RampColor RampColorConstruct(float2 rampUV, sampler2D HairCoolRamp, float3 HairCoolRampColor, float HairCoolRampColorMixFactor,
    sampler2D HairWarmRamp, float3 HairWarmRampColor, float HairWarmRampColorMixFactor,
    sampler2D BodyCoolRamp, float3 BodyCoolRampColor, float BodyCoolRampColorMixFactor,
    sampler2D BodyWarmRamp, float3 BodyWarmRampColor, float BodyWarmRampColorMixFactor)
{
    RampColor R;
    float3 coolRampTexCol = 1;
    float3 warmRampTexCol = 1;
    float3 coolRampCol = 1;
    float3 warmRampCol = 1;
    //hair的Ramp贴图和身体或脸部的不一样，按照keyword采样
    #if _AREA_HAIR
        coolRampTexCol = tex2D(HairCoolRamp, rampUV).rgb;
        warmRampTexCol = tex2D(HairWarmRamp, rampUV).rgb;
        coolRampCol = LinearColorMix(coolRampTexCol, HairCoolRampColor, HairCoolRampColorMixFactor);
        warmRampCol = LinearColorMix(warmRampTexCol, HairWarmRampColor, HairWarmRampColorMixFactor);
    #elif _AREA_FACE || _AREA_UPPERBODY || _AREA_LOWERBODY
        coolRampTexCol = tex2D(BodyCoolRamp, rampUV).rgb;
        warmRampTexCol = tex2D(BodyWarmRamp, rampUV).rgb;
        coolRampCol = LinearColorMix(coolRampTexCol, BodyCoolRampColor, BodyCoolRampColorMixFactor);
        warmRampCol = LinearColorMix(warmRampTexCol, BodyWarmRampColor, BodyWarmRampColorMixFactor);
    #endif
    R.coolRampCol = coolRampCol;
    R.warmRampCol = warmRampCol;
    return R;
}

float4 GetLightMapTex(float2 uv, sampler2D HairLightMap, sampler2D UpperBodyLightMap, sampler2D LowerBodyLightMap)
{
    float4 lightMap = 0;
    #if _AREA_HAIR
        lightMap = tex2D(HairLightMap, uv);
    #elif _AREA_UPPERBODY
        lightMap = tex2D(UpperBodyLightMap, uv);
    #elif _AREA_LOWERBODY
        lightMap = tex2D(LowerBodyLightMap, uv);
    #endif
    return lightMap;
}

struct RampRowNumIndex
{
    int rampRowIndex;
    int rampRowNum;
};

RampRowNumIndex GetRampRowNumIndex(int rampRowIndex, int rampRowNum, float materialId)
{
    RampRowNumIndex R;
    //头发的Ramp贴图只有一行，因此不用计算
    #if _AREA_HAIR
        rampRowIndex = 1;
        rampRowNum = 1;
        //上下衣的Ramp贴图有8行
    #elif _AREA_UPPERBODY || _AREA_LOWERBODY
        int rawIndex = round(materialId * 8.04 + 0.81);
        //奇数行不变，偶数行先偏移4行，再对8取余
        rampRowIndex = lerp(fmod((rawIndex + 4), 8), rawIndex, fmod(rawIndex, 2));
        //身体的Ramp贴图有8行
        rampRowNum = 8;
    #elif _AREA_FACE
        //脸部ramp直接使用皮肤的行号即可
        rampRowIndex = 1;
        rampRowNum = 8;
    #endif
    R.rampRowIndex = rampRowIndex;
    R.rampRowNum = rampRowNum;
    return R;
}

float2 GetRampUV(float mainLightShadow, float ShadowRampOffset, int rampRowIndex, int rampRowNum)
{
    //RampUV计算
    //根据NdotL计算UV的u，由于ramp贴图的变化主要集中在3/4的地方，把uv乘以0.25然后加上0.75
    //这里_ShadowRampOffset=0.75
    float rampUVx = mainLightShadow * (1 - ShadowRampOffset) + ShadowRampOffset;
    //计算uv的v
    float rampUVy = (2 * rampRowIndex - 1) * (1.0 / (rampRowNum * 2));

    float2 rampUV = float2(rampUVx, rampUVy);
    return rampUV;
}

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold) 
{
#if _UseAlphaClipping
    clip(alpha - alphaTestThreshold);
#endif
}

CharCoreVaryings SRUniversalVertex(CharCoreAttributes input)
{
    CharCoreVaryings output = (CharCoreVaryings)0;

    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(input.normalOS,input.tangentOS);

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    // 世界空间
    output.positionWSAndFogFactor = float4(vertexPositionInputs.positionWS, ComputeFogFactor(vertexPositionInputs.positionCS.z));
    // 世界空间法线、切线、副切线
    output.normalWS = vertexNormalInputs.normalWS;
    output.tangentWS = vertexNormalInputs.tangentWS;
    output.bitangentWS = vertexNormalInputs.bitangentWS;
    // 世界空间相机向量
    output.viewDirectionWS = unity_OrthoParams.w == 0 ? GetCameraPositionWS() - vertexPositionInputs.positionWS : GetWorldToViewMatrix()[2].xyz;
    // 间接光 with 球谐函数
    output.SH = SampleSH(lerp(vertexNormalInputs.normalWS, float3(0,0,0), _IndirectLightFlattenNormal));

    output.positionCS = vertexPositionInputs.positionCS;

    return output;
}

float4 colorFragmentTarget(inout CharCoreVaryings input, bool isFrontFace)
{
    //片元世界空间位置
    float3 positionWS = input.positionWSAndFogFactor.xyz;

    //阴影坐标
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);

    //获取主光源，传入shadowCoord是为了让mainLight获取阴影衰减，也就是实时阴影（shadowCoord为灯光空间坐标，xy采样shadowmap然后与z对比）
    Light mainLight = GetCharacterMainLightStruct(shadowCoord);
    //获取主光源颜色
    float4 LightColor = GetMainLightBrightness(mainLight.color.rgb, _MainLightBrightnessFactor);
    //使用一个参数_MainLightColorUsage控制主光源颜色的使用程度
    float3 mainLightColor = GetMainLightColor(LightColor.rgb, _MainLightColorUsage);
    //获取主光源方向
    float3 lightDirectionWS = normalize(mainLight.direction);

    //获取世界空间法线，如果要采样NormalMap，要使用TBN矩阵变换
    #if _NORMAL_MAP_ON
        float3x3 tangentToWorld = half3x3(input.tangentWS, input.bitangentWS, input.normalWS);
        float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
        float3 normalTS = UnpackNormal(normalMap);
        float3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld, true);
        input.normalWS = normalWS;
    #else
        float3 normalWS = normalize(input.normalWS);
    #endif
    
    //视线方向
    float3 viewDirectionWS = normalize(input.viewDirectionWS);

    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
        _HairColorMap, _HairColorMapColor,
        _UpperBodyColorMap, _UpperBodyColorMapColor,
        _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _BaseColorRPower, _BaseColorGPower, _BaseColorBPower);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);
    
    //对有LightMap的部位，采样 LightMap
    float4 lightMap = 0;
    lightMap = GetLightMapTex(input.uv, _HairLightMap, _UpperBodyLightMap, _LowerBodyLightMap);

    //对脸部采样 faceMap，脸部的LightMap就是这张FaceMap
    float4 faceMap = 0;
    #if _AREA_FACE
        faceMap = tex2D(_FaceMap, input.uv);
    #endif

    // LightMap
    float shadowIntensity = lightMap.r;
    float diffuseThreshold = lightMap.g;
    float specularThreshold = lightMap.b;
    float materialId = lightMap.a;

    // Expression
    #if _AREA_FACE && _Expression_ON
        {
            float4 exprMap = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, input.uv.xy);
            float3 exCheek = lerp(baseColor.rgb, baseColor.rgb * _ExCheekColor.rgb, exprMap.r);
            baseColor.rgb = lerp(baseColor.rgb, exCheek, _ExCheekIntensity);
            float3 exShy = lerp(baseColor.rgb, baseColor.rgb * _ExShyColor.rgb, exprMap.g);
            baseColor.rgb = lerp(baseColor.rgb, exShy, _ExShyIntensity);
            float3 exShadow = lerp(baseColor.rgb, baseColor.rgb * _ExShadowColor.rgb, exprMap.b);
            baseColor.rgb = lerp(baseColor.rgb, exShadow, _ExShadowIntensity);
            float3 exEyeShadow = lerp(baseColor.rgb, baseColor.rgb * _ExEyeColor.rgb, faceMap.r);
            baseColor.rgb = lerp(baseColor.rgb, exEyeShadow, _ExShadowIntensity);
        }
    #endif

    //lightmap的R通道是AO，也就是静态阴影，根据AO，来影响环境光照
    float3 indirectLightColor = input.SH.rgb * _IndirectLightUsage;
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        
        indirectLightColor *= lerp(1, shadowIntensity, _IndirectLightOcclusionUsage); // 加个 Ambient Occlusion
    #elif _AREA_FACE
        indirectLightColor *= lerp(1, lerp(faceMap.g, 1, step(faceMap.r, 0.5)), _IndirectLightOcclusionUsage);
    #endif
    indirectLightColor *= lerp(1, baseColor, _IndirectLightMixBaseColor);


    float mainLightShadow = 1;
    int rampRowIndex = 0;
    int rampRowNum = 1;
    //lightmap的G通道直接光阴影的形状，值越小，越容易进入阴影，有些刺的效果就是这里出来的
    #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
        {
            float NoL = dot(normalWS, lightDirectionWS);
            float remappedNoL = NoL * 0.5 + 0.5;
            float shadowThreshold = diffuseThreshold;
            //加个过渡，这里_ShadowThresholdSoftness=0.1
            mainLightShadow = smoothstep(
                1.0 - shadowThreshold - _ShadowThresholdSoftness,
                1.0 - shadowThreshold + _ShadowThresholdSoftness,
                remappedNoL + _ShadowThresholdCenter);
            //应用AO
            mainLightShadow *= shadowIntensity;
            mainLightShadow = lerp(0.20, mainLightShadow, saturate(mainLight.shadowAttenuation + HALF_EPS));

            RampRowNumIndex RRNI = GetRampRowNumIndex(rampRowIndex, rampRowNum, materialId);
            rampRowIndex = RRNI.rampRowIndex;
            rampRowNum = RRNI.rampRowNum;

        }
    #elif _AREA_FACE
        {
            float3 headForward = normalize(_HeadForward).xyz;
            float3 headRight = normalize(_HeadRight).xyz;
            float3 headUp = normalize(cross(headForward, headRight));
            float3 lightDir = normalize(lightDirectionWS - dot(lightDirectionWS, headUp) * headUp);
            //光照在左脸的时候。左脸的uv采样左脸，右脸的uv采样右脸，而光照在右脸的时候，左脸的uv采样右脸，右脸的uv采样左脸，因为SDF贴图明暗变化在右脸
            float isRight = step(0, dot(lightDir, headRight));
            //相当于float sdfUVx=isRight?1-input.uv.x:input.uv.x;
            //即打在右脸的时候，反转uv的u坐标
            float sdfUVx = lerp(input.uv.x, 1 - input.uv.x, isRight);
            float2 sdfUV = float2(sdfUVx, input.uv.y);
            //使用uv采样面部贴图的a通道
            float sdfValue = tex2D(_FaceMap, sdfUV).a;
            sdfValue += _FaceShadowOffset;
            //dot(lightDir,headForward)的范围是[1,-1]映射到[0,1]
            float sdfThreshold = 1 - (dot(lightDir, headForward) * 0.5 + 0.5);
            //采样结果大于点乘结果，不在阴影，小于则处于阴影
            float sdf = smoothstep(sdfThreshold - _FaceShadowTransitionSoftness, sdfThreshold + _FaceShadowTransitionSoftness, sdfValue);
            //AO中常暗的区域，step提取大于0.5的部分，使用g通道的阴影形状（常亮/常暗），其他部分使用sdf贴图
            mainLightShadow = lerp(faceMap.g, sdf, step(faceMap.r, 0.5));
            mainLightShadow *= mainLight.shadowAttenuation;

            RampRowNumIndex RRNI = GetRampRowNumIndex(rampRowIndex, rampRowNum, materialId);
            rampRowIndex = RRNI.rampRowIndex;
            rampRowNum = RRNI.rampRowNum;
        }
    #endif

    float3 coolRampCol = 1;
    float3 warmRampCol = 1;
    float2 rampUV;

    rampUV = GetRampUV(mainLightShadow, _ShadowRampOffset, rampRowIndex, rampRowNum);

    //Ramp Color
    RampColor RC = RampColorConstruct(rampUV, _HairCoolRamp, _HairCoolRampColor, _HairCoolRampColorMixFactor,
        _HairWarmRamp, _HairWarmRampColor, _HairWarmRampColorMixFactor,
        _BodyCoolRamp, _BodyCoolRampColor, _BodyCoolRampColorMixFactor,
        _BodyWarmRamp, _BodyWarmRampColor, _BodyWarmRampColorMixFactor);
    coolRampCol = RC.coolRampCol;
    warmRampCol = RC.warmRampCol;
    //根据白天夜晚，插值获得最终的rampColor，_DayTime也可以用变量由C#脚本传入Shader
    #if _DayTime_MANUAL_ON
        float DayTime = _DayTime;
    #else
        float DayTime = (lightDirectionWS.y * 0.5 + 0.5) * 12;
    #endif
    float3 rampColor = LerpRampColor(coolRampCol, warmRampCol, DayTime);
    rampColor = lerp(f3one, rampColor, _ShadowBoost);
    mainLightColor *= baseColor * rampColor;


    //高光
    float3 specularColor = 0;
    #if _SPECULAR_ON
        #if _AREA_HAIR || _AREA_UPPERBODY || _AREA_LOWERBODY
            {
                //计算半程向量
                float3 halfVectorWS = normalize(viewDirectionWS + lightDirectionWS);
                float NoH = dot(normalWS, halfVectorWS);
                float blinnPhong = pow(saturate(NoH), _SpecularExpon);
                //非金属的反射率一般为0.04
                float nonMetalSpecular = step(1.04 - blinnPhong, specularThreshold) * _SpecularKsNonMetal;
                //金属反射率取1
                float metalSpecular = blinnPhong * specularThreshold * _SpecularKsMetal;

                float metallic = 0;
                #if _METAL_SPECULAR_ON
                    #if  _AREA_UPPERBODY || _AREA_LOWERBODY
                        //金属部分的Alpha值为0.52，此时metallic为1，以0.1为插值范围，确定金属度
                        metallic = saturate((abs(materialId - _MetalSpecularMetallic) - 0.1)/(0 - 0.1));
                    #endif
                #else
                    //因为头发没有金属，所以头发位置要关掉这个keyword
                    metallic = 0;
                #endif
                specularColor = lerp(nonMetalSpecular, metalSpecular * baseColor, metallic);
                #if _SPECULAR_COLOR_CUSTOM
                    //开启该keyword以使用自定义高光颜色
                    specularColor *= _SpecularColor;
                #else
                    //高光颜色与主光源的颜色同步
                    specularColor *= LightColor.rgb;
                #endif
                //强度系数
                specularColor *= _SpecularBrightness;
                specularColor *= mainLight.shadowAttenuation;
            }
        #endif
    #else
        specularColor = 0;
    #endif

    float3 stockingsEffect = 1;
    #if _STOCKINGS_ON
        #if _AREA_UPPERBODY || _AREA_LOWERBODY
            {
                float2 stockingsMapRG = 0;
                float stockingsMapB = 0;
                #if _AREA_UPPERBODY
                    stockingsMapRG = tex2D(_UpperBodyStockings, input.uv).rg;
                    stockingsMapB = tex2D(_UpperBodyStockings, input.uv * 20).b;
                #elif _AREA_LOWERBODY
                    stockingsMapRG = tex2D(_LowerBodyStockings, input.uv).rg;
                    stockingsMapB = tex2D(_LowerBodyStockings, input.uv * 20).b;
                #endif
                float NoV = dot(normalWS, viewDirectionWS);
                float fac = NoV;
                fac = pow(saturate(fac), _StockingsTransitionPower);
                fac = saturate((fac - _StockingsTransitionHardness/2)/(1 - _StockingsTransitionHardness));
                fac = fac * (stockingsMapB * _StockingsTextureUsage + (1 - _StockingsTextureUsage)); // 细节纹理
                fac = lerp(fac, 1, stockingsMapRG.g); // 厚度插值亮区
                Gradient curve = GradientConstruct();
                curve.colorsLength = 3;
                curve.colors[0] = float4(_StockingsDarkColor, 0);
                curve.colors[1] = float4(_StockingsTransitionColor, _StockingsTransitionThreshold);
                curve.colors[2] = float4(_StockingsLightColor, 1);
                float3 stockingsColor = SampleGradient(curve, fac);

                stockingsEffect = lerp(1, stockingsColor, stockingsMapRG.r);

            }
        #endif
    #else
        stockingsEffect = 1;
    #endif
    //边缘光部分
    float3 rimLightColor;
    #if _RIM_LIGHTING_ON
        {
            //获取当前片元的深度
            float linearEyeDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
            //根据视线空间的法线采样左边或者右边的深度图
            float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
            //根据视线空间的法线采样左边或者右边的深度图，根据深度缩放，实现近大远小的效果
            float2 uvOffset = float2(sign(normalVS.x), 0) * _RimLightWidth / (1 + linearEyeDepth) / 100;
            int2 loadTexPos = input.positionCS.xy + uvOffset * _ScaledScreenParams.xy;
            //限制左右，不采样到边界
            loadTexPos = min(max(loadTexPos, 0), _ScaledScreenParams.xy - 1);
            //偏移后的片元深度
            float offsetSceneDepth = LoadSceneDepth(loadTexPos);
            //转换为LinearEyeDepth
            float offsetLinearEyeDepth = LinearEyeDepth(offsetSceneDepth, _ZBufferParams);
            //深度差超过阈值，表示是边界
            float rimLight = saturate(offsetLinearEyeDepth - (linearEyeDepth + _RimLightThreshold)) / _RimLightFadeout;
            rimLightColor = rimLight * LightColor.rgb;
            rimLightColor *= _RimLightTintColor;
            rimLightColor *= _RimLightBrightness;
        }
    #else
        rimLightColor = 0;
    #endif

    float3 emissionColor = 0;
    #if _EMISSION_ON
        {
            emissionColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
                _HairColorMap, _HairColorMapColor,
                _UpperBodyColorMap, _UpperBodyColorMapColor,
                _LowerBodyColorMap, _LowerBodyColorMapColor).a;
            emissionColor *= LinearColorMix(f3one, baseColor, _EmissionMixBaseColor);
            emissionColor *= _EmissionTintColor;
            emissionColor *= _EmissionIntensity;
        }
    #endif

    float fakeOutlineEffect = 0;
    float3 fakeOutlineColor = 0;
    #if _AREA_FACE && _OUTLINE_ON && _FAKE_OUTLINE_ON
        {
            float fakeOutline = faceMap.b;
            float3 headForward = normalize(_HeadForward);
            fakeOutlineEffect = smoothstep(0.0, 0.25, pow(saturate(dot(headForward, viewDirectionWS)), 20) * fakeOutline);
            float2 outlineUV = float2(0, 0.0625);
            coolRampCol = tex2D(_BodyCoolRamp, outlineUV).rgb;
            warmRampCol = tex2D(_BodyWarmRamp, outlineUV).rgb;
            #if _USE_RAMP_COLOR_ON
                float3 OutlineRamp = abs(lerp(coolRampCol, warmRampCol, 0.5));
            #else
                float3 OutlineRamp = _OutlineColor.rgb;
            #endif
            fakeOutlineColor = pow(OutlineRamp, _OutlineGamma);
        }
    #endif

    float3 albedo = 0;
    albedo += indirectLightColor;
    albedo += mainLightColor;
    albedo += specularColor;
    albedo *= stockingsEffect;
    albedo += rimLightColor * lerp(1, albedo, _RimLightMixAlbedo);
    albedo += emissionColor;
    albedo = lerp(albedo, fakeOutlineColor, fakeOutlineEffect);

    float alpha = _Alpha;

    #if _DRAW_OVERLAY_ON
        {
            float3 headForward = normalize(_HeadForward);
            alpha = lerp(1, alpha, saturate(dot(headForward, viewDirectionWS)));
        }
    #endif

    float4 FinalColor = float4(albedo, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

    return FinalColor;
}

void SRUniversalFragment(
    CharCoreVaryings input,
    bool isFrontFace            : SV_IsFrontFace,
    out float4 colorTarget      : SV_Target0,
    out float4 bloomTarget      : SV_Target1)
{
    float4 outputColor = colorFragmentTarget(input, isFrontFace);

    colorTarget = float4(outputColor.rgba);
    bloomTarget = EncodeBloomColor(_BloomColor0.rgb, _mBloomIntensity0);
}

CharShadowVaryings CharacterShadowVertex(CharShadowAttributes input)
{
    return CharShadowVertex(input);
}

void CharacterShadowFragment(
    CharShadowVaryings input,
    bool isFrontFace            : SV_IsFrontFace)
{
    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
        _HairColorMap, _HairColorMapColor,
        _UpperBodyColorMap, _UpperBodyColorMapColor,
        _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _BaseColorRPower, _BaseColorGPower, _BaseColorBPower);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);
}

CharDepthOnlyVaryings CharacterDepthOnlyVertex(CharDepthOnlyAttributes input)
{
    return CharDepthOnlyVertex(input);
}

float4 CharacterDepthOnlyFragment(
    CharDepthOnlyVaryings input,
    bool isFrontFace            : SV_IsFrontFace) : SV_Target
{
    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
        _HairColorMap, _HairColorMapColor,
        _UpperBodyColorMap, _UpperBodyColorMapColor,
        _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _BaseColorRPower, _BaseColorGPower, _BaseColorBPower);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);

    return CharDepthOnlyFragment(input);
}

CharDepthNormalsVaryings CharacterDepthNormalsVertex(CharDepthNormalsAttributes input)
{
    return CharDepthNormalsVertex(input);
}

float4 CharacterDepthNormalsFragment(
    CharDepthNormalsVaryings input,
    bool isFrontFace            : SV_IsFrontFace) : SV_Target
{
    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
        _HairColorMap, _HairColorMapColor,
        _UpperBodyColorMap, _UpperBodyColorMapColor,
        _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _BaseColorRPower, _BaseColorGPower, _BaseColorBPower);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);

    return CharDepthNormalsFragment(input);
}

CharMotionVectorsVaryings CharacterMotionVectorsVertex(CharMotionVectorsAttributes input)
{
    return CharMotionVectorsVertex(input);
}

half4 CharacterMotionVectorsFragment(
    CharMotionVectorsVaryings input,
    bool isFrontFace            : SV_IsFrontFace) : SV_Target
{
    float3 baseColor = 0;
    baseColor = tex2D(_BaseMap, input.uv).rgb;
    baseColor = GetMainTexColor(input.uv, _FaceColorMap, _FaceColorMapColor,
        _HairColorMap, _HairColorMapColor,
        _UpperBodyColorMap, _UpperBodyColorMapColor,
        _LowerBodyColorMap, _LowerBodyColorMapColor).rgb;
    baseColor = RGBAdjustment(baseColor, _BaseColorRPower, _BaseColorGPower, _BaseColorBPower);
    //给背面填充颜色，对眼睛，丝袜很有用
    baseColor *= lerp(_BackFaceTintColor, _FrontFaceTintColor, isFrontFace);

    float alpha = _Alpha;
    float4 FinalColor = float4(baseColor, alpha);

    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);

    return CharMotionVectorsFragment(input);
}
