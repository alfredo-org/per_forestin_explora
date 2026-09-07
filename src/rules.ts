export type Point = { x:number; z:number };
export const spawn:Point={x:-10,z:31};
export const trail:Point[]=[spawn,{x:-10,z:18},{x:-16,z:5},{x:-11,z:-8},{x:-7,z:-24},{x:-3,z:-34},{x:-13,z:-42},{x:-20,z:-50}];
export const litter:Point[]=[{x:-10,z:18},{x:-11,z:-8},{x:-13,z:-42}];
export const discoveries=[
{id:'mirador',title:'El primer mirador',short:'Descubre el mirador',detail:'Sigue el sendero hasta el letrero.',fact:'Las torres de granito le dan su nombre a este paisaje extraordinario. Detente un momento: la Patagonia también se descubre mirando.',x:-16,z:5,icon:'mountain'},
{id:'guanaco',title:'Un encuentro patagónico',short:'Fotografía un guanaco',detail:'Busca a los guanacos junto al sendero. Usa la cámara.',fact:'El guanaco es un camélido nativo. La mejor fotografía es la que respeta su espacio: observa desde lejos y nunca lo alimentes.',x:-18,z:-17,icon:'camera'},
{id:'lago',title:'El color del agua',short:'Descubre la orilla',detail:'Continúa por el sendero hasta el lago.',fact:'Una pausa junto al agua. Conserva este lugar como lo encontraste y recorre siempre los senderos habilitados.',x:-3,z:-34,icon:'waves'},
{id:'residuos',title:'Una huella más ligera',short:'Cuida el sendero',detail:'Recoge los tres residuos señalados a lo largo del camino.',fact:'Cada pequeño gesto cuenta. Lleva tus residuos de regreso y deja que la naturaleza sea la protagonista.',x:-13,z:-42,icon:'leaf'}
] as const;
export type DiscoveryId=typeof discoveries[number]['id'];
export type Progress={version:1;discovered:DiscoveryId[];collected:number[];position:Point;night:boolean};
export const distance=(a:Point,b:Point)=>Math.hypot(a.x-b.x,a.z-b.z);
export function height(x:number,z:number){return 3.8+Math.sin(x*.065)*1.7+Math.cos(z*.083)*1.05+Math.sin(x*.18+z*.09)*.34-Math.max(0,x-2)*.28;}
export function canWalk(p:Point){return Number.isFinite(p.x)&&Number.isFinite(p.z)&&p.x>-43&&p.x<7&&p.z>-58&&p.z<43&&height(p.x,p.z)>1.1;}
export function distanceToTrail(p:Point){let result=Infinity;for(let i=1;i<trail.length;i++){const a=trail[i-1],b=trail[i],dx=b.x-a.x,dz=b.z-a.z;const t=Math.max(0,Math.min(1,((p.x-a.x)*dx+(p.z-a.z)*dz)/(dx*dx+dz*dz)));result=Math.min(result,distance(p,{x:a.x+t*dx,z:a.z+t*dz}));}return result;}
export function fresh():Progress{return {version:1,discovered:[],collected:[],position:{...spawn},night:false};}
export function sanitize(raw:unknown):Progress{const out=fresh();if(!raw||typeof raw!=='object')return out;const r=raw as Partial<Progress>;if(r.version!==1)return out;out.collected=[...new Set(Array.isArray(r.collected)?r.collected.filter(i=>Number.isInteger(i)&&i>=0&&i<3):[])];out.discovered=[...new Set(Array.isArray(r.discovered)?r.discovered.filter(id=>discoveries.some(d=>d.id===id)&&id!=='residuos'):[])];if(out.collected.length===3)out.discovered.push('residuos');if(r.position&&canWalk(r.position))out.position={x:r.position.x,z:r.position.z};out.night=r.night===true;return out;}
export function photoFeedback(dist:number,inFrame:boolean,visible:boolean){if(dist<7)return 'Mantén distancia · aléjate un poco';if(dist>19)return 'Acércate por el sendero';if(!inFrame)return 'Centra al guanaco en el encuadre';if(!visible)return 'Busca una vista despejada';return 'Buen encuadre · toma la foto';}
export function collect(p:Progress,index:number){if(index<0||index>=litter.length||!Number.isInteger(index)||p.collected.includes(index)||distance(p.position,litter[index])>2.6)return false;p.collected.push(index);if(p.collected.length===3&&!p.discovered.includes('residuos'))p.discovered.push('residuos');return true;}
