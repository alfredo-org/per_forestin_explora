import * as B from './babylon';
import {height,distanceToTrail,trail} from './rules';

type Blocker={x:number;z:number;r:number};
type Point3=[number,number,number];
type Tint=[number,number,number];
/** Desktop detail: three opaque batches, deterministic placement, no collider or world RNG mutation.
 * Pass the existing windyGrass material so seed heads use the same wind/night uniforms.
 * Create only when !mobile && !software. All positions are world space; leave root at identity.
 */
export function groundDetail(scene:B.Scene,blockers:readonly Blocker[],windMaterial?:B.Material){
 const root=new B.TransformNode('Patagonian trail understory',scene);
 let state=0x51ca34be;
 const random=()=>{state^=state<<13;state^=state>>>17;state^=state<<5;return (state>>>0)/4294967296;};
 class Batch{
  positions:number[]=[];indices:number[]=[];colors:number[]=[];
  triangle(a:Point3,b:Point3,c:Point3,tint:Tint){const i=this.positions.length/3;this.positions.push(...a,...b,...c);this.indices.push(i,i+1,i+2);for(let k=0;k<3;k++)this.colors.push(...tint,1);}
  quad(a:Point3,b:Point3,c:Point3,d:Point3,tint:Tint){this.triangle(a,b,c,tint);this.triangle(a,c,d,tint);}
  mesh(name:string,material:B.Material){const normals:number[]=[];B.VertexData.ComputeNormals(this.positions,this.indices,normals,{useRightHandedSystem:true});const mesh=new B.Mesh(name,scene),data=new B.VertexData();Object.assign(data,{positions:this.positions,indices:this.indices,colors:this.colors,normals,uvs:new Array(this.positions.length/3*2).fill(0)});data.applyToMesh(mesh);mesh.material=material;mesh.parent=root;mesh.isPickable=false;mesh.checkCollisions=false;mesh.receiveShadows=true;return mesh;}
 }
 const stems=new Batch(),stones=new Batch(),cushions=new Batch();
 const tint=(base:Tint,v:number):Tint=>[base[0]*v,base[1]*v,base[2]*v];
 function material(name:string){const m=new B.PBRMaterial(name,scene);m.albedoColor=B.Color3.White();m.metallic=0;m.roughness=.98;m.backFaceCulling=false;return m;}
 const open=(x:number,z:number,clearance=.25)=>height(x,z)>1.55&&!blockers.some(b=>Math.hypot(x-b.x,z-b.z)<b.r+clearance);
 function seedhead(x:number,z:number,h:number,a:number){
  const y=height(x,z)+.015,bend=.12+random()*.12,dx=Math.cos(a),dz=Math.sin(a),sx=-dz,sz=dx;
  const base:Point3=[x,y,z],tip:Point3=[x+dx*bend,y+h,z+dz*bend],w=.009;
  const stemColor=tint([.58,.53,.31],.9+random()*.2);
  stems.quad([base[0]-sx*w,y,base[2]-sz*w],[base[0]+sx*w,y,base[2]+sz*w],[tip[0]+sx*w,tip[1],tip[2]+sz*w],[tip[0]-sx*w,tip[1],tip[2]-sz*w],stemColor);
  // A narrow staggered panicle, not a broad wheat cob: muted oat/champagne highlights.
  for(let k=0;k<5;k++){
   const f=.73+k*.049,px=x+dx*bend*f,py=y+h*f,pz=z+dz*bend*f;
   const sign=k%2?1:-1,reach=.025+Math.sin(k/5*Math.PI)*.023;
   const center:Point3=[px+sx*reach*sign,py+.018,pz+sz*reach*sign];
   const color=tint([.68,.62,.40],.87+random()*.22);
   stems.triangle([px,py-.008,pz],[center[0]+dx*.01,center[1],center[2]+dz*.01],[center[0],center[1]+.035,center[2]],color);
   stems.triangle([px,py-.008,pz],[center[0],center[1]+.035,center[2]],[center[0]-dx*.01,center[1],center[2]-dz*.01],color);
  }
 }
 function tussock(x:number,z:number){
  const spread=.16+random()*.17,phase=random()*Math.PI*2;
  for(let i=0;i<16;i++){
   const angle=i*2.39996+phase,r=Math.sqrt(random())*spread,xx=x+Math.cos(angle)*r,zz=z+Math.sin(angle)*r,y=height(xx,zz)+.015;
   const h=.19+random()*.23,w=.01+random()*.014,bend=.14+random()*.19,dx=Math.cos(angle),dz=Math.sin(angle),sx=-dz,sz=dx;
   const left:Point3=[xx-sx*w,y,zz-sz*w],right:Point3=[xx+sx*w,y,zz+sz*w];
   const midL:Point3=[xx+dx*bend*.25-sx*w*.55,y+h*.68,zz+dz*bend*.25-sz*w*.55],midR:Point3=[xx+dx*bend*.25+sx*w*.55,y+h*.68,zz+dz*bend*.25+sz*w*.55];
   const c=tint(i%4===0?[.59,.54,.32]:[.39,.44,.27],.87+random()*.23);
   stems.quad(left,right,midR,midL,c);stems.triangle(midL,midR,[xx+dx*bend,y+h,zz+dz*bend],tint(c,1.15));
  }
  for(let i=0;i<3;i++)seedhead(x+(random()-.5)*spread,z+(random()-.5)*spread,.48+random()*.34,phase+i*2.1);
 }
 function pebble(x:number,z:number,size:number){
  const y=height(x,z)+size*.16,a=random()*Math.PI*2,vertices:Point3[]=[];
  for(let k=0;k<6;k++){const angle=k*Math.PI/3+a,r=size*(.83+random()*.24);vertices.push([x+Math.cos(angle)*r,y+Math.sin(k*2)*size*.075,z+Math.sin(angle)*r*.73]);}
  const top:Point3=[x-size*.15,y+size*.63,z+size*.09],bottom:Point3=[x,y-size*.4,z];
  const c=tint([.42,.43,.39],.85+random()*.34);
  for(let k=0;k<6;k++){stones.triangle(vertices[k],vertices[(k+1)%6],top,tint(c,.91+random()*.15));stones.triangle(vertices[(k+1)%6],vertices[k],bottom,tint(c,.78));}
 }
 function cushion(x:number,z:number){
  const y=height(x,z)+.025,r=.16+random()*.15;
  // Overlapping tight rosettes make a low grey-green cushion; never spherical bushes.
  for(let i=0;i<22;i++){
   const a=i*2.39996,rr=Math.sqrt((i+.5)/22)*r,xx=x+Math.cos(a)*rr,zz=z+Math.sin(a)*rr,h=.05+(1-rr/r)*.07;
   const yaw=a+random()*.5,dx=Math.cos(yaw),dz=Math.sin(yaw),sx=-dz,sz=dx,len=.055+random()*.035,w=.025;
   const base:Point3=[xx-dx*len,y+h*.3,zz-dz*len],tip:Point3=[xx+dx*len,y+h*.65,zz+dz*len],left:Point3=[xx+sx*w,y+h,zz+sz*w],right:Point3=[xx-sx*w,y+h,zz-sz*w];
   const c=tint([.39,.45,.33],.87+random()*.22);cushions.triangle(base,left,tip,c);cushions.triangle(base,tip,right,tint(c,.86));
  }
 }
 // Trail margins form ecological groups, with clear bare-earth gaps between patches.
 for(let i=0;i<96;i++){
  const segment=1+Math.floor(random()*(trail.length-1)),a=trail[segment-1],b=trail[segment],t=.08+random()*.84;
  const length=Math.hypot(b.x-a.x,b.z-a.z),side=random()<.5?-1:1,offset=2.1+random()*3.6;
  const x=a.x+(b.x-a.x)*t-(b.z-a.z)/length*offset*side,z=a.z+(b.z-a.z)*t+(b.x-a.x)/length*offset*side;
  if(!open(x,z,.65)||distanceToTrail({x,z})<1.85)continue;
  for(let j=0;j<3;j++){const xx=x+(random()-.5)*1.2,zz=z+(random()-.5)*1.2;if(open(xx,zz)&&distanceToTrail({x:xx,z:zz})>1.72)tussock(xx,zz);}
  if(i%2===0)cushion(x+.45,z-.27);
  for(let k=0;k<3;k++){const xx=x+(random()-.5)*1.6,zz=z+(random()-.5)*1.6;if(open(xx,zz))pebble(xx,zz,.065+random()*.10);}
 }
 const meshes=[stems.mesh('trail tussocks and seed heads',windMaterial??material('dry stems physical')),stones.mesh('small glacial stones',material('glacial gravel physical')),cushions.mesh('low steppe cushions',material('cushion leaves physical'))];
 return {root,meshes,triangleCount:(stems.indices.length+stones.indices.length+cushions.indices.length)/3};
}
