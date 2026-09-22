shader_type spatial;
render_mode diffuse_burley;
uniform vec4 fabric_color : source_color = vec4(.8,.5,.1,1.0);
void fragment(){
 // Fade the fine weave at distance instead of allowing shimmering or moire.
 vec2 thread=UV*vec2(120.0,100.0);
 float footprint=max(length(dFdx(thread)),length(dFdy(thread)));
 float visibility=1.0-smoothstep(.3,1.0,footprint);
 float weave=sin(thread.x*6.283185)*sin(thread.y*6.283185);
 ALBEDO=fabric_color.rgb*(.97+.025*weave*visibility);
 ROUGHNESS=.92;
 SPECULAR=.16;
}
