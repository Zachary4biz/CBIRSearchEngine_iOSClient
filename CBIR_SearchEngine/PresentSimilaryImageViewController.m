//
//  PresentSimilaryImageViewController.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/3/26.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "PresentSimilaryImageViewController.h"
#import "PresentSimilaryImageCollectionViewCell.h"
#import "Masonry.h"
@interface PresentSimilaryImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *layout;

@property (nonatomic, strong) UIImageView *tempTriggerView;
@property (nonatomic, strong) UIImageView *BGIV;

@end

@implementation PresentSimilaryImageViewController


static NSString *cellID = @"cellID";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareView];
    [self prepareLayout];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)prepareView
{
//BGI
    self.BGIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BGI4"]];
    [self.view addSubview:self.BGIV];
    
    UIVisualEffectView *v = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self.BGIV addSubview:v];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.BGIV);
    }];
    
//tempTriggerView
    self.tempTriggerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"searchTrigger_white"]];
    [self.view addSubview:self.tempTriggerView];
    self.tempTriggerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self.tempTriggerView addGestureRecognizer:tap];
    
    
//collectionView
    self.layout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    [self.collectionView registerClass:[PresentSimilaryImageCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    

    
}
- (void)prepareLayout
{
    [self.BGIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tempTriggerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(2);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.bottom.equalTo(self.tempTriggerView.mas_top).offset(-8);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)tap{
    [self dismissViewControllerAnimated:YES completion:nil];
    //动画有点问题
//    [UIView animateWithDuration:0.3 animations:^{
//        self.tempTriggerView.bounds = CGRectMake(0, 0, 100, 100);
//        self.tempTriggerView.center = self.view.center;
//        self.collectionView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - self.collectionView.frame.origin.y);
//    }completion:^(BOOL finished) {
//        [self dismissViewControllerAnimated:NO completion:^{
//            self.collectionView.transform = CGAffineTransformIdentity;
//            [self.tempTriggerView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.view.mas_top).offset(20);
//                make.centerX.equalTo(self.view.mas_centerX);
//                make.width.mas_equalTo(50);
//                make.height.mas_equalTo(50);
//            }];
//        }];
//    }];
}
#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%ld",self.resultArr.count);
    return self.resultArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PresentSimilaryImageCollectionViewCell *aCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    aCell.imgURL = [NSURL URLWithString:self.resultArr[indexPath.row]];
    return aCell;
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(0.45*self.view.frame.size.width, 1.5*0.4*self.view.frame.size.width);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 0.03*self.view.frame.size.width, 10, 0.03*self.view.frame.size.width);
}

- (void)dealloc
{
    NSLog(@"presentSimilaryVC dealloc");
}

#pragma mark - 特殊效果

@end
