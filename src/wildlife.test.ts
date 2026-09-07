import {test} from 'node:test';
import assert from 'node:assert/strict';
import {wildlifeStep} from './wildlife.ts';
import {distance} from './rules.ts';
test('wildlife gives space without leaving its habitat or crossing obstacles',()=>{const home={x:0,z:0},player={x:0,z:2};let p=home;for(let i=0;i<200;i++)p=wildlifeStep(p,home,player,'retreating',.1,()=>true).position;assert.ok(distance(p,home)<=4);assert.ok(p.z<0);assert.deepEqual(wildlifeStep(home,home,player,'grazing',.1,()=>false).position,home);});
test('watching hysteresis and calm return preserve a photographable animal',()=>{const home={x:0,z:0};assert.equal(wildlifeStep(home,home,{x:0,z:12},'watching',.1,()=>true).state,'watching');assert.equal(wildlifeStep(home,home,{x:0,z:14},'watching',.1,()=>true).state,'grazing');const r=wildlifeStep({x:2,z:0},home,{x:0,z:20},'watching',.1,()=>true);assert.equal(r.state,'returning');assert.ok(r.position.x<2);});
