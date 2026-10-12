import json, sys, os, subprocess
d = sys.argv[1]; out = sys.argv[2]
J = json.load(open(f'{d}/frames.json')); fr = J['frames']; t0 = fr[0][1]
with open(f'{d}/list.txt','w') as f:
    for (n,t),(n2,t2) in zip(fr, fr[1:]+[[None, fr[-1][1]+1.0]]):
        f.write(f"file '{n}'\nduration {max(t2-t,0.001):.4f}\n")
    f.write(f"file '{fr[-1][0]}'\n")
subprocess.run(['ffmpeg','-y','-loglevel','error','-f','concat','-safe','0','-i',f'{d}/list.txt','-vf','fps=30,scale=1080:-2:flags=lanczos,format=yuv420p','-c:v','libx264','-crf','18','-preset','medium',out], check=True)
print('marks', [(m, round(t-t0,1)) for m,t in J['marks']])
