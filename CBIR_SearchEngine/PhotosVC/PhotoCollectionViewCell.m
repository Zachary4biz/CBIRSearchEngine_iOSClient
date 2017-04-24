//
//  PhotoCollectionViewCell.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UIImageView *selectedV;

@end
@implementation PhotoCollectionViewCell

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

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (isSelected) {
        self.selectedV.hidden = NO;
        self.layer.borderColor = [UIColor blueColor].CGColor;
    }else{
        self.selectedV.hidden = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}
- (void)setPhoto:(UIImage *)photo
{
    self.imgV.image = photo;
    _photo = photo;
}
@end
