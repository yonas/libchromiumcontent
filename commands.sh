
BUILDROOT=/tmp/fun

cd $BUILDROOT
git clone https://github.com/yonas/freebsd-chromium.git
cd freebsd-chromium/www/chromium/
#git checkout 418e996e3a
sudo make fetch
make extract
make patch

cd $BUILDROOT
ln -s `realpath freebsd-chromium/www/chromium/work/chromium-42.0.2311.135` chromium

git clone https://github.com/yonas/libchromiumcontent.git
cd libchromiumcontent/
#git checkout v42.0.2311.107-atom
cd vendor/python-patch/
git submodule update --init --recursive

cd $BUILDROOT/libchromiumcontent
ln -s `realpath ../chromium` vendor/chromium/src

rm vendor/chromium/src/base/process/launch.cc.orig # patch conflict
script/apply-patches

cp -R chromiumcontent/ vendor/chromium/src/chromiumcontent
cd vendor/chromium/src/

setenv CC  gcc48
setenv CXX g++48

setenv CFLAGS "-isystem/usr/local/include/ -fno-omit-frame-pointer -fno-stack-protector"

# found in script/update
setenv GYP_GENERATORS ninja
setenv GYP_DEFINES "disable_nacl=1 component=shared_library target_arch=x64"
setenv GYP_GENERATOR_FLAGS output_dir=out_component

# borrowed from the chromium port makefile
setenv GYP_DEFINES "$GYP_DEFINES clang_use_chrome_plugins=0"
setenv GYP_DEFINES "$GYP_DEFINES linux_breakpad=0"
setenv GYP_DEFINES "$GYP_DEFINES linux_use_heapchecker=0"
setenv GYP_DEFINES "$GYP_DEFINES linux_strip_binary=1"
setenv GYP_DEFINES "$GYP_DEFINES test_isolation_mode=noop"
setenv GYP_DEFINES "$GYP_DEFINES disable_nacl=1"
setenv GYP_DEFINES "$GYP_DEFINES enable_extensions=1"
setenv GYP_DEFINES "$GYP_DEFINES enable_one_click_signin=1"
setenv GYP_DEFINES "$GYP_DEFINES enable_openmax=1"
setenv GYP_DEFINES "$GYP_DEFINES enable_webrtc=1"
setenv GYP_DEFINES "$GYP_DEFINES werror="
setenv GYP_DEFINES "$GYP_DEFINES no_gc_sections=1"
setenv GYP_DEFINES "$GYP_DEFINES os_ver=9.3"
setenv GYP_DEFINES "$GYP_DEFINES prefix_dir=/usr/local"
setenv GYP_DEFINES "$GYP_DEFINES python_ver=2.7.9"
setenv GYP_DEFINES "$GYP_DEFINES use_allocator=none"
setenv GYP_DEFINES "$GYP_DEFINES use_cups=1"
setenv GYP_DEFINES "$GYP_DEFINES linux_link_gsettings=1"
setenv GYP_DEFINES "$GYP_DEFINES linux_link_libpci=1"
setenv GYP_DEFINES "$GYP_DEFINES linux_link_libspeechd=1"
setenv GYP_DEFINES "$GYP_DEFINES libspeechd_h_prefix=speech-dispatcher/"
setenv GYP_DEFINES "$GYP_DEFINES usb_ids_path=/usr/local/share/usbids/usb.ids"
setenv GYP_DEFINES "$GYP_DEFINES want_separate_host_toolset=0"
setenv GYP_DEFINES "$GYP_DEFINES use_system_bzip2=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_flac=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_harfbuzz=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_icu=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_jsoncpp=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libevent=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libexif=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libjpeg=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libpng=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libusb=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libwebp=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libxml=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_libxslt=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_nspr=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_protobuf=0"
setenv GYP_DEFINES "$GYP_DEFINES use_system_re2=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_snappy=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_speex=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_xdg_utils=1"
setenv GYP_DEFINES "$GYP_DEFINES use_system_yasm=1"
setenv GYP_DEFINES "$GYP_DEFINES v8_use_external_startup_data=0"

# overrides
setenv GYP_DEFINES "$GYP_DEFINES clang=0"          # because gcc
setenv GYP_DEFINES "$GYP_DEFINES use_system_icu=0" # better that way

build/gyp_chromium --depth . -Ichromiumcontent/chromiumcontent.gypi chromiumcontent/chromiumcontent.gyp
ninja -C out_component/Release chromiumcontent_all
