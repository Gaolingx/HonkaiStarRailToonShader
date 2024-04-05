float3 MixBloomColor(float3 colorTarget, float3 bloomColor, float bloomIntensity)
{
    return colorTarget * (1 + max(0, bloomIntensity) * bloomColor);
}