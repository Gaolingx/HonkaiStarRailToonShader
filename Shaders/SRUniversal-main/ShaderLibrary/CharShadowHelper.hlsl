#include "Packages/com.stalomeow.star-rail-npr-shader/Shaders/Shadow/PerObjectShadow.hlsl"

Light GetCharPerObjectShadow(Light light, float3 positionWS, float perObjShadowCasterId)
{
    #if defined(_MAIN_LIGHT_SELF_SHADOWS)
        float selfShadow = MainLightPerObjectSelfShadow(positionWS, perObjShadowCasterId);
        light.shadowAttenuation = min(light.shadowAttenuation, selfShadow);
    #endif

    return light;
}
