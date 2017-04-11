//
//  GKRSA.m
//  ycl
//
//  Created by Gao on 2017/4/11.
//  Copyright © 2017年 otoc. All rights reserved.
//

#import "GKRSA.h"
#import <Security/Security.h>
#import <openssl/rsa.h>
#import <openssl/pem.h>

@implementation GKRSA

static NSString *base64_encode_data(NSData *data) {
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

static NSData *base64_decode(NSString *str) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

#pragma mark -生成密钥

/* START: creat keys */

+ (void)keyWith:(void(^)(NSString *pubKey, NSString *priKey))block {
    
    /* 产生RSA密钥 */
    
    RSA *rsa =NULL;
    
    rsa = RSA_new();
    
    //产生一个模为num位的密钥对，e为公开的加密指数，一般为65537（0x10001）
    
    rsa = RSA_generate_key(1024,0x10001,NULL,NULL);
    
    // 路径
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
    
    /* 提取公钥字符串 */
    
    // 最终存储的地方，所以需要创建一个路径去存储字符串
    
    NSString *pubPath = [documentsPath stringByAppendingPathComponent:@"PubFile.txt"];
    
    FILE* pubWrite =NULL;
    
    pubWrite = fopen([pubPath UTF8String],"wb");
    
    if(pubWrite ==NULL)
        
        NSLog(@"Read Filed.");
    
    else
        
    {
        
        PEM_write_RSA_PUBKEY(pubWrite,rsa);
        
        fclose(pubWrite);
        
    }
    
    NSString *str=[NSString stringWithContentsOfFile:pubPath encoding:NSUTF8StringEncoding error:nil];
    
    str = [str stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----"withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----"withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    
    /*提取私钥字符串*/
    
    NSString *priPath = [documentsPath stringByAppendingPathComponent:@"PriFile.txt"];
    
    FILE *priWtire =NULL;
    
    priWtire = fopen([priPath UTF8String],"wb");
    
    EVP_PKEY *pkey =NULL;
    
    if(priWtire ==NULL) {
        
        NSLog(@"Read Filed.");
        
    }else{
        
        //函数使用PKCS#8标准保存EVP_PKEY里面的私钥到文件或者BIO中，并采用PKCS#5
        
        //v2.0的标准加密私钥。enc参数定义了使用的加密算法。跟其他PEM的IO函数不一样的是，本函数的加密是基于PKCS#8层次上的，而不是基于PEM信息字段的，所以这两个函数也是单独实现的函数，而不是宏定义函数。如果enc参数为NULL，那么就不会执行加密操作，只是使用PKCS#8私钥 信息结构。成功执行返回大于0 的数，否则返回0。
        
        pkey = EVP_PKEY_new();
        
        EVP_PKEY_assign_RSA(pkey, rsa);
        
        PEM_write_PKCS8PrivateKey(priWtire, pkey,NULL,NULL,0,0,NULL);
        
        fclose(priWtire);
        
    }
    
    NSString *priStr=[NSString stringWithContentsOfFile:priPath encoding:NSUTF8StringEncoding error:nil];
    
    priStr = [priStr stringByReplacingOccurrencesOfString:@"-----BEGIN PRIVATE KEY-----"withString:@""];
    
    priStr = [priStr stringByReplacingOccurrencesOfString:@"-----END PRIVATE KEY-----"withString:@""];
    
    priStr = [priStr stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    
    block(str,priStr);
    
}

#pragma mark -使用公钥字符串加密

/* START: Encryption with RSA public key */

//使用公钥字符串加密（PKCS8格式）

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
    
    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    
    NSString *ret = base64_encode_data(data);
    
    return ret;
    
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    
    if(!data || !pubKey){
        
        return nil;
        
    }
    
    SecKeyRef keyRef = [self addPublicKey:pubKey];
    
    if(!keyRef){
        
        return nil;
        
    }
    
    return[self encryptData:data withKeyRef:keyRef];
    
}

//构建公钥（PKCS8格式）

+ (SecKeyRef)addPublicKey:(NSString *)key {
    
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        
        NSUInteger s = spos.location + spos.length;
        
        NSUInteger e = epos.location;
        
        NSRange range = NSMakeRange(s, e-s);
        
        key = [key substringWithRange:range];
        
    }
    
    key = [key stringByReplacingOccurrencesOfString:@"\r"withString:@""];
    
    key = [key stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    
    key = [key stringByReplacingOccurrencesOfString:@"\t"withString:@""];
    
    key = [key stringByReplacingOccurrencesOfString:@" "withString:@""];
    
    //key经过base64编码 解码
    
    NSData *data = base64_decode(key);
    
    data = [self stripPublicKeyHeader:data];
    
    if(!data){
        
        return nil;
        
    }
    
    //a tag to read/write keychain storage
    
    NSString *tag =@"RSAUtil_PubKey";
    
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     
     kSecAttrKeyClass];
    
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey =nil;
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    
    if(persistKey !=nil){
        
        CFRelease(persistKey);
        
    }
    
    if((status != noErr) && (status != errSecDuplicateItem)) {
        
        return nil;
        
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    
    SecKeyRef keyRef =nil;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    
    if(status != noErr){
        
        return nil;
        
    }
    
    return keyRef;
    
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    
    // Skip ASN.1 public key header
    
    if(d_key ==nil)return(nil);
    
    unsigned long len = [d_key length];
    
    if(!len)return(nil);
    
    unsigned char*c_key = (unsigned char*)[d_key bytes];
    
    unsigned int idx=0;
    
    if(c_key[idx++] !=0x30)return(nil);
    
    if(c_key[idx] >0x80) idx += c_key[idx] -0x80+1;
    
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    
    static unsigned char seqiod[] =
    
    {0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,
        
        0x01,0x05,0x00};
    
    if(memcmp(&c_key[idx], seqiod,15))return(nil);
    
    idx +=15;
    
    if(c_key[idx++] !=0x03)return(nil);
    
    if(c_key[idx] >0x80) idx += c_key[idx] -0x80+1;
    
    else idx++;
    
    if(c_key[idx++] !='\0')return(nil);
    
    // Now make a new NSData from this buffer
    
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
    
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
    
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) *sizeof(uint8_t);
    
    void*outbuf = malloc(block_size);
    
    size_t src_block_size = block_size -11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    
    for(int idx=0; idx<srclen; idx+=src_block_size) {
        
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        
        size_t data_len = srclen - idx;
        
        if(data_len > src_block_size){
            
            data_len = src_block_size;
            
        }
        
        size_t outlen = block_size;
        
        OSStatus status = noErr;
        
        status = SecKeyEncrypt(keyRef,
                               
                               kSecPaddingPKCS1,
                               
                               srcbuf + idx,
                               
                               data_len,
                               
                               outbuf,
                               
                               &outlen
                               
                               );
        
        if(status !=0) {
            
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            
            ret =nil;
            
            break;
            
        }else{
            
            [ret appendBytes:outbuf length:outlen];
            
        }
        
    }
    
    free(outbuf);
    
    CFRelease(keyRef);
    
    return ret;
    
}

/* END: Encryption with RSA public key */
        
#pragma mark -使用私钥字符串解密
        
/* START: Decryption with RSA private key */

//使用私钥字符串解密

+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey{
    
    if(!str)return nil;
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    data = [self decryptData:data privateKey:privKey];
    
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return ret;
    
}

+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey{
    
    if(!data || !privKey){
        
        return nil;
        
    }
    
    SecKeyRef keyRef = [self addPrivateKey:privKey];
    
    if(!keyRef){
        
        return nil;
        
    }
    
    return[self decryptData:data withKeyRef:keyRef];
    
}

//（PKCS8格式）

+ (SecKeyRef)addPrivateKey:(NSString *)key{
    
    NSRange spos = [key rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
    
    NSRange epos = [key rangeOfString:@"-----END PRIVATE KEY-----"];
    
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        
        NSUInteger s = spos.location + spos.length;
        
        NSUInteger e = epos.location;
        
        NSRange range = NSMakeRange(s, e-s);
        
        key = [key substringWithRange:range];
        
    }
    
    key = [key stringByReplacingOccurrencesOfString:@"\r"withString:@""];
    
    key = [key stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    
    key = [key stringByReplacingOccurrencesOfString:@"\t"withString:@""];
    
    key = [key stringByReplacingOccurrencesOfString:@" "withString:@""];
    
    // This will be base64 encoded, decode it.
    
    NSData *data = base64_decode(key);
    
    data = [self stripPrivateKeyHeader:data];
    
    if(!data){
        
        return nil;
        
    }
    
    //a tag to read/write keychain storage
    
    NSString *tag =@"RSAUtil_PrivKey";
    
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    
    [privateKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    
    SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    // Add persistent version of the key to system keychain
    
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    
    [privateKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)
     
     kSecAttrKeyClass];
    
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey =nil;
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    
    if(persistKey !=nil){
        
        CFRelease(persistKey);
        
    }
    
    if((status != noErr) && (status != errSecDuplicateItem)) {
        
        return nil;
        
    }
    
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    
    SecKeyRef keyRef =nil;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    
    if(status != noErr){
        
        return nil;
        
    }
    
    return keyRef;
    
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key{
    
    // Skip ASN.1 private key header
    
    if(d_key ==nil)return(nil);
    
    unsigned long len = [d_key length];
    
    if(!len)return(nil);
    
    unsigned char*c_key = (unsigned char*)[d_key bytes];
    
    unsigned int idx=22;//magic byte at offset 22
    
    if(0x04!= c_key[idx++])return nil;
    
    //calculate length of the key
    
    unsigned int c_len = c_key[idx++];
    
    int det = c_len &0x80;
    
    if(!det) {
        
        c_len = c_len &0x7f;
        
    }else{
        
        int byteCount = c_len &0x7f;
        
        if(byteCount + idx > len) {
            
            //rsa length field longer than buffer
            
            return nil;
            
        }
        
        unsigned int accum =0;
        
        unsigned char*ptr = &c_key[idx];
        
        idx += byteCount;
        
        while(byteCount) {
            
            accum = (accum <<8) + *ptr;
            
            ptr++;
            
            byteCount--;
            
        }
        
        c_len = accum;
        
    }
    
    // Now make a new NSData from this buffer
    
    return[d_key subdataWithRange:NSMakeRange(idx, c_len)];
    
}

+ (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
    
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) *sizeof(uint8_t);
    
    UInt8 *outbuf = malloc(block_size);
    
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    
    for(int idx=0; idx<srclen; idx+=src_block_size) {
        
        size_t data_len = srclen - idx;
        
        if(data_len > src_block_size){
            
            data_len = src_block_size;
            
        }
        
        size_t outlen = block_size;
        
        OSStatus status = noErr;
        
        status = SecKeyDecrypt(keyRef,
                               
                               kSecPaddingPKCS1,
                               
                               srcbuf + idx,
                               
                               data_len,
                               
                               outbuf,
                               
                               &outlen
                               
                               );
        
        if(status !=0) {
            
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            
            ret =nil;
            
            break;
            
        }else{
            
            //the actual decrypted data is in the middle, locate it!
            
            int idxFirstZero = -1;
            
            int idxNextZero = (int)outlen;
            
            for(int i =0; i < outlen; i++ ) {
                
                if( outbuf[i] ==0) {
                    
                    if( idxFirstZero <0) {
                        
                        idxFirstZero = i;
                        
                    }else{
                        
                        idxNextZero = i;
                        
                        break;
                        
                    }
                    
                }
                
            }
            
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
            
        }
        
    }
    
    free(outbuf);
    
    CFRelease(keyRef);
    
    return ret;
    
}

@end
