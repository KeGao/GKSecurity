//
//  NSString+Base64.h
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

- (NSString *)base64_encrypt;

- (NSString *)base64_decrypt;

- (NSData *)base64_encryptToData;

- (NSData *)base64_decryptToData;

@end
