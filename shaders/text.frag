#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D text_atlas;

in vec2 v_texture_coords;
in vec4 v_color;

out vec4 frag_color;

void main() {
    //float distance = texture(text_atlas, v_texture_coords).a;    
    //float smoothing = fwidth(distance);
    //float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
    //if (alpha < 0.01) discard;
    frag_color = v_color * texture(text_atlas, v_texture_coords); // frag_color vec4(v_color.rgb, v_color.a * alpha);
}
