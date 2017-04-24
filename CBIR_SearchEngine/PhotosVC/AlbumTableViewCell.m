//
//  AlbumTableViewCell.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "AlbumTableViewCell.h"

@interface AlbumTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *countLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *selectedV;

@end
@implementation AlbumTableViewCell
- (void)setMod:(AlbumMod *)mod
{
    _mod = mod;
    self.imgV.image = mod.img;
    self.countLbl.text = [NSString stringWithFormat:@"%ld",mod.count];
    self.nameLbl.text = mod.name;
    self.selectedV.hidden = !mod.selected;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.imgV.contentMode = UIViewContentModeScaleAspectFit
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
