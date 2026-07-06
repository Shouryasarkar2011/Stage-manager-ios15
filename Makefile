# Rootless requirement
export THEOS_PACKAGE_SCHEME = rootless

# Architectures and Target
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StageManager
StageManager_FILES = Tweak.xm
StageManager_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
