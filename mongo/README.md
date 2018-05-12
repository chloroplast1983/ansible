# mongo 环境配置 ansible 剧本

---

## 简介

根据`mongo`的

* [Operations Checklist](https://docs.mongodb.com/manual/administration/production-checklist-operations/)进行环境优化.

## 目录

* [角色](#role)
* [auth](#auth)
* [更新记录](#version)

## <a name="role">角色</a>

### common

* 关闭`tuned`服务.
* 关闭`transparent huge pages`.
* 修改`/etc/security/limits.conf`
	* fsize
		* soft: unlimited
		* hard: unlimited
	* cpu
		* soft: unlimited
		* hard: unlimited
	* as
		* soft: unlimited
		* hard: unlimited
	* nproc
		* 64000: unlimited
		* 64000: unlimited
	* nofile
		* 64000: unlimited
		* 64000: unlimited
* 修改内核参数
	* net.ipv4.tcp_keepalive_time: 300
	* fs.file-max: 98000
	* kernel.pid_max: 64000
	* kernel.threads-max: 64000
		 	
## <a name="auth">auth</a>	

默认`mongo`是没有认证的, 开启认证功能方法如下:

```
[root@demo data]# docker run --name mongo -p "27017:27017" -v /data/mongo:/data/db -d mongo:3.6 --auth

创建admin
[root@demo data]# docker exec -it mongo mongo admin
db.createUser(
  {
    user: "myUserAdmin",
    pwd: "abc123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
Successfully added user: {
	"user" : "myUserAdmin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}

创建test库的用户

use admin
db.auth("myUserAdmin", "abc123")

use test
db.createUser(
  {
    user: "myTester",
    pwd: "xyz123",
    roles: [ { role: "readWrite", db: "test" },
             { role: "readWrite", db: "reporting" } ]
  }
)

db.grantRolesToUser(
    "myTester",
    [
      { role: "readWrite", db: "test" },
      { role: "readWrite", db: "reporting" },
    ]
)


Successfully added user: {
	"user" : "myTester",
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "test"
		},
		{
			"role" : "read",
			"db" : "reporting"
		}
	]
}
```	 

现在直接在应用层添加数据会出现:

```php
配置文件如下
'mongo.host' => 'mongodb://120.25.87.35:27017'

Uncaught MongoDB\Driver\Exception\RuntimeException: not authorized on test to execute command
```	

修改配置文件添加用户和密码:

```php
'mongo.host' => 'mongodb://myTester:xyz123@120.25.87.35:27017/test',
需要声明用户名,密码和数据库
```
		 		
## <a name="version">更新记录</a>

### 1.0

初始化剧本.