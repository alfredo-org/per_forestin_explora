shader_type spatial;
render_mode cull_disabled, diffuse_burley;
varying vec3 world_position;
void vertex(){
 world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 VERTEX.x+=sin(TIME*1.3+world_position.x*.7+world_position.z*.4)*.018;
 VERTEX.z+=sin(TIME*.85+world_position.x)*.012;
}
void fragment(){
 float vein=1.0-smoothstep(.0,.055,abs(UV.x-.5));
 ALBEDO=COLOR.rgb*(.88+UV.y*.16)+vec3(.035,.025,.005)*vein;
 ROUGHNESS=.86;
 if(!FRONT_FACING){NORMAL=-NORMAL;ALBEDO*=.80;}
}
