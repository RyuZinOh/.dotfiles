#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
};
layout(binding = 1) uniform sampler2D source;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float random2(vec2 st) {
    return fract(sin(dot(st.xy, vec2(93.9898, 67.345))) * 28653.5453123);
}

void main() {
    vec2 uv = qt_TexCoord0;
    
    float flameWave1 = sin(uv.y * 12.0 + time * 3.0) * 0.015;
    float flameWave2 = sin(uv.y * 18.0 - time * 4.5) * 0.01;
    float flameWave3 = cos(uv.y * 25.0 + time * 2.5) * 0.008;
    uv.x += flameWave1 + flameWave2 + flameWave3;
    
    vec4 col = texture(source, uv);
    
    float flicker = sin(time * 8.0) * 0.03 + sin(time * 15.0) * 0.02;
    col.rgb *= 1.0 + flicker;
    
    vec2 sparkleUV = qt_TexCoord0 * 12.0;
    sparkleUV.y += time * 0.6;
    sparkleUV.x += sin(sparkleUV.y * 2.0 + time) * 0.3;
    
    float sparkle = random(floor(sparkleUV));
    float sparkle2 = random2(floor(sparkleUV));
    float sparkleTime = fract(sparkle * 7.0 + time * 0.4);
    
    if (sparkle > 0.94 && sparkleTime < 0.4) {
        vec2 sparklePos = fract(sparkleUV) - 0.5;
        
        float angle = atan(sparklePos.y, sparklePos.x);
        float dist = length(sparklePos);
        
        float triangle = abs(mod(angle + 3.14159, 2.09439) - 1.0472);
        triangle = smoothstep(0.8, 0.3, triangle / dist);
        
        float fade = 1.0 - sparkleTime / 0.4;
        float intensity = triangle * fade;
        
        vec3 sparkleColor = mix(vec3(1.0, 1.0, 1.0), vec3(0.8, 0.6, 1.0), sparkle2);
        col.rgb += sparkleColor * intensity * 0.6;
    }
    
    fragColor = col * qt_Opacity;
}
