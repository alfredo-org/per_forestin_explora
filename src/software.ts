// CPU fallback for the same Babylon scene. Each pixel tests reciprocal camera
// depth, so large lake/terrain triangles cannot cover closer geometry by order.
import {Color3,Scene,Mesh,StandardMaterial,Vector3,Matrix} from './babylon';

type Vertex = {x:number;y:number;w:number;r:number;g:number;b:number};
type CachedMesh = {matrix:Float32Array;positions:Float32Array;normals:Float32Array;projected:Float32Array};
const clamp = (v:number) => Math.max(0,Math.min(1,v));

// Clip in homogeneous space before division. An intersecting triangle remains
// visible when one or two vertices pass behind the camera.
function clipNear(input:Vertex[],near:number):Vertex[]{
 const out:Vertex[]=[];
 let a=input[input.length-1];
 for(const b of input){
  const aIn=a.w>=near,bIn=b.w>=near;
  if(aIn!==bIn){const t=(near-a.w)/(b.w-a.w);out.push({x:a.x+(b.x-a.x)*t,y:a.y+(b.y-a.y)*t,w:near,r:a.r+(b.r-a.r)*t,g:a.g+(b.g-a.g)*t,b:a.b+(b.b-a.b)*t});}
  if(bIn)out.push(b);
  a=b;
 }
 return out;
}

export function softwareRenderer(canvas:HTMLCanvasElement,scene:Scene,onSize:(w:number,h:number)=>void){
 const ctx=canvas.getContext('2d')!;
 const cache=new WeakMap<Mesh,CachedMesh>();
 const light=new Vector3(-.5,1,-.35).normalize();
 let previous=0,depthBuffer=new Float32Array(0);
 return (night:boolean)=>{
  const now=performance.now();if(now-previous<85)return;previous=now;
  const cssW=Math.max(1,canvas.clientWidth),cssH=Math.max(1,canvas.clientHeight);
  // A bounded total pixel count also protects portrait devices.
  const scale=Math.min(1,720/cssW,Math.sqrt(480000/(cssW*cssH)));
  const w=Math.max(1,Math.round(cssW*scale)),h=Math.max(1,Math.round(cssH*scale));
  if(canvas.width!==w||canvas.height!==h){canvas.width=w;canvas.height=h;onSize(w,h);}
  if(depthBuffer.length!==w*h)depthBuffer=new Float32Array(w*h);else depthBuffer.fill(0);
  const sky=ctx.createLinearGradient(0,0,0,h*.75);
  sky.addColorStop(0,night?'#101f37':'#669bcb');sky.addColorStop(.7,night?'#263a50':'#b7cdd0');sky.addColorStop(1,night?'#34484e':'#e3e3c6');
  ctx.fillStyle=sky;ctx.fillRect(0,0,w,h);
  if(!night){ctx.fillStyle='#fbf4dc4d';for(let i=0;i<7;i++){ctx.beginPath();ctx.ellipse(w*(.13+i*.17),h*(.13+Math.sin(i*4)*.06),w*.11,h*.026,0,0,Math.PI*2);ctx.fill();}}
  const frame=ctx.getImageData(0,0,w,h),pixels=frame.data;
  const camera=scene.activeCamera;if(!camera)return;
  const view=scene.getTransformMatrix().m,near=Math.max(.12,camera.minZ);
  const fogR=night?.13:.64,fogG=night?.2:.76,fogB=night?.29:.77;

  function raster(a:Vertex,b:Vertex,c:Vertex){
   const az=1/a.w,bz=1/b.w,cz=1/c.w;
   const ax=(a.x*az+1)*w*.5,ay=(1-a.y*az)*h*.5;
   const bx=(b.x*bz+1)*w*.5,by=(1-b.y*bz)*h*.5;
   const cx=(c.x*cz+1)*w*.5,cy=(1-c.y*cz)*h*.5;
   const area=(bx-ax)*(cy-ay)-(by-ay)*(cx-ax);
   if(!Number.isFinite(area)||Math.abs(area)<.0001)return;
   const minX=Math.max(0,Math.ceil(Math.min(ax,bx,cx)-.5));
   const maxX=Math.min(w-1,Math.floor(Math.max(ax,bx,cx)-.5));
   const minY=Math.max(0,Math.ceil(Math.min(ay,by,cy)-.5));
   const maxY=Math.min(h-1,Math.floor(Math.max(ay,by,cy)-.5));
   if(minX>maxX||minY>maxY)return;
   const inverseArea=1/area;
   const dax=(by-cy)*inverseArea,day=(cx-bx)*inverseArea;
   const dbx=(cy-ay)*inverseArea,dby=(ax-cx)*inverseArea;
   const dcx=-dax-dbx,dcy=-day-dby;
   let rowA=((bx-(minX+.5))*(cy-(minY+.5))-(by-(minY+.5))*(cx-(minX+.5)))*inverseArea;
   let rowB=((cx-(minX+.5))*(ay-(minY+.5))-(cy-(minY+.5))*(ax-(minX+.5)))*inverseArea;
   let rowC=1-rowA-rowB;
   const ar=a.r*az,ag=a.g*az,ab=a.b*az;
   const br=b.r*bz,bg=b.g*bz,bb=b.b*bz;
   const cr=c.r*cz,cg=c.g*cz,cb=c.b*cz;
   for(let y=minY;y<=maxY;y++){
    let wa=rowA,wb=rowB,wc=rowC,index=y*w+minX;
    for(let x=minX;x<=maxX;x++,index++,wa+=dax,wb+=dbx,wc+=dcx){
     if(wa<-.000001||wb<-.000001||wc<-.000001)continue;
     const reciprocal=wa*az+wb*bz+wc*cz;
     if(reciprocal<=depthBuffer[index])continue;
     depthBuffer[index]=reciprocal;
     const p=index*4,denom=255/reciprocal;
     pixels[p]=(wa*ar+wb*br+wc*cr)*denom;
     pixels[p+1]=(wa*ag+wb*bg+wc*cg)*denom;
     pixels[p+2]=(wa*ab+wb*bb+wc*cb)*denom;
    }
    rowA+=day;rowB+=dby;rowC+=dcy;
   }
  }

  for(const abstract of scene.meshes){
   if(!(abstract instanceof Mesh)||!abstract.isEnabled()||!abstract.isVisible||abstract.visibility===0)continue;
   if(abstract.name==='helmet lettering'||abstract.name==='low shrub'||abstract.name==='sky'||abstract.name==='ripple'||(abstract.name==='golden grasses'&&cssW<500))continue;
   const mesh=abstract,positions=mesh.getVerticesData('position'),indices=mesh.getIndices();if(!positions||!indices)continue;
   mesh.computeWorldMatrix(true);
   const wm=mesh.getWorldMatrix().m;
   let data=cache.get(mesh),changed=!data||data.positions.length!==positions.length;
   if(data&&!changed)for(let i=0;i<16;i++)if(data.matrix[i]!==wm[i]){changed=true;break;}
   if(changed){
    const wp=new Float32Array(positions.length),normals=new Float32Array(positions.length),raw=mesh.getVerticesData('normal');
    // Cofactor matrix / determinant = inverse-transpose of the linear part.
    // Required for stretched bodies, cheeks, boots, rocks, and mountain meshes.
    const n0=wm[5]*wm[10]-wm[9]*wm[6],n1=wm[9]*wm[2]-wm[1]*wm[10],n2=wm[1]*wm[6]-wm[5]*wm[2];
    const n3=wm[8]*wm[6]-wm[4]*wm[10],n4=wm[0]*wm[10]-wm[8]*wm[2],n5=wm[4]*wm[2]-wm[0]*wm[6];
    const n6=wm[4]*wm[9]-wm[8]*wm[5],n7=wm[8]*wm[1]-wm[0]*wm[9],n8=wm[0]*wm[5]-wm[4]*wm[1];
    const determinant=wm[0]*n0+wm[1]*n3+wm[2]*n6,sign=determinant<0?-1:1;
    for(let i=0;i<positions.length;i+=3){
     const x=positions[i],y=positions[i+1],z=positions[i+2];
     wp[i]=x*wm[0]+y*wm[4]+z*wm[8]+wm[12];wp[i+1]=x*wm[1]+y*wm[5]+z*wm[9]+wm[13];wp[i+2]=x*wm[2]+y*wm[6]+z*wm[10]+wm[14];
     if(raw){const nx=(raw[i]*n0+raw[i+1]*n1+raw[i+2]*n2)*sign,ny=(raw[i]*n3+raw[i+1]*n4+raw[i+2]*n5)*sign,nz=(raw[i]*n6+raw[i+1]*n7+raw[i+2]*n8)*sign,length=Math.hypot(nx,ny,nz)||1;normals[i]=nx/length;normals[i+1]=ny/length;normals[i+2]=nz/length;}
    }
    data={matrix:Float32Array.from(wm),positions:wp,normals,projected:new Float32Array(positions.length*2)};cache.set(mesh,data);
   }
   const d=data!,count=positions.length/3,projected=d.projected;
   const material=mesh.material as StandardMaterial,base=material?.diffuseColor??new Color3(.7,.7,.6),colors=mesh.getVerticesData('color');
   for(let i=0;i<count;i++){
    const j=i*3,k=i*6,x=d.positions[j],y=d.positions[j+1],z=d.positions[j+2];
    const cw=x*view[3]+y*view[7]+z*view[11]+view[15];
    projected[k]=x*view[0]+y*view[4]+z*view[8]+view[12];projected[k+1]=x*view[1]+y*view[5]+z*view[9]+view[13];projected[k+2]=cw;
    const dot=d.normals[j]*light.x+d.normals[j+1]*light.y+d.normals[j+2]*light.z;
    const shade=night?.38:.62+Math.max(0,dot)*.48,fog=Math.min(.72,1-Math.exp(-Math.max(0,cw)*.002));
    projected[k+3]=clamp(base.r*(colors?colors[i*4]:1)*shade*(1-fog)+fogR*fog);
    projected[k+4]=clamp(base.g*(colors?colors[i*4+1]:1)*shade*(1-fog)+fogG*fog);
    projected[k+5]=clamp(base.b*(colors?colors[i*4+2]:1)*shade*(1-fog)+fogB*fog);
   }
   const vertex=(index:number):Vertex=>{const j=index*6;return {x:projected[j],y:projected[j+1],w:projected[j+2],r:projected[j+3],g:projected[j+4],b:projected[j+5]};};
   for(let i=0;i<indices.length;i+=3){
    const ia=indices[i],ib=indices[i+1],ic=indices[i+2];
    const ka=ia*6,kb=ib*6,kc=ic*6,aw=projected[ka+2],bw=projected[kb+2],cw=projected[kc+2];
    if(aw<near&&bw<near&&cw<near)continue;
    // Homogeneous frustum reject avoids allocating vertices for offscreen
    // foliage, distant terrain and the far half of large merged meshes.
    if((projected[ka]<-aw&&projected[kb]<-bw&&projected[kc]<-cw)||(projected[ka]>aw&&projected[kb]>bw&&projected[kc]>cw)||(projected[ka+1]<-aw&&projected[kb+1]<-bw&&projected[kc+1]<-cw)||(projected[ka+1]>aw&&projected[kb+1]>bw&&projected[kc+1]>cw))continue;
    if(material?.backFaceCulling!==false){
     // Use the average transformed vertex normal, matching Babylon's outward
     // normals even where custom geometry has a different index convention.
     const a=ia*3,b=ib*3,c=ic*3;
     const nx=d.normals[a]+d.normals[b]+d.normals[c],ny=d.normals[a+1]+d.normals[b+1]+d.normals[c+1],nz=d.normals[a+2]+d.normals[b+2]+d.normals[c+2];
     if(nx*(camera.position.x-d.positions[a])+ny*(camera.position.y-d.positions[a+1])+nz*(camera.position.z-d.positions[a+2])<0)continue;
    }
    const a=vertex(ia),b=vertex(ib),c=vertex(ic);
    if(a.w>=near&&b.w>=near&&c.w>=near)raster(a,b,c);
    else{const polygon=clipNear([a,b,c],near);for(let j=1;j<polygon.length-1;j++)raster(polygon[0],polygon[j],polygon[j+1]);}
   }
  }
  ctx.putImageData(frame,0,0);
  for(const mesh of scene.meshes){
   if(!mesh.metadata?.label||!mesh.isEnabled()||!mesh.isVisible)continue;
   const position=mesh.getAbsolutePosition();
   const p=Vector3.Project(position,Matrix.Identity(),scene.getTransformMatrix(),camera.viewport.toGlobal(w,h));
   const cw=position.x*view[3]+position.y*view[7]+position.z*view[11]+view[15];
   if(cw<near||p.z<=0||p.z>=1||p.x<0||p.x>=w||p.y<0||p.y>=h)continue;
   const visibleDepth=depthBuffer[Math.floor(p.y)*w+Math.floor(p.x)];
   // Small allowance for the label's surface and pixel sampling, but never
   // paint a sign or the helmet lettering through the back of an object.
   if(visibleDepth>1/Math.max(near,cw-.13)*1.01)continue;
   const dist=Vector3.Distance(camera.position,position),size=Math.max(5,Math.min(20,145/dist));
   ctx.font='bold '+size+'px sans-serif';ctx.textAlign='center';ctx.fillStyle=mesh.metadata.labelColor??'#56452d';ctx.fillText(mesh.metadata.label,p.x,p.y+size*.3);
  }
 };
}
