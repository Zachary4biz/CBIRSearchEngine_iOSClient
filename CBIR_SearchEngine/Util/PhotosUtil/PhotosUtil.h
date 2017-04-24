//
//  PhotosUtil.h
//  TestAboutALL
//
//  Created by Zac on 2017/4/14.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PhotosUtil : NSObject
//获取用户自定义相册数组
+ (NSMutableArray<PHAssetCollection*> *_Nullable)prepareUserAlbums;
//获取智能相册数组
+ (NSMutableArray<PHAssetCollection*> *_Nonnull)prepareSmartAlbums;
//获取某个相册的缩略图
+ (void)fetchThumbOfAlbum:(PHAssetCollection *)album size:(CGSize)size complition:(void (^)(UIImage * _Nullable result, NSDictionary * _Nullable info))complitionBlock;
/**
 获取 某个/全部 相册中的图片 PHAsset对象

 @param assetCollection 如果传入的是普通相册就取该相册中的图片，如果传入的是ZTAllAlbum，就取所有相册的图片
 @param ascending YES表示按时间升序，NO表示按时间降序
 @return PHAsset的数组
 */
+ (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

/**
 解析一个PHAsset对象
 这里要注意这个图片的原始大小，会导致内存疯长
 @param asset 待解析的PHAsset
 @param complitionBlock 解析完成的操作
 */
+ (void)decodeAsset:(PHAsset *)asset complition:(void (^_Nonnull)(UIImage *__nullable result, NSDictionary *__nullable info))complitionBlock;

//获得自定义的大小
+ (void)decodeAsset:(PHAsset *_Nonnull)asset size:(CGSize)size complition:(void (^_Nonnull)(UIImage *__nullable result, NSDictionary *__nullable info))complitionBlock;

+ (NSString *_Nonnull)transformAblumTitle:(NSString *_Nonnull)title;
@end
