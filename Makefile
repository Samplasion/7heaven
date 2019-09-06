INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 7Heaven

7Heaven_FILES = Tweak.x
7Heaven_CFLAGS = -fobjc-arc
7Heaven_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
