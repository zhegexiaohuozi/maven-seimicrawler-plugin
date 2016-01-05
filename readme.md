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
    <version>1.0.0</version>
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
│   ├── run.bat    #windows下启动脚本
│   └── run.sh     #Linux下启动脚本
└── seimi
    ├── classes     #Crawler工程业务类及相关配置文件目录
    └── lib         #工程依赖包目录
```

# 社区讨论 #
大家有什么问题或建议现在都可以选择通过下面的邮件列表讨论，首次发言前需先订阅并等待审核通过（主要用来屏蔽广告宣传等）
- 订阅:请发邮件到 `seimicrawler+subscribe@googlegroups.com`
- 发言:请发邮件到 `seimicrawler@googlegroups.com`
- 退订:请发邮件至 `seimicrawler+unsubscribe@googlegroups.com`