maven-seimicrawler-plugin
==========
Package seimicrawler project so that can be fast and standalone deployed.It is based on maven-war-plugin and modified.

`maven-seimicrawler-plugin`是基于`maven-war-plugin` v2.6版本修改定制而来。旨在方便开发者对于SeimiCrawler工程的快速打包并独立部署。

# 开始 #
pom添加添加plugin
```
<plugin>
    <groupId>cn.wanghaomiao</groupId>
    <artifactId>maven-seimicrawler-plugin</artifactId>
    <version>1.3.0</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>build</goal>
            </goals>
        </execution>
    </executions>
    <!--<configuration>-->
        <!-- 默认target目录 -->
        <!--<outputDirectory>/some/path</outputDirectory>-->
    <!--</configuration>-->
</plugin>
```
执行`mvn clean package`即可，包目录结构如下：
```
.
├── bin             # 相应的脚本中也有具体启动参数说明介绍，在此不再敖述
│   ├── run.bat    # windows下启动脚本
│   └── run.sh     # Linux下启动脚本
│   └── seimi.cfg  # Linux下启动配置
└── seimi
    ├── classes     # Crawler工程业务类及相关配置文件目录
    └── lib         # 工程依赖包目录
```

## 启动说明 ##

### Linux ###

#### 启动说明 ####
```
SeimiCrawler service helper
usage: run.sh [options]
       start          start service
       stop           stop service
       help           Print service help
```

- `./bin/run.sh start`
启动seimicrawler服务

- `./bin/run.sh stop`
停止当前seimicrawler服务

- `./bin/run.sh help`
查看使用说明

#### 配置文件 ####

```
[init_cfg]
params=-c basic -p 8080

[linux]
stdout=/tmp/seimicrawler.stdout.log
```
`params`只启动seimicrawler时启动参数，其中`-p`指定端口启动一个内嵌的http服务，接受通过http接口（参考SeimiCrawler文档有说明具体的接口）添加抓取请求或是查询抓取状态等操作，`-c`指定要启动的crawler的名称，如果不指定，默认是以workers形式启动所有扫描到的crawler，并开始监听抓取请求。两个参数都不是必须的。`stdout`配置的是seimicrawler服务启动后控制台日志输出路径。

### windows ###

windows脚本比较简单，全部内容都在`run.bat`里了，直接在里面改就好了。

# SeimiCrawler项目 #
SeimiCrawler是一个敏捷的，独立部署的，支持分布式的Java爬虫框架，希望能在最大程度上降低新手开发一个可用性高且性能不差的爬虫系统的门槛，以及提升开发爬虫系统的开发效率。在SeimiCrawler的世界里，绝大多数人只需关心去写抓取的业务逻辑就够了，其余的Seimi帮你搞定。设计思想上SeimiCrawler受Python的爬虫框架Scrapy启发很大，同时融合了Java语言本身特点与Spring的特性，并希望在国内更方便且普遍的使用更有效率的XPath解析HTML，所以SeimiCrawler默认的HTML解析器是[JsoupXpath](http://jsoupxpath.wanghaomiao.cn)(独立扩展项目，非jsoup自带),默认解析提取HTML数据工作均使用XPath来完成（当然，数据处理亦可以自行选择其他解析器）。

> 直达[SeimiCrawler](https://github.com/zhegexiaohuozi/SeimiCrawler)项目

# 社区讨论 #
大家有什么问题或建议现在都可以选择通过下面的邮件列表讨论，首次发言前需先订阅并等待审核通过（主要用来屏蔽广告宣传等）
- 订阅:请发邮件到 `seimicrawler+subscribe@googlegroups.com`
- 发言:请发邮件到 `seimicrawler@googlegroups.com`
- 退订:请发邮件至 `seimicrawler+unsubscribe@googlegroups.com`