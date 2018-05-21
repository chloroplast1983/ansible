# ansible

----

### 目录

* dev : 开发主机部署,程序自己电脑集体部署剧本
* k8s : 沙箱和生产的k8s部署剧本
* rancher : 沙箱和生产的rancher部署剧本
* repository : docker 私有仓库部署剧本,现在暂时使用阿里云的私有仓库.暂不使用.
* docker : 用于在服务器部署`dokcer`.
	* 阿里云版本
	* 虚拟机版本

### 使用前要准备的工作

#### 创建目标主机用户 ansible

当我们创建了一台新的服务器时候,我们需要做如下操作.这里的操作我没有放到剧本里是因为在是用 root 和 密码登陆时候ansible链接会报异常.而且为了安全考虑如下操作还是换成人工处理方式.等以后ansible使用熟练在考虑替换的部分.

##### `security/security.sh`

`./security.sh`

连续输入服务器的`ip`地址和`ansible`账户的密码.

连续输入ansible账户对应该台服务器的密码即可.

该文件执行了如下操作:

* 添加`ansible`账户
* 为`ansible`账户设定密码
* 把`ansible`加入到`wheel`组
* 修改`/etc/sudoers`让`wheel`组的用户执行`sudo`时不用输入密码,主要用于ansible剧本的自动执行.
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

#### dev

主要用于部署我们的开发电脑,详细见 [dev play book](./dev "dev play book")

#### k8s

主要用于k8s的`master`和`minon`节点部署,详细见 [k8s play book](./k8s "k8s play book")

#### rancher

主要用于rancher的`server`和`agent`节点部署,详细见 [rancher play book](./rancher "rancher play book")

#### security

主要用于部署服务器安全性的剧本,在给服务器添加用ansible用户后(上述操作),运行该脚本统一配置服务器的一些安全化设置,详细见 [security play book](./security "security play book")

#### repository

仓库服务器,暂时因为使用阿里云的容器仓库,这个暂时不做更新.

#### docker

主要用于在服务器部署`docker`的生产环境. 针对`linux`版本为`centos 7 min` [docker play book](./docker "docker play book")
## 