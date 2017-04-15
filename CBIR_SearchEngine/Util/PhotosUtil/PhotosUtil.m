//
//  PhotosUtil.m
//  TestAboutALL
//
//  Created by Zac on 2017/4/14.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "PhotosUtil.h"

PHAssetCollection *const ZTAllAlbum;
@interface PhotosUtil()<PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) PHFetchResult *userAlbums;
@property (nonatomic, strong) PHFetchResult *smartAlbums;
@property (nonatomic, strong) NSArray *assetArr;
@end

@implementation PhotosUtil
- (void)wrapper
{
    //检测访问权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        NSLog(@"没有访问权限");
    }else{
        NSLog(@"有访问权限");
        //实时监听相册内部图片变化，需要注册代理
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
        //准备一下所有相册
        [self prepareAllAlbum];
        
        
        //获取所有照片资源
        self.assetArr = [self getAssetsInAssetCollection:ZTAllAlbum ascending:YES];
        NSLog(@"所有照片一共有 %ld 张",self.assetArr.count);
        
    }
}

#pragma mark - 获取所有相册
//准备好所有的相册
- (void)prepareAllAlbum
{
    self.userAlbums = [self prepareUserAlbums];
    self.smartAlbums = [self prepareSmartAlbums];
}

//获取用户自定义相册
- (PHFetchResult *)prepareUserAlbums
{
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                         options:nil];
    NSLog(@">>>>>用户自定义相册一共有 %ld 个",userAlbums.count);
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"相册名字:%@", collection.localizedTitle);
    }];
    
    return userAlbums;
}

//获取智能相册
- (PHFetchResult *)prepareSmartAlbums
{
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                          options:nil];
    
    NSLog(@">>>>>智能相册一共有 %ld 个",smartAlbums.count);
    [smartAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx,BOOL *stop) {
        PHAssetCollection *collection = (PHAssetCollection*)obj;
        NSLog(@"相册名字:%@", collection.localizedTitle);
    }];
    
    return smartAlbums;
}


#pragma mark - 获取 指定/全部 相册内 PHAsset(图片)

- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assetArr = [NSMutableArray array];
    
    //1、配置option。ascending 为YES时，按照照片的创建时间升序排列，反之降序
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    //2、判断是获取所有还是某一个相册的图片
    PHFetchResult *result;
    if (assetCollection == ZTAllAlbum) {
        //给的参数是ZTAllAlbum，意味着获取所有相册的资源
        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    }else{
        //给的不是ZTAll，就按 “指定相册” 类型获取，按 "option" 进行操作（主要是排序）
        result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    }
    
    //3、遍历获取的结果，添加到数组中
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assetArr addObject:obj];//这个obj即PHAsset对象
    }];
    
    return assetArr;
}

#pragma mark - 根据PHAsset对象，解析图片
//默认按照图像原尺寸获得image
- (void)dealwithAsset:(PHAsset *)asset complition:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))complitionBlock
{
    [self dealWithAsset:asset size:PHImageManagerMaximumSize complition:complitionBlock];
    
}
//自定义获取图像的尺寸
- (void)dealWithAsset:(PHAsset *)asset size:(CGSize)size complition:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))complitionBlock
{
    /**
     * option.resizeMode选项如下：
     *   PHImageRequestOptionsResizeModeNone,
     *   PHImageRequestOptionsResizeModeFast, //根据传入的size，迅速加载大小相匹配(略大于或略小于)的图像
     *   PHImageRequestOptionsResizeModeExact //精确的加载与传入size相匹配的图像
     */
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    //仅显示缩略图，不控制质量显示
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    //决定是否能从iCloud上下载图片，默认是NO
    option.networkAccessAllowed = YES;
    //targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:size
                                                     contentMode:PHImageContentModeAspectFit
                                                         options:option
                                                   resultHandler:complitionBlock];
    
}
#pragma mark - 工具封装
//判断是不是在本地，因为开启了iCloud后，有可能图片不在本地
- (BOOL)isLocalAsset:(PHAsset *)asset
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset
                                                             options:option
                                                       resultHandler:^(NSData * _Nullable imageData,
                                                                       NSString * _Nullable dataUTI,
                                                                       UIImageOrientation orientation,
                                                                       NSDictionary * _Nullable info) {
                                                           isInLocalAblum = imageData ? YES : NO;
                                                       }];
    return isInLocalAblum;
}

//智能相册相册名字对应的中文
- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    return nil;
}

#pragma mark - PHPhotoLibraryChangeObserver
//相册发生变化回调 --> （注意这里是在子线程，如果要进行UI操作需要回到主线程）
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    NSLog(@"相册发生变化");
}




@end
