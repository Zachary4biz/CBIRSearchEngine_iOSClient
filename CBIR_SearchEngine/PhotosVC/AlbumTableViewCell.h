//
//  AlbumTableViewCell.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumMod.h"
@interface AlbumTableViewCell : UITableViewCell
@property (nonatomic, strong) AlbumMod *mod;
@property (weak, nonatomic) IBOutlet UIImageView *imgvBGV;
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
//@property (nonatomic, strong) NSString *name;
//@property (nonatomic, assign) NSInteger *count;
//@property (nonatomic, strong) UIImage *img;

@end
