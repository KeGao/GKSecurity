//
//  GKRSA.h
//  ycl
//
//  Created by Gao on 2017/4/11.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKRSA : NSObject

/**
 *  创建RSA密钥对
 *
 *  @param block rsa公钥和私钥
 */
+ (void)keyWith:(void(^)(NSString *pubKey, NSString *priKey))block;

/**
 *  加密方法
 *
 *  @param str    需要加密的字符串
 *  @param pubKey 公钥字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

/**
 *  解密方法
 *
 *  @param str     需要解密的字符串
 *  @param privKey 私钥字符串
 *
 *  @return 解密后的字符串
 */
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;

@end
