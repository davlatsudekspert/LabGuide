# LabGuide o'quv videolari

1. Kadrlar (haqiqiy ilova vidjetlari, 360x640 @3x = 1080x1920):
   `flutter test tool/video/frames_test.dart --update-goldens`
   -> /home/user/labguide-videos/work/frames/vN/*.png + frames.json
2. Video: `python3 tool/video/make_tutorials.py [--only 1 3]`
   (ffmpeg, Pillow, numpy; Inter shrifti /usr/share/fonts/opentype/inter/).
   Chiqish: /home/user/labguide-videos/ (mp4, srt, txt, contact png).

Sarlavhalar (o'zbekcha) `make_tutorials.py` ichidagi `VIDEOS` ro'yxatida.
Videolar repoga qo'shilmaydi.
