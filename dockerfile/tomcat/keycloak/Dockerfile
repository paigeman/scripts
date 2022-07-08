FROM tomcat:8.5-jdk8-openjdk
# 基础镜像换成官方默认debian的，解决apline jdk镜像不能jmap、jstack等1进程的问题
# 设置时区
ENV TZ Asia/Shanghai

# 移除tomcat自带的一些项目
RUN rm -rf /usr/local/tomcat/webapps/*

ADD keycloak-oidc-tomcat-adapter-18.0.2.zip .

RUN unzip -d keycloak keycloak-oidc-tomcat-adapter-18.0.2.zip && \
    mv keycloak/* /usr/local/tomcat/lib

# 换中科大镜像源
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# 安装常用工具 vi，vim，less，netstat(ifconfig等都包含在net-tools中)，curl(已有)，wget(已有)，telnet，arthas(对应命令as.sh)，more(已有)，ping(已有)，ps(已有)
RUN apt-get update -y
RUN apt-get install -y vim telnet less net-tools
