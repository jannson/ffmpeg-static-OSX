#!/bin/bash
clear
( exec &> >(while read -r line; do echo "$(date +"[%Y-%m-%d %H:%M:%S]") $line"; done;) #_Date to Every Line

tput bold ; echo "adam | 2014 < 2022-07-26" ; tput sgr0
tput bold ; echo "Download and Build Last Static FFmpeg" ; tput sgr0
tput bold ; echo "macOS 10.12 < 12.5 Build Compatibility" ; tput sgr0
echo "macOS $(sw_vers -productVersion) | $(system_profiler SPHardwareDataType | grep Memory | cut -d ':' -f2) | $(system_profiler SPHardwareDataType | grep Cores: | cut -d ':' -f2) Cores | $(system_profiler SPHardwareDataType | grep Speed | cut -d ':' -f2)" ; sleep 2

#_ Check Xcode CLI Install
tput bold ; echo ; echo '♻️  ' Check Xcode CLI Install ; tput sgr0
if ls /Library/Developer/CommandLineTools >/dev/null 2>&1 ; then tput bold ; echo "Xcode CLI AllReady Installed" ; else tput bold ; echo "Xcode CLI Install" ; tput sgr0 ; xcode-select --install
sleep 1
while pgrep 'Install Command Line Developer Tools' >/dev/null ; do sleep 5 ; done
if ls /Library/Developer/CommandLineTools >/dev/null 2>&1 ; then tput bold ; echo "Xcode CLI Was SucessFully Installed" ; else tput bold ; echo "Xcode CLI Was NOT Installed" ; tput sgr0 ; exit ; fi ; fi

#_ Check Homebrew Install
tput bold ; echo ; echo '♻️  ' Check Homebrew Install ; tput sgr0 ; sleep 2
if ls /usr/local/bin/brew >/dev/null ; then tput sgr0 ; echo "HomeBrew AllReady Installed" ; else tput bold ; echo "Installing HomeBrew" ; tput sgr0 ; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ; fi

#_ Check Homebrew Update
tput bold ; echo ; echo '♻️  ' Check Homebrew Update ; tput sgr0 ; sleep 2
brew cleanup ; brew doctor ; brew update ; brew upgrade

#_ Java Install - Fix PopUp
tput bold ; echo ; echo '♻️  ' Check Java Install ; tput sgr0 ; sleep 2
if java -version ; then tput sgr0 ; echo "Java AllReady Installed"
else tput bold ; echo "Java Install" ; tput sgr0
brew reinstall java
echo '🔒 Please Enter Your Password :'
sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
fi

#_ Check Homebrew Config
tput bold ; echo ; echo '♻️  ' Check Homebrew Config ; tput sgr0 ; sleep 2
#brew uninstall ffmpeg
brew install git wget cmake autoconf automake nasm libtool ninja meson pkg-config rtmpdump rust cargo-c jpeg libtiff mawk python3

#_ Check Miminum Requirement Build Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo ; echo '⏱  ' Miminum Requirement Build in "$Time"s ; tput sgr0 ; sleep 2

#_ Eject RamDisk
if df | grep RamDisk > /dev/null ; then tput bold ; echo ; echo '⏏  ' Eject RamDisk ; tput sgr0 ; fi
if df | grep RamDisk > /dev/null ; then diskutil eject RamDisk ; sleep 2 ; fi

#_ Made RamDisk
tput bold ; echo ; echo '💾 ' Made 2Go RamDisk ; tput sgr0
diskutil erasevolume HFS+ 'RamDisk' $(hdiutil attach -nomount ram://4194304)
sleep 1

#_ CPU & PATHS & ERROR
THREADS=$(sysctl -n hw.ncpu)
TARGET="/Volumes/RamDisk/sw"
CMPL="/Volumes/RamDisk/compile"
export PATH="${TARGET}"/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/include:/usr/local/opt:/usr/local/Cellar:/usr/local/lib:/usr/local/share:/usr/local/etc
mdutil -i off /Volumes/RamDisk

#_ Make RamDisk Directories
mkdir ${TARGET}
mkdir ${CMPL}


#-> BASE
tput bold ; echo ; echo ; echo '⚙️  ' Base Builds ; tput sgr0

#_ librtmp
tput bold ; echo ; echo '📍 ' librtmp 2.4 Copy ; tput sgr0 ; sleep 2
cp -v /usr/local/Cellar/rtmpdump/2.4+20151223_1/bin/* /Volumes/RamDisk/sw/bin/
cp -vr /usr/local/Cellar/rtmpdump/2.4+20151223_1/include/* /Volumes/RamDisk/sw/include/
cp -v /usr/local/Cellar/rtmpdump/2.4+20151223_1/lib/pkgconfig/librtmp.pc /Volumes/RamDisk/sw/lib/pkgconfig
cp -v /usr/local/Cellar/rtmpdump/2.4+20151223_1/lib/librtmp* /Volumes/RamDisk/sw/lib


#-> FFmpeg Check
tput bold ; echo ; echo ; echo '⚙️  ' FFmpeg Build ; tput sgr0

#_ Purge .dylib
tput bold ; echo ; echo '💢 ' Purge .dylib ; tput sgr0 ; sleep 2
rm -vfr $TARGET/lib/*.dylib
rm -vfr /usr/local/opt/libx11/lib/libX11.6.dylib

#_ Flags
tput bold ; echo ; echo '🚩 ' Define FLAGS ; tput sgr0 ; sleep 2
export LDFLAGS="-L${TARGET}/lib -Wl,-framework,OpenAL"
export CPPFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL"
export CFLAGS="-I${TARGET}/include -Wl,-framework,OpenAL,-fno-stack-check"

#_ FFmpeg Build
tput bold ; echo ; echo '📍 ' FFmpeg git ; tput sgr0 ; sleep 2
#cd ${CMPL}
#git clone git://git.ffmpeg.org/ffmpeg.git
#cd ffmpe*/
cd /Volumes/win/source/ffmpeg-static-OSX/compile/ffmpeg
./configure --extra-version=adam-"$(date +"%Y-%m-%d")" --extra-cflags="-fno-stack-check" --arch=x86_64 --cc=/usr/bin/clang \
 --pkg_config='pkg-config --static' --enable-nonfree --enable-gpl --enable-version3 --prefix=${TARGET} \
 --enable-postproc --enable-runtime-cpudetect \
 --enable-pthreads --enable-zlib --disable-doc --disable-debug --disable-lzma --disable-vaapi --disable-vdpau --disable-outdevs --disable-runtime-cpudetect --enable-lto --enable-neon --enable-vfp --disable-x86asm --enable-small --disable-ffplay --disable-bzlib --disable-lzma --disable-alsa --disable-iconv --disable-sndio --disable-schannel --disable-sdl2 --disable-securetransport --disable-xlib --disable-v4l2-m2m --disable-avdevice --disable-postproc --disable-swresample --disable-swscale --disable-everything --enable-decoder=mpeg1video --enable-decoder=mpeg2video --enable-decoder=mpeg4 --enable-decoder=mpegvideo --enable-parser=aac --enable-parser=flac --enable-parser=ac3 --enable-parser=h264 --enable-parser=hevc --enable-parser=mpegaudio --enable-parser=mpeg4video --enable-parser=mpegvideo --enable-parser=vc1 --enable-demuxer=avi --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=matroska --enable-demuxer=mov --enable-demuxer=mpegps --enable-demuxer=mpegts --enable-demuxer=mpegvideo --enable-demuxer=ogg --enable-demuxer=rm --enable-demuxer=vc1 --enable-demuxer=wv --enable-muxer=matroska --enable-muxer=h264 --enable-muxer=hevc --enable-muxer=mp4 --enable-muxer=mpeg1video --enable-muxer=mpeg2video --enable-muxer=mpegts --enable-muxer=ogg --enable-protocol=file --enable-protocol=pipe --enable-decoder=h264 --enable-decoder=hevc --enable-decoder=vc1 \
  --enable-muxer=mjpeg --enable-muxer=mpeg --enable-libopenjpeg --enable-encoder=png --enable-encoder=mjpeg --enable-muxer=image2 --enable-muxer=image2pipe --enable-videotoolbox \
 --enable-swscale --enable-swscale-alpha --enable-filter=scale 

make -j "$THREADS" && make install

#_ Check Static
tput bold ; echo ; echo '♻️  ' Check Static FFmpeg ; tput sgr0 ; sleep 2
if otool -L /Volumes/RamDisk/sw/bin/ffmpeg | grep /usr/local
then echo FFmpeg build Not Static, Please Report
open ~/Library/Logs/adam-FFmpeg-Static.log
else echo FFmpeg build Static, Have Fun
cp /Volumes/RamDisk/sw/bin/ffmpeg ~/Desktop/ffmpeg
fi

#_ End Time
Time="$(echo 'obase=60;'$SECONDS | bc | sed 's/ /:/g' | cut -c 2-)"
tput bold ; echo ; echo '⏱  ' End in "$Time"s ; tput sgr0
) 2>&1 | tee "$HOME/Library/Logs/adam-FFmpeg-Static.log"
