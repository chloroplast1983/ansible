# security 剧本介绍

---

### 简介

主要用于执行一些部署服务器前期的配置工作

### sshd_config.yml

* 创建`sshallow`用户组
* 添加`ansible`用户附加组`sshallow`
* 更新`/etc/ssh/sshd_config`配置文件.

	* 用于修改`ssh`端口.
	* 禁用`root`账户远程登录.
	* 设定只有`AllowGroups`组的用户可以`ssh`

### disable_ping.yml

* 服务器禁ping

### tmout.yml

* 设定`linux`系统的空闲等待时间
	* 复制`tmout.sh`脚本到`/etc/profile.d`下
	* 设定`TMOUT`值
	* 设定`TMOUT`为`readonly`

### pam.yml

#### 登录尝试失败后锁定用户

* `pam/password-auth.yml`
* `pam/system-auth.yml`

参考官方文档`https://access.redhat.com/documentation/zh-CN/Red_Hat_Enterprise_Linux/7/html/Security_Guide/chap-Hardening_Your_System_with_Tools_and_Services.html#sec-Locking_User_Accounts_After_Failed_Login_Attempts`

* 程序先判定是否存在`pam_faillock.so`,如果不存在直接写入, 否则更新.
* 根据官方文档, 需要修改`/etc/pam.d/system-auth`文件和`/etc/pam.d/password-auth`文件中的`auth`区段
* 设定用户登录错误的尝试次数,`pam_faillock.so`(`https://linux.die.net/man/8/pam_faillock`)
	* 在登录前触发`preauth`
	* 不提示任何信息`silent`
	* 几次失败后触发`deny=n`
	* 多长时间内失败次数判定`fail_interval=n`
	* 解锁时间`unlock_time=n`
	* 对`root`用户也做类似判定`even_deny_root`
	* `root`用户失败后的解锁时间

要查看每个用户的尝试失败次数，则须作为 root 用户运行以下命令行：

```shell
[ansible@iZ94ebqp9jtZ ~]$ sudo faillock
ansible:
When                Type  Source                                           Valid
root:
When                Type  Source                                           Valid
tom:
When                Type  Source                                           Valid
2017-08-30 02:03:34 TTY   pts/0                                                V
2017-08-30 02:03:39 TTY   pts/0                                                V
2017-08-30 02:03:44 TTY   pts/0                                                V
```

要解锁一个用户的账户，则须作为 root 用户运行以下命令行：

```shell
faillock --user <username> --reset
```

#### 添加密码复杂度

在`/etc/pam.d/passwd`文件中添加`pam_pwquality.so`.

更新配置文件`/etc/security/pwquality.conf`:

* `minlen`密码最小长度限制
* `maxclassrepeat`在新密码中设置同一类的允许连续字符的最大数目
* `dcredit=-1`在新密码中至少需要一个数字
* `ucredit=-1`在新密码中至少需要一个大写字符
* `lcredit = -1`在新密码中至少需要一个小写字符
* `ocredit = -1`密码包括至少一个特殊字符
* `maxsequence = 3`在新密码中设置单调字符序列的最大长度(ex⇒'12345','fedc')
* `difok=5`设置新密码中不能出现在旧密码中的字符数


#### 更新用户密码过期时间

`chage -M` 设置用户密码过期天数.

`chage -l userName` 查看某个用户密码状态, 可以查见过期天数.

##### /etc/login.defs

* 修改`PASS_MAX_DAYS`新添加用户的密码默认过期天数
* 修改`PASS_MIN_LEN`新添加用户的密码默认长度为`12`
* 修改`PASS_WARN_AGE`密码过期警告时间为`30`天

## 版本

### 1.0

* 更新`sshd`配置修改,变更端口,禁止`root`用户.
* 添加`security.sh`脚本, 自动初始化`ansible`用户和免登陆

### 1.1

* 添加禁ping功能

### 2.0

* 剧本改写为`role`模式
* 针对用户添加密码过期时间
* 添加用户密码复杂度
* 添加针对同时在线人数限制
* 添加对资源限制
* 添加密码登录失败超过一定次数限制登录功能

### 2.1

* 修改`/etc/login.defs`
	* PASS_MAX_DAYS
	* PASS_MIN_LEN
	* PASS_WARN_AGE

### 2.1

#### 解决`locale` 设置程序运行语言环境

`-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory`

通过`locale -a`检索出支持的语言环境.

添加`/etc/environment`文件.

```shell

LANG=zh_CN.utf8
LC_ALL=zh_CN.utf8
```

### 2.2

#### 修改`/etc/environment`为空, 解决在虚拟机里面默认为中文而显示乱码的情况
#### 修改`security.sh`脚本

从`passwd`文件读取密码. 如果密码包含特殊字符需要外围用双引号包围起来.

例如我的密码是`'PHDh$=b5X<5\wwn`, 则在`passwd`文件里面必须写入

```
"'PHDh$=b5X<5\wwn"
```

### 2.3

修复在虚拟机部署时, 更新配置`sshd`需要事先:

1. 关闭`selinux`.
2. 关闭防火墙.

否则会重启失败.

更新`limits.conf`修改限制最大系统登录用户为限制最大登录用户组`sshallow`为`2`次. 