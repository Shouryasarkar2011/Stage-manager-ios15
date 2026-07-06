export THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1

ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StageManager
StageManager_FILES = Tweak.xm
StageManager_FRAMEWORKS = UIKit
StageManager_LIBRARIES = dl
StageManager_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
