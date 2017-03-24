//
//  NSString+AES128.h
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+AES128.h"

@interface NSString (AES128)

/**
 *  不建议使用 加密完成后的data数据转换为二进制字符串 并不是NSData转NSString
 *
 *  @param key AESKEY
 *
 *  @return 二进制字符串
 */
- (NSString *)aes128_encrypt:(NSString *)key GKDEPRECATED("Use -aes128_encryptToData:");

/**
 *  不建议使用 针对data数据转换而成的二进制字符串 进行解密 并不是对NSString数据进行解密
 *
 *  @param key AESKEY
 *
 *  @return 解密后的字符串
 */
- (NSString *)aes128_decrypt:(NSString *)key GKDEPRECATED("只针对data数据转换而成的二进制字符串进行解密");

- (NSData *)aes128_encryptToData:(NSString *)key;

/**
 *  不建议使用 针对data数据转换而成的二进制字符串 进行解密 并不是对NSString数据进行解密
 *
 *  @param key AESKEY
 *
 *  @return 解密后的data
 */
- (NSData *)aes128_decryptToData:(NSString *)key GKDEPRECATED("只针对data数据转换而成的二进制字符串进行解密");

@end
