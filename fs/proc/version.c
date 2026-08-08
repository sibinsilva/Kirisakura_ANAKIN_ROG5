// SPDX-License-Identifier: GPL-2.0
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/utsname.h>

#include <linux/string.h>

static int version_proc_show(struct seq_file *m, void *v)
{
	char proc_release[64];
	const char *release = utsname()->release;

	if (!strncmp(release, "5.4.210", 7)) {
		snprintf(proc_release, sizeof(proc_release), "5.4.302%s", release + 7);
	} else {
		strlcpy(proc_release, release, sizeof(proc_release));
	}

	seq_printf(m, linux_proc_banner,
		utsname()->sysname,
		proc_release,
		utsname()->version);
	return 0;
}

static int __init proc_version_init(void)
{
	proc_create_single("version", 0, NULL, version_proc_show);
	return 0;
}
fs_initcall(proc_version_init);
