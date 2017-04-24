//
//  UIImage+ImageName.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/21.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "UIImage+ImageName.h"
#import <objc/runtime.h>
@implementation UIImage (ImageName)
static void *name = &name;
- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, &name, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)name
{
    return objc_getAssociatedObject(self, &name);
}

@end
