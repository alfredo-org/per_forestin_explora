shader_type spatial;
render_mode cull_disabled, diffuse_burley;
varying vec3 blade_color;
void vertex(){
 vec3 p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 float gust=sin(TIME*1.3+p.x*.36+p.z*.22)+.35*sin(TIME*2.1+p.z*.8);
 VERTEX.x+=gust*VERTEX.y*VERTEX.y*.32;
 VERTEX.z+=cos(TIME*.8+p.x*.21)*VERTEX.y*VERTEX.y*.13;
 blade_color=COLOR.rgb;
}
void fragment(){
 if(!FRONT_FACING){NORMAL=-NORMAL;}
 ALBEDO=blade_color*mix(.64,1.10,clamp(UV.y,0.0,1.0));
 ROUGHNESS=.93;
 BACKLIGHT=blade_color*.22;
}
