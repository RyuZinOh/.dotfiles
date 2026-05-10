#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
};

layout(binding = 1) uniform sampler2D source;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float minDist = 1.0;
    
    for(int j = -1; j <= 1; j++) {
        for(int i = -1; i <= 1; i++) {
            vec2 neighbor = vec2(float(i), float(j));
            vec2 point = hash(n + neighbor) * vec2(1.0) + neighbor;
            vec2 diff = point - f;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    
    return minDist;
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for(int i = 0; i < 3; i++) {
        value += amplitude * noise(p);
        p *= 2.3;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 uv = qt_TexCoord0;
    float t = time * 0.4;
    
    vec2 flameUV = uv;
    
    float heightFactor = pow(1.0 - uv.y, 1.5);
    
    float vor1 = voronoi(vec2(uv.x * 6.0, uv.y * 8.0 - t * 3.0));
    float vor2 = voronoi(vec2(uv.x * 12.0, uv.y * 15.0 - t * 4.5));
    
    float sharpNoise = vor1 * vor2;
    sharpNoise = pow(sharpNoise, 0.7);
    
    flameUV.x += (sharpNoise - 0.5) * 0.15 * heightFactor;
    
    float turbulence = fbm(vec2(uv.x * 8.0, uv.y * 10.0 - t * 5.0));
    flameUV.x += (turbulence - 0.5) * 0.08 * heightFactor;
    
    float vertWave = sin(uv.x * 15.0 + t * 4.0) * 0.03 * heightFactor;
    flameUV.y += vertWave;
    
    vec4 color = texture(source, flameUV);
    
    float edgeSharp = voronoi(vec2(uv.x * 10.0, uv.y * 12.0 - t * 3.5));
    edgeSharp = pow(edgeSharp, 0.5);
    
    float flicker = fbm(vec2(uv.x * 15.0, t * 8.0)) * 0.4 + 0.6;
    float bottomGlow = pow(1.0 - uv.y, 2.5) * flicker * edgeSharp;
    
    color.rgb *= 1.0 + bottomGlow * 0.7;
    
    float edgeGlow = (1.0 - abs(uv.x - 0.5) * 2.0) * bottomGlow * 0.5;
    color.rgb += color.rgb * edgeGlow * edgeSharp;
    
    float topFade = smoothstep(0.98, 0.65, uv.y);
    color.a *= topFade;
    
    fragColor = color * qt_Opacity;
}
