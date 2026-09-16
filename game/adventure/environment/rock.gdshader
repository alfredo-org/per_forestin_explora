shader_type spatial;
render_mode diffuse_burley;
varying vec3 p;
varying vec3 n;
float hash(vec3 v){return fract(sin(dot(v,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 v){vec3 i=floor(v);vec3 f=fract(v);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){p=VERTEX;n=NORMAL;}
void fragment(){
 float grain=noise(p*48.0);float mottling=noise(p*5.0)*.7+noise(p*12.0)*.3;
 vec3 stone=mix(vec3(.20,.22,.22),vec3(.40,.41,.37),mottling);
 float moss=smoothstep(.25,.8,n.y)*smoothstep(.40,.72,noise(p*8.0));
 ALBEDO=mix(stone,vec3(.22,.27,.12),moss*.65)*(0.90+grain*.18);
 ROUGHNESS=.92;
}
