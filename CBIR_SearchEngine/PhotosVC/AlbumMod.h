//
//  AlbumMod.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface AlbumMod : NSObject
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL selected;
@end
