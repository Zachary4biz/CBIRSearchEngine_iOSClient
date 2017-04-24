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


#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedAlbumArr = [NSMutableArray new];
    self.searchTriggerView.userInteractionEnabled = YES;
    self.searchView.userInteractionEnabled = YES;
    self.uploadView.userInteractionEnabled = YES;

    //添加一堆手势
    UITapGestureRecognizer *tapTriggerView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTriggerViewHandler)];
    [self.searchTriggerView addGestureRecognizer:tapTriggerView];
    
    UITapGestureRecognizer *tapSearchView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSearchViewHandler)];
    [self.searchView addGestureRecognizer:tapSearchView];
    
    UITapGestureRecognizer *tapUploadView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUploadViewHandler)];
    [self.uploadView addGestureRecognizer:tapUploadView];
    
    //wrapperV 添加阴影、圆角
    self.searchTriggerWrapperView.layer.cornerRadius = 5.0;
    self.searchTriggerWrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchTriggerWrapperView.layer.shadowOffset = CGSizeMake(0, 3);
    self.searchTriggerWrapperView.layer.shadowRadius = 8.0;
    self.searchTriggerWrapperView.layer.shadowOpacity = 0.8;
    
    //给self.view添加一个手势，因为使用CASpring的Layer动画后，下面的imgV的真实frame没有变
    //导致那两个imgV不能响应手势了
    UITapGestureRecognizer *tapSenderGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSenderGes:)];
    [self.view addGestureRecognizer:tapSenderGes];
    
    //需要一个pan手势，和点击trigger一样的效果
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGes];
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
//为了使用CASpring动画后还能响应，就给self.view加了个tap，通过区域判断响应哪一个view
//通过wrapperV的presentationLayer来判断需不需响应
- (void)tapSenderGes:(UITapGestureRecognizer *)tap
{
    CGPoint tapP = [tap locationInView:self.view];
    if ([self.searchTriggerWrapperView.layer.presentationLayer hitTest:tapP]) {
        if (CGRectGetMinX(self.searchView.frame)<tapP.x&&tapP.x<CGRectGetMaxX(self.searchView.frame)) {
            [self tapSearchViewHandler];
        }else if (CGRectGetMinX(self.uploadView.frame)<tapP.x&&tapP.x<CGRectGetMaxX(self.uploadView.frame)){
            [self tapUploadViewHandler];
        }
    }
}
//在self.view上，向上pan能够触发wrapperV显示，向下pan能够触发wrapperV隐藏
CGPoint beginP;
BOOL isPanGesAnimating;
- (void)pan:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            beginP = [pan locationInView:self.view];
//            NSLog(@"开始的是%f",beginP.y);
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint curP = [pan locationInView:self.view];
            if (!isPanGesAnimating) {
                //如果没有在进行动画，就根据位移做动画
                if ((curP.y-beginP.y)>50) {
                    NSLog(@"下滑");
                    isPanGesAnimating = YES;
                    [self hideWrapperV];
                }else if ((curP.y-beginP.y)<-50){
                    NSLog(@"上滑");
                    [self showWrapperV];
                    isPanGesAnimating = YES;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
            isPanGesAnimating = NO;
            break;
        default:
            break;
    }
}

- (void)tapTriggerViewHandler
{
    //按钮点按反馈
    [UIView animateWithDuration:0.1 animations:^{
        self.searchTriggerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.searchTriggerView.transform = CGAffineTransformIdentity;
        }];
    }];
    //动画改变的东西都在presentationLayer上，而直接用属性取得到的其实是modelLayer
    //所以可以理解为,pLayer就是改变后的，mLayer就是类似CGAffineTransformIdentity
    CALayer *pLayer = [self.searchTriggerWrapperView.layer presentationLayer];
    CALayer *mLayer = [self.searchTriggerWrapperView.layer modelLayer];
    
    if (pLayer.position.y==mLayer.position.y) {
        //弹出
        [self showWrapperV];
    }else{
        //收回
        [self hideWrapperV];
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

#pragma mark - 效果
- (void)showWrapperV
{
    //弹出前要移除之前的动画
    [self.searchTriggerWrapperView.layer removeAnimationForKey:@"hide"];
    CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"position.y"];
    //这里这样设置的效果是中心点就在view的最底下，也就是只显示一半的wrapperV，
    //我把WrapperV的控件都放在了上半部分，下半部分是空的，为了让Spring动画更好看
    CGFloat newPositionY = self.view.frame.size.height;
    animation.fromValue = @(self.searchTriggerWrapperView.layer.position.y);
    animation.toValue = @(newPositionY);
    //惯性质量，越大运动得越远
    animation.mass = 1;
    //阻力，越大停止越快
    animation.damping = 15;
    //初始速率，
    animation.initialVelocity = 0;
    //刚度，越大形变越快
    animation.stiffness = 400;
    //持续时间，使用settlingDuration可以让动画完整播放，自己设时间会出问题
    animation.duration = animation.settlingDuration;
    
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.searchTriggerWrapperView.layer addAnimation:animation forKey:@"show"];
}
- (void)hideWrapperV
{
    CALayer *mLayer = [self.searchTriggerWrapperView.layer modelLayer];
    [self.searchTriggerWrapperView.layer removeAnimationForKey:@"show"];
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position.y"];
    ani.toValue = @(mLayer.position.y);
    ani.duration = 0.3;
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    [self.searchTriggerWrapperView.layer addAnimation:ani forKey:@"hide"];
}

@end
