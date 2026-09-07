import {distance,type Point} from './rules.ts';
export type WildlifeState='grazing'|'watching'|'retreating'|'returning';
export function wildlifeStep(position:Point,home:Point,player:Point,previous:WildlifeState,dt:number,safe:(p:Point)=>boolean){
 const d=distance(position,player);let state:WildlifeState=d<6||(previous==='retreating'&&d<9)?'retreating':d<11||(previous==='watching'&&d<13)?'watching':distance(position,home)>.15?'returning':'grazing';
 let next={x:position.x,z:position.z};if(state==='retreating'||state==='returning'){const dx=state==='retreating'?position.x-player.x:home.x-position.x,dz=state==='retreating'?position.z-player.z:home.z-position.z,len=Math.hypot(dx,dz);const step=Math.min(len,Math.max(0,Math.min(.12,dt))*(state==='retreating'?1.2:.55));if(len>.001){const p={x:position.x+dx/len*step,z:position.z+dz/len*step};if(distance(p,home)<=4&&safe(p))next=p;else state='watching';}}
 return {position:next,state};
}
