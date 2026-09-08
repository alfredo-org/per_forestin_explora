import {test} from 'node:test';
import assert from 'node:assert/strict';
import {approach,approachAngle} from './motion.ts';
test('camera turns across the angle seam by the short arc',()=>{
 const current=Math.PI-.03,target=-Math.PI+.03,next=approachAngle(current,target,1/60,12);
 assert.ok(next>current&&next-current<.03);
});
test('desktop acceleration and braking are consistent at 30 and 60 FPS',()=>{
 function sequence(fps:number){let speed=0;for(let i=0;i<fps;i++)speed=approach(speed,1,1/fps,10);for(let i=0;i<fps/2;i++)speed=approach(speed,0,1/fps,14);return speed;}
 assert.ok(Math.abs(sequence(30)-sequence(60))<1e-10);assert.ok(sequence(60)<.001);
 assert.equal(approach(.4,1,0,10),.4);assert.ok(approach(.4,1,.5,10)<=1);
});
