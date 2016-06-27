#!/bin/sh
JAVA_CMD="java"
SEIMI_HOME="`pwd`"
SEIMI_CLASS_PATH=".:$SEIMI_HOME/seimi/classes:$SEIMI_HOME/seimi/lib/*"
SEIMI_SYS_ARGS="-Dfile.encoding=UTF-8"
# e.g. SEIMI_CRAWLER_ARGS="8080 basic" 这里指定要启动的Crawler的name，若第一个参数为数字则认为是启动该端口号的内置http服务接受http接口发送过来的Request
SEIMI_CRAWLER_ARGS=""
$JAVA_CMD -cp $SEIMI_CLASS_PATH $SEIMI_SYS_ARGS cn.wanghaomiao.seimi.boot.Run $1 $2