//
//  PresentSimilaryImageViewController.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/3/26.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentSimilaryImageViewController : UIViewController

/**
 数组中存放的是所有相似图片的完整URL地址 string类型
 */
@property (nonatomic, strong) NSMutableArray *resultArr;

@end
