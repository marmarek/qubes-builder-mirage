ifeq ($(DIST),mirage)
MIRAGE_PLUGIN_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DISTRIBUTION := mirage
BUILDER_MAKEFILE := $(MIRAGE_PLUGIN_DIR)Makefile.mirage
TEMPLATE_SCRIPTS := $(MIRAGE_PLUGIN_DIR)template_scripts
TEMPLATE_ENV_WHITELIST += MIRAGE_KERNEL_PATH
endif

# vim: ft=make
