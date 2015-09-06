![jenkins](https://csphere.cn/assets/33acb95a-24e8-4559-9889-fa31b8cb95bd)

## 如何使用镜像

```console
$ docker run -p 8080:8080 index.csphere.cn/microimages/jenkins
```

这样启动将会把所有workspace存储到 `/var/jenkins_home` 目录，包括所有数据、插件以及配置，你也许希望运行在一个持久化的数
据卷里:

```console
$ docker run --name myjenkins -p 8080:8080 -v /var/jenkins_home index.csphere.cn/microimages/jenkins
```

myjenkins这个容器里的卷将会得到持久化，你也可以映射一个主机目录:

首先必须确保 `/your/home` 可以被容器里的jenkins用户访问(uid 1000)

```console
$ sudo chown 1000 /your/home
$ docker run -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home index.csphere.cn/microimages/jenkins
```

## 备份数据

如果你挂载了主机目录到容器内，那么备份该目录即可。这也是我们推荐的方法。将 `/var/jenkins_home` 目录看作数据库目录。

如果你的卷在容器里面，那么可以通过 ```docker cp $ID:/var/jenkins_home``` 命令拷贝出数据。

如果对docker数据管理有兴趣，可以阅读 [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/)

## 设置执行器的数量

你可以通过groovy脚本来指定jenkins master执行器的数量。默认是2个，但你可以扩展镜像:

```
# executors.groovy
Jenkins.instance.setNumExecutors(5)
```

和 `Dockerfile`

```
FROM index.csphere.cn/microimages/jenkins
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
```


## 构建executors

你可以在master上构建，但如果想在slave上构建的话，必须做好50000端口映射，这是用来连接slave agent的。

## 传递JVM参数

你也许想修改JVM的运行参数，比如heap memory:

```
$ docker run --name myjenkins -p 8080:8080 -p 50000:50000 --env JAVA_OPTS=-Dhudson.footerURL=http://mycompany.com index.csphere.cn/microimages/jenkins
```

## 配置日志

Jenkins的日志可以通过 `java.util.logging.config.file` Java property来配置

```console
$ mkdir data
$ cat > data/log.properties <<EOF
handlers=java.util.logging.ConsoleHandler
jenkins.level=FINEST
java.util.logging.ConsoleHandler.level=FINEST
EOF
$ docker run --name myjenkins -p 8080:8080 -p 50000:50000 --env JAVA_OPTS="-Djava.util.logging.config.file=/var/jenkins_home/log.properties" -v `pwd`/data:/var/jenkins_home index.csphere.cn/microimages/jenkins
```


## 传递Jenkins的启动参数

你也可以传递jenkins的运行参数：

```
docker run jenkins --version
```

你还可以在环境变量 `JENKINS_OPTS` 中定义jenkins的运行参数，比如：

```
FROM index.csphere.cn/microimages/jenkins

COPY https.pem /var/lib/jenkins/cert
COPY https.key /var/lib/jenkins/pk
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsCertificate=/var/lib/jenkins/cert --httpsPrivateKey=/var/lib/jenkins/pk
EXPOSE 8083
```

你还可以通过定义环境变量 `JENKINS_SLAVE_AGENT_PORT` 来改变默认的slave端口

```
FROM index.csphere.cn/microimages/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50001
```

或者直接通过-e环境变量提供：

```
docker run --name myjenkins -p 8080:8080 -p 50001:50001 -e JENKINS_SLAVE_AGENT_PORT=50001 index.csphere.cn/microimages/jenkins
```

## 安装更多工具

我们可以继承此镜像，来定义我们自己的jenkins的hook脚本或插件。比如我们希望加入更多的插件：

具体的插件可以通过[Jenkins插件](http://updates.jenkins-ci.org/download/plugins/) 搜索。

plugins.txt文件的内容如下：

```
pluginID:version
anotherPluginID:version
```


Dockerfile编写如下：

```
FROM index.csphere.cn/microimages/jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
```


## 升级

所有数据都保存在 `/var/jenkins_home` 目录，只要在运行jenkins时指定了host volume的目录( `-v hostdir:/var/jenkins_home` )，当你升级时，只要该目录不丢失，升级不会造成之前的配置、数据丢失。

## 授权和法律

该镜像由希云制造，未经允许，任何第三方企业和个人，不得重新分发。违者必究。

## 支持和反馈

该镜像由希云为企业客户提供技术支持和保障，任何问题都可以直接反馈到: `docker@csphere.cn`

