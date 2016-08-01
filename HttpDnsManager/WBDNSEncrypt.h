//
//  DPDEncrypt.h
//  Pods
//
//  Created by admin on 16/1/21.
//
//

#import <Foundation/Foundation.h>

@interface WBDNSEncrypt : NSObject


+ (NSString *)encrypt:(NSString*)domain;
+ (NSString *)decrypt:(NSData*)raw ;

@end
