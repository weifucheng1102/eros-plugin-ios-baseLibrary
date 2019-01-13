# eros-plugin-ios-baseLibrary 
Eros iOS 项目基础依赖库

## 欢迎大家继续扩展，以下功能必须将pod中的基础库改为本仓库地址才可以使用。

# 扩展新增微信官方授权登录

在pod中加入：

pod 'WXAuthPlugin', :git => 'https://github.com/dmlzj/WxAuthPlugin.git', :tag => '1.0.6'

然后pod update

```javascript

let wx = weex.requireModule('WXAuth')

wx.initWX('wxba10ce478962') // 初始化微信

this.hasWeixin = wx.isInstallWXApp() // 判断是否有微信

// 获取code

wx.WXAuth({

    scope: 'snsapi_userinfo',
                    
    state: 'auth',
    
    appid: this.CONFIG.WX_APP_ID
                    
    }, async (code) => {
                
         this.$notice.alert(code)
                    
    })
```
# 扩展上拉加载更多，修改底部状态动画
```js
// 数据全部加载完后执行noticeNoMoreData，会显示没有更多数据

this.$refs[`categoryList-${index}`][0].noticeNoMoreData()

// 执行完noticeNoMoreData再执行了下拉刷新之后要执行下resetNoMoreData,否则下面会一直显示没有更多数据

this.$refs[`categoryList-${index}`][0].resetNoMoreData()

```
