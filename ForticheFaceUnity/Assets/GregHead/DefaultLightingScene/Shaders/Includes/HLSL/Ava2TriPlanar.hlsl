#ifndef Ava2_TRIPLANAR_INCLUDED
#define Ava2_TRIPLANAR_INCLUDED

/// Calculates a tri-planar uv blend based on position/normal values
half2 CalculateTriPlanarBlend(float3 worldPosition, float3 worldNormal, half4 texture_ST)
{
    half3 triplanarBlend = abs(worldNormal);
    triplanarBlend /= dot(triplanarBlend, half3(1.0, 1.0, 1.0));

    half2 uvX = worldPosition.zy * texture_ST.xy + texture_ST.zw;
    half2 uvY = worldPosition.xz * texture_ST.xy + texture_ST.zw;
    half2 uvZ = worldPosition.xy * texture_ST.xy + texture_ST.zw;

    // Ternary operator is 2 instructions faster than sign() when we don't care about zero returning a zero sign.
    half3 axisSign = worldNormal < 0 ? -1 : 1;
    uvX.x *= axisSign.x;
    uvY.x *= axisSign.y;
    uvZ.x *= -axisSign.z;

    half absX = abs(triplanarBlend.x);
    half absY = abs(triplanarBlend.y);
    half absZ = abs(triplanarBlend.z);

    // if/else/else should be further optimized
    half2 uvs;
    if (absX > absY && absX > absZ)
    {
        uvs = uvX;
    }
    else if (absY > absX && absY > absZ)
    {
        uvs = uvY;
    }
    else
    {
        uvs = uvZ;
    }

    return uvs;
}

#endif // Ava2_TRIPLANAR_INCLUDED
