//
//  GKAES.m
//  ycl
//
//  Created by Gao on 2017/3/23.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "GKAES.h"
#import "NSString+AES128.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "NSString+MD5.h"

#define AESKEY @"0365a7515c9193cb"

@implementation GKAES

+ (id)shareInstance {
    static GKAES *_aes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _aes = [[self alloc] init];
    });
    return _aes;
}

- (NSString *)encryptByGKAes:(NSString*)content {
    NSDate *date = [NSDate date];
    long padding = 5000;  //有效时间 5秒
    NSString *time = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]*1000+padding];  //当前时间戳加padding
    NSString *md5Str = [content md5String];                             //对数据进行MD5加密
    NSString *str = [NSString stringWithFormat:@"%@.%@",time,md5Str];   //拼接
    NSData *aesData = [str aes128_encryptToData:AESKEY];                //进行aes对称加密
    NSString *base64Str = [aesData base64_encryptToString];             //进行base64加密
    return base64Str;
}

- (NSString *)decryptTokenByGKAes:(NSString*)content {
    NSArray *arr = [content componentsSeparatedByString:@"."];
    if (arr.count == 0) {
        return nil;
    }
    NSString *random = arr.lastObject;      //截取到随机数
    NSString *base64Token = [content substringToIndex:content.length-random.length-1];  //获取base64加密token
    NSData *aesToken = [base64Token base64_decryptToData];                              //base64解密 获取aes加密token
    NSString *md5Str = [[NSString stringWithFormat:@"%@%@",AESKEY,random] md5String];   //秘钥加获取的随机数进行MD5加密
    NSString *myAesKey = [md5Str substringWithRange:NSMakeRange(8, 16)];                //获取md5的第9到24位字符串作为解密的秘钥
    NSString *realToken = [aesToken aes128_decryptToString:myAesKey];                   //通过获取的秘钥 aes解密获取真实token
    return realToken;
}

- (NSString *)encryptTokenByGKAes:(NSString *)content {
    NSDate *date = [NSDate date];
    long padding = 5000;  //有效时间 5秒
    NSString *time = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]*1000+padding];  //当前时间戳加padding
    NSString *token = [NSString stringWithFormat:@"%@.%@",content,time];                //真实token拼接时间戳
    NSString *random = [NSString stringWithFormat:@"%ld",(long)arc4random()%10000];     //生成随机数
    NSString *md5Str = [[NSString stringWithFormat:@"%@%@",AESKEY,random] md5String];   //拼接秘钥和随机数并进行MD5加密
    NSString *newAesKey = [md5Str substringWithRange:NSMakeRange(8, 16)];               //截取MD5的9到24位  作为加密的秘钥
    NSData *aesData = [token aes128_encryptToData:newAesKey];                           //通过获取的秘钥 aes加密获取加密token
    NSString *base64Str = [aesData base64_encryptToString];                             //加密token再进行base64加密
    NSString *fullToken = [NSString stringWithFormat:@"%@.%@",base64Str,random];        //base64加密token拼接随机数得到完整token
    return fullToken;
}

@end
