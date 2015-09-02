
![logo](http://jenkins-ci.org/sites/default/files/jenkins_logo.png)

## 如何使用镜像

```console
$ docker run -p 8080:8080 index.csphere.cn/micromiages/jenkins
```

这样启动将会把所有workspace存储到 `/var/jenkins_home` 目录，包括所有数据、插件以及配置，你也许希望运行在一个持久化的数据卷里:

```console
$ docker run --name myjenkins -p 8080:8080 -v /var/jenkins_home index.csphere.cn/micromiages/jenkins
```

myjenkins这个容器里的卷将会得到持久化，你也可以映射一个主机目录:

首先必须确保 `/your/home` 可以被容器里的jenkins用户访问

```console
$ docker run -p 8080:8080 -v /your/home:/var/jenkins_home index.csphere.cn/micromiages/jenkins
```

## 备份数据

If you bind mount in a volume - you can simply back up that directory (which is jenkins_home) at any time.

If your volume is inside a container - you can use `docker cp
$ID:/var/jenkins_home` command to extract the data.

## Attaching build executors

You can run builds on the master (out of the box) buf if you want to attach build slave servers: make sure you map the port: `-p 50000:50000` - which will be used when you connect a slave agent.

[Here](https://registry.hub.docker.com/u/maestrodev/build-agent/) is an example docker container you can use as a build server with lots of good tools installed - which is well worth trying.

## Upgrading

All the data needed is in the /var/jenkins_home directory - so depending on how you manage that - depends on how you upgrade. Generally - you can copy it out - and then "docker pull" the image again - and you will have the latest LTS - you can then start up with -v pointing to that data (/var/jenkins_home) and everything will be as you left it.

