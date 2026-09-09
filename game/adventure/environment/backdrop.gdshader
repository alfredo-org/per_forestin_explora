shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D landscape_texture:source_color,filter_linear_mipmap,repeat_disable;
uniform vec3 tint:source_color=vec3(.8,.85,.90);
float hash(vec2 p){return fract(sin(dot(p,vec2(12.9898,78.233)))*43758.5453);}
void fragment(){
 vec4 sample_color=texture(landscape_texture,UV);
 float edge=smoothstep(0.0,.12,UV.x)*smoothstep(0.0,.12,1.0-UV.x)*smoothstep(0.0,.02,UV.y);
 if(sample_color.a*edge<max(.08,hash(FRAGCOORD.xy))){discard;}
 ALBEDO=sample_color.rgb*tint;
}
