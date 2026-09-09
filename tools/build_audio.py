from pathlib import Path
import math,random,struct,wave
root=Path(__file__).resolve().parents[1]/'game/adventure';r=22050;rng=random.Random(53)
def write(name,data):
 with wave.open(str(root/name),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(r);w.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,v))*32760)) for v in data))
v=0;wind=[]
for i in range(r*8):
 v=v*.965+rng.uniform(-1,1)*.035;wind.append(v*2*(.7+.2*math.sin(i/r*math.tau/8)))
for i in range(600):wind[i]=wind[-600+i]*(1-i/600)+wind[i]*(i/600)
write('wind.wav',wind)
write('step.wav',[rng.uniform(-1,1)*math.exp(-i/r*30)*.4 for i in range(int(r*.14))])
write('chime.wav',[sum(.12*math.sin(math.tau*f*(i/r-j*.13))*math.exp(-max(0,i/r-j*.13)*3) for j,f in enumerate([587.33,739.99,880]) if i/r>=j*.13) for i in range(r*2)])
