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

You can also use a volume container:

```console
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

Argument you pass to docker running the jenkins image are passed to jenkins launcher, so you can run for sample :
```
docker run jenkins --version
```
This will dump Jenkins version, just like when you run jenkins as an executable war.

You also can define jenkins arguments as `JENKINS_OPTS`. This is usefull to define a set of arguments to pass to jenkins launcher as you
define a derived jenkins image based on the official one with some customized settings. The following sample Dockerfile uses this option
to force use of HTTPS with a certificate included in the image

```
FROM index.csphere.cn/microimages/jenkins

COPY https.pem /var/lib/jenkins/cert
COPY https.key /var/lib/jenkins/pk
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsCertificate=/var/lib/jenkins/cert --httpsPrivateKey=/var/lib/jenkins/pk
EXPOSE 8083
```

You can also change the default slave agent port for jenkins by defining `JENKINS_SLAVE_AGENT_PORT` in a sample Dockerfile.

```
FROM index.csphere.cn/microimages/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50001
```
or as a parameter to docker,
```
docker run --name myjenkins -p 8080:8080 -p 50001:50001 --env JENKINS_SLAVE_AGENT_PORT=50001 index.csphere.cn/microimages/jenkins
```

# Installing more tools

You can run your container as root - and install via apt-get, install as part of build steps via jenkins tool installers, or you can create your own Dockerfile to customise, for example: 

```
FROM index.csphere.cn/microimages/jenkins
# if we want to install via apt
USER root
RUN apt-get update && apt-get install -y ruby make more-thing-here
USER jenkins # drop back to the regular jenkins user - good practice
```

In such a derived image, you can customize your jenkins instance with hook scripts or additional plugins. 
For this purpose, use `/usr/share/jenkins/ref` as a place to define the default JENKINS_HOME content you
wish the target installation to look like :

```
FROM index.csphere.cn/microimages/jenkins
COPY plugins.txt /usr/share/jenkins/ref/
COPY custom.groovy /usr/share/jenkins/ref/init.groovy.d/custom.groovy
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
```

When jenkins container starts, it will check JENKINS_HOME has this reference content, and copy them there if required. It will not override such files, so if you upgraded some plugins from UI they won't be reverted on next start.

Also see [JENKINS-24986](https://issues.jenkins-ci.org/browse/JENKINS-24986)

For your convenience, you also can use a plain text file to define plugins to be installed (using core-support plugin format)
```
pluginID:version
anotherPluginID:version
```
And in derived Dockerfile just invoke the utility plugin.sh script
```
FROM index.csphere.cn/microimages/jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
```


# Upgrading

All the data needed is in the /var/jenkins_home directory - so depending on how you manage that - depends on how you upgrade. Generally - you can copy it out - and then "docker pull" the image again - and you will have the latest LTS - you can then start up with -v pointing to that data (/var/jenkins_home) and everything will be as you left it.

As always - please ensure that you know how to drive docker - especially volume handling!

## 授权和法律

该镜像由希云制造，未经允许，任何第三方企业和个人，不得重新分发。违者必究。

## 支持和反馈

该镜像由希云为企业客户提供技术支持和保障，任何问题都可以直接反馈到: `docker@csphere.cn`

