# susfs selinux_hide feature
# old susfs won't have this manual hook
# and nongki 4.14- can't use simonpunk's hook for that
# check it, when there doesn't have, fallback to auto hook
ifeq ($(shell grep -q "ksu_selinux_hide_running" $(srctree)/security/selinux/hooks.c; echo $$?),0)
$(info -- $(REPO_NAME)/susfs_feature_check: selinux_hide manual hook found)
ccflags-y += -DKSU_COMPAT_HAS_SUSFS_FEATURE_SELINUX_HIDE
endif

# susfs's dev branch currently using post_execve_hook
# but in other branch, it still direcctly call ksu_install_su_fd
# to avoid install su fd repeatedly
ifeq ($(shell grep -q "ksu_install_su_fd" $(srctree)/fs/exec.c; echo $$?),0)
$(info -- $(REPO_NAME)/compat: ksu_install_su_fd direct call found)
ccflags-y += -DKSU_COMPAT_HAS_SUSFS_INSTALL_SU_FD_DIRECT_CALL
endif

# The upstream SuSFS hooks still use fake_state. Venus 5.4 instead routes
# the updated inline hooks through BakaSU's dual-policy/SID-table helpers.
ifeq ($(VERSION).$(PATCHLEVEL),5.4)
ifeq ($(shell grep -qs '^\#define SUSFS_BAKASU_SELINUX_BRIDGE 1$$' $(srctree)/include/linux/susfs_selinux.h && grep -q 'ksu_susfs_context_to_sid' $(srctree)/security/selinux/hooks.c && grep -q 'ksu_susfs_compute_av' $(srctree)/security/selinux/selinuxfs.c && ! grep -q 'fake_state' $(srctree)/security/selinux/hooks.c $(srctree)/security/selinux/selinuxfs.c; echo $$?),0)
ccflags-y += -DKSU_COMPAT_HAS_SUSFS_SELINUX_BRIDGE
else
$(error SuSFS requires the updated BakaSU SELinux bridge in this 5.4 kernel.)
endif
else
$(error Please wait susfs update. This fork's bridge currently supports Linux 5.4 only.)
endif
