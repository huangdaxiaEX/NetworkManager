//
//  HKNetworkManager.h
//  EditStyle
//
//  Created by huangdaxia on 16/1/22.
//  Copyright © 2016年 xiaorizi. All rights reserved.
//

#import "AFNetworking.h"

typedef NS_ENUM(NSUInteger, HKHTTPRequestCachePolicy) {
    HKHTTPRequestReturnCacheDataThenLoad       = 1, //有缓存就先返回缓存，同步请求数据
    HKHTTPRequestReloadIngnoringLocalCacheData = 1 << 1, //忽略缓存，重新请求
    HKHTTPRequestReturnCacheDataElseLoad       = 1 << 2, //有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    HKHTTPRequestReturnCacheDataDontLoad       = 1 << 3, //有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
};

@interface HKNetworkManager : AFHTTPSessionManager

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
                      success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

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
                      success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

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
                       success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

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
                       success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
