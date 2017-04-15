//
//  PresentSimilaryImageCollectionViewCell.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/3/26.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "PresentSimilaryImageCollectionViewCell.h"
#import "UIImageView+WebCache.h"
@interface PresentSimilaryImageCollectionViewCell()
@property (nonatomic, strong) UIImageView *imgV;
@end
@implementation PresentSimilaryImageCollectionViewCell

//- (void)setImg:(UIImage *)img
//{
//    self.img = img;
//    self.imgV = [[UIImageView alloc]initWithFrame:self.bounds];
//    self.imgV.image = img;
//}

//prepareForReuse是为复用准备的，也就是说初次加载，没有复用时不会进入这个
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        _imgV = [[UIImageView alloc]initWithFrame:self.bounds];
        _imgV.image = [UIImage imageNamed:@"searchTrigger"];
        [self addSubview:_imgV];
    }
    return self;
}
- (void)setImgURL:(NSURL *)imgURL
{
    _imgURL = imgURL;
    [_imgV sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"searchTrigger"] options:SDWebImageRefreshCached];
    
#warning 发现自己写的会特别慢
//    NSURLSessionDataTask *t = [[NSURLSession sharedSession] dataTaskWithURL:imgURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"cell下载图片出错");
//        }else{
//            UIImage *img = [UIImage imageWithData:data];
//            self.imgV.image = img;
//        }
//    }];
//    [t resume];
}

@end
