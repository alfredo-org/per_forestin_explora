/** Frame-rate independent easing for desktop input and camera motion. */
export function approach(value:number,target:number,dt:number,response:number){
 return value+(target-value)*(1-Math.exp(-Math.max(0,dt)*response));
}
export function approachAngle(value:number,target:number,dt:number,response:number){
 const arc=Math.atan2(Math.sin(target-value),Math.cos(target-value));
 return value+arc*(1-Math.exp(-Math.max(0,dt)*response));
}
