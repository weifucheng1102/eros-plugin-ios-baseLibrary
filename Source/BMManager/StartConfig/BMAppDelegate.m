//
//  BMAppDelegate.m
//  BMBaseLibrary
//
//  Created by XHY on 2018/4/26.
//

#import "BMAppDelegate.h"
#import <ErosPluginBaseLibrary/BMConfigManager.h>
#import <ErosPluginBaseLibrary/BMMediatorManager.h>

#import <ErosPluginBaseLibrary/BMRouterManager.h>
#import <ErosPluginBaseLibrary/BMDefine.h>

#import <CTMediator+BMPushActions.h>
#import <CTMediator+BMShareActions.h>
#import <CTMediator+BMPayActions.h>
#import <CTMediator+MBWXAuthActions.h>
// jpush
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <JPush/JPUSHService.h>
#import "JPushWeexPluginModule.h"
#import "WXApi.h"
#import "BMGlobalEventManager.h"
// #import "QYSDK.h"

@interface BMAppDelegate ()
{
    BOOL _isLoad;
}

@end

@implementation BMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    /* 初始化数据 */
    [BMConfigManager configDefaultData];
    
    if (_isLoad == NO) {
        [self startApp];
    }
    
    /** 注册通知 当js更新文件准备就绪用户点击立即升级会触发这个方法 重新加载最新js资源文件 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startApp) name:K_BMAppReStartNotification object:nil];
    
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url && [[NSString stringWithFormat:@"%@",url] containsString:[self getUrlSchemesWithName:@"syapp"]]) {
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:nil forKey:@"launchOptions"];
        [ud synchronize];
        [self sendEventWithUrl:url];
        
    }else{
        /* jpush */
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:launchOptions forKey:@"launchOptions"];
        [ud synchronize];
    }
    //    七鱼客服初始化
    // [[QYSDK sharedSDK] registerAppId:@"d0272648f6cee6970423077219de0505" appName:@"好产拼"];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!_isLoad) {
        [self startApp];
    }
    
    [[CTMediator sharedInstance] CTMediator_setIsLaunchedByNotification:NO];
    
    if ([[NSString stringWithFormat:@"%@",url] containsString:[self getUrlSchemesWithName:@"syapp"]]) {
        [self sendEventWithUrl:url];
        return YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (url) {
        [dic setValue:url forKey:@"url"];
    }
    if (sourceApplication) {
        [dic setValue:sourceApplication forKey:@"sourceApplication"];
    }
    if (annotation) {
        [dic setValue:annotation forKey:@"annotation"];
    }
    
  
    
    // 微信支付回调
    if ([url.host isEqualToString:@"pay"]) {
        return [[CTMediator sharedInstance] CTMediator_PayHandleOpenURL:dic];
    }
    // 微信授权回调
    if ([url.host isEqualToString:@"oauth"]) {
        return [[CTMediator sharedInstance] CTMediator_WXAuthHandleOpenURL:dic];
    }
    if ([url.query containsString:@"TestAutoCheckContextId"]) {
            // 分享回调
        BOOL result = [[CTMediator sharedInstance] CTMediator_ShareHandleOpenURL:dic];
        if (result) {
            return result;
        }
    } else{
       return  [WXApi handleOpenURL:url delegate:self];
    }
    BOOL result = [BMRouterManager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return result;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[CTMediator sharedInstance] CTMediator_registerForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    /* 注册推送失败 */
    WXLogInfo(@"%@",[error localizedDescription]);
}
//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    [[CTMediator sharedInstance] CTMediator_performFetchWithCompletionHandler:@{@"block":completionHandler}];
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    /* 收到push消息 */
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (userInfo) {
        [dic setValue:userInfo forKey:@"userInfo"];
    }
    if (completionHandler) {
        [dic setValue:completionHandler forKey:@"block"];
    }
    /* jpush */
    [[CTMediator sharedInstance] CTMediator_receiveRemoteNotification:dic];
}

-(void)startApp
{
    _isLoad = YES;
    
    [BMConfigManager compareVersion];
    
    /** 加载页面 */
    self.window.rootViewController = [[BMMediatorManager shareInstance] loadHomeViewController];
    [self.window makeKeyAndVisible];
}

-(void)sendEventWithUrl:(NSURL *)url
{
    //处理url
    NSString * urlString = [NSString stringWithFormat:@"%@",url];
    //url 包含参数  才发送事件请求js
    if ([urlString containsString:[self getUrlSchemesWithName:@"syapp"]]&& ![urlString isEqualToString:[self getUrlSchemesWithName:@"syapp"]]) {
        //发送事件
        [BMGlobalEventManager  sendGlobalEvent:@"startApp" params:[self parameterWithURL:url]];
    }
}

-(NSString *)getUrlSchemesWithName:(NSString *)name
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSArray *bundleUrltypes = [infoDic objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary * dic in bundleUrltypes) {
        if ([[dic objectForKey:@"CFBundleURLName"] isEqualToString:name]) {
            //CFBundleURLSchemes为啥是个数组 ==！
            NSArray * schemesArr = [dic objectForKey:@"CFBundleURLSchemes"];
            if (schemesArr.count!=0) {
                return schemesArr[0];
            }else{
                return  nil;
            }
        }
    }
}

    /**
 获取url的所有参数
 @param url 需要提取参数的url
 @return NSDictionary
 */
- (NSDictionary *)parameterWithURL:(NSURL *)url {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:2];
    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    
    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [params setObject:obj.value forKey:obj.name];
    }];
    
    return params;
}


@end
