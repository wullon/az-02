del /s release

set PATH=%PATH%;%SYSTEMROOT%\system32
mkdir release

mkdir release\data
mkdir release\data\music
mkdir release\data\tex
mkdir release\data\tex\zoom
mkdir release\data\tracks
mkdir release\data\shaders

copy data\music\*.ogg release\data\music\*.ogg 

copy data\tex\*.jpg release\data\tex
copy data\tex\*.jp2 release\data\tex
copy data\tex\*.png release\data\tex
copy data\tex\*.bmp release\data\tex
copy data\tex\*.tif release\data\tex
copy data\tex\zoom\*.tif release\data\tex\zoom
copy data\zoom.azr release\data\zoom.azr

copy data\tracks\*.azc release\data\tracks

copy data\shaders\*.vs release\data\shaders
copy data\shaders\*.fs release\data\shaders


copy *.dll release
copy launcher.exe release
copy az02.exe release
copy az02.nfo release
copy libportaudio.so release



pause
