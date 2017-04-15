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
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *searchTriggerView;
@property (weak, nonatomic) IBOutlet UIView *searchTriggerWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *searchView;
@property (weak, nonatomic) IBOutlet UIImageView *uploadView;


@property (nonatomic, strong) UIImagePickerController *p;
@property (nonatomic, assign) BOOL isPickerUpload;

@property (nonatomic, strong) NSURL *uploadURL;
@property (nonatomic, strong) NSURL *searchURL;
@property (nonatomic, strong) PresentSimilaryImageViewController *presentVC;
/**
 保存有服务器返回的结果，之后会遍历处理成完整的URL 的string
 */
@property (nonatomic, strong) NSMutableArray *searchResultArr;


@end

//static NSString *serverStr = @"http://192.168.220.153:5000/";
static NSString *serverStr = @"http://0.0.0.0:5000/";

@implementation ViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    _p = [[UIImagePickerController alloc]init];
    _p.delegate = self;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
#pragma mark - upload
- (void)uploadImage:(UIImage *)img andName:(NSString *)name
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.uploadURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 3.0;
    
    PostMakerParams *p = [[PostMakerParams alloc]initWithData:UIImageJPEGRepresentation(img,0.5) name:@"image" fileName:name ContentType:@"image/jpeg"];
    [PostBodyMakerUtil makeBodyOfRequest:request andParams:p];
    
    NSURLSessionDataTask *t = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                              completionHandler:^(NSData * _Nullable data,
                                                                                  NSURLResponse * _Nullable response,
                                                                                  NSError * _Nullable error) {
                                                                  if (error) {
                                                                      NSLog(@"%@",error);
                                                                  }else{
                                                                      NSLog(@"上传成功");
                                                                  }
                                                              }];
    [t resume];

}
#pragma mark - search
- (void)searchImage:(UIImage *)img andName:(NSString *)name
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.searchURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 3.0;
    
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
                                                                      }else{
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [self showPresentVCWithArr:arrFromServer];
                                                                          });
                                                                      }
                                                                  }
                                                              }];
    [t resume];
}

- (void)showPresentVCWithArr:(NSArray *)arrFromServer
{
    self.searchResultArr = [arrFromServer mutableCopy];
    self.presentVC.resultArr = [NSMutableArray array];
    //遍历，加上服务器的域名
    [self.searchResultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.presentVC.resultArr addObject:[serverStr stringByAppendingString:obj]];
    }];
    [self presentViewController:self.presentVC animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *img4upload = [UIImage new];
    UIImage *originalIMG = info[@"UIImagePickerControllerOriginalImage"];
    UIImage *editedIMG = info[@"UIImagePickerControllerEditedImage"];
    if (editedIMG) {
        img4upload = editedIMG;
    }else{
        img4upload = originalIMG;
    }
    NSURL *url = info[@"UIImagePickerControllerReferenceURL"];
    NSLog(@"%@",url.lastPathComponent);
    
    //获取一下文件名,然后上传到服务器
    [self getFileNameWithInfoDic:info complition:^(NSString *filename) {
        if (self.isPickerUpload) {
            [self uploadImage:img4upload
                      andName:filename];
        }else{
            [self searchImage:img4upload
                      andName:filename];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 获取某个图片的名称
- (void)getFileNameWithInfoDic:(NSDictionary *)info complition:(void (^)(NSString *filename))complition
{
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        NSString *fileName = [representation filename];
        complition(fileName);
    };
    
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
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
    [self presentViewController:_p animated:YES completion:^{
        self.searchTriggerWrapperView.transform = CGAffineTransformMakeTranslation(0, self.searchTriggerWrapperView.frame.size.height);
    }];
}
- (void)tapUploadViewHandler
{
    self.isPickerUpload = YES;
    [UIView animateWithDuration:0.1 animations:^{
        self.uploadView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.uploadView.transform = CGAffineTransformIdentity;
        }];
    }];
    [self presentViewController:_p animated:YES completion:^{
        self.searchTriggerWrapperView.transform = CGAffineTransformMakeTranslation(0, self.searchTriggerWrapperView.frame.size.height);
    }];
}


@end
