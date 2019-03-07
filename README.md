# ansible

----

### 目录

* [mongo](./mongo) : 用于根据`mongo`的生产配置推荐修改服务器.
* [operate](./operate) : 用于批量修改操作服务器.
* [docker](./docker) : 用于在服务器部署`dokcer`.
	* 阿里云版本
	* 虚拟机版本
* [security](./security) : 用于在服务器的安全方面部署工作.

### 使用前要准备的工作

#### 创建目标主机用户 ansible

当我们创建了一台新的服务器时候,我们需要做如下操作.这里的操作我没有放到剧本里是因为在是用 root 和 密码登陆时候ansible链接会报异常.而且为了安全考虑如下操作还是换成人工处理方式.等以后ansible使用熟练在考虑替换的部分.

##### `security/security.sh`

`./security.sh`

连续输入服务器的`ip`地址和`ansible`账户的密码.

连续输入`ansible`账户对应该台服务器的密码即可.

该文件执行了如下操作:

* 添加`ansible`账户
* 为`ansible`账户设定密码
* 把`ansible`加入到`wheel`组
* 修改`/etc/sudoers`让`wheel`组的用户执行`sudo`时不用输入密码,主要用于`ansible`剧本的自动执行.
* 本机到目标服务器对于ansible用户进行`ssh免密码登陆`

#### 执行security剧本

更改我们的`登陆端口`,以及`禁止root登陆`的操作

		ansible-playbook security.yml

### 常用操作

#### 检查模式

`-- check`将不会对远程的系统做出任何修改. 会做语法检查.

#### 从组中筛选主机

我们从test组筛选出 minon1 主机

		ansible test --limit minon1 -m ping
		
#### tags

执行符合tag的task

		ansible-playbook xxx.yml --tags="tag1,tag2"

### 剧本

#### security

主要用于部署服务器安全性的剧本,在给服务器添加用ansible用户后(上述操作),运行该脚本统一配置服务器的一些安全化设置,详细见[security play book](./security "security play book")

#### docker

主要用于在服务器部署`docker`的生产环境. 针对`linux`版本为`centos 7 min`[docker play book](./docker "docker play book")

### 加密

* 加密`ansible`的`ssh_keys`服务器密钥
* 加密密钥文件`ansible-vault encrypt xxx`
* 编辑加密的密钥文件`ansible-vault edit`
* 解密密钥文件`ansible-vault decrypt xxx`
