# Use the default kernel version if the Makefile doesn't override it

LINUX_RELEASE?=1

LINUX_VERSION-3.18 = .136
LINUX_VERSION-4.9 = .167
LINUX_VERSION-4.14 = .110
LINUX_VERSION-4.19 = .25

LINUX_KERNEL_HASH-3.18.136 = 48c8775013d23229462134f911bbb14c7935096fcccfb19ce28ecd5f7154f35c
LINUX_KERNEL_HASH-4.9.167 = a2b8608a2fe7a6203ed46c3a3d55091b19ac8304dded6338410a361dc63f0a8c
LINUX_KERNEL_HASH-4.14.110 = 99ea359464dc8a7ab9862195934a1f3504c38a32af5fa424e3ae56244dd59e72
LINUX_KERNEL_HASH-4.19.25 = 7ec71d90d6e96e6f741676d157ac06f30c75be4eaf1649143a3c8b7d4f919731

remove_uri_prefix=$(subst git://,,$(subst http://,,$(subst https://,,$(1))))
sanitize_uri=$(call qstrip,$(subst @,_,$(subst :,_,$(subst .,_,$(subst -,_,$(subst /,_,$(1)))))))

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_CLONE_URI)),)
  LINUX_VERSION:=$(call sanitize_uri,$(call remove_uri_prefix,$(CONFIG_KERNEL_GIT_CLONE_URI)))
  ifeq ($(call qstrip,$(CONFIG_KERNEL_GIT_REF)),)
    CONFIG_KERNEL_GIT_REF:=HEAD
  endif
  LINUX_VERSION:=$(LINUX_VERSION)-$(call sanitize_uri,$(CONFIG_KERNEL_GIT_REF))
else
ifdef KERNEL_PATCHVER
  LINUX_VERSION:=$(KERNEL_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_PATCHVER)))
endif
endif

split_version=$(subst ., ,$(1))
merge_version=$(subst $(space),.,$(1))
KERNEL_BASE=$(firstword $(subst -, ,$(LINUX_VERSION)))
KERNEL=$(call merge_version,$(wordlist 1,2,$(call split_version,$(KERNEL_BASE))))
KERNEL_PATCHVER ?= $(KERNEL)

# disable the md5sum check for unknown kernel versions
LINUX_KERNEL_HASH:=$(LINUX_KERNEL_HASH-$(strip $(LINUX_VERSION)))
LINUX_KERNEL_HASH?=x
