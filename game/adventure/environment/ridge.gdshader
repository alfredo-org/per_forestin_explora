shader_type spatial;
varying vec3 p;
float hash(vec2 q){return fract(sin(dot(q,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 q){vec2 i=floor(q);vec2 f=fract(q);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 float bands=noise(vec2(p.x*.25+p.y*.3,p.z*.22))*0.7+noise(p.xz*1.8)*0.3;
 ALBEDO=mix(vec3(.09,.12,.115),vec3(.24,.27,.235),bands);
 ROUGHNESS=1.0;
}
