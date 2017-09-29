//
//  NSData+AES128.h
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)

- (NSData *)aes128_encrypt:(NSString *)key;

- (NSData *)aes128_decrypt:(NSString *)key;

/**
 *  不建议使用 加密完成后的data数据转换为二进制字符串 并不是NSData转NSString
 *
 *  @param key AESKEY
 *
 *  @return  二进制字符串
 */
- (NSString *)aes128_encryptToString:(NSString *)key GKDEPRECATED("Use -aes128_encrypt:");

- (NSString *)aes128_decryptToString:(NSString *)key;

@end
