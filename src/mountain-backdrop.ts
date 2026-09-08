import * as B from './babylon';

/** Fixed world-space matte painting: nearby geometry supplies the parallax.
 * Keep the original range until the image loads successfully. No placement RNG.
 */
export function mountainBackdrop(scene:B.Scene){
 const originals=scene.meshes.filter(m=>m.name.startsWith('Torre')||['western massif','eastern massif','granite base'].includes(m.name)||
  (m.name==='distant Andes'&&Math.abs(m.getBoundingInfo().boundingBox.centerWorld.x)<145));
 const mountain=B.MeshBuilder.CreatePlane('Torres del Paine illustrated range',{width:270,height:180},scene);
 mountain.position.set(-7,51,-270);
 mountain.isPickable=false;
 mountain.metadata={backdrop:true};
 mountain.setEnabled(false);
 const material=new B.StandardMaterial('Paine matte painting',scene);
 material.backFaceCulling=false;
 material.disableLighting=true;
 material.diffuseColor=B.Color3.Black();
 material.emissiveColor=B.Color3.White();
 material.specularColor=B.Color3.Black();
 // Alpha testing writes depth and avoids a transparent rectangle over the sky.
 // The high cutoff removes the soft translucent fringe from the generated cutout.
 material.transparencyMode=B.Material.MATERIAL_ALPHATEST;
 material.alphaCutOff=.8;
 material.useAlphaFromDiffuseTexture=true;
 mountain.material=material;
 const texture=new B.Texture('./assets/torres-paine-v1.png',scene,false,true,B.Texture.TRILINEAR_SAMPLINGMODE,
  ()=>{if(scene.isDisposed)return;mountain.setEnabled(true);originals.forEach(m=>m.setEnabled(false));},
  ()=>console.warn('Mountain illustration unavailable; retaining the 3D range.'));
 texture.hasAlpha=true;
 texture.wrapU=texture.wrapV=B.Texture.CLAMP_ADDRESSMODE;
 texture.anisotropicFilteringLevel=8;
 material.diffuseTexture=texture;
 return {night(value:boolean){material.emissiveColor=value?new B.Color3(.14,.19,.29):B.Color3.White();}};
}
