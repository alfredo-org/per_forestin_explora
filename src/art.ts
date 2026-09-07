import * as B from './babylon';

/** Small opaque geometry details: no fur shells or transparent sorting cost. */
export function furTufts(scene:B.Scene,parent:B.TransformNode,center:B.Vector3,radii:B.Vector3,count:number,color:string,name='fur detail'){
 const positions:number[]=[],indices:number[]=[],colors:number[]=[];
 const base=B.Color3.FromHexString(color);
 for(let i=0;i<count;i++){
  const y=1-2*(i+.5)/count,a=i*2.39996323,s=Math.sqrt(1-y*y);
  const normal=new B.Vector3(Math.cos(a)*s,y,Math.sin(a)*s);
  const point=center.add(new B.Vector3(normal.x*radii.x,normal.y*radii.y,normal.z*radii.z));
  const tangent=B.Vector3.Cross(normal,Math.abs(y)>.9?B.Vector3.Right():B.Vector3.Up()).normalize();
  const len=.018+.026*(.5+.5*Math.sin(i*7.71)),width=len*.22;
  const tip=point.add(normal.scale(len)).add(new B.Vector3(0,-len*.36,0));
  const vertices=[point.subtract(tangent.scale(width)),point.add(tangent.scale(width)),tip];
  vertices.forEach(v=>positions.push(v.x,v.y,v.z));indices.push(i*3,i*3+1,i*3+2);
  const c=base.scale(.72+(.5+.5*Math.sin(i*12.71))*.52);
  for(let n=0;n<3;n++)colors.push(c.r,c.g,c.b,1);
 }
 const normals:number[]=[];B.VertexData.ComputeNormals(positions,indices,normals);
 const mesh=new B.Mesh(name,scene),data=new B.VertexData();Object.assign(data,{positions,indices,normals,colors});data.applyToMesh(mesh);mesh.parent=parent;mesh.isPickable=false;
 const material=new B.StandardMaterial(name+' matte',scene);material.diffuseColor=B.Color3.White();material.specularColor=B.Color3.Black();material.backFaceCulling=false;mesh.material=material;
 return mesh;
}

/** Fiber color and tangent-space relief, distinct from the woven uniform. */
export function furSurface(scene:B.Scene,name:string,scale:number){
 const size=256,texture=new B.DynamicTexture(name,{width:size,height:size},scene,true),bump=new B.DynamicTexture(name+' relief',{width:size,height:size},scene,true);
 const ctx=texture.getContext(),bctx=bump.getContext(),pixels=ctx.getImageData(0,0,size,size),normals=bctx.getImageData(0,0,size,size);
 const fiber=(x:number,y:number)=>Math.sin(x*1.4726+Math.sin(y*.0491)*.65)*.5+Math.sin(x*2.9207+y*.0982)*.22+Math.sin(x*.1963+y*.02454)*.28;
 for(let y=0;y<size;y++)for(let x=0;x<size;x++){
  const i=(y*size+x)*4,f=fiber(x,y),v=223+f*28;
  pixels.data.set([v,v*.98,v*.93,255],i);
  const dx=fiber(x+1,y)-fiber(x-1,y),dy=fiber(x,y+1)-fiber(x,y-1);
  const n=new B.Vector3(-dx*.25,-dy*.25,1).normalize();normals.data.set([(n.x*.5+.5)*255,(n.y*.5+.5)*255,(n.z*.5+.5)*255,255],i);
 }
 ctx.putImageData(pixels,0,0);bctx.putImageData(normals,0,0);texture.update();bump.update();
 for(const t of [texture,bump]){t.uScale=scale;t.vScale=scale;t.anisotropicFilteringLevel=4;}bump.level=.38;
 return {texture,bump};
}

export function bootDetails(scene:B.Scene,leg:B.TransformNode,material:B.Material,laceMaterial:B.Material){
 const sole=B.MeshBuilder.CreateSphere('boot sole',{diameter:1,segments:12},scene);sole.parent=leg;sole.position.set(0,-.425,-.09);sole.scaling.set(.39,.065,.6);sole.material=material;sole.isPickable=false;
 for(let i=0;i<3;i++){
  const lace=B.MeshBuilder.CreateTube('boot laces',{path:[new B.Vector3(-.11,-.28+i*.035,-.29+i*.035),new B.Vector3(.11,-.28+i*.035,-.29+i*.035)],radius:.012,tessellation:4},scene);lace.parent=leg;lace.material=laceMaterial;lace.isPickable=false;
 }
}
