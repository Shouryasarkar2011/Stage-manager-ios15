ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StageManager
StageManager_FILES = Tweak.xm
StageManager_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
