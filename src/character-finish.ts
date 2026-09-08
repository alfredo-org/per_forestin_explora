import * as B from './babylon';

/** Opaque, tapered, combed fur. Five triangles per fiber, one draw call per patch. */
function combedCoat(scene:B.Scene,parent:B.TransformNode,name:string,center:B.Vector3,radii:B.Vector3,count:number,tint:string,length:number,keep:(n:B.Vector3)=>boolean=()=>true){
 const positions:number[]=[],normals:number[]=[],indices:number[]=[],colors:number[]=[];
 const base=B.Color3.FromHexString(tint);
 let seed=7817;const rand=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
 for(let i=0;i<count;i++){
  const y=1-2*(i+.5)/count,a=i*2.3999632297,s=Math.sqrt(1-y*y),n=new B.Vector3(Math.cos(a)*s,y,Math.sin(a)*s);
  if(!keep(n))continue;
  const normal=new B.Vector3(n.x/radii.x,n.y/radii.y,n.z/radii.z).normalize();
  const point=center.add(new B.Vector3(n.x*radii.x,n.y*radii.y,n.z*radii.z)).subtract(normal.scale(.005));
  const down=new B.Vector3(n.x*.25,-1,.16);let comb=down.subtract(normal.scale(B.Vector3.Dot(down,normal)));
  if(comb.lengthSquared()<.001)comb=B.Vector3.Cross(normal,B.Vector3.Right());comb.normalize();
  const across=B.Vector3.Cross(normal,comb).normalize(),len=length*(.65+rand()*.7),width=len*(.075+rand()*.06),curl=(rand()-.5)*len*.18;
  const vertexStart=positions.length/3,color=base.scale(.86+rand()*.25);
  // Narrow ribbon curls along the surface, with just enough lift to soften silhouettes.
  for(let row=0;row<3;row++){
   const t=row/3,mid=point.add(comb.scale(len*t)).add(normal.scale(len*(.10+t*.26))).add(across.scale(curl*t*t));
   for(const side of [-1,1]){
    const v=mid.add(across.scale(side*width*(1-t*.78)));positions.push(v.x,v.y,v.z);normals.push(normal.x,normal.y,normal.z);
    const shade=.83+t*.20;colors.push(color.r*shade,color.g*shade,color.b*shade,1);
   }
  }
  const tip=point.add(comb.scale(len)).add(normal.scale(len*.29)).add(across.scale(curl));positions.push(tip.x,tip.y,tip.z);normals.push(normal.x,normal.y,normal.z);colors.push(color.r*1.08,color.g*1.08,color.b*1.08,1);
  for(const v of [0,1,2,1,3,2,2,3,4,3,5,4,4,5,6])indices.push(vertexStart+v);
 }
 const mesh=new B.Mesh(name,scene),data=new B.VertexData();Object.assign(data,{positions,normals,indices,colors});data.applyToMesh(mesh);mesh.parent=parent;mesh.isPickable=false;mesh.receiveShadows=true;
 const mat=new B.PBRMaterial(name+' soft fibers',scene);mat.albedoColor=B.Color3.White();mat.metallic=0;mat.roughness=.97;mat.backFaceCulling=false;mat.twoSidedLighting=true;mat.sheen.isEnabled=true;mat.sheen.intensity=.3;mat.sheen.color=B.Color3.FromHexString('#e0c08c');mat.sheen.roughness=.85;mesh.material=mat;
 return mesh;
}

/** Call once AFTER existing PBR conversion, and only when !mobile && !software. */
export function desktopCharacterFinish(scene:B.Scene,player:B.TransformNode,animals:B.TransformNode[]){
 const meshes:B.Mesh[]=[];
 const body=player.getChildTransformNodes(false).find(n=>n.name==='walking body');
 const head=player.getChildTransformNodes(false).find(n=>n.name==='head rig');
 if(!body||!head)return meshes;
 // Existing short tufts remain an undercoat. Longer ribbons only occupy visible face regions.
 meshes.push(combedCoat(scene,head,'Forestin combed guard hairs',new B.Vector3(0,.17,.04),new B.Vector3(.505,.43,.405),1550,'#b48240',.09,n=>n.y<.48&&!(n.z<-.65&&n.y>.12)));
 for(const side of [-1,1])meshes.push(combedCoat(scene,head,'Forestin flowing cheek fur',new B.Vector3(side*.17,.04,-.43),new B.Vector3(.251,.207,.222),360,'#d8aa61',.068,n=>!(n.z<-.6&&n.x*side<-.15)));
 for(const animal of animals){
  meshes.push(combedCoat(scene,animal,'guanaco soft shoulder coat',new B.Vector3(0,1.17,0),new B.Vector3(.32,.351,.751),530,'#a97a4e',.069,n=>n.y>-.55));
  const neck=animal.getChildTransformNodes(false).find(n=>n.name==='articulated neck');
  if(neck)meshes.push(combedCoat(scene,neck,'guanaco neck fleece',new B.Vector3(0,.4,-.07),new B.Vector3(.157,.498,.178),180,'#a97a4e',.053,n=>n.z>-.65));
 }
 // Sewn hems use one opaque batched mesh and follow the walking body.
 const stitches:B.Mesh[]=[];
 const thread=new B.PBRMaterial('ranger topstitch thread',scene);thread.albedoColor=B.Color3.FromHexString('#c1b999');thread.roughness=.98;thread.metallic=0;
 const stitch=(x:number,y:number,z:number,horizontal:boolean)=>{const m=B.MeshBuilder.CreateBox('uniform stitch',{width:horizontal?.025:.006,height:horizontal?.006:.025,depth:.004},scene);m.position.set(x,y,z);m.material=thread;stitches.push(m);};
 for(const side of [-1,1]){
  for(let i=0;i<6;i++)stitch(side*.2-.09+i*.036,1.50,-.373,true);
  for(let i=0;i<5;i++){stitch(side*.2-.104,1.32+i*.035,-.341,false);stitch(side*.2+.104,1.32+i*.035,-.341,false);}
 }
 for(let i=0;i<13;i++)stitch(.022,1.08+i*.037,-.341,false);
 const seams=B.Mesh.MergeMeshes(stitches,true,true,undefined,false,false);if(seams){seams.name='ranger sewn pocket details';seams.parent=body;seams.isPickable=false;seams.receiveShadows=true;meshes.push(seams);}
 // Existing PBR surfaces gain appropriate, restrained grazing-light response.
 for(const material of scene.materials){
  if(!(material instanceof B.PBRMaterial))continue;
  if(/fur|muzzle|undercoat|woven|shirt|canvas|trousers|glove/i.test(material.name)){
   material.sheen.isEnabled=true;material.sheen.intensity=/fur|muzzle|undercoat/i.test(material.name)?.24:.12;material.sheen.roughness=.85;material.sheen.color=new B.Color3(.8,.7,.52);
  }
  if(material.name==='green Forestin helmet physical'){material.clearCoat.isEnabled=true;material.clearCoat.intensity=.22;material.clearCoat.roughness=.36;}
 }
 return meshes;
}
