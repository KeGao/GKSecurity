//
//  NSData+Base64.m
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64)

- (NSData *)base64_encrypt {
    NSString *str = [self base64EncodedStringWithOptions:0];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSData *)base64_decrypt {
    NSString *str = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    return data;
}

- (NSString *)base64_encryptToString {
    NSString *str = [self base64EncodedStringWithOptions:0];
    return str;
}

- (NSString *)base64_decryptToString {
    NSData *data = [self base64_decrypt];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end
