//
//  DPDEncrypt.m
//  Pods
//
//  Created by admin on 16/1/21.
//
//

#import "WBDNSEncrypt.h"
#import "WBDNSConfigManager.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation WBDNSEncrypt


static char DIGITS_UPPER[] =    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

static int hexDigit(char c){
    int result = -1;
    if ('0' <= c && c <= '9') {
        result = c - '0';
    } else if ('a' <= c && c <= 'f') {
        result = 10 + (c - 'a');
    } else if ('A' <= c && c <= 'F') {
        result = 10 + (c - 'A');
    }
    return result;
}

static char* decodeHex(const char* data, int size){
    if ((size & 0x01) != 0) {
        return NULL;
    }
    char *output = malloc(size/2);
    int outLimit = 0;
    for (int i=0, j=0; j<size; i++) {
        int f = hexDigit(data[j]);
        if (f <0) {
            outLimit = 1;
            break;
        }
        j++;
        int f2 = hexDigit(data[j]);
        if (f2 < 0) {
            outLimit = 1;
            break;
        }
        f = (f<<4) |f2;
        j++;
        output[i] = (char)(f & 0xff);
    }
    if (outLimit) {
        free(output);
        return NULL;
    }
    return output;
}

static char* encodeHex(const char* data, int size, char hexTable[]){
    char* output = malloc(size *2);
    for (int i =0, j=0; i< size; i++) {
        output[j++] = hexTable[((0XF0&data[i]) >>4)&0X0F];
        output[j++] = hexTable[((0X0F&data[i]))&0X0F];
    }
    return output;
}


+(NSString *)encodeHexData:(NSData *)data {
    char* e = encodeHex(data.bytes, (int)data.length, DIGITS_UPPER);
    NSString *str= [[NSString alloc] initWithBytes:e length:data.length*2 encoding:NSASCIIStringEncoding];
    free(e);
    return str;
}

+(NSString *)encodeHexString:(NSString *)str {
    return [self encodeHexData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

+(NSData *)decodeHexString:(NSString*)hex {
    char *d = decodeHex(hex.UTF8String, (int)hex.length);
    if (d == NULL) {
        return nil;
    }
    NSData *data = [NSData dataWithBytes:d length:hex.length/2];
    free(d);
    return data;
}

+(NSString *)decodeHexToString:(NSString*)hex {
    NSData *data = [self decodeHexString:hex];
    if (data == nil) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)encrypt:(NSString*)domain {
    
    
    
    NSData *data = [self encryptWithData:[domain dataUsingEncoding:NSUTF8StringEncoding] andKey:[[WBDNSConfigManager getDPlusKey] dataUsingEncoding:NSUTF8StringEncoding]];
    if (data == nil) {
        return nil;
    }
    NSString * str = [self encodeHexData:data];
    return str;
}

+ (NSString *)decrypt:(NSData*)raw {
    NSData *enc = [self decodeHexString:[[NSString alloc]initWithData:raw
                                                                 encoding:NSUTF8StringEncoding]];
    if (enc == nil) {
        return nil;
    }
    NSData *data = [self decrpytWithData:enc andKey:[[WBDNSConfigManager getDPlusKey] dataUsingEncoding:NSUTF8StringEncoding]];
    if (data == nil) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+(NSData *)encryptWithData:(NSData*)data andKey:(NSData *)key{
    const void *input = data.bytes;
    size_t inputSize = data.length;
    
    size_t bufferSize = (inputSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    uint8_t *buffer = malloc( bufferSize * sizeof(uint8_t));
    memset((void *)buffer, 0x0, bufferSize);
    size_t movedBytes = 0;
    
    const void *vkey = key.bytes;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                                       kCCAlgorithmDES,
                                       kCCOptionECBMode|kCCOptionPKCS7Padding,
                                       vkey,
                                       kCCKeySizeDES,
                                       NULL,
                                       input,
                                       inputSize,
                                       (void *)buffer,
                                       bufferSize,
                                       &movedBytes);
    if (ccStatus != kCCSuccess) {
        NSLog(@"error code %d", ccStatus);
        free(buffer);
        return nil;
    }
    NSData *encrypted = [NSData dataWithBytes:(const void *)buffer length:(NSUInteger)movedBytes];
    free(buffer);
    return encrypted;
}

+(NSData *)decrpytWithData:(NSData*)raw andKey:(NSData *)key{
    const void *input = raw.bytes;
    size_t inputSize = raw.length;
    
    size_t bufferSize = 1024;
    uint8_t *buffer = malloc( bufferSize * sizeof(uint8_t));
    memset((void *)buffer, 0x0, bufferSize);
    size_t movedBytes = 0;
    
    const void *vkey = key.bytes;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithmDES,
                                       kCCOptionECBMode|kCCOptionPKCS7Padding,
                                       vkey,
                                       kCCKeySizeDES,
                                       NULL,
                                       input,
                                       inputSize,
                                       (void *)buffer,
                                       bufferSize,
                                       &movedBytes);
    
    if (ccStatus != kCCSuccess) {
        NSLog(@"error code %d", ccStatus);
        free(buffer);
        return nil;
    }
    
    NSData *decrypted = [NSData dataWithBytes:(const void *)buffer length:(NSUInteger)movedBytes];
    free(buffer);
    return decrypted;
}

@end
