#ifndef _SR_UNIVERSAL_COMMON_PASS_INCLUDED
#define _SR_UNIVERSAL_COMMON_PASS_INCLUDED

struct Attributes
{

};

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
