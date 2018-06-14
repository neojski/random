#include <linux/init.h>
#include <linux/module.h>

static int __init demo_init(void)
{
        pr_info("Hello World! I'm loaded at 0x%p.\n", demo_init);
        return 0;
}
static void __exit demo_exit(void)
{
        pr_info("Goodbye, people! I'm unloading from 0x%p.\n", demo_exit);
}

module_init(demo_init);
module_exit(demo_exit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Tomasz");
