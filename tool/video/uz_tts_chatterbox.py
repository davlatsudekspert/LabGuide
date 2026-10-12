"""O‘zbekcha ovoz (MIT): Abduqayum/uzbek-tts-natural-speech-chatterbox, gokhaneraslan/chatterbox-finetuning ichidan ishlatiladi.
    cd chatterbox-finetuning && python uz_tts_chatterbox.py lines.json OUT_DIR
Talab: transformers==4.46.3; pretrained_models/ da ve, s3gen, conds va modelning tokenizer.json; t3_cfg shart emas.
"""
import sys, json, time, numpy as np, soundfile as sf, torch
sys.argv = [sys.argv[0]] + sys.argv[1:]
import uz_inference as U
lines = json.load(open(sys.argv[1])); out = sys.argv[2]
torch.set_num_threads(4)
eng = U.load_engine('pretrained_models', 'uzbek_chatterbox/t3_finetuned_merged.safetensors', 'cpu')
for name, _, txt, *_ in lines:
    t=time.time()
    wav = U.synthesize(eng, txt, 'uzbek_chatterbox/reference_voice.wav')
    if isinstance(wav, tuple): wav = wav[0]
    wav = np.asarray(wav, dtype=np.float32).squeeze()
    sf.write(f'{out}/{name}.wav', wav, eng.sr); print(name, round(len(wav)/eng.sr,2), 's', round(time.time()-t), 'sek', flush=True)
