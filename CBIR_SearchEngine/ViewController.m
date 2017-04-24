//
//  ViewController.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/3/26.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "ViewController.h"
#import "PostBodyMakerUtil.h"
#import "PresentSimilaryImageViewController.h"
#import "PhotoViewController.h"
#import "AlbumTableViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *searchTriggerView;
@property (weak, nonatomic) IBOutlet UIView *searchTriggerWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *searchView;
@property (weak, nonatomic) IBOutlet UIImageView *uploadView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;



//@property (nonatomic, strong) UIImagePickerController *p;
@property (nonatomic, assign) BOOL isPickerUpload;

@property (nonatomic, strong) NSURL *uploadURL;
@property (nonatomic, strong) NSURL *searchURL;
@property (nonatomic, strong) PresentSimilaryImageViewController *presentVC;
/**
 保存有服务器返回的结果，之后会遍历处理成完整的URL 的string
 */
@property (nonatomic, strong) NSMutableArray *searchResultArr;


@end

static NSString *serverStr = @"http://192.168.221.54:5000/";
//static NSString *serverStr = @"http://0.0.0.0:5000/";

@implementation ViewController
#pragma mark - lazy
- (NSURL *)uploadURL
{
    if(!_uploadURL){
        _uploadURL = [NSURL URLWithString:[serverStr stringByAppendingString:@"uploaddataset"]];
    }
    return _uploadURL;
}
- (NSURL *)searchURL
{
    if(!_searchURL){
        _searchURL = [NSURL URLWithString:[serverStr stringByAppendingString:@"searchimage"]];
    }
    return _searchURL;
}
- (NSMutableArray *)searchResultArr
{
    if(!_searchResultArr){
        _searchResultArr = [[NSMutableArray alloc]init];
    }
    return _searchResultArr;
}
- (PresentSimilaryImageViewController *)presentVC
{
    if(!_presentVC){
        _presentVC = [[PresentSimilaryImageViewController alloc]init];
    }
    return _presentVC;
}


#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedAlbumArr = [NSMutableArray new];
    self.searchTriggerView.userInteractionEnabled = YES;
    self.searchView.userInteractionEnabled = YES;
    self.uploadView.userInteractionEnabled = YES;
    self.searchTriggerWrapperView.transform = CGAffineTransformMakeTranslation(0, self.searchTriggerWrapperView.frame.size.height);
    
    UITapGestureRecognizer *tapTriggerView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTriggerViewHandler)];
    [self.searchTriggerView addGestureRecognizer:tapTriggerView];
    
    UITapGestureRecognizer *tapSearchView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSearchViewHandler)];
    [self.searchView addGestureRecognizer:tapSearchView];
    
    UITapGestureRecognizer *tapUploadView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUploadViewHandler)];
    [self.uploadView addGestureRecognizer:tapUploadView];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
//上传相册作为搜索源
- (void)setSelectedAlbumArr:(NSMutableArray *)selectedAlbumArr
{
    _selectedAlbumArr = selectedAlbumArr;
    [self uploadSelectedAlbum];
}
//上传图片作为搜索目标
- (void)setSelectedImg:(UIImage *)selectedImg
{
    _selectedImg = selectedImg;
//    [self searchImage:selectedImg andName:selectedImg.name];
    
}
- (void)setSelectedAsset:(PHAsset *)selectedAsset
{
    [PhotosUtil decodeAsset:selectedAsset complition:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [self searchImage:result andName:[selectedAsset valueForKey:@"filename"]];
    }];
}

#pragma mark - upload
//上传相册
- (void)uploadSelectedAlbum
{
    NSMutableArray *ar = [NSMutableArray new];
    for (int i=0; i<self.selectedAlbumArr.count; i++) {
        PHAssetCollection *assetCollection = self.selectedAlbumArr[i];
        [ar addObjectsFromArray:[PhotosUtil getAssetsInAssetCollection:assetCollection ascending:YES]];
    }
    self.assetArr4Upload = [NSMutableArray arrayWithArray:ar];
    [self.progressV setProgress:0 animated:nil];
    self.progressV.alpha = 1.0;
    [self uploadAssetAtIndex:ar.count-1];
    NSLog(@"将上传%ld",ar.count);
}
PHAsset *asset = nil;
- (void)uploadAssetAtIndex:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressV setProgress:((self.assetArr4Upload.count-index)*1.0/self.assetArr4Upload.count) animated:NO];
        if (self.progressV.progress >0.99) {
            [UIView animateWithDuration:0.3 animations:^{
                self.progressV.alpha = 0;
            }];
        }
    });
    if (index<0) {
        NSLog(@"上传完成");
        return;
    }
        asset = self.assetArr4Upload[index];
    [PhotosUtil decodeAsset:asset complition:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSString *name = [asset valueForKey:@"filename"];
        [self uploadImage:result andName:name complition:^(BOOL suc) {
            [self uploadAssetAtIndex:index-1];
            
        }];
    }];
}
- (void)uploadImage:(UIImage *)img andName:(NSString *)name complition:(void(^)(BOOL suc))complition
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.uploadURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 7.0;
    
    PostMakerParams *p = [[PostMakerParams alloc]initWithData:UIImageJPEGRepresentation(img,0.5) name:@"image" fileName:name ContentType:@"image/jpeg"];
    [PostBodyMakerUtil makeBodyOfRequest:request andParams:p];
    
    NSURLSessionDataTask *t = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                              completionHandler:^(NSData * _Nullable data,
                                                                                  NSURLResponse * _Nullable response,
                                                                                  NSError * _Nullable error) {
                                                                  if (error) {
                                                                      NSLog(@"%@",error);
                                                                      complition(NO);
                                                                  }else{
//                                                                      NSLog(@"上传成功");
                                                                      complition(YES);
                                                                  }
                                                              }];
    [t resume];

}
#pragma mark - search
- (void)searchImage:(UIImage *)img andName:(NSString *)name
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.searchURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 7.0;
    
    PostMakerParams *p = [[PostMakerParams alloc]initWithData:UIImageJPEGRepresentation(img,0.5) name:@"image" fileName:name ContentType:@"image/jpeg"];
    [PostBodyMakerUtil makeBodyOfRequest:request andParams:p];
    
    
    NSURLSessionDataTask *t = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                              completionHandler:^(NSData * _Nullable data,
                                                                                  NSURLResponse * _Nullable response,
                                                                                  NSError * _Nullable error) {
                                                                  if (error) {
                                                                      NSLog(@"%@",error);
                                                                      
                                                                  }else{
                                                                      NSError *jsonEr = nil;
                                                                      NSArray *arrFromServer = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                               options:NSJSONReadingAllowFragments
                                                                                                                                 error:&jsonEr];
                                                                      NSLog(@"查询结果--\n  %@",arrFromServer);
                                                                      if (jsonEr) {
                                                                          NSLog(@"jsonEr %@",jsonEr);
                                                                      }
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          [self showPresentVCWithArr:arrFromServer];
                                                                      });
                                                                  }
                                                              }];
    [t resume];
}

- (void)showPresentVCWithArr:(NSArray *)arrFromServer
{
    self.searchResultArr = [arrFromServer mutableCopy];
    PresentSimilaryImageViewController *presentVC = [[PresentSimilaryImageViewController alloc]init];
    presentVC.resultArr = [NSMutableArray array];
    //遍历，加上服务器的域名
    [self.searchResultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [presentVC.resultArr addObject:[serverStr stringByAppendingString:obj]];
    }];
    [self presentViewController:presentVC animated:YES completion:nil];
}
#pragma mark - GestureHandler
- (void)tapTriggerViewHandler
{
    if (!CGAffineTransformIsIdentity(self.searchTriggerWrapperView.transform)) {
        [UIView animateWithDuration:0.1 animations:^{
            self.searchTriggerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.searchTriggerView.transform = CGAffineTransformIdentity;
            }];
        }];
        [UIView animateWithDuration:0.2 animations:^{
            self.searchTriggerWrapperView.transform = CGAffineTransformIdentity;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.searchTriggerWrapperView.transform = CGAffineTransformMakeTranslation(0, self.searchTriggerWrapperView.frame.size.height);
        }];
    }
}
- (void)tapSearchViewHandler
{
    self.isPickerUpload = NO;
    [UIView animateWithDuration:0.1 animations:^{
        self.searchView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.searchView.transform = CGAffineTransformIdentity;
        }];
    }];
    
    AlbumTableViewController *albumVC = [[AlbumTableViewController alloc]initWithType:ChosePhoto];
    [self presentViewController:albumVC animated:YES completion:^{
        
    }];
}
- (void)tapUploadViewHandler
{
    [UIView animateWithDuration:0.1 animations:^{
        self.uploadView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.uploadView.transform = CGAffineTransformIdentity;
        }];
    }];
    
    AlbumTableViewController *albumVC = [[AlbumTableViewController alloc]initWithType:ChoseAlbum];
    [self presentViewController:albumVC animated:YES completion:^{
        
    }];
}


@end
