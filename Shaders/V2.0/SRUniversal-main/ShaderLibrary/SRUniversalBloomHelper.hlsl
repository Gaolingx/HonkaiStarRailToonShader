static const float bloomIntensityRange = 100.0;

float4 EncodeBloomColor(float3 color, float intensity)
{
    return float4(color, saturate(intensity * (1.0 / bloomIntensityRange)));
}

float3 DecodeBloomColor(float4 bloom)
{
    float intensity = bloom.a * bloomIntensityRange;
    return bloom.rgb * intensity;
}
