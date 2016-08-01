# HTTPDNSLib
DNSCache库使用说明书
感谢新浪研发中心技术保障部移动端保障团队。
源码链接:https://github.com/SinaMSRE/HTTPDNSLib-for-iOS.git

此项目修改自微博的HTTPDNS源码.
主要更换HTTPDNS服务为DNSPOD企业版~。去掉自动上传LOG,和Config下载。
保留原有的Cache,DB,ip择优等核心业务。

相关机制链接:

http://www.360doc.com/content/15/1016/07/2909773_505968464.shtml

安装:

pod 'HTTPDNSLib', :git => 'https://github.com/zhengwu119/HTTPDNSLib.git'

在AppDelegate里（也就是尽可能早的时候）初始化 WBDNSCache库。

[WBDNSCache setAppID:@"DNSPOD_ID" appkey:@"DNSPOD_KEY"];

初始化库，期间会从参数服务器请求配置参数
[[WBDNSCache sharedInstance] initialize];

建议初始化后延时调用 预请求域名对应IP，提前从服务器拉取域名对应IP
[[WBDNSCache sharedInstance]preloadDomains:@[@"http://www.baidu.com", @"http://api.weibo.cn/"]];

然后就可以在任何地方调用
[[WBDNSCache sharedInstance] getDomainServerIpFromURL:url]
获取转换后Url 和 需要设置的host值。
这个函数拿到的是一个WBDNSDomainInfo 对象数组，一般来说 取第一个就可以了。
WBDNSDomainInfo.id 暂时没用。
WBDNSDomainInfo.url 已经替换好的URL， 客户端可以直接用它 请求资源。
WBDNSDomainInfo.host 客户端需要将这个host设置到HTTP的请求头里。 如果Host为@“” 代表不需要设置Host
以AFNetworking举例
[manager.requestSerializer setValue:WBDNSDomainInfo.host forHTTPHeaderField:@"Host"];

已解决在网络丢包严重时阻塞主线程