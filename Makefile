# Project Name
PROJECT = msc-ram

# Path you your toolchain and openocd installation, leave empty if already in system PATH
TOOLCHAIN_ROOT = /opt/wch/mounriver-studio-toolchain-riscv/bin/
OPENOCD_ROOT   = /opt/wch/mounriver-studio-toolchain-openocd/bin/

# Path to the WCH vendor codebase, make sure to update the submodule to get the code
VENDOR_ROOT = ./vendor/

# Path to CherryUSB codebase
#CHERRYUSB_ROOT = /home/rax/exp/wch/CherryUSB/
CHERRYUSB_ROOT = ./src/cherry/

###############################################################################

# Project specific
TARGET = $(PROJECT).elf
SRC_DIR = src/

CORE_DIR = $(VENDOR_ROOT)Core/
DEBUG_DIR = $(VENDOR_ROOT)Debug/
PERIPHERAL_DIR = $(VENDOR_ROOT)Peripheral/
STARTUP_DIR = $(VENDOR_ROOT)Startup/

# Toolchain
CC = $(TOOLCHAIN_ROOT)riscv-none-embed-gcc
DB = $(TOOLCHAIN_ROOT)riscv-none-embed-gdb
SIZE = $(TOOLCHAIN_ROOT)riscv-none-embed-size

# Project sources
SRC_FILES  = $(wildcard $(SRC_DIR)*.c) $(wildcard $(SRC_DIR)*/*.c)
SRC_FILES += $(wildcard $(CHERRYUSB_ROOT)*/*.c) #$(wildcard $(CHERRYUSB_ROOT)*/*/*.c)
SRC_FILES += $(CHERRYUSB_ROOT)port/ch32/usb_dc_usbfs.c
SRC_FILES += $(CHERRYUSB_ROOT)class/msc/usbd_msc.c

# Project includes
INCLUDES  = -I$(SRC_DIR)
INCLUDES += -I$(SRC_DIR)/cherry/common/
INCLUDES += -I$(SRC_DIR)/cherry/core/
INCLUDES += -I$(SRC_DIR)/cherry/osal/
INCLUDES += -I$(SRC_DIR)/cherry/port/ch32/
INCLUDES += -I$(SRC_DIR)/cherry/class/cdc/
INCLUDES += -I$(SRC_DIR)/cherry/class/hub/
INCLUDES += -I$(SRC_DIR)/cherry/class/hid/
INCLUDES += -I$(SRC_DIR)/cherry/class/audio/
INCLUDES += -I$(SRC_DIR)/cherry/class/dfu/
INCLUDES += -I$(SRC_DIR)/cherry/class/msc/
INCLUDES += -I$(SRC_DIR)/cherry/class/midi/
INCLUDES += -I$(SRC_DIR)/cherry/class/tmc/
INCLUDES += -I$(SRC_DIR)/cherry/class/video/
#INCLUDES += -I$(wildcard $(CHERRYUSB_ROOT)*.h)

# Vendor sources:
ASM_FILES += $(STARTUP_DIR)startup_ch32v30x_D8C.S
SRC_FILES += $(CORE_DIR)core_riscv.c
SRC_FILES += $(DEBUG_DIR)debug.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_adc.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_bkp.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_can.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_crc.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_dac.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_dbgmcu.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_dma.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_dvp.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_eth.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_exti.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_flash.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_fsmc.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_gpio.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_i2c.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_iwdg.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_misc.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_opa.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_pwr.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_rcc.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_rng.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_rtc.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_sdio.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_spi.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_tim.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_usart.c
SRC_FILES += $(PERIPHERAL_DIR)src/ch32v30x_wwdg.c

# Vendor includes
INCLUDES  += -I$(CORE_DIR)
INCLUDES  += -I$(DEBUG_DIR)
INCLUDES  += -I$(PERIPHERAL_DIR)inc/

# Vendor Link Script
LD_SCRIPT = $(VENDOR_ROOT)Ld/Link.ld

# Compiler Flags
CFLAGS  = -march=rv32imac -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -Os
CFLAGS += -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wunused -Wuninitialized -g #-x assembler
CFLAGS += -std=gnu99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)"
CFLAGS += $(INCLUDES)

# Assembler Flags
ASMFLAGS = -x assembler

# Linker Flags
LFLAGS = -T $(LD_SCRIPT) -nostartfiles -Xlinker --gc-sections -Wl,-Map,$(PROJECT).map --specs=nano.specs --specs=nosys.specs

###############################################################################

# This does an in-source build. An out-of-source build that places all object
# files into a build directory would be a better solution, but the goal was to
# keep this file very simple.

CXX_OBJS = $(SRC_FILES:.c=.o)
ASM_OBJS = $(ASM_FILES:.S=.o)
ALL_OBJS = $(ASM_OBJS) $(CXX_OBJS)

.PHONY: clean prog gdb-server_openocd gdb-client

all: $(TARGET)

# Compile

$(ASM_OBJS): %.o: %.S
	@echo "[ASM CC] $@"
	@$(CC) $(CFLAGS) $(ASMFLAGS) -c $< -o $@

$(CXX_OBJS): %.o: %.c
	@echo "[CC] $@"
	@$(CC) $(CFLAGS) -c $< -o $@

# Link
%.elf: $(ALL_OBJS)
	@echo "[LD] $@"
	@$(CC) $(CFLAGS) $(LFLAGS) $(ALL_OBJS) -o $@
	@$(SIZE) $@

# Clean
clean:
	@rm -f $(ALL_OBJS) $(ALL_OBJS:o=d) $(TARGET) $(PROJECT).map

# Program
prog: $(TARGET)
	$(OPENOCD_ROOT)openocd -f $(OPENOCD_ROOT)wch-riscv.cfg -c init -c halt -c "flash erase_sector wch_riscv 0 last " -c exit
	$(OPENOCD_ROOT)openocd -f $(OPENOCD_ROOT)wch-riscv.cfg -c init -c halt -c "program $(TARGET) 0x08000000" -c exit
	#$(OPENOCD_ROOT)openocd -f $(OPENOCD_ROOT)wch-riscv.cfg -c init -c halt -c "verify_image $(TARGET)" -c exit
	$(OPENOCD_ROOT)openocd -f $(OPENOCD_ROOT)wch-riscv.cfg -c init -c "reset" -c exit || exit 0

# Debug
gdb-server_openocd:
	$(OPENOCD_ROOT)openocd -f $(OPENOCD_ROOT)wch-riscv.cfg

gdb-client: $(TARGET)
	$(DB) $(TARGET)
