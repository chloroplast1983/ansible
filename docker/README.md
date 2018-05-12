# docker

---

## 概述

ansible docker 部署代码,我们在剧本中区分如下角色:

* common 通用部署.
* 虚拟机部署.

## 目录

* [角色](#role)
* [更新记录](#version)

## <a name="role">角色</a>

### common

* 修改主机名称
* 更新主机软件包
	* lvm2
	* yum-utils
	* device-mapper-persistent-data
* 更新`selinux`
* 格式化docker精简池
	* 硬盘分区 lvm
	* 检查分区是否已经创建,如果分区已经创建
		* 创建 pv
		* 创建 vg
		* 创建 lvm:thinpool
		* 创建 lvm:thinpoolmeta
		* 转换 lvm:thinpool to thinpool 和 lvm:thinpoolmeta to poolmetadata
		* 更新 docker-thinpool.profile 配置文件,使用精简池
		* 更新 lv配置
* 格式化数据盘
	* 硬盘分区 lvm
	* 创建 pv
	* 创建 vg
	* 格式化硬盘(数据盘)
	* 挂载数据盘到`/data`

### docker

* 安装docker 
	* 安装`17.06.x-ce`docker
	* 开机启动docker服务
	* 复制配置docker配置文件
	* 复制docker配置文件使用精简池
	* 重新启动docker
	* 创建docker用户组
	* 把ansible用户添加入docker用户组
* 更新内核参数
	* `/etc/sysctl.conf`
		* `net.netfilter.nf_conntrack_max`
		* `net.netfilter.nf_conntrack_tcp_timeout_established`
		* `net.netfilter.nf_conntrack_tcp_timeout_close_wait`
		* `net.netfilter.nf_conntrack_tcp_timeout_fin_wait`
		* `net.netfilter.nf_conntrack_tcp_timeout_time_wait`
		
### virtual

* 更新主机`yum`源为阿里云的源
* 安装软件包
	* `vim`
	* `ntp`
	* `net-tools`
* 更新`ntpd`配置文件
* 创建交换分区
	* 创建存储交换分区文件的文件夹
	* 创建交换分区文件
	* 检查交换分区文件是否存在,如果存在
		* 创建交换分区文件
		* 启动交换分区文件
		* 挂载交换分区文件


## <a name="version">更新记录</a>

### 1.0

#### sysctl.conf

在`common`任务添加对`/etc/sysctl.conf`配置文件修改, 修改

* `net.netfilter.nf_conntrack_max`
* `net.netfilter.nf_conntrack_tcp_timeout_established`
* `net.netfilter.nf_conntrack_tcp_timeout_close_wait`
* `net.netfilter.nf_conntrack_tcp_timeout_fin_wait`
* `net.netfilter.nf_conntrack_tcp_timeout_time_wait`

`net.netfilter.nf_conntrack_max`值计算方法`CONNTRACK_MAX = RAMSIZE (in bytes) / 16384 / (ARCH / 32)`.

我们生产服务器为`8G`, 按照`4G`空余使用计算:

`4*1024*1024*1024/16384/2 = 131072`.

* `1024*1024*1024` = `1G`
* `ARCH / 32` = `64 /32` = `2`