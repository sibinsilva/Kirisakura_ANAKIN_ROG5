#ifndef __EROFS_COMPAT_H__
#define __EROFS_COMPAT_H__

#include <linux/pagemap.h>
#include <linux/sched.h>
#include <linux/sched/types.h>
#include <uapi/linux/sched/types.h>
#include <linux/statfs.h>

#ifndef MIN_T
#define MIN_T(type, x, y) min_t(type, x, y)
#endif

/* Compatibility shims for backporting EROFS from 5.10 to 5.4 */

/* attach/detach page private helpers */
static inline void attach_page_private(struct page *page, void *data)
{
	get_page(page);
	set_page_private(page, (unsigned long)data);
	SetPagePrivate(page);
}

static inline void *detach_page_private(struct page *page)
{
	void *data = (void *)page_private(page);

	if (!PagePrivate(page))
		return NULL;
	ClearPagePrivate(page);
	set_page_private(page, 0);
	put_page(page);

	return data;
}

/* u64_to_fsid helper */
static inline __kernel_fsid_t u64_to_fsid(u64 v)
{
	return (__kernel_fsid_t){.val = {(u32)v, (u32)(v>>32)}};
}

/* scheduler helpers */
static inline void sched_set_fifo_low(struct task_struct *p)
{
	struct sched_param sp = { .sched_priority = 1 };
	WARN_ON_ONCE(sched_setscheduler_nocheck(p, SCHED_FIFO, &sp) != 0);
}

static inline void sched_set_normal(struct task_struct *p, int nice)
{
	struct sched_attr attr = {
		.sched_policy = SCHED_NORMAL,
		.sched_nice = nice,
	};
	WARN_ON_ONCE(sched_setattr_nocheck(p, &attr) != 0);
}

/* readahead compatibility wrapper */
struct readahead_control {
	struct address_space *mapping;
	struct file *file;
	pgoff_t _index;
	unsigned int _nr_pages;
	struct list_head *_pages;
	gfp_t _gfp;
};

static inline pgoff_t readahead_index(struct readahead_control *rac)
{
	return rac->_index;
}

static inline unsigned int readahead_count(struct readahead_control *rac)
{
	return rac->_nr_pages;
}

static inline loff_t readahead_pos(struct readahead_control *rac)
{
	return (loff_t)rac->_index << PAGE_SHIFT;
}

static inline struct page *erofs_readahead_page(struct readahead_control *rac, struct list_head *pagepool)
{
	struct page *page;
	while (!list_empty(rac->_pages)) {
		page = lru_to_page(rac->_pages);
		list_del(&page->lru);
		if (add_to_page_cache_lru(page, rac->mapping, page->index, rac->_gfp)) {
			if (pagepool)
				list_add(&page->lru, pagepool);
			else
				put_page(page);
			continue;
		}
		return page;
	}
	return NULL;
}

#endif /* __EROFS_COMPAT_H__ */
