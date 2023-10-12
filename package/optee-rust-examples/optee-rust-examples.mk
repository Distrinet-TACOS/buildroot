OPTEE_RUST_EXAMPLES_VERSION = 1.0
OPTEE_RUST_EXAMPLES_SOURCE = local
OPTEE_RUST_EXAMPLES_SITE = $(call qstrip,$(BR2_PACKAGE_OPTEE_RUST_EXAMPLES_SITE))
OPTEE_RUST_EXAMPLES_SITE_METHOD = local
OPTEE_RUST_EXAMPLES_INSTALL_STAGING = YES

OPTEE_RUST_EXAMPLES_DEPENDENCIES = optee-client optee-os

ifneq (,$(BR2_PACKAGE_OPTEE_RUST_EXAMPLES_TC_PATH_ENV))
OPTEE_RUST_EXAMPLES_TC_PATH_ENV = PATH=$(BR2_PACKAGE_OPTEE_RUST_EXAMPLES_TC_PATH_ENV)
endif

EXAMPLE = $(wildcard examples/*)

export RUST_TARGET_PATH = $(@D)
export RUST_COMPILER_RT_ROOT = $(RUST_TARGET_PATH)/rust/rust/src/llvm-project/compiler-rt
export OPTEE_OS_DIR = $(OPTEE_OS_BUILDDIR)
export OPTEE_CLIENT_DIR
export OPTEE_CLIENT_INCLUDE = $(OPTEE_CLIENT_DIR)/out/export/usr/include
export OPTEE_OS_INCLUDE = $(OPTEE_OS_BUILDDIR)/out/export-ta_arm32/include
export ARCH

ifneq ($(ARCH), arm)
	export VENDOR = qemu_v8.mk
	export CC = $(OPTEE_DIR)/toolchains/aarch64/bin/aarch64-linux-gnu-gcc
	export HOST_TARGET = aarch64-unknown-linux-gnu
	export TA_TARGET = aarch64-unknown-optee-trustzone
else
	export VENDOR = qemu.mk
	export CC = $(HOST_DIR)/bin/arm-none-linux-gnueabihf-gcc
	export HOST_TARGET = arm-unknown-linux-gnueabihf
	export TA_TARGET = arm-unknown-optee-trustzone
endif

define OPTEE_RUST_EXAMPLES_BUILD_CMDS
	@$(foreach f,$(wildcard $(@D)/examples/*/Makefile), \
		@printf "\n====== Building $f ======\n" && \
		$(OPTEE_RUST_EXAMPLES_TC_PATH_ENV) $(MAKE) -C $(dir $f)
	)
endef

define OPTEE_RUST_EXAMPLES_INSTALL_TARGET_CMDS
	@$(foreach f,$(wildcard $(@D)/examples/*/ta/target/$(TA_TARGET)/release/*.ta), \
		mkdir -p $(TARGET_DIR)/lib/optee_armtz && \
		echo Installing $f && \
		$(INSTALL) -v -p --mode=444 \
			--target-directory=$(TARGET_DIR)/lib/optee_armtz $f \
			&&) true
	@$(foreach f,$(wildcard $(@D)/examples/*/host/target/$(HOST_TARGET)/release/*-rs), \
		echo Installing $f && \
		$(INSTALL) -v -p --target-directory=$(TARGET_DIR)/usr/bin $f \
		&&) true
	@$(foreach f,$(wildcard $(@D)/examples/*/plugin/target/$(HOST_TARGET)/release/*.plugin.so), \
		mkdir -p $(TARGET_DIR)/usr/lib/tee-supplicant/plugins && \
		echo Installing $f && \
		$(INSTALL) -v -p --target-directory=$(TARGET_DIR)/usr/lib/tee-supplicant/plugins $f \
		&&) true
endef

$(eval $(generic-package))
