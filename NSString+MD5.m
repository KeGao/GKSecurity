//
//  NSString+MD5.m
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)md5String {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [str appendFormat:@"%02x", digest[i]];
    
    return str;
}

- (NSData *)md5Data {
    NSString *str = [self md5String];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

@end
