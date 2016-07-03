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
    <version>1.2.0</version>
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
└── seimi
    ├── classes     # Crawler工程业务类及相关配置文件目录
    └── lib         # 工程依赖包目录
```

## 启动说明 ##
以shell脚本为例：

- `./bin/run.sh basic`
加载所有扫描到的爬虫规则类，并触发名为`basic`的爬虫规则开始抓取。

- `./bin/run.sh 8000 basic`
加载所有扫描到的爬虫规则类，并触发名为`basic`的爬虫规则开始抓取,同时在`8000`端口启动一个http服务接受通过制定http接口（参考SeimiCrawler文档）添加抓取请求，查询抓取状态等。

- `./bin/run.sh`
加载所有扫描到的爬虫规则类，并全都都处于监听任务状态。就是`startAllWorkers()`。

- `./bin/run.sh 8000`
加载所有扫描到的爬虫规则类，并全都都处于监听任务状态。就是`startAllWorkers()`。于此同时在`8000`端口启动一个http服务接受通过制定http接口（参考SeimiCrawler文档）添加抓取请求，查询抓取状态等。

# SeimiCrawler项目 #
SeimiCrawler是一个敏捷的，独立部署的，支持分布式的Java爬虫框架，希望能在最大程度上降低新手开发一个可用性高且性能不差的爬虫系统的门槛，以及提升开发爬虫系统的开发效率。在SeimiCrawler的世界里，绝大多数人只需关心去写抓取的业务逻辑就够了，其余的Seimi帮你搞定。设计思想上SeimiCrawler受Python的爬虫框架Scrapy启发很大，同时融合了Java语言本身特点与Spring的特性，并希望在国内更方便且普遍的使用更有效率的XPath解析HTML，所以SeimiCrawler默认的HTML解析器是[JsoupXpath](http://jsoupxpath.wanghaomiao.cn)(独立扩展项目，非jsoup自带),默认解析提取HTML数据工作均使用XPath来完成（当然，数据处理亦可以自行选择其他解析器）。

> 直达[SeimiCrawler](https://github.com/zhegexiaohuozi/SeimiCrawler)项目

# 社区讨论 #
大家有什么问题或建议现在都可以选择通过下面的邮件列表讨论，首次发言前需先订阅并等待审核通过（主要用来屏蔽广告宣传等）
- 订阅:请发邮件到 `seimicrawler+subscribe@googlegroups.com`
- 发言:请发邮件到 `seimicrawler@googlegroups.com`
- 退订:请发邮件至 `seimicrawler+unsubscribe@googlegroups.com`