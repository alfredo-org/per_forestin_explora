import {contactOcclusion} from './desktop-light';
import type {RenderPreference} from './performance';
import {renderDensity,adaptiveStep} from './performance';
import * as B from './babylon';
/** Tiny local sky cube gives curved helmets and eyes an actual environment reflection. */
export function skyEnvironment(scene:B.Scene,size=32){
 const faces:Uint8Array[]=[];
 for(let face=0;face<6;face++){
  const pixels=new Uint8Array(size*size*3);
  for(let y=0;y<size;y++)for(let x=0;x<size;x++){
   const u=(x+.5)/size*2-1,v=(y+.5)/size*2-1;
   const dirs=[[1,-v,-u],[-1,-v,u],[u,1,v],[u,-1,-v],[u,-v,1],[-u,-v,-1]];
   const d=B.Vector3.FromArray(dirs[face]).normalize(),h=Math.max(0,d.y);
   const sky=B.Color3.Lerp(new B.Color3(.52,.62,.65),new B.Color3(.16,.35,.59),Math.sqrt(h));
   const ground=new B.Color3(.20,.22,.12),c=d.y<0?B.Color3.Lerp(sky,ground,Math.min(1,-d.y*3)):sky;
   const glow=Math.pow(Math.max(0,B.Vector3.Dot(d,new B.Vector3(-.6,1,-.35).normalize())),28)*.28;
   pixels.set([Math.min(255,(c.r+glow)*255),Math.min(255,(c.g+glow*.8)*255),Math.min(255,(c.b+glow*.55)*255)],(y*size+x)*3);
  }
  faces.push(pixels);
 }
 const texture=new B.RawCubeTexture(scene,faces,size,B.Engine.TEXTUREFORMAT_RGB,B.Engine.TEXTURETYPE_UNSIGNED_BYTE,true,false);
 texture.name='Local Patagonian sky';texture.gammaSpace=false;
 const polynomial=new B.SphericalPolynomial();polynomial.addAmbient(new B.Color3(.20,.24,.25));polynomial.y.set(.035,.06,.10);texture.sphericalPolynomial=polynomial;
 scene.environmentTexture=texture;scene.environmentIntensity=.55;
}
/** Repeatable surface detail, authored locally; no network assets at runtime. */
export function surface(scene:B.Scene,name:string,scale:number,grain:number,n=256){
 const texture=new B.DynamicTexture(name,{width:n,height:n},scene,true),ctx=texture.getContext(),pixels=ctx.getImageData(0,0,n,n);
 const rock=name.includes('granite'),cloth=name.includes('cloth'),wood=name.includes('bark');
 const field=(x:number,y:number)=>cloth?Math.sin(x*Math.PI/2)*Math.sin(y*Math.PI/2)*.28+Math.cos(y*Math.PI)*.1:wood?Math.sin(x*.2945+Math.sin(y*.0491)*.65)*.42+Math.sin(x*.8836+y*.0245)*.18:rock?Math.sin(x*.098+y*.147)*.25+Math.sin(x*.245-y*.098)*.22-Math.pow(.5+.5*Math.sin(x*.1963+Math.sin(y*.0491)*1.3),18)*.55+Math.sin(x*1.571-y*1.178)*.13:Math.sin(x*.098+y*.147)*.3+Math.sin(x*.245-y*.098)*.2+Math.sin(x*.589+y*.442)*.13+Math.sin(x*1.571-y*1.178)*.07;
 for(let y=0;y<n;y++)for(let x=0;x<n;x++){const i=(y*n+x)*4,v=Math.round(212+field(x,y)*grain+Math.sin(x*12.9898+y*78.233)*grain*.15);pixels.data[i]=v;pixels.data[i+1]=v;pixels.data[i+2]=v;pixels.data[i+3]=255;}ctx.putImageData(pixels,0,0);texture.update();texture.uScale=scale;texture.vScale=scale;texture.anisotropicFilteringLevel=4;
 const bump=new B.DynamicTexture(name+' normals',{width:n,height:n},scene,true),bctx=bump.getContext(),normal=bctx.getImageData(0,0,n,n);for(let y=0;y<n;y++)for(let x=0;x<n;x++){const i=(y*n+x)*4,dx=field((x+1)%n,y)-field((x+n-1)%n,y),dy=field(x,(y+1)%n)-field(x,(y+n-1)%n);normal.data[i]=128-dx*45;normal.data[i+1]=128-dy*45;normal.data[i+2]=252;normal.data[i+3]=255;}bctx.putImageData(normal,0,0);bump.update();bump.uScale=scale;bump.vScale=scale;bump.level=.35;return {texture,bump};
}
export function cinematicPipeline(scene:B.Scene,camera:B.FreeCamera,software:boolean,mobile=false,onQuality:(quality:RenderPreference)=>void=()=>{}){
 scene.imageProcessingConfiguration.toneMappingEnabled=true;scene.imageProcessingConfiguration.toneMappingType=B.ImageProcessingConfiguration.TONEMAPPING_ACES;scene.imageProcessingConfiguration.exposure=1.08;scene.imageProcessingConfiguration.contrast=1.04;
 let quality:RenderPreference=mobile?'balanced':'ultra',adaptive=1,elapsed=0,total=0,samples=0;
 const preferenceKey=mobile?'forestin.quality.mobile.v2':'forestin.quality';
 try{const saved=localStorage.getItem(preferenceKey);if(saved==='balanced'||saved==='cinematic'||(!mobile&&saved==='ultra'))quality=saved;}catch{}
 let ao=!software&&!mobile?contactOcclusion(scene,camera,quality):null;
 let pipeline:B.DefaultRenderingPipeline|null=null;
 if(!software&&!mobile){try{pipeline=new B.DefaultRenderingPipeline('Patagonia cinematic',true,scene,[camera]);}catch(error){console.warn('Postprocessing unavailable; keeping direct 3D rendering.',error);}}
 if(pipeline){pipeline.fxaaEnabled=true;pipeline.bloomThreshold=.9;pipeline.bloomWeight=.1;pipeline.bloomKernel=32;pipeline.bloomScale=.35;pipeline.samples=1;pipeline.depthOfFieldEnabled=false;pipeline.sharpenEnabled=true;pipeline.sharpen.edgeAmount=.15;pipeline.sharpen.colorAmount=1;}
 function apply(){if(software)return;if(pipeline){pipeline.bloomEnabled=quality!=='balanced';pipeline.samples=quality==='ultra'?Math.max(1,Math.min(4,scene.getEngine().getCaps().maxMSAASamples||1)):1;}const canvas=scene.getEngine().getRenderingCanvas();const density=renderDensity(canvas?.clientWidth||1,canvas?.clientHeight||1,devicePixelRatio,mobile,quality,adaptive);scene.getEngine().setHardwareScalingLevel(1/density);}
 apply();onQuality(quality);return {mobile,resize:apply,sample(ms:number){if(software||ms>200||ms<1)return;elapsed+=ms;total+=ms;samples++;if(elapsed<2500)return;const next=adaptiveStep(adaptive,total/samples,mobile);elapsed=total=samples=0;if(next!==adaptive){adaptive=next;apply();}},toggle(){quality=mobile?(quality==='cinematic'?'balanced':'cinematic'):(quality==='balanced'?'cinematic':quality==='cinematic'?'ultra':'balanced');if(!software&&!mobile){pipeline?.removeCamera(camera);ao?.dispose(true);ao=contactOcclusion(scene,camera,quality);pipeline?.addCamera(camera);}adaptive=1;apply();onQuality(quality);try{localStorage.setItem(preferenceKey,quality);}catch{}},label(){return software?'Modo compatible':mobile?(quality==='cinematic'?'Móvil · detalle':'Móvil · fluida'):quality==='ultra'?'Ultra · PC':quality==='cinematic'?'Cinematográfica':'Equilibrada';}};
}
export function lakeMaterial(scene:B.Scene,reflective=false){
 B.Effect.ShadersStore['paineWaterVertexShader']=`precision highp float;attribute vec3 position;uniform mat4 world;uniform mat4 worldViewProjection;uniform float time;varying vec3 vWorld;void main(){vec3 p=position;p.y+=sin(p.x*.18+time*.7)*.028+sin(p.z*.23-time*.5)*.018;vWorld=(world*vec4(p,1.)).xyz;gl_Position=worldViewProjection*vec4(p,1.);}`;
 B.Effect.ShadersStore['paineWaterFragmentShader']=`precision highp float;varying vec3 vWorld;uniform vec3 cameraPosition;uniform float time;uniform float night;void main(){vec2 p=vWorld.xz;float a=cos(p.x*.18+time*.7)*.00504,b=cos(p.y*.23-time*.5)*.00414;float ripple=sin(p.x*2.8+p.y*1.7+time*1.5)*.023;vec3 n=normalize(vec3(-a+ripple,1.,-b+ripple*.6));float ground=3.8+sin(p.x*.065)*1.7+cos(p.y*.083)*1.05+sin(p.x*.18+p.y*.09)*.34-max(0.,p.x-2.)*.28;float depth=max(0.,.85-ground);vec3 eye=normalize(cameraPosition-vWorld);float fresnel=pow(1.-max(dot(eye,n),0.),3.);vec3 water=mix(vec3(.28,.59,.53),vec3(.055,.31,.38),1.-exp(-depth*.21));vec3 sky=vec3(.57,.72,.75);vec3 color=mix(water,sky,fresnel*.78);vec3 halfV=normalize(eye+normalize(vec3(-.6,1.,-.35)));float sun=pow(max(dot(n,halfV),0.),190.);color+=vec3(1.,.88,.57)*sun*.68;float edge=(1.-smoothstep(.04,.34,depth))*smoothstep(0.,.04,depth);color=mix(color,vec3(.78,.85,.75),edge*(.18+.12*sin(p.y*4.+time))); float fog=1.-exp(-length(cameraPosition-vWorld)*.0032);color=mix(color,vec3(.67,.76,.76),fog);color=mix(color,color*vec3(.14,.22,.36),night);gl_FragColor=vec4(color,1.);}`;
 const shader=reflective?'paineWaterDesktop':'paineWater';
 if(reflective){
  B.Effect.ShadersStore[shader+'VertexShader']=B.Effect.ShadersStore['paineWaterVertexShader'].replace('varying vec3 vWorld;','varying vec3 vWorld;uniform mat4 reflectionViewProjection;varying vec4 vReflection;').replace('gl_Position=','vReflection=reflectionViewProjection*vec4(vWorld,1.);gl_Position=');
  B.Effect.ShadersStore[shader+'FragmentShader']=B.Effect.ShadersStore['paineWaterFragmentShader'].replace('void main(){','uniform sampler2D reflectionSampler;uniform float reflectionEnabled;varying vec4 vReflection;void main(){').replace('vec3 color=mix(water,sky,fresnel*.78);','vec3 reflectedSky=sky;if(reflectionEnabled>.5&&vReflection.w>0.){vec2 uv=vReflection.xy/vReflection.w*.5+.5+n.xz*.022;float valid=step(0.,uv.x)*step(uv.x,1.)*step(0.,uv.y)*step(uv.y,1.);vec3 reflection=texture2D(reflectionSampler,clamp(uv,vec2(.002),vec2(.998))).rgb;reflectedSky=mix(sky,reflection,valid);}vec3 color=mix(water,reflectedSky,.08+fresnel*.7);');
 }
 const m=new B.ShaderMaterial('moving glacial lake',scene,{vertex:shader,fragment:shader},{attributes:['position'],uniforms:['world','worldViewProjection','cameraPosition','time','night',...(reflective?['reflectionViewProjection','reflectionEnabled']:[])],samplers:reflective?['reflectionSampler']:[]});m.backFaceCulling=false;m.setFloat('time',0);m.setFloat('night',0);
 if(reflective){m.setMatrix('reflectionViewProjection',B.Matrix.Identity());m.setFloat('reflectionEnabled',0);m.setTexture('reflectionSampler',new B.RawTexture(new Uint8Array([145,184,191,255]),1,1,B.Engine.TEXTUREFORMAT_RGBA,scene,false,false));}
 return m;
}

/** Wind bends only grass tips. One draw call, no CPU vertex updates. */
export function grassMaterial(scene:B.Scene){
 B.Effect.ShadersStore['paineGrassVertexShader']=`precision highp float;attribute vec3 position;attribute vec3 normal;attribute vec4 color;uniform mat4 worldViewProjection;uniform float time;varying vec4 vColor;varying vec3 vPosition;varying vec3 vNormal;void main(){vec3 p=position;float ground=3.8+sin(p.x*.065)*1.7+cos(p.z*.083)*1.05+sin(p.x*.18+p.z*.09)*.34-max(0.,p.x-2.)*.28;float tip=max(0.,p.y-ground);float gust=sin(time*1.6+p.x*.22+p.z*.16)*.12+sin(time*2.8+p.z*.6)*.025;p.x+=gust*tip;p.z+=gust*.4*tip;vColor=color;vPosition=p;vNormal=normal;gl_Position=worldViewProjection*vec4(p,1.);}`;
 B.Effect.ShadersStore['paineGrassFragmentShader']=`precision highp float;varying vec4 vColor;varying vec3 vPosition;varying vec3 vNormal;uniform vec3 cameraPosition;uniform float night;void main(){float light=.62+.35*abs(dot(normalize(vNormal),normalize(vec3(-.6,1.,-.35))));vec3 color=vColor.rgb*light;float distanceFog=1.-exp(-length(cameraPosition-vPosition)*.0032);color=mix(color,vec3(.65,.77,.79),distanceFog);color=mix(color,color*vec3(.20,.28,.37),night);gl_FragColor=vec4(color,1.);}`;
 const material=new B.ShaderMaterial('wind through golden grasses',scene,{vertex:'paineGrass',fragment:'paineGrass'},{attributes:['position','normal','color'],uniforms:['worldViewProjection','time','cameraPosition','night']});material.backFaceCulling=false;material.setFloat('time',0);material.setFloat('night',0);return material;
}
