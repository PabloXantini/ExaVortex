uniform sampler2D char_text;

in vec2 v_texture_coords;
in vec4 v_color;

out vec4 frag_color;

const float smoothing = 1.0 / 16.0;

void main() {
  float distance = texture(char_text, v_texture_coords).a;
  float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
  
  frag_color = vec4(v_color.rgb, v_color.a * alpha);
}
