//
//  PhotoViewController.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/15.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotosUtil.h"

@interface PhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *colV;

@property (nonatomic, strong) PhotosUtil *photoUtil;
/**
 这里因为，assetArr获取了之后，还需要遍历+解析，而解析是在另一个线程，
 所以imgArr的count在collectionView计算的时候还是0，
 具体观察代码，发现 尴尬之处在于，遍历时是主线程，解析是子线程，有10个遍历就有10个子线程，
 这样就不知道到底什么时候才全部结束
 所以决定每解析完一个就 reload一下collectionView对应的cell
 这就要求collectionView提前准备好所有的cell，即提前知道有多少个count
 */
@property (nonatomic, assign) NSInteger dataCount;
@property (nonatomic, strong) NSMutableArray *imgArr;
@property (nonatomic, strong) NSMutableArray *infoArr;
@end

@implementation PhotoViewController
extern PHAssetCollection *const ZTAllAlbum;
- (PhotosUtil *)photoUtil
{
    if(!_photoUtil){
        _photoUtil = [PhotosUtil new];
    }
    return _photoUtil;
}
- (NSMutableArray *)imgArr
{
    if(!_imgArr){
        _imgArr = [NSMutableArray array];
        for (int i = 0; i<self.dataCount; i++) {
            [_imgArr addObject:[UIImage imageNamed:@"tmp"]];
        }
    }
    return _imgArr;
}
- (NSMutableArray *)infoArr
{
    if(!_infoArr){
        _infoArr = [NSMutableArray new];
        for (int i = 0; i<self.dataCount; i++) {
            [_infoArr addObject:[NSDictionary dictionary]];
        }
    }
    return _infoArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareImage];
    
    [self prepareViews];
    
}

- (void)prepareImage
{
    NSArray *assetArr = [self.photoUtil getAssetsInAssetCollection:ZTAllAlbum ascending:YES];

    self.dataCount = assetArr.count;
    NSLog(@"一共有 %ld 张照片",self.dataCount);
    for (int i=0;i<assetArr.count;i++)
    {
        PHAsset *asset = assetArr[i];
        [self.photoUtil dealwithAsset:asset complition:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self.imgArr replaceObjectAtIndex:i withObject:result];
                [self.infoArr replaceObjectAtIndex:i withObject:info];
//                NSLog(@"info is %@",info);
                [self.colV reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                NSLog(@"reload %d",i);
            }else{
                NSLog(@"没有得到图片？？？");
            }
        }];
    }
    
}

- (void)prepareViews
{
    [self prepareBtn];
    [self prepareCollectionView];
}
- (void)prepareBtn
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    btn.backgroundColor = [UIColor yellowColor];
    [btn addTarget:self action:@selector(btnHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)btnHandler
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
static NSString *const cellID = @"cellID";
- (void)prepareCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.colV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50) collectionViewLayout:flowLayout];
    [self.colV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    self.colV.delegate = self;
    self.colV.dataSource = self;
    [self.view addSubview:self.colV];
}

#pragma mark - UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:cell.backgroundView.bounds];
    [imgV setImage:self.imgArr[indexPath.row]];
    cell.backgroundView = imgV;
    return cell;
}
#pragma mark - UICollectionViewDelegate

@end
