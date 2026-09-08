import {test} from 'node:test';
import assert from 'node:assert/strict';
import {renderDensity,adaptiveStep} from './performance.ts';
test('phone resolution stays within pixel budget across rotation and high DPR',()=>{
 for(const [w,h] of [[393,852],[852,393],[430,932],[932,430],[1024,1366]]){
  const density=renderDensity(w,h,3,true,'cinematic');
  assert.ok(w*h*density*density<=850001);assert.ok(density<=1.15);
 }
 assert.equal(renderDensity(393,852,3,true,'balanced'),.9);
});
test('adaptive resolution has bounded gradual recovery and a stable band',()=>{
 assert.ok(adaptiveStep(1,45,true)<1);assert.equal(adaptiveStep(.65,90,true),.65);
 assert.equal(adaptiveStep(.8,35,true),.8);assert.equal(adaptiveStep(1,15,true),1);
 const recovery=adaptiveStep(.8,15,true);assert.ok(recovery>.8&&recovery<.9);
});
test('desktop Ultra preserves native 1440p and still adapts on a DPR1 monitor',()=>{
 const high=renderDensity(2560,1440,1,false,'ultra');
 assert.equal(high,1);
 assert.ok(high>renderDensity(2560,1440,1,false,'cinematic'));
 assert.ok(renderDensity(2560,1440,1,false,'ultra',.7)<high);
 const fourK=renderDensity(3840,2160,2,false,'ultra');
 assert.ok(3840*2160*fourK*fourK<=6200001);
 assert.equal(renderDensity(393,852,3,true,'balanced'),.9);
});
