#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/irq.h>
#include <linux/workqueue.h>
#include <linux/errno.h>
#include <linux/pm.h>
#include <linux/platform_device.h>
#include <linux/input.h>
#include <linux/i2c.h>
#include <linux/gpio.h>
#include <linux/slab.h>
#include <linux/wait.h>
#include <linux/time.h>
#include <linux/delay.h>
#include <linux/of_gpio.h>
#include <linux/kthread.h>
#include <linux/list.h>
#include <linux/pinctrl/consumer.h>
#include <linux/regulator/consumer.h>

#include <linux/leds.h>

// #undef pr_debug
// #define pr_debug(fmt, ...) printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__)

//reg list
#define P0_INPUT	0x00
#define P1_INPUT 	0x01
#define P0_OUTPUT 	0x02
#define P1_OUTPUT 	0x03
#define P0_CONFIG	0x04
#define P1_CONFIG 	0x05
#define P0_INT		0x06
#define P1_INT		0x07
#define ID_REG		0x10
#define CTL_REG		0x11
#define P0_LED_MODE	0x12
#define P1_LED_MODE	0x13
#define PN_DIM_00   0x20
#define PN_DIM_01   0x21
#define PN_DIM_02   0x22
#define PN_DIM_03   0x23
#define PN_DIM_04   0x24
#define PN_DIM_05   0x25
#define PN_DIM_06   0x26
#define PN_DIM_07   0x27
#define PN_DIM_10   0x28
#define PN_DIM_11   0x29
#define PN_DIM_12   0x2A
#define PN_DIM_13   0x2B
#define PN_DIM_14   0x2C
#define PN_DIM_15   0x2D
#define PN_DIM_16   0x2E
#define PN_DIM_17   0x2F
#define SW_RSTN		0x7F

struct aw9523_platform_data {
	struct mutex lock;
	struct task_struct *trigger_thread;

	spinlock_t q_lock;
	int q_count;
	struct list_head queue;

	int reset_gpio;
	struct i2c_client *client;
	int led_count;
	struct led_classdev *leds[16];
};

#define MAX_LED_COUNTS(pdata) sizeof(pdata->leds)/sizeof(pdata->leds[0])
#define MAX_RGBLED_VALUE 255
#define NAME_FMT "logo-%d-%d"

static int __aw9523_read_reg(struct i2c_client *client, int reg, unsigned char *val)
{
	int ret;

	ret = i2c_smbus_read_byte_data(client, reg);
	if (ret < 0) {
		dev_err(&client->dev, "i2c read fail: can't read from %02x: %d\n", reg, ret);
		return ret;
	} else {
		*val = ret;
	}
	return 0;
}

static int __aw9523_write_reg(struct i2c_client *client, int reg, int val)
{
	int ret;

	ret = i2c_smbus_write_byte_data(client, reg, val);
	if (ret < 0) {
		dev_err(&client->dev, "i2c write fail: can't write %02x to %02x: %d\n",
			val, reg, ret);
		return ret;
	}
	return 0;
}

static int aw9523_read_reg(struct i2c_client *client, int reg,
						unsigned char *val)
{
	int rc;
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);
	mutex_lock(&pdata->lock);
	rc = __aw9523_read_reg(client, reg, val);
	mutex_unlock(&pdata->lock);

	return rc;
}

static int aw9523_write_reg(struct i2c_client *client, int reg,
						unsigned char val)
{
	int rc;
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);
	mutex_lock(&pdata->lock);
	rc = __aw9523_write_reg(client, reg, val);
	mutex_unlock(&pdata->lock);

	return rc;
}

#ifdef AW9523_DEBUG
void aw9523_test(struct i2c_client *client)
{ 
	unsigned char val;
	
	pr_debug(KERN_ERR "<<<<<<<<<9523 reg dump>>>>>>>>\n");

	aw9523_read_reg(client, ID_REG, &val);
	pr_debug(KERN_ERR"ID_REG=0x%x\n",val);
	aw9523_read_reg(client, P0_INPUT, &val);
	pr_debug(KERN_ERR"P0_INPUT=0x%x\n",val);
	aw9523_read_reg(client, P1_INPUT, &val);
	pr_debug(KERN_ERR"P1_INPUT=0x%x\n",val);
	aw9523_read_reg(client, P0_OUTPUT, &val);
	pr_debug(KERN_ERR"P0_OUTPUT=0x%x\n",val);
	aw9523_read_reg(client, P1_OUTPUT, &val);
	pr_debug(KERN_ERR"P1_OUTPUT=0x%x\n",val);
	aw9523_read_reg(client, P0_CONFIG, &val);
	pr_debug(KERN_ERR"P0_CONFIG=0x%x\n",val);
	aw9523_read_reg(client, P1_CONFIG, &val);
	pr_debug(KERN_ERR"P1_CONFIG=0x%x\n",val);
	aw9523_read_reg(client, P0_INT, &val);
	pr_debug(KERN_ERR"P0_INT=0x%x\n",val);
	aw9523_read_reg(client, P1_INT, &val);
	pr_debug(KERN_ERR"P1_INT=0x%x\n",val);
	aw9523_read_reg(client, CTL_REG, &val);
	pr_debug(KERN_ERR"CTL_REG=0x%x\n",val);

}
#endif

void aw9523_init(struct i2c_client *client)
{
	unsigned char val = 0;

	aw9523_read_reg(client, ID_REG, &val);
	pr_debug(KERN_ERR "aw9523b ID_REG=0x%x\n",val);

	aw9523_write_reg(client, P0_CONFIG, 0x00); //set p0 port output mode
    aw9523_write_reg(client, P1_CONFIG, 0x00); //set p1 port output mode

	aw9523_write_reg(client, P0_OUTPUT, 0x00); //P0 line output 1
	aw9523_write_reg(client, P1_OUTPUT, 0x00); //P1 line output 1
	
	aw9523_write_reg(client, P0_INT, 0xFF); //P0 interrupt disable
	aw9523_write_reg(client, P1_INT, 0xFF); //P1 interrupt disable

	/*
	Init RGB LED
	    Set P1_LED_MODE register to led model.
	    P1_LED_MODE:This register is LED or GPIO mode switch.
	    Set the register P1_0~P1_2 to 0 (1: gpio 0: led)
	    reg P1_0~P1_2:   PN_DIM_10   PN_DIM_11   PN_DIM_10
	*/
	aw9523_write_reg(client, P1_LED_MODE, 0x00);
	aw9523_write_reg(client, P0_LED_MODE, 0x00);

	/* PULL/PUSH */
	aw9523_write_reg(client, CTL_REG, 0x10);
}

typedef struct {
	struct list_head list;
	int reg, val;
} trig_q_t;

static void aw9523_leds_PXX(struct led_classdev *cdev,
			       enum led_brightness value)
{
	int nrx, reg, ret;
	struct i2c_client *client = to_i2c_client(cdev->dev->parent);
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);
	trig_q_t *node;

	if (value > MAX_RGBLED_VALUE)
		value = MAX_RGBLED_VALUE;

	ret = sscanf(cdev->name, NAME_FMT, &nrx, &reg);
	reg += 0x20;

	pr_debug(KERN_INFO "aw9523_leds[%d]_P00 %x value=%d\n", nrx, reg, value);
	/* led trigger is timer_fn, so do not call directlly~! */
	node = kmalloc(sizeof(trig_q_t), GFP_KERNEL);
	if(!node) {
		return;
	}
	node->reg = reg;
	node->val = value;
	spin_lock_bh(&pdata->q_lock);
	list_add(&node->list, &pdata->queue);
	pdata->q_count ++;
	spin_unlock_bh(&pdata->q_lock);

	wake_up_process(pdata->trigger_thread);
	// aw9523_write_reg(client, reg, value);
}

static int nr = 0;
static int led_class_register(struct i2c_client *client)
{
	int i;
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);

	WARN_ON(pdata->led_count);

	/*RGB LED control file create*/
	for(i=0; i<MAX_LED_COUNTS(pdata); i++) {
		char name[16];
		struct led_classdev *class = kzalloc(sizeof(struct led_classdev), GFP_KERNEL);//&AW9523b_RGB[i];
		if(!class) {
			return -ENOMEM;
		}
		pdata->leds[pdata->led_count] = class;
		snprintf(name, sizeof(name), NAME_FMT, nr, pdata->led_count);
		class->name = kstrdup(name, GFP_KERNEL);
		class->brightness_set = aw9523_leds_PXX;
		class->max_brightness = MAX_RGBLED_VALUE;
		if(led_classdev_register(&client->dev, class)) {
			pr_err("%s: aw9523b [%d-%d] failed\n", __func__, nr, i);
			return -EINVAL;
		}
		pdata->led_count ++;
	}
	nr ++;
	pr_info("aw9523b-[%d] has %d leds registered.\n", nr, pdata->led_count);
	return 0;
}

static void led_class_unregister(struct i2c_client *client)
{
	int i;
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);

	/*RGB LED control file create*/
	for(i=0; i<MAX_LED_COUNTS(pdata); i++) {
		struct led_classdev* class = pdata->leds[i];
		if(class) {
			led_classdev_unregister(class);
			kfree(class->name);
			kfree(class);
			pdata->leds[i] = NULL;
		}
	}
	nr --;
}

int work_thread_fn(void *u)
{
	struct i2c_client *client = u;
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);

	for (;;) {
		struct list_head tmp;
		trig_q_t *node, *n; 

		if (kthread_should_stop())
			break;

		spin_lock_bh(&pdata->q_lock);
		if(list_empty(&pdata->queue)) {
			spin_unlock_bh(&pdata->q_lock);
			// schedule();
			msleep(1);
			continue;
		}

		INIT_LIST_HEAD(&tmp);
		list_for_each_entry_safe(node, n, &pdata->queue, list) {
			list_move(&node->list, &tmp);
			pdata->q_count --;
		}
		spin_unlock_bh(&pdata->q_lock);

		/* i2c call */
		list_for_each_entry_safe(node, n, &tmp, list) {
			list_del(&node->list);
			__aw9523_write_reg(client, node->reg, node->val);
			kfree(node);
		}

		cond_resched();
	}
	return 0;
}

static int aw9523_probe(struct i2c_client *client,
			 const struct i2c_device_id *id)
{
	struct aw9523_platform_data *pdata = NULL;
	int i, ret = 0;

	dev_err(&client->dev, "probe...\n");
	if (!i2c_check_functionality(client->adapter,
					I2C_FUNC_SMBUS_BYTE_DATA)) {
		dev_err(&client->dev, "SMBUS Byte Data not Supported\n");
		return -EIO;
	}
	
	pdata = devm_kzalloc(&client->dev, sizeof(struct aw9523_platform_data), GFP_KERNEL);
	if (!pdata) 
	{
		dev_err(&client->dev, "Failed to allocate memory\n");
		return -ENOMEM;
	}
	pdata->client = client;
	i2c_set_clientdata(client, pdata);

	pdata->reset_gpio = of_get_named_gpio(client->dev.of_node, "gpios", 0);
	if ((!gpio_is_valid(pdata->reset_gpio))){
		dev_err(&client->dev, "aw9523_probe reset_gpio=%d failed\n", pdata->reset_gpio);
		return -EINVAL;
	}
	dev_err(&client->dev, "reset use gpio: %d\n", pdata->reset_gpio);
	ret = gpio_request(pdata->reset_gpio, "reset-leds");
	if (ret) {
		dev_err(&client->dev, "unable to request gpio [%d]\n",
			pdata->reset_gpio);
		goto err_free;
	}
	ret = gpio_direction_output(pdata->reset_gpio, 1);
	if (ret) {
		dev_err(&client->dev, "unable to set direction for gpio [%d]\n",
			pdata->reset_gpio);
		goto err_reset_gpio;
	}
	gpio_set_value(pdata->reset_gpio, 0); /* ULPM */
	msleep(100);
	gpio_set_value(pdata->reset_gpio, 1); /* HPD */

	if((ret=__aw9523_read_reg(client, ID_REG, (void*)&i))) {
		dev_err(&client->dev, "unable to access ID REG\n");
		goto err_reset_gpio;
	}

	/*RGB LED control file create*/
	if(led_class_register(client)) {
		goto err_release_led;
	}

	i2c_set_clientdata(client, pdata);
	mutex_init(&pdata->lock);
	spin_lock_init(&pdata->q_lock);
	INIT_LIST_HEAD(&pdata->queue);

	pdata->trigger_thread = kthread_create(work_thread_fn, client, "aw9523b-%d", nr);
	if(IS_ERR(pdata->trigger_thread)) {
		dev_err(&client->dev, "create thread failed.\n");
		goto err_release_led;
	}

    aw9523_init(client);
	wake_up_process(pdata->trigger_thread);

	printk("%s finished.\n", __func__);
	return 0;

err_release_led:
	led_class_unregister(client);
err_reset_gpio:
	gpio_free(pdata->reset_gpio);
err_free:
	devm_kfree(&client->dev, pdata);
	return ret;
}

static int aw9523_remove(struct i2c_client *client)
{
	struct aw9523_platform_data *pdata = i2c_get_clientdata(client);

	// aw9523_write_reg(client, P0_OUTPUT, 0xFF);
	// aw9523_write_reg(client, P1_OUTPUT, 0xFF);
	kthread_stop(pdata->trigger_thread);
	gpio_free(pdata->reset_gpio);
	led_class_unregister(client);
	printk("%s %d success.\n", __func__, nr);
	return 0;
}

static const struct of_device_id aw9523_keypad_of_match[] = {
	{ .compatible = "awinic,aw9523b",},
	{},
};

static const struct i2c_device_id aw9523_id[] = {
	{"aw9523-leds", 0},
	{},
};
MODULE_DEVICE_TABLE(i2c, aw9523_id);

static struct i2c_driver aw9523_driver = {
	.driver = {
		.name = "aw9523b",
		.owner		= THIS_MODULE,
		.of_match_table = aw9523_keypad_of_match,
	},
	.probe    = aw9523_probe,
	.remove   = aw9523_remove,
	.id_table = aw9523_id,
};

module_i2c_driver(aw9523_driver);

MODULE_AUTHOR("nobody <nx@china.com.cn>");
MODULE_DESCRIPTION("Aw9523 Leds driver");
MODULE_LICENSE("GPL");
MODULE_ALIAS("i2c:aw9523-leds");
