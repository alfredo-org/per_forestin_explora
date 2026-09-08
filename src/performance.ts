export type RenderPreference='balanced'|'cinematic'|'ultra';
/** Babylon scaling is inverse pixel density, not devicePixelRatio / density. */
export function renderDensity(width:number,height:number,dpr:number,mobile:boolean,preference:RenderPreference,adaptive=1){
 const desired=mobile?(preference==='cinematic'?1.15:.9):(preference==='ultra'?1.6:preference==='cinematic'?1.5:1);
 const budget=mobile?850000:preference==='ultra'?6200000:2400000;
 return Math.max(.45,Math.min(Math.min(Math.max(1,dpr),desired)*adaptive,Math.sqrt(budget/Math.max(1,width*height))));
}
export function adaptiveStep(scale:number,averageMs:number,mobile:boolean){
 const slow=mobile?38:24,fast=mobile?34:17;
 return averageMs>slow?Math.max(.65,scale-.1):averageMs<fast?Math.min(1,scale+.05):scale;
}
