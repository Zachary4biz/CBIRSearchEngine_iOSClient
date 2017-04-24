//
//  AlbumTableViewController.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewController : UIViewController
typedef enum : NSUInteger {
    ChosePhoto,
    ChoseAlbum,
} VCType;

/**
 两种模式，
 1、要到某个相册里，上传目标图片。
 2、“本地搜索”，选定某个目标相册进行搜索。

 @param type @"upload" @"local"
 @return self
 */
-(instancetype)initWithType:(VCType)type;
@end
