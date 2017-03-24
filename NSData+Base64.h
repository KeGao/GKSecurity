//
//  NSData+Base64.h
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

- (NSData *)base64_encrypt;

- (NSData *)base64_decrypt;

- (NSString *)base64_encryptToString;

- (NSString *)base64_decryptToString;

@end
