#基础镜像
#centos版本不要超过宿主机的centos版本
FROM centos:7.3.1611
MAINTAINER      hpy253215039@163.com

#前期准备，比如创建运行用户，相关目录，相关的基础命令如telnet, mysql, redis-cli等。
RUN useradd inc \
;mkdir -p /app/3rd\
;mkdir -p /app/3rd/skywalking-agent/config\
;mkdir  -p /app/inc/apps  \
;mkdir -p /data/inc/logs/tomcat \
;chown -R inc:inc /app/inc/ /data/inc \
;ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime && /usr/bin/yum -y install net-tools  telnet tcpdump iproute  && /usr/bin/yum clean all && echo 'alias log="cd /data/inc/logs/$HOSTNAME"' >> ~/.bashrc

#将oraclejdk压入镜像
#ADD命令含义：
#1、如果源路径是个文件，且目标路径是以 / 结尾， 则docker会把目标路径当作一个目录，会把源文件拷贝到该目录下。
#   如果目标路径不存在，则会自动创建目标路径。
#2、如果源路径是个文件，且目标路径是不是以 / 结尾，则docker会把目标路径当作一个文件。
#   如果目标路径不存在，会以目标路径为名创建一个文件，内容同源文件；
#   如果目标文件是个存在的文件，会用源文件覆盖它，当然只是内容覆盖，文件名还是目标文件名。
#   如果目标文件实际是个存在的目录，则会源文件拷贝到该目录下。 注意，这种情况下，最好显示的以 / 结尾，以避免混淆。
#3、如果源路径是个目录，且目标路径不存在，则docker会自动以目标路径创建一个目录，把源路径目录下的文件拷贝进来。
#   如果目标路径是个已经存在的目录，则docker会把源路径目录下的文件拷贝到该目录下。
#4、如果源文件是个归档文件（压缩文件），则docker会自动帮解压。
#
#需要注意：
#   jdk.tar.gz解压后的目录要和后边的ENV JAVA_HOME的配置相匹配，否则运行容器后找不到java命令。
ADD ruby-2.6.5.tar.gz /app/3rd/
ADD redis-5.0.7.tar.gz /app/3rd/

#使用 WORKDIR 指令可以来指定工作目录（或者称为当前目录），以后各层的当前目录就被改为指定的目录，如该目录不存在，WORKDIR >会帮你建立目录。
WORKDIR /app/3rd/ruby-2.6.5
RUN yum -y install gcc automake autoconf libtool make \
;./configure --prefix=/usr/local/ruby-2.6.5 \
; make && make install \
; ln -s /usr/local/ruby-2.6.5/bin/ruby /usr/bin/ruby

WORKDIR /app/3rd/redis-5.0.7
RUN ./configure --prefix=/usr/local/redis-5.0.7 \
; make && make install \
; ln -s /usr/local/redis-5.0.7/bin/redis /usr/bin/redis \
; ln -s /usr/local/redis-5.0.7/bin/redis-cli /usr/bin/redis-cli

#配置环境变量
#注意版本
ENV JAVA_HOME /app/3rd/jdk/default
ENV PATH $PATH:/$JAVA_HOME/bin
ENV LANG en_US.UTF-8
