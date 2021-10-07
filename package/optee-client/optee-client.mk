################################################################################
#
# optee-client
#
################################################################################



ifeq ($(BR2_PACKAGE_OPTEE_CLIENT_LATEST), y)
OPTEE_CLIENT_VERSION = origin/master
else
OPTEE_CLIENT_VERSION = $(call qstrip,$(BR2_PACKAGE_OPTEE_CLIENT_VERSION))
endif

CFG_TEE_BENCHMARK = $(BR2_PACKAGE_OPTEE_CLIENT_CFG_TEE_BENCHMARK)


#OPTEE_CLIENT_SITE = $(call github,Distrinet-TACOS,optee_client,$(OPTEE_CLIENT_VERSION))
BR_NO_CHECK_HASH_FOR += $(OPTEE_CLIENT_SOURCE)
OPTEE_CLIENT_LICENSE = BSD-2-Clause
OPTEE_CLIENT_LICENSE_FILES = LICENSE
OPTEE_CLIENT_INSTALL_STAGING = YES



ifeq ($(BR2_PACKAGE_OPTEE_CLIENT_CUSTOM_GIT),y)
OPTEE_CLIENT_SITE = $(call qstrip,$(BR2_PACKAGE_OPTEE_CLIENT_CUSTOM_REPO_URL))
OPTEE_CLIENT_SITE_METHOD = git
else
OPTEE_CLIENT_SITE = $(call github,Distrinet-TACOS,optee_client,$(OPTEE_CLIENT_VERSION))
endif




OPTEE_CLIENT_CONF_OPTS = \
	-DCFG_TEE_FS_PARENT_PATH=$(BR2_PACKAGE_OPTEE_CLIENT_TEE_FS_PATH) \
	-DCFG_WERROR=OFF

define OPTEE_CLIENT_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(OPTEE_CLIENT_PKGDIR)/S30optee \
		$(TARGET_DIR)/etc/init.d/S30optee
endef

$(eval $(cmake-package))
