//
//  AlbumTableViewController.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/20.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "AlbumTableViewController.h"
#import "PhotoViewController.h"
#import "PhotosUtil.h"
#import "AlbumMod.h"
#import "AlbumTableViewCell.h"
#import "ViewController.h"
@interface AlbumTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *albumArr;
@property (nonatomic, strong) NSMutableArray *modArr;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomV;
@property (nonatomic, assign) VCType type;

@property (nonatomic, strong) NSMutableArray *selectedAlbumArr;

@end

@implementation AlbumTableViewController
- (NSMutableArray *)selectedAlbumArr
{
    if(!_selectedAlbumArr){
        _selectedAlbumArr = [NSMutableArray new];
    }
    return _selectedAlbumArr;
}
- (instancetype)initWithType:(VCType)type
{
    if (self=[super init]) {
        self.type = type;
    }
    return self;
}
NSString *cellID = @"cD";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIVisualEffectView *v = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    v.frame = self.view.bounds;
    [self.view insertSubview:v atIndex:0];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"wallpaper"]];
    [self.view insertSubview:imgV atIndex:0];
    
    [self prepareData];
    
    [self prepareTableView];
    [self prepareBottomView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)prepareTableView
{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
}
- (void)prepareBottomView
{
    self.bottomV = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    self.bottomV.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.97];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0, 0, 40, 44);
    [backBtn addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"完成" forState:UIControlStateNormal];
    //
    [self.bottomV addSubview:backBtn];
    [self.view addSubview:self.bottomV];
    
    backBtn.center = CGPointMake(self.bottomV.center.x,self.bottomV.frame.size.height*0.5);
}

- (void)prepareData
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        NSLog(@"没有访问权限");
    }else{
        NSMutableArray *smartAlbum = [PhotosUtil prepareSmartAlbums];
        NSMutableArray *userAlbum = [PhotosUtil prepareUserAlbums];
        [self cleanAlbumArr:smartAlbum];
        
        self.albumArr = [NSMutableArray arrayWithArray:smartAlbum];
        [self.albumArr addObjectsFromArray:userAlbum];
        NSLog(@"一共有 %ld 个相册",self.albumArr.count);
        
        self.modArr = [NSMutableArray new];
        NSMutableArray *newAlbumArr = [NSMutableArray new];
        for (PHAssetCollection *col in self.albumArr)
        {
            NSArray *ar = [PhotosUtil getAssetsInAssetCollection:col ascending:YES];
            if (ar.count>0) {
                AlbumMod *mod = [[AlbumMod alloc]init];
                mod.name = col.localizedTitle;
                mod.img = [UIImage imageNamed:@"tmp"];
                mod.count = ar.count;
                mod.name = [PhotosUtil transformAblumTitle:mod.name];
                mod.selected = NO;
                [self.modArr addObject:mod];
                [newAlbumArr addObject:col];
            }else{
                //相册内是0个
            }
        }
        //相册内没有相片的已经被过滤掉了
        self.albumArr = newAlbumArr;
    }
}

//去除相册中不需要的类型，如视频等
- (void)cleanAlbumArr:(NSMutableArray *)albumArr
{
    [albumArr enumerateObjectsUsingBlock:^(PHAssetCollection* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.localizedTitle  isEqual: @"Videos"]) {
            [albumArr removeObject:obj];
        }else if([obj.localizedTitle isEqualToString:@"Time-lapse"]){
            [albumArr removeObject:obj];
        }
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = (AlbumTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.mod = self.modArr[indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(AlbumTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumMod *mod = self.modArr[indexPath.row];
    [PhotosUtil fetchThumbOfAlbum:self.albumArr[indexPath.row] size:CGSizeMake(100, 100) complition:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        mod.img = result;
        cell.mod = mod;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *album = self.albumArr[indexPath.row];
    switch (self.type) {
        case ChosePhoto:{
            
            PhotoViewController *v = [[PhotoViewController alloc]initWithAlbum:album];
            [self presentViewController:v animated:YES completion:nil];
            break;
        }
        case ChoseAlbum:{
            AlbumMod *mod = self.modArr[indexPath.row];
            mod.selected = !mod.selected;
            AlbumTableViewCell *cell = (AlbumTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            cell.mod=mod;
            if (mod.selected) {
                [self.selectedAlbumArr addObject:album];
            }else{
                [self.selectedAlbumArr removeObject:album];
            }
            self.bottomV.transform = CGAffineTransformIdentity;
            break;
        }
        default:
            break;
    }
    
}

CGFloat lastOffSet =0;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (lastOffSet>scrollView.contentOffset.y) {
        NSLog(@"下");
        [self animBottomDirection:NO];
    }else{
        NSLog(@"上");
        [self animBottomDirection:YES];
    }
    lastOffSet = scrollView.contentOffset.y;
}
#pragma mark - Handler
- (void)clickBack
{
    if (self.type==ChoseAlbum) {
        if (self.selectedAlbumArr.count>0) {
            ViewController *v = (ViewController *)self.presentingViewController;
            v.selectedAlbumArr = self.selectedAlbumArr;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - anim
- (void)animBottomDirection:(BOOL)isUP
{
    if (self.tableView.contentOffset.y == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomV.transform = CGAffineTransformIdentity;
        }];
    }else{
        if (isUP) {
            if (CGAffineTransformIsIdentity(self.bottomV.transform)) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.bottomV.transform = CGAffineTransformMakeTranslation(0, self.bottomV.frame.size.height);
                    CGRect r = self.tableView.frame;
                    r.size.height += 44;
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
                    CGRect r = self.tableView.frame;
                    r.size.height -= 44;
                }];
            }
        }
    }
}
@end
