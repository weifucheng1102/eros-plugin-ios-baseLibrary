//
//  BMStorageModule.h
//  WeexDemo
//
//  Created by XHY on 2017/2/8.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeexSDK.h>

@interface BMStorageModule : NSObject <WXModuleProtocol>
- (NSDictionary *)setDataSync:(NSString *)key data:(id)data;
@end
