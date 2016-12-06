@echo off
set JAVA_CMD=java
set SEIMI_HOME=%cd%
set CLASS_PATH=.;%SEIMI_HOME%\seimi\classes;%SEIMI_HOME%\seimi\lib\*;
% windows环境下注意日志输出编码要与系统控制台一致 %
set SEIMI_SYS_ARGS=-Dfile.encoding=GBK
% e.g. -c 这里指定要启动的Crawler的name,-p 参数为数字,是启动该端口号的内置http服务接受http接口发送过来的Request %
%JAVA_CMD% -cp %CLASS_PATH% %SEIMI_SYS_ARGS% cn.wanghaomiao.seimi.boot.Run -p %1 -c %2