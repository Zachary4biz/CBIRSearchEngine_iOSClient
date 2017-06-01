//
//  CompactPhotoCollectionViewCell.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/6/2.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "CompactPhotoCollectionViewCell.h"
@interface CompactPhotoCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UIImageView *selectedV;

@end

@implementation CompactPhotoCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 0.9;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.clipsToBounds = YES;
        
        _imgV = [UIImageView new];
        _imgV.frame = self.bounds;
        [self addSubview:_imgV];
        
        self.selected = NO;
        _selectedV = [UIImageView new];
        _selectedV.image = [UIImage imageNamed:@"selected"];
        _selectedV.frame = CGRectMake(0, 0, 15, 15);
        _selectedV.hidden = YES;
        [self addSubview:_selectedV];
        
    }
    return self;
}
- (void)setPhoto:(UIImage *)photo
{
    self.imgV.image = photo;
    _photo = photo;
}
@end
