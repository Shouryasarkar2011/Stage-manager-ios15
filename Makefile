# Include your common settings
include Makefile.common

# Define the tweak
TWEAK_NAME = StageManager
StageManager_FILES = Tweak.xm
StageManager_FRAMEWORKS = UIKit CoreGraphics

# Include the standard Theos tweak build path
include $(THEOS_MAKE_PATH)/tweak.mk