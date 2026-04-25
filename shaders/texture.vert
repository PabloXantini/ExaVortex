uniform FrameInfo {
  mat4 mvp;
}
frame_info;

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texture_coords;
layout (location = 2) in vec4 color;
out vec2 v_texture_coords;
out vec4 v_color;

void main() {
  v_texture_coords = texture_coords;
  v_color = color;
  gl_Position = frame_info.mvp * vec4(position, 1.0);
}