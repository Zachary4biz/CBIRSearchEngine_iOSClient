//
//  CompactPhotoViewController.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/6/2.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "CompactPhotoViewController.h"

#import "CompactPhotoCollectionViewCell.h"
#import "CustomCameraViewController.h"
#import "PhotosUtil.h"
@interface CompactPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
//数据
@property (nonatomic, strong) PhotosUtil *photoUtil;
@property (nonatomic, strong) NSMutableArray<PHAsset*> *assetArr;
@property (nonatomic, assign) CGSize photoSize;

//目的是参考iMessage的效果
//UI
@property (weak, nonatomic) IBOutlet UIView *leftV;//用来标定位置（相机）
@property (weak, nonatomic) IBOutlet UIView *rightV;//标定位置（相册的图片）
@property (nonatomic, strong) UICollectionView *colV;
@end

@implementation CompactPhotoViewController


- (PhotosUtil *)photoUtil
{
    if(!_photoUtil){
        _photoUtil = [PhotosUtil new];
    }
    return _photoUtil;
}
#pragma mark - 数据
//准备好所有的相片asset
- (void)prepareData
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        NSLog(@"没有访问权限");
    }else{
        
            self.assetArr =[NSMutableArray arrayWithArray:[PhotosUtil getAssetsInAssetCollection:NULL ascending:YES]];
    
        NSLog(@"一共有 %ld 张照片",self.assetArr.count);
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    CustomCameraViewController *cameraVC = [[CustomCameraViewController alloc]init];
    [self addChildViewController:cameraVC];
    cameraVC.view.frame = self.leftV.bounds;
    [self.leftV addSubview:cameraVC.view];

    UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    self.colV = [[UICollectionView alloc]initWithFrame:self.rightV.bounds collectionViewLayout:layout];
    self.colV.delegate = self;
    self.colV.dataSource = self;
    [self.rightV addSubview:self.colV];
    
    
    self.photoSize = CGSizeMake(120, 240);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CompactPhotoCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetArr[indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        [PhotosUtil decodeAsset:self.assetArr[indexPath.row] size:self.photoSize complition:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                UIImageView *imgV = [[UIImageView alloc]initWithFrame:cell.backgroundView.bounds];
                [imgV setImage:result];
                CompactPhotoCollectionViewCell *theCell = (CompactPhotoCollectionViewCell*) [self.colV cellForItemAtIndexPath:indexPath];
                theCell.photo = result;
                theCell.isSelected = NO;
            }else{
                NSLog(@"没有得到图片？？？");
            }
        }];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CompactPhotoCollectionViewCell *theCell = (CompactPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (theCell.isSelected) {
        //已经被选择，取消
        theCell.isSelected = NO;
        
    }else{
        //没被选择，选中它
        theCell.isSelected = YES;

    }
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 8, 0, 8);
}

@end
