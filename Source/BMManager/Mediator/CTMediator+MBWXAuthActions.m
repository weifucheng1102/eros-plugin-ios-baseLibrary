//
//  CTMediator+MBWXAuthActions.m
//  AFNetworking
//
//  Created by mac3 on 2018/12/30.
//

#import "CTMediator+MBWXAuthActions.h"
NSString *const kCTMediatorWXAuthTarget = @"BMWXAuth";
NSString *const kCTMediatorActionWXAuthHandleOpenURL = @"WXAuthHandleOpenURL";
@implementation CTMediator (MBWXAuthActions)
- (BOOL)CTMediator_WXAuthHandleOpenURL:(NSDictionary *)info
{
    id result = [self performTarget:kCTMediatorWXAuthTarget
                             action:kCTMediatorActionWXAuthHandleOpenURL
                             params:info
                  shouldCacheTarget:NO];
    return [result boolValue];
}

@end
