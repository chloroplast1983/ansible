# elasticsearch

根据`es`官方推荐配置, 添加生产环境内核参数修改`https://www.elastic.co/guide/en/elasticsearch/reference/5.0/vm-max-map-count.html`

```
sysctl -w vm.max_map_count=262144
```

