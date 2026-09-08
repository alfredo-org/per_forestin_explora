import * as B from './babylon';
import type {RenderPreference} from './performance';

/** Limited scenery-only reflection, managed separately from the main camera. */
export function lakeReflection(scene:B.Scene,water:B.ShaderMaterial){
 let mirror:B.MirrorTexture|null=null;
 try{
  mirror=new B.MirrorTexture('Paine landscape in the lake',768,scene,false,B.Engine.TEXTURETYPE_UNSIGNED_BYTE);
  mirror.mirrorPlane=new B.Plane(0,-1,0,.85);mirror.refreshRate=2;
  mirror.useCameraPostProcesses=false;mirror.renderParticles=false;mirror.disableImageProcessing=true;mirror.gammaSpace=false;
  mirror.renderList=scene.meshes.filter(m=>m.name==='sky'||!!m.metadata?.occluder||!!m.metadata?.backdrop);
  mirror.onBeforeRenderObservable.add(()=>water.setMatrix('reflectionViewProjection',scene.getTransformMatrix().clone()));
  water.setTexture('reflectionSampler',mirror);
 }catch(error){mirror?.dispose();mirror=null;console.warn('Lake reflection unavailable; keeping analytical water.',error);}
 function apply(quality:RenderPreference){
  if(!mirror)return;const enabled=quality!=='balanced';
  const index=scene.customRenderTargets.indexOf(mirror);
  if(enabled&&index<0){scene.customRenderTargets.push(mirror);mirror.resetRefreshCounter();}
  if(!enabled&&index>=0)scene.customRenderTargets.splice(index,1);
  mirror.refreshRate=quality==='ultra'?1:2;water.setFloat('reflectionEnabled',enabled?1:0);
 }
 return {apply};
}

/** This must attach before the color/AA pipeline. */
export function contactOcclusion(scene:B.Scene,camera:B.FreeCamera,quality:RenderPreference){
 if(quality==='balanced'||!B.SSAO2RenderingPipeline.IsSupported||!scene.getEngine().getCaps().drawBuffersExtension)return null;
 let ao:B.SSAO2RenderingPipeline|null=null;
 try{
  ao=new B.SSAO2RenderingPipeline('Paine contact shadows',scene,{ssaoRatio:.5,blurRatio:1},[camera],true);
  ao.radius=.6;ao.totalStrength=.6;ao.base=.18;ao.maxZ=65;ao.epsilon=.025;
  ao.samples=quality==='ultra'?16:8;ao.textureSamples=1;ao.expensiveBlur=true;ao.bilateralSamples=8;ao.bilateralSoften=.35;
 }catch(error){ao?.dispose(true);ao=null;console.warn('Contact shadows unavailable; retaining direct light.',error);}
 return ao;
}
