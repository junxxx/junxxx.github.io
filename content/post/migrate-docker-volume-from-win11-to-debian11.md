---
title: "Migrate Docker Volume From Win11 to Debian11"
date: 2025-10-13T11:12:34+08:00
categories: ["Tech", "Docker"]
tags: ["Docker"]
author: "Paisen"
---

## Backup images, volumes in Win11

```powershell
docker save -o all_images.tar (docker images --format "{{.Repository}}")
 
docker volume ls -q | ForEach-Object {  docker run --rm -v "${_}:/volume" -v "${PWD}:/backup" alpine tar -czf "/backup/${_}.tar.gz" -C /volume .}

docker ps -a --format "{{.Names}}" | ForEach-Object {  docker inspect $_ | Out-File -Encoding utf8 "$_.json"}
```

## Restore on Debian11

```bash
# load images
docker load -i all_images.tar

# create volumes and restore data
for f in *.tar.gz; do
  vol="${f%.tar.gz}"
  echo "Restoring $vol ..."
  docker volume create "$vol" >/dev/null 2>&1
  docker run --rm \
    -v "$vol:/volume" \
    -v "$(pwd):/backup" \
    ubuntu sh -c "cd /volume && tar -xzf /backup/$f"
done
```

## Issues

1. volume already exists but was not created by Docker Compose. Use `external: true` to use an existing volume
    
    ```yaml
    volumes:
      taiga-static-data:
        external: true
    ```
    
2. volume doesn’t exist
    
    ```yaml
    volumes:
      taiga-static-data:
        external: true
        name: taiga-docker_taiga-static-data
    ```

## 吐槽

docker compose创建volume时，会在compose.yml文件里定义的volume名称前面加上当前项目名（文件夹名）。比如说，你在目录~/**project**/compose.yml里定义如下的volume:
```
volumes:
      taiga-static-data:
```
当你运行docker compose up 创建容器时，新建的volume名称实际上是`project_taiga-static-data`。

在新机器上恢复volume数据之后，再次回到之前的项目~/project/ 运行`docker compose up`时，提示
```
...volume already exists but was not created by Docker Compose. Use `external: true` to use an existing volume
```
加上external:true之后，又提示volume doesn't exist。感觉有点死循环了。无奈，再加一个name，暂时解决这个问题。


## Reference
1. []()