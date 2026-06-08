### ffmpeg
## 1 
```sh
ls -1tr | awk '{printf "file %s\n",$1}' > videos.txt
ffmpeg -hwaccel vaapi -f concat -safe 0 -i ./videos.txt -c:a acc -c:v h264_vaapi -qp 25  ~/videos/xxx.mp4 
```
## 2
```sh
ffmpeg -f concat -safe 0 -i x1.flv -i x2.flv -c copy -qp 25 ~/videos/xxx.mp4
```
## 3
```sh
ffmpeg -i input.mp4 -ss 00:00:1 -t 00:00:15 -c copy output.mp4
```
