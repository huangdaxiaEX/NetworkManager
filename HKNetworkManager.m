//
//  HKNetworkManager.m
//  EditStyle
//
//  Created by huangdaxia on 16/1/22.
//  Copyright © 2016年 xiaorizi. All rights reserved.
//

#import "HKNetworkManager.h"
#import "YYCache.h"

static NSString * const HKHTTPRequestCache         = @"HKHTTPRequestCache";
static NSString * const HKHTTPRequestBaseURLString = @"your base api url";
typedef NS_ENUM(NSUInteger, HKHTTPRequestType) {
    HKHTTPRequestType_POST = 0,
    HKHTTPRequestType_GET,
};

//分离出去的头文件
//@interface NSJSONSerialization (JSON)
//+ (nullable NSString *)stringWithJSONObject:(nonnull id)JSONObject;
//+ (nullable id)objectwithJSONString:(nonnull NSString *)JSONString;
//+ (nullable id)objectWithJSONData:(nonnull NSData *)JSONData;
//+ (nullable id)objectWithJSONData:(NSData *)JSONData options:(NSJSONReadingOptions)option;
//@end

@implementation NSJSONSerialization (JSON)

+ (nullable NSString *)stringWithJSONObject:(nonnull id)JSONObject {
    if (![NSJSONSerialization isValidJSONObject:JSONObject]) {
        NSLog(@"不是一个json对象");
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONObject options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (nullable id)objectwithJSONString:(nonnull NSString *)JSONString {
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    return [self objectWithJSONData:data options:NSJSONReadingMutableContainers];
}

+ (nullable id)objectWithJSONData:(nonnull NSData *)JSONData {
    return [self objectWithJSONData:JSONData options:NSJSONReadingMutableContainers];
}

+ (nullable id)objectWithJSONData:(NSData *)JSONData options:(NSJSONReadingOptions)option {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:JSONData options:option error:&error];
}

@end

@implementation HKNetworkManager

#pragma mark GET

/**
 *  默认使用 HKHTTPRequestReturnCacheDataThenLoad 的get请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param success
 *  @param failure
 *
 *  @return
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(NSURLSessionDataTask *, id))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self GET:URLString parameters:parameters cachePolicy:HKHTTPRequestReturnCacheDataThenLoad success:success failure:failure];
}

/**
 *  自定义 HKHTTPRequestCachePolicy 的get请求
 *
 *  @param URLString   请求地址
 *  @param parameters  请求参数
 *  @param cachePolicy 缓存策略
 *  @param success
 *  @param failure
 *
 *  @return
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                  cachePolicy:(HKHTTPRequestCachePolicy)cachePolicy
                      success:(void (^)(NSURLSessionDataTask *, id))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self requestType:HKHTTPRequestType_GET URLString:URLString parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}

#pragma mark POST

/**
 *  默认使用 HKHTTPRequestReturnCacheDataThenLoad 的post请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param success
 *  @param failure
 *
 *  @return
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self POST:URLString parameters:parameters cachePolicy:HKHTTPRequestReturnCacheDataThenLoad success:success failure:failure];
}

/**
 *  自定义 HKHTTPRequestCachePolicy 的get请求
 *
 *  @param URLString   请求地址
 *  @param parameters  请求参数
 *  @param cachePolicy 缓存策略
 *  @param success
 *  @param failure
 *
 *  @return
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                   cachePolicy:(HKHTTPRequestCachePolicy)cachePolicy
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self requestType:HKHTTPRequestType_POST URLString:URLString parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}

#pragma mark
+ (NSURLSessionDataTask *)requestType:(HKHTTPRequestType)requestType
                            URLString:(NSString *)URLString
                           parameters:(NSDictionary *)parameters
                          cachePolicy:(HKHTTPRequestCachePolicy)cachePolicy
                              success:(void (^)(NSURLSessionDataTask *, id))success
                              failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *cacheKey = URLString;
    if (parameters) {
        if (![NSJSONSerialization isValidJSONObject:parameters]) {
            return nil;
        }
        NSData *data          = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        NSString *paramString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        cacheKey              = [URLString stringByAppendingString:paramString];
    }
    
    YYCache *cache = [[YYCache alloc] initWithName:HKHTTPRequestCache];
    cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning        = YES;
    cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    id object = [cache objectForKey:cacheKey];
    switch (cachePolicy) {
        case HKHTTPRequestReturnCacheDataThenLoad:
            if (object) {
                success(nil, object);
            }
            break;
        case HKHTTPRequestReloadIngnoringLocalCacheData:
            break;
        case HKHTTPRequestReturnCacheDataElseLoad:
            if (object) {
                success(nil, object);
            }
            break;
        case HKHTTPRequestReturnCacheDataDontLoad:
            if (object) {
                success(nil, object);
            }
            return nil;
            break;
        default:
            break;
    }
    return [self requestType:requestType URLString:URLString parameters:parameters cache:cache cacheKey:cacheKey success:success failure:failure];
}

+ (NSURLSessionDataTask *)requestType:(HKHTTPRequestType)requestType
                            URLString:(NSString *)URLString
                           parameters:(NSDictionary *)parameters
                                cache:(YYCache *)cache
                             cacheKey:(NSString *)cacheKey
                              success:(void (^)(NSURLSessionDataTask *, id))success
                              failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    switch (requestType) {
        case HKHTTPRequestType_GET:
            return [[HKNetworkManager shareInstance] GET:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [cache setObject:responseObject forKey:cacheKey];
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failure(task, error);
            }];
            break;
        case HKHTTPRequestType_POST:
            return [[HKNetworkManager shareInstance] POST:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [cache setObject:responseObject forKey:cacheKey];
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failure(task, error);
            }];
        default:
            break;
    }
}

#pragma mark 实例
+ (instancetype)shareInstance {
    static HKNetworkManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [self getInstance];
        shareInstance.requestSerializer  = [AFHTTPRequestSerializer serializer];
        shareInstance.responseSerializer = [AFHTTPResponseSerializer serializer];
        //shareInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    
    return shareInstance;
}

+ (instancetype)getInstance {
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [[HKNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:HKHTTPRequestBaseURLString] sessionConfiguration:cfg];
}
@end

