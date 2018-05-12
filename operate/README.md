# 常用操作脚本

## 简介

主要用于一般服务器维护和更新使用的`ansible`脚本. 这个主要就是临时使用的一些脚本.

### 更新`fluentd.conf`配置

* 创建对应`fluentd`的配置文件`/data/fluentd`.
* 批量更新数据节点的`fluentd.conf`配置文件.

```
--tags="fluentd"
```

### `crontab`计划任务配置

计划任务使用`ansible`账户运行.

```
--tags="cron"
```