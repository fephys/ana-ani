find out -name '*.png' ! -size 0 | sort | while read fn; do
    n="`basename "$fn" .png`"
    pngtopnm "$fn" | cjpeg >out/"$n".jpg
    echo "file '$n.jpg'"
    echo "file '$n.jpg'"
    echo "file '$n.jpg'"
done >out/flist
rm out.mp4
time ffmpeg -f concat -i out/flist out.mp4
