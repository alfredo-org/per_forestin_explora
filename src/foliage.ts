// Integration: copy into src/foliage.ts. Uses no world RNG and changes no collision data.
import * as B from './babylon';

/** A small opaque leaf crown, suitable for the world's material buckets.
 * center/scale follow ell(): scale is the full diameter, not the radius.
 * Set material.backFaceCulling=false once on the leaf material before calling.
 * The mesh is decorative and never used for picking or collisions.
 */
export function foliageCluster(
  scene:B.Scene,
  name:string,
  center:B.Vector3,
  scale:B.Vector3,
  material:B.Material,
  seed:number,
  software=false,
):B.Mesh {
  let state=(seed|0) || 0x13579b;
  const random=()=>{state^=state<<13;state^=state>>>17;state^=state<<5;return (state>>>0)/4294967296;};
  const positions:number[]=[],indices:number[]=[],colors:number[]=[],normals:number[]=[];
  const count=software?12:50;
  const small=Math.min(scale.x,scale.z);
  for(let i=0;i<count;i++){
    // Fibonacci shell coverage with small independent jitter: no clumping into one side.
    const yy=1-2*(i+.5)/count;
    const angle=i*2.399963229728653+(random()-.5)*.6;
    const radial=Math.sqrt(1-yy*yy);
    const shell=.44+random()*.17;
    const c=new B.Vector3(center.x+Math.cos(angle)*radial*scale.x*shell,
      center.y+yy*scale.y*shell,center.z+Math.sin(angle)*radial*scale.z*shell);
    const yaw=random()*Math.PI*2;
    const pitch=(random()-.5)*1.05;
    const axis=new B.Vector3(Math.cos(yaw)*Math.cos(pitch),Math.sin(pitch),Math.sin(yaw)*Math.cos(pitch));
    const side=new B.Vector3(-Math.sin(yaw),0,Math.cos(yaw));
    // Coarse opaque leaves avoid alpha sorting and texture download; some deliberately
    // overlap the inner crown so their tips break its smooth elliptical silhouette.
    const length=Math.max(.12,small*(.11+random()*.095))*(software?1.3:1);
    const width=length*(.24+random()*.15);
    const fold=length*.12;
    const base=c.subtract(axis.scale(length*.5));
    const right=c.add(side.scale(width));right.y+=fold;
    const tip=c.add(axis.scale(length*.5));
    const left=c.subtract(side.scale(width));left.y+=fold;
    const first=positions.length/3;
    for(const p of [base,right,tip,left])positions.push(p.x,p.y,p.z);
    indices.push(first,first+1,first+2,first,first+2,first+3);
    const shade=.78+random()*.35;
    // Multiplier preserves caller material's green palette and reads in the CPU renderer.
    for(const intensity of [.83,1,1.07,.93])colors.push(shade*.95*intensity,shade*intensity,shade*.77*intensity,1);
  }
  B.VertexData.ComputeNormals(positions,indices,normals,{useRightHandedSystem:true});
  const mesh=new B.Mesh(name,scene);
  const data=new B.VertexData();
  Object.assign(data,{positions,indices,normals,colors,uvs:new Array(positions.length/3*2).fill(0)});data.applyToMesh(mesh);
  mesh.material=material;mesh.isPickable=false;mesh.receiveShadows=true;
  return mesh;
}

/** Stable seed per crown without consuming world.rand(). */
export function foliageSeed(x:number,z:number,crown:number){
  return (Math.imul(Math.round(x*100),73856093)^Math.imul(Math.round(z*100),19349663)^Math.imul(crown+1,83492791))>>>0;
}
