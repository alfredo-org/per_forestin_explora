shader_type spatial;
render_mode diffuse_burley;
varying vec3 world_position;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 p=world_position.xz;
 float broad=noise(p*.19)*.65+noise(p*.7)*.35;
 float fine=noise(p*17.0);
 float stone=smoothstep(.72,.90,noise(p*6.0));
 vec3 meadow=mix(vec3(.075,.10,.042),vec3(.20,.19,.075),broad);
 vec3 dirt=mix(vec3(.23,.18,.105),vec3(.34,.28,.17),noise(p*1.9));
 float trail=1.0-smoothstep(.9,2.1,UV2.x+(noise(p*2.0)-.5)*.45);
 ALBEDO=mix(meadow,dirt,trail)*(0.88+fine*.22);
 ALBEDO=mix(ALBEDO,vec3(.30,.29,.25),stone*.24);
 ROUGHNESS=.94;
 NORMAL_MAP=normalize(vec3((noise(p*19.0)-.5)*.10,(noise(p*19.0+vec2(3,8))-.5)*.10,1.0))*.5+.5;
 NORMAL_MAP_DEPTH=.45;
}
