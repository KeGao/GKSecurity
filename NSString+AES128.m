//
//  NSString+AES128.m
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "NSString+AES128.h"

@implementation NSString (AES128)

//不建议使用
- (NSString *)aes128_encrypt:(NSString *)key {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data aes128_encryptToString:key];
}

//不建议使用
- (NSString *)aes128_decrypt:(NSString *)key {
//    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    //转换为二进制Data
    NSMutableData *data = [NSMutableData dataWithCapacity:self.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return [data aes128_decryptToString:key];
}

- (NSData *)aes128_encryptToData:(NSString *)key {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data aes128_encrypt:key];
}

//不建议使用
- (NSData *)aes128_decryptToData:(NSString *)key {
//    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    //转换为二进制Data
    NSMutableData *data = [NSMutableData dataWithCapacity:self.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return [data aes128_decrypt:key];
}

@end
