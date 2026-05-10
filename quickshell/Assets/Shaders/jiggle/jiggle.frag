#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 mousePos;
    float time;
    float intensity;
} ubuf;

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 uv = qt_TexCoord0;
    
    vec2 jiggleCenter = ubuf.mousePos;
    float jiggleRadius = 0.18;
    
    float dist = distance(uv, jiggleCenter);
    float falloff = smoothstep(jiggleRadius, 0.0, dist);
    
    vec2 offset = vec2(0.0);
    if (falloff > 0.0) {
        float t = ubuf.time;
        float dampingFactor = 3.5;
        float decay = exp(-t * dampingFactor);
        
        float naturalFreq = 18.0;
        float verticalBias = 1.8;
        
        float phase = t * naturalFreq;
        float envelope = decay * falloff * ubuf.intensity;
        
        offset.y = sin(phase) * envelope * 0.025 * verticalBias;
        
        float horizontalDamping = 0.4;
        offset.x = sin(phase * 1.3 + 0.5) * envelope * 0.012 * horizontalDamping;
        
        float secondaryFreq = naturalFreq * 2.2;
        float secondaryDecay = exp(-t * dampingFactor * 1.8);
        offset.y += sin(t * secondaryFreq) * secondaryDecay * falloff * ubuf.intensity * 0.008;
        
        float softness = 1.0 - pow(falloff, 0.6);
        offset *= mix(1.0, 0.7, softness);
    }
    
    vec2 samplingUV = uv + offset;
    vec4 color = texture(source, samplingUV);
    
    fragColor = color * ubuf.qt_Opacity;
}
