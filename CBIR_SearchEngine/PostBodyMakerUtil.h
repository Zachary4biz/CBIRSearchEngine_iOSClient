//
//  PostBodyMakerUtil.h
//  TestAboutALL
//
//  Created by Zac on 2017/3/9.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostMakerParams : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *ContentDisposition;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *ContentType;
@property (nonatomic, strong) NSString *ContentTransferEncoding;

- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)filename ContentType:(NSString *)type;
@end

@interface PostBodyMakerUtil : NSObject

+ (void)makeBodyOfRequest:(NSURLRequest *)request andParams:(PostMakerParams *)params;


@end
