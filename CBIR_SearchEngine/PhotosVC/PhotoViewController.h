//
//  PhotoViewController.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/15.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosUtil.h"
@interface PhotoViewController : UIViewController
@property (nonatomic, strong) PHAssetCollection *album;
- (instancetype)initWithAlbum:(PHAssetCollection *)album;
@end
