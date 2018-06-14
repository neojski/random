#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

// This is based on https://www.apriorit.com/dev-blog/195-simple-driver-for-linux-os
// See also: https://linux-kernel-labs.github.io/master/labs/device_drivers.html

static const char    data[] = "Hello world from kernel mode!\n\0";
static ssize_t device_file_read(struct file *file_ptr, char __user *user_buffer, size_t count, loff_t *offset) {
  struct inode* inode = file_ptr->f_inode;
  printk(KERN_NOTICE "tomasz-driver: Device major number = %i, minor number = %i\n", imajor(inode), iminor(inode));
  printk(KERN_NOTICE "tomasz-driver: Device file is read at offset = %i, read bytes count = %u\n", (int)*offset, (unsigned int)count);
  if (*offset + count > sizeof(data)) {
    count = sizeof(data) - *offset;
  }
  count = 1; // intentional. Run `strace cat device` to see that it returns 1 character at a time
  if (copy_to_user(user_buffer, data + *offset, count) != 0)
    return -EFAULT;
  *offset += count;
  return count;
}

static struct file_operations simple_driver_fops = {
    .owner = THIS_MODULE,
    .read  = device_file_read,
};

static int device_file_major_number = 0;
static const char device_name[] = "tomasz-driver";

static int register_device(void) {
  int result = 0;
  printk(KERN_NOTICE "tomasz-driver: register_device() is called.\n");
  result = register_chrdev(0, device_name, &simple_driver_fops);
  if (result < 0) {
    printk(KERN_WARNING "tomasz-driver:  can't register character device with errorcode = %i\n", result);
    return result;
  }
  device_file_major_number = result;
  printk(KERN_NOTICE "tomasz-driver: registered character device with major number = %i\n", device_file_major_number);
  return 0;
}

void unregister_device(void) {
  printk(KERN_NOTICE "tomasz-driver: unregister_device() is called\n");
  if (device_file_major_number != 0) {
    unregister_chrdev(device_file_major_number, device_name);
  }
}

static int __init demo_init(void) {
  int result;
  printk(KERN_NOTICE "Hello World! I'm loaded at 0x%p.\n", demo_init);
  result = register_device();
  return result;
}
static void __exit demo_exit(void) {
  printk(KERN_NOTICE "Goodbye, people! I'm unloading from 0x%p.\n", demo_exit);
  unregister_device();
}

module_init(demo_init);
module_exit(demo_exit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Tomasz");
