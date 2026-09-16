shader_type spatial;
render_mode cull_disabled, diffuse_burley;
varying vec3 world_position;
void vertex(){
 world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 float flex=UV.y*UV.y;
 VERTEX.x+=sin(TIME*1.3+world_position.x*.7+world_position.z*.4)*.022*flex;
 VERTEX.z+=sin(TIME*.85+world_position.x)*.014*flex;
}
void fragment(){
 float center_distance=abs(UV.x-.5);
 float vein=1.0-smoothstep(.008,.028,center_distance);
 float rib=1.0-smoothstep(.02,.08,abs(fract(UV.y*7.0-center_distance*4.0)-.5));
 float edge=smoothstep(.27,.5,center_distance);
 ALBEDO=COLOR.rgb*(.92+UV.y*.11-edge*.10)+vec3(.035,.042,.011)*(vein+rib*.18);
 ROUGHNESS=.78;
 SPECULAR=.22;
 // Soft underside fill helps crowns read as foliage rather than dark paper facets.
 if(!FRONT_FACING){NORMAL=-NORMAL;ALBEDO*=.91;}
 BACKLIGHT=COLOR.rgb*.18;
}
