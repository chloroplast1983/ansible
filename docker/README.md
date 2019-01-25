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
	* 安装`17.09.1.ce`docker
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

## <a name="version">更新记录</a>

### 1.0

#### sysctl.conf

[数据测试](https://github.com/chloroplast1983/readingNotes/blob/41dc2778c84a189a9632930cb7096fef5c1d8e32/%E6%9D%82%E8%AE%B0/docker/nf_conntrack-%20table%20full%2Cdropping%20packet.md)

在`common`任务添加对`/etc/sysctl.conf`配置文件修改, 修改

* `net.netfilter.nf_conntrack_max`
* `net.netfilter.nf_conntrack_tcp_timeout_established = 300`
* `net.netfilter.nf_conntrack_tcp_timeout_close_wait`
* `net.netfilter.nf_conntrack_tcp_timeout_fin_wait`
* `net.netfilter.nf_conntrack_tcp_timeout_time_wait`

`net.netfilter.nf_conntrack_max`值计算方法`CONNTRACK_MAX = RAMSIZE (in bytes) / 16384 / (ARCH / 32)`.

我们生产服务器为`8G`, 按照`4G`空余使用计算:

`4*1024*1024*1024/16384/2 = 131072`.

* `1024*1024*1024` = `1G`
* `ARCH / 32` = `64 /32` = `2`

#### net.netfilter.nf_conntrack_tcp_timeout_established

就是它让iptables对于已建立的连接, xxx秒若没有活动, 那么则清除掉, 默认的时间是432000秒(5天). 

### 1.1

取消创建交换分区任务

### 1.2

#### swappiness

`swappiness`, Linux内核参数, 控制换出运行时内存的相对权重. `swappiness`参数值可设置范围在`0`到`100`之间. 低参数值会让内核尽量少用交换, 更高参数值会使内核更多的去使用交换空间.

默认一般为`60`. 我们修改为`0`. 表示最大限度使用物理内存

#### ip_local_port_range

参考自**高性能mysql.p418**

```
[ansible@iZ94ebqp9jtZ ~]$ cat /proc/sys/net/ipv4/ip_local_port_range
32768	60999
```

说明这台机器本地能向外连接`60999-32768=28231`个, 注意是本地向外连接，不是这台机器的所有连接，不会影响这台机器的80端口的对外连接数.

我们修改为`1024	65000`

#### net.ipv4.tcp_fin_timeout

参考自**高性能mysql.p418**

修改`TCP`保持状态的超时时间. 默认是1分钟. 我们修改为`10s`

#### net.ipv4.tcp_syncookies

开启SYN Cookies, 当出现SYN等待队列溢出时, 启用cookies来处理.

SYN Cookie是对TCP服务器端的三次握手做一些修改, 专门用来防范SYN Flood攻击的一种手段. 它的原理是, 在TCP服务器接收到TCP SYN包并返回TCP SYN + ACK包时, 不分配一个专门的数据区, 而是根据这个SYN包计算出一个cookie值. 这个cookie作为将要返回的SYN ACK包的初始序列号. 当客户端返回一个ACK包时, 根据包头信息计算cookie, 与返回的确认序列号(初始序列号 + 1)进行对比, 如果相同, 则是一个正常连接, 然后, 分配资源, 建立连接.

#### net.ipv4.tcp_max_syn_backlog

参考自**高性能mysql.p418**

Tcp syn队列的最大长度, 在进行系统调用connect时会发生Tcp的三次握手, server内核会为Tcp维护两个队列, Syn队列和Accept队列, Syn队列是指存放完成第一次握手的连接, Accept队列是存放完成整个Tcp三次握手的连接, 修改net.ipv4.tcp_max_syn_backlog使之增大可以接受更多的网络连接.
注意此参数过大可能遭遇到Syn flood攻击, 即对方发送多个Syn报文端填充满Syn队列, 使server无法继续接受其他连接.

```
[ansible@iZ94ebqp9jtZ ~]$ cat /proc/sys/net/ipv4/tcp_max_syn_backlog
1024
```

默认是`1024`, 增加为`4096`

#### net.ipv4.tcp_keepalive_time

TCP发送keepalive探测消息的间隔时间(秒)，用于确认TCP连接是否有效. 修改为**600**.

### 1.3

#### 修改`include`为`include_tasks`

`include`被`deprecated`了.

#### 降级`docker`版本为`17.03.2`

`k8s`支持`docker`版本为`17.03.x`. 这里默认`ansible`部署为`17.03.2`

`rancher-1.6.17`支持`docker`版本为`18.03.x-ce`. 如果需要部署`rancher 1.x`需要手动修改`docker`版本.

### 1.4

#### 升级`docker`版本为`18.06.1`

`kubernetes`默认支持`docker`版本为`18.06.1`

#### 修改`docker`的默认`storage driver`为`overlay2`

