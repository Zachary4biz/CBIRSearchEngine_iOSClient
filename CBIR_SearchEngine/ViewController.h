//
//  ViewController.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/3/26.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageName.h"
#import "PhotosUtil.h"
@interface ViewController : UIViewController
/**
 来自AlbumVC的 选中的相册 数据
 */
@property (nonatomic, strong) NSMutableArray *selectedAlbumArr;
@property (nonatomic, strong) NSMutableArray *assetArr4Upload;


/**
 来自PhotoVC的 待搜索的目标图片
 */
@property (nonatomic, strong) UIImage *selectedImg;
@property (nonatomic, strong) PHAsset *selectedAsset;


@end

