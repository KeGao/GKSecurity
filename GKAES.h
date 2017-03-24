//
//  GKAES.h
//  ycl
//
//  Created by Gao on 2017/3/23.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**尽量不要把数据用AES加密成aesStr
   也不要对aesStr进行AES解密 **/

@interface GKAES : NSObject

+ (id)shareInstance;

/**
 *  对数据进行md5加密后再加时间戳 再进行Aes对称加密 最后base64
 *
 *  @param content 被加密的字符串内容
 *
 *  @return 加密后的字符串内容
 */
- (NSString *)encryptByGKAes:(NSString*)content;

/**
 *  Aes对称解密 获取真实token
 *
 *  @param content 被解密的token
 *
 *  @return 解密后的真实token
 */
- (NSString *)decryptTokenByGKAes:(NSString*)content;

/**
 *  Aes对称加密 对真实token进行加密
 *
 *  @param content 被加密的token
 *
 *  @return 加密后的token
 */
- (NSString *)encryptTokenByGKAes:(NSString*)content;

@end
