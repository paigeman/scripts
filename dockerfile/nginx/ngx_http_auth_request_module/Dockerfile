FROM centos:centos7
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo
RUN yum -y update
RUN yum -y install  gcc gcc-c++ autoconf automake make
RUN yum -y install  zlib zlib-devel openssl* pcre* wget lua-devel
ADD http://nginx.org/download/nginx-1.22.0.tar.gz /tmp
WORKDIR /tmp
RUN useradd -M -s /sbin/nologin nginx
RUN tar -zxvf nginx-1.22.0.tar.gz && cd /tmp/nginx-1.22.0 && ./configure --prefix=/opt/nginx \
    --user=nginx --group=nginx \
    --with-http_ssl_module \
    --with-http_auth_request_module \
    && make && make install
RUN /opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf
CMD ["/opt/nginx/sbin/nginx","-g","daemon off;"]
