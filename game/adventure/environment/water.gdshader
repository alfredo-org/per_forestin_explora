shader_type spatial;
render_mode cull_disabled;
varying vec3 p;
void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 float a=sin(p.x*1.6+p.z*.8+TIME*.8);
 float b=sin(p.x*.7-p.z*2.2+TIME*1.1);
 NORMAL_MAP=normalize(vec3(a*.085,b*.065,1.0))*.5+.5;
 NORMAL_MAP_DEPTH=.6;
 float fresnel=pow(1.0-clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0),3.0);
 ALBEDO=mix(vec3(.025,.20,.235),vec3(.26,.47,.51),fresnel*.65)+(a*b)*.012;
 ROUGHNESS=.23;METALLIC=.08;SPECULAR=.65;
}
