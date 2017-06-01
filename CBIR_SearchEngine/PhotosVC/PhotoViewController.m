//
//  PhotoViewController.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/15.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "PhotoViewController.h"

#import "Masonry.h"
#import "PhotoCollectionViewCell.h"
#import "ViewController.h"
#import "AlbumTableViewController.h"
@interface PhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
//数据
@property (nonatomic, strong) NSMutableArray<PHAsset*> *assetArr;
@property (nonatomic, strong) NSMutableArray<PHAsset*> *selectedArr;//弃用了
@property (nonatomic, strong) UIImage *selectedImg;


//背景
@property (nonatomic, strong) UIImageView *BGIV;

//展示
@property (nonatomic, strong) UIView *wrapperV;
@property (nonatomic, strong) UICollectionView *colV;
@property (nonatomic, assign) CGSize photoSize;
@property (nonatomic, strong) PhotosUtil *photoUtil;

//底部工具
@property (nonatomic, strong) UIView *bottomV;


//顶部导航
@property (nonatomic, strong) UIView *navV;

@end

@implementation PhotoViewController
extern PHAssetCollection *const ZTAllAlbum;
#pragma mark - lazy
- (PhotosUtil *)photoUtil
{
    if(!_photoUtil){
        _photoUtil = [PhotosUtil new];
    }
    return _photoUtil;
}
- (NSMutableArray *)assetArr
{
    if(!_assetArr){
        _assetArr = [NSMutableArray new];
    }
    return _assetArr;
}
- (NSMutableArray *)selectedArr
{
    if(!_selectedArr){
        _selectedArr = [NSMutableArray new];
    }
    return _selectedArr;
}

#pragma mark - lifeCycle
- (instancetype)initWithAlbum:(PHAssetCollection *)album
{
    if (self=[super init]) {
        self.album =album;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.photoSize = CGSizeMake(0.3*self.view.frame.size.width, 0.4*self.view.frame.size.width);
    
    [self prepareData];
    
    [self prepareViews];
    [self prepareLayout];
    [self GG];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    [self gradientAlphaOnView:(self.view) andFrame:CGRectMake(0, 0, self.colV.frame.size.width, 80)];
//    [self gradientAlphaOnView:(self.view) andFrame:self.colV.frame];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
        if (self.album) {
            //如果给定了某个相册就选该相册
            self.assetArr =[NSMutableArray arrayWithArray:[PhotosUtil getAssetsInAssetCollection:self.album ascending:YES]];
        }else{
            //否则就选所有
            self.assetArr =[NSMutableArray arrayWithArray:[PhotosUtil getAssetsInAssetCollection:ZTAllAlbum ascending:YES]];
        }
        NSLog(@"一共有 %ld 张照片",self.assetArr.count);
        
    }
}
#pragma mark - 初始化
- (void)prepareViews
{
    //按界面从下到上的顺序来
    [self prepareBackgroundIMGView];
    [self prepareWrapperView];
    [self prepareCollectionView];
    [self prepareNavigationView];
    [self prepareBottomView];
}
- (void)prepareBottomView
{
    self.bottomV = [[NSBundle mainBundle] loadNibNamed:@"Photos" owner:nil options:nil][0];
    self.bottomV.backgroundColor = [UIColor clearColor];
    
    //从XIB中，根据tag获取view
    //1.左按钮
    UIButton *leftBtn = [self.bottomV viewWithTag:1];
    [leftBtn addTarget:self action:@selector(bottomVLeftBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    
    //3.右按钮
    UIButton *rightBtn = [self.bottomV viewWithTag:3];
    [rightBtn addTarget:self action:@selector(bottomVRightBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.bottomV];
    
    
//    UIVisualEffectView *v = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//    [self.bottomV insertSubview:v atIndex:0];
//    [v mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.bottomV);
//    }];
//    [self.bottomV bringSubviewToFront:rightBtn];
//    [self.bottomV bringSubviewToFront:leftBtn];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapBottom)];
    doubleTap.numberOfTapsRequired = 2;
    [self.bottomV addGestureRecognizer:doubleTap];
    
}
- (void)doubleTapBottom
{
    [self.colV setContentOffset:CGPointMake(0, self.colV.contentSize.height-self.colV.frame.size.height-44) animated:YES];
}
- (void)prepareNavigationView
{
    self.navV = [[NSBundle mainBundle] loadNibNamed:@"Photos" owner:nil options:nil][1];
    self.navV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.navV];
}
- (void)prepareBackgroundIMGView
{
    self.BGIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BGI"]];
    [self.view addSubview:self.BGIV];
    
    UIVisualEffectView *v = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    [self.BGIV addSubview:v];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.BGIV);
    }];
}
- (void)prepareWrapperView
{
    self.wrapperV = [[UIView alloc]init];
    [self.view addSubview:self.wrapperV];
    [self prepareCollectionView];
}
static NSString *const cellID = @"cellID";
- (void)prepareCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = self.photoSize;
    
    self.colV = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.colV registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    self.colV.delegate = self;
    self.colV.dataSource = self;
    self.colV.alwaysBounceVertical = YES;
    self.colV.backgroundColor = [UIColor clearColor];
//    self.colV.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [self.wrapperV addSubview:self.colV];
    
}
#pragma mark - 布局
- (void)prepareLayout
{
    [self.BGIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.navV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(20);
        make.height.mas_equalTo(44);
    }];
    [self.bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self.wrapperV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navV.mas_bottom);
        make.left.right.equalTo(self.navV);
        make.bottom.equalTo(self.bottomV.mas_top);
//        make.bottom.equalTo(self.view.mas_bottom).mas_offset(-10);
    }];
    
    [self.colV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.wrapperV);
    }];
}
#pragma mark - UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.photo = [UIImage imageNamed:@"temp"];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(PhotoCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetArr[indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        [PhotosUtil decodeAsset:self.assetArr[indexPath.row] size:self.photoSize complition:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                UIImageView *imgV = [[UIImageView alloc]initWithFrame:cell.backgroundView.bounds];
                [imgV setImage:result];
                PhotoCollectionViewCell *theCell = (PhotoCollectionViewCell*) [self.colV cellForItemAtIndexPath:indexPath];
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
    PhotoCollectionViewCell *theCell = (PhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (theCell.isSelected) {
        //已经被选择，取消
        theCell.isSelected = NO;
        [self.selectedArr removeObject:[self.assetArr objectAtIndex:indexPath.row]];
    }else{
        //没被选择，选中它
        theCell.isSelected = YES;
        [self.selectedArr addObject:[self.assetArr objectAtIndex:indexPath.row]];
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

#pragma mark - UIScrollViewDelegate
static CGFloat lastOffset = 0;
static BOOL direction = NO;//NO是上，YES是下
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    lastOffset = scrollView.contentOffset.y;
    NSLog(@"%lf",lastOffset);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //取消掉，不好看
//    if (scrollView.contentOffset.y>lastOffset) {
//        NSLog(@"上");
//        [self animBottomDirection:YES];
//        direction = NO;
//    }else{
//        NSLog(@"下");
//        [self animBottomDirection:NO];
//        direction = YES;
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   
    if (direction) {
        NSLog(@"减速 下");
    }else{
        NSLog(@"减速 上");
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //代码控制的滚动结束后到这里
    if (scrollView.contentOffset.y == 0) {
        
    }
}

#pragma mark - btnHandler
- (void)bottomVLeftBtnHandler
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)bottomVRightBtnHandler
{
    NSLog(@"rightBtn，PhotoVC目前应该只穿一张图");
    if (self.selectedArr.count>1) {
        NSLog(@"暂不支持多图片检索");
        UIAlertController *aC = [UIAlertController alertControllerWithTitle:@"暂不支持多图片检索" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [aC dismissViewControllerAnimated:YES completion:nil];
        }];
        [aC addAction:act];
        [self presentViewController:aC animated:YES completion:nil];
    }else{
        if (self.selectedArr.count>0) {
            ViewController *v = (ViewController*)self.presentingViewController.presentingViewController;
            v.selectedAsset = [self.selectedArr firstObject];
            AlbumTableViewController *v0 =(AlbumTableViewController*) self.presentingViewController;
            
            [self dismissViewControllerAnimated:YES completion:^{
                //            [v0 performSelector:NSSelectorFromString(@"clickBack")];
                [v0 dismissViewControllerAnimated:YES completion:nil];
            }];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
}
    
}

#pragma mark - 特殊效果&动画
//滚动结束时的收缩动画，就是刹车的感觉，参考iMessage的App选择界面，
- (void)compactAnima
{
    //感觉这个是需要从FlowLayout实现的
}
- (void)animBottomDirection:(BOOL)isUP
{
    if (self.colV.contentOffset.y == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomV.transform = CGAffineTransformIdentity;
        }];
    }else{
        if (isUP) {
            if (CGAffineTransformIsIdentity(self.bottomV.transform)) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.bottomV.transform = CGAffineTransformMakeTranslation(0, self.bottomV.frame.size.height);
                }];
            }else{
                return;
            }
        }else{
            if (CGAffineTransformIsIdentity(self.bottomV.transform)) {
                return;
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.bottomV.transform = CGAffineTransformIdentity;
                }];
            }
        }
    }
}

//collectionView 顶部和底部大概15个像素位置开始渐变消失
- (void)GG
{
//1、渐变Layer (上+下)
    [self.view layoutIfNeeded];
    CGRect Gframe = self.wrapperV.bounds;
    CAGradientLayer *GLayer = [CAGradientLayer layer];
    GLayer.frame = Gframe;
    
    //分配颜色，这里使用clearColor配合透明度，来实现渐变隐藏、出现的效果
    [GLayer setColors:[NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] colorWithAlphaComponent:0].CGColor,
                       (id)[[UIColor clearColor] colorWithAlphaComponent:1.0].CGColor,
                       (id)[[UIColor clearColor] colorWithAlphaComponent:1.0].CGColor,
                       (id)[[UIColor clearColor] colorWithAlphaComponent:0].CGColor,
                       nil]];
    //在layer内部 0.x ~ 0.y 位置间进行渐变
    CGFloat baseH = self.wrapperV.frame.size.height;
    GLayer.locations = @[@(0.0),@(15.0/baseH),
                         @((baseH-15)/baseH),@(1.0)];
    //纵向渐变
    [GLayer setStartPoint:CGPointMake(0, 0)];
    [GLayer setEndPoint:CGPointMake(0, 1)];
    
    self.wrapperV.layer.mask = GLayer;
    
}

@end
