//
//  PostBodyMakerUtil.m
//  TestAboutALL
//
//  Created by Zac on 2017/3/9.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "PostBodyMakerUtil.h"
@implementation PostMakerParams
- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)filename ContentType:(NSString *)type
{
    if (self = [super init]) {
        self.data = data;
        self.name = name;
        self.filename = filename;
        self.ContentType = type;
        
        self.ContentDisposition = @"form-data";
        self.ContentTransferEncoding = @"binary";
    }
    return  self;
}

@end
@implementation PostBodyMakerUtil
static NSString *boundary = @"ZTBoundary";
+ (void)makeBodyOfRequest:(NSMutableURLRequest *)request andParams:(PostMakerParams *)params
{
    
    request.timeoutInterval = 10;
    request.HTTPMethod = @"POST";
    
    //1.初始化数据（这个就是请求体HTTPBody)
    NSMutableData *requestMutableData = [NSMutableData data];
    //2.拼接请求体
    //2.1请求体前部
    //设置分隔符（开始）
    NSMutableString *myString = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",boundary];
    //设置上传的文件名
    [myString appendString:[NSString stringWithFormat:@"Content-Disposition:form-data;name=\"%@\";filename=\"%@\"\r\n",params.name,params.filename]];
    //设置图片类型
    [myString appendString:[NSString stringWithFormat:@"Content-Type:%@\r\n",params.ContentType]];
    //设置编码方式
    //注意到这里要有两套\r\n，因为这里跟数据之间要空出一行的
    [myString appendString:@"Content-Transfer-Encoding:binary\r\n\r\n"];
    //请求体转成二进制数据
    [requestMutableData appendData:[myString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //2.2文件数据部分
    [requestMutableData appendData:params.data];
    
    //2.3请求体结束拼接
    //设置分隔符（结束）
    [requestMutableData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //3.赋值请求体
    request.HTTPBody = requestMutableData;
    
    //4.设置请求头
    NSString *headStr = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary];
    [request setValue:headStr forHTTPHeaderField:@"Content-Type"];

}



@end
