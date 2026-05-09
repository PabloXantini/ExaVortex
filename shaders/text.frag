uniform sampler2D char_text;

in vec2 v_texture_coords;
in vec4 v_color;

out vec4 frag_color;

void main() {
  // We store the distance in the red channel
  float distance = texture(char_text, v_texture_coords).r;
  
  // Use derivatives to calculate the width for smoothing
  // This provides consistent anti-aliasing across scales
  float width = fwidth(distance);
  float alpha = smoothstep(0.5 - width, 0.5 + width, distance);
  
  frag_color = vec4(v_color.rgb, v_color.a * alpha);
}
