export THEOS=/var/mobile/theos
ARCHS := arm64
TARGET := iphone:clang:16.5
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := PastaCode

$(TWEAK_NAME)_FILES += sources/Tweak.mm
$(TWEAK_NAME)_FILES += sources/UIView+SecureView.m
$(TWEAK_NAME)_FILES += $(wildcard sources/KIF/*.mm sources/KIF/*.m)
$(TWEAK_NAME)_FILES += $(wildcard esp/drawing_view/*.m esp/drawing_view/*.mm esp/drawing_view/*.cpp)
$(TWEAK_NAME)_FILES += $(wildcard esp/helpers/*.m esp/helpers/*.mm)
$(TWEAK_NAME)_FILES += $(wildcard esp/unity_api/*.m esp/unity_api/*.mm)

sources/KIF/UITouch-KIFAdditions.m_CFLAGS := $(filter-out -mllvm -enable-fco,$(PastaCode_CFLAGS))

$(TWEAK_NAME)_CFLAGS += -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-module-import-in-extern-c -Wunused-but-set-variable
$(TWEAK_NAME)_OBJCCFLAGS += -fobjc-arc

$(TWEAK_NAME)_CXXFLAGS += -std=c++17
$(TWEAK_NAME)_OBJCXXFLAGS += -std=c++17

$(TWEAK_NAME)_CFLAGS += -Iheaders
$(TWEAK_NAME)_CFLAGS += -Isources
$(TWEAK_NAME)_CFLAGS += -Isources/KIF

$(TWEAK_NAME)_FRAMEWORKS += CoreGraphics CoreServices QuartzCore IOKit UIKit AVFoundation AudioToolbox CoreMedia

include $(THEOS_MAKE_PATH)/tweak.mk

after-all::
	@mkdir -p packages
	@cp -f .theos/obj/debug/$(TWEAK_NAME).dylib packages/$(TWEAK_NAME).dylib 2>/dev/null || cp -f .theos/obj/$(TWEAK_NAME).dylib packages/$(TWEAK_NAME).dylib 2>/dev/null || true
