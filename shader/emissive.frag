layout(location = 0) out vec4 fragcolor;
 
layout(binding = 1) uniform sampler2D color_buffer;
layout(binding = 2) uniform sampler2D normal_buffer;
layout(binding = 3) uniform sampler2D depth_buffer;

void main() {
  GBufferSample gbuffer = sample_gbuffer(color_buffer, normal_buffer, depth_buffer);
  fragcolor.rgb = gbuffer.emissive * gbuffer.color;
  fragcolor.a = 1.f;
}
