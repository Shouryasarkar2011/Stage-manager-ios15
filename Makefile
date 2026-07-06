# Rootless requirement
export THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1

# Standard build setup
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StageManager

StageManager_FILES = Tweak.xm
StageManager_FRAMEWORKS = UIKit
# Ensure we link against the dynamic loading library for dlsym
StageManager_LIBRARIES = dl

# This is critical for Rootless arm64e support
StageManager_ARCHS = arm64 arm64e
StageManager_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
