shader_type spatial;
varying vec3 p;
varying vec3 rock_normal;
float hash(vec3 q){return fract(sin(dot(q,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 q){vec3 i=floor(q);vec3 f=fract(q);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;rock_normal=MODEL_NORMAL_MATRIX*NORMAL;}
void fragment(){
 float large=noise(p*vec3(.23,.055,.23));
 float fracture=noise(p*vec3(1.8,.16,1.8));
 float grain=noise(p*3.2);
 vec3 stone=mix(vec3(.22,.24,.24),vec3(.48,.44,.36),large);
 stone*=.72+.38*fracture+.10*grain;
 float ledge=smoothstep(.35,.72,normalize(rock_normal).y);
 float snow=ledge*smoothstep(22.0,40.0,p.y+large*8.0);
 ALBEDO=mix(stone,vec3(.76,.82,.83),snow);
 ROUGHNESS=.96;SPECULAR=.18;
}
