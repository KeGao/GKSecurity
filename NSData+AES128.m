//
//  NSData+AES128.m
//  ycl
//
//  Created by Gao on 2017/3/24.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "NSData+AES128.h"
#import <CommonCrypto/CommonCryptor.h>

#define gIv          key   //向量 默认等于key 可以自行修改

//(key和iv向量这里是16位的) 这里是CBC加密模式，安全性更高
@implementation NSData (AES128)

- (NSData *)aes128_encrypt:(NSString *)key {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,    // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)aes128_decrypt:(NSString *)key {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,   // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

//不建议使用
- (NSString *)aes128_encryptToString:(NSString *)key {
    NSData *data = [self aes128_encrypt:key];
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //转换为二进制字符串
    if (data && data.length > 0) {
        Byte *datas = (Byte*)[data bytes];
        NSMutableString *str = [NSMutableString stringWithCapacity:data.length * 2];
        for(int i = 0; i < data.length; i++){
            [str appendFormat:@"%02x", datas[i]];
        }
        return str;
    }
    return nil;
}

- (NSString *)aes128_decryptToString:(NSString *)key {
    NSData *data = [self aes128_decrypt:key];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end
