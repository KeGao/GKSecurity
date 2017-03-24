//
//  NSString+Base64.m
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSString *)base64_encrypt {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [data base64EncodedStringWithOptions:0];
    return str;
}

- (NSString *)base64_decrypt {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

- (NSData *)base64_encryptToData {
    NSString *str = [self base64_encrypt];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSData *)base64_decryptToData {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    return data;
}

@end
