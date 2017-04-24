//
//  PhotoCollectionViewCell.h
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, assign) BOOL isSelected;

@end
