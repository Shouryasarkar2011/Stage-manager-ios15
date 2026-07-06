# Rootless requirement
export THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1

# Architectures and Target
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StageManager
StageManager_FILES = Tweak.xm
StageManager_FRAMEWORKS = UIKit
# This tells the linker to include the library needed for dlsym
StageManager_LIBRARIES = dl

include $(THEOS_MAKE_PATH)/tweak.mk
