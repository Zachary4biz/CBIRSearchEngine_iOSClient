//
//  BezierPathFromPaintCode.m
//  CBIR_SearchEngine
//
//  Created by Zac on 2017/4/25.
//  Copyright © 2017年 Zac. All rights reserved.
//

#import "BezierPathFromPaintCode.h"


@implementation BezierPathFromPaintCode
#pragma mark - 使用paintCode绘制BezierPath
+ (UIBezierPath *)getLogoBezierPath
{
    //画布是256*256
    //对着图用钢笔描边（右键锚点可以变成曲线模式）
    //描完后，shift选中所有路径，用Difference模式合并路径
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(112, 78)];
    [bezier5Path addCurveToPoint: CGPointMake(87, 91) controlPoint1: CGPointMake(112, 78) controlPoint2: CGPointMake(97.25, 82)];
    [bezier5Path addCurveToPoint: CGPointMake(71, 114) controlPoint1: CGPointMake(76.75, 100) controlPoint2: CGPointMake(71, 114)];
    [bezier5Path addLineToPoint: CGPointMake(112, 117)];
    [bezier5Path addLineToPoint: CGPointMake(112, 78)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(138, 76)];
    [bezier5Path addCurveToPoint: CGPointMake(137.91, 77.05) controlPoint1: CGPointMake(138, 76) controlPoint2: CGPointMake(137.97, 76.37)];
    [bezier5Path addCurveToPoint: CGPointMake(134.5, 117.5) controlPoint1: CGPointMake(137.37, 83.5) controlPoint2: CGPointMake(134.5, 117.5)];
    [bezier5Path addLineToPoint: CGPointMake(180, 122)];
    [bezier5Path addCurveToPoint: CGPointMake(166, 93) controlPoint1: CGPointMake(180, 122) controlPoint2: CGPointMake(176.5, 104.5)];
    [bezier5Path addCurveToPoint: CGPointMake(138, 76) controlPoint1: CGPointMake(155.5, 81.5) controlPoint2: CGPointMake(138, 76)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(137, 23)];
    [bezier5Path addCurveToPoint: CGPointMake(144, 33) controlPoint1: CGPointMake(142, 26.25) controlPoint2: CGPointMake(144, 33)];
    [bezier5Path addCurveToPoint: CGPointMake(143, 43) controlPoint1: CGPointMake(144, 33) controlPoint2: CGPointMake(143.75, 38)];
    [bezier5Path addCurveToPoint: CGPointMake(141, 54) controlPoint1: CGPointMake(142.25, 48) controlPoint2: CGPointMake(141, 54)];
    [bezier5Path addCurveToPoint: CGPointMake(162, 60) controlPoint1: CGPointMake(141, 54) controlPoint2: CGPointMake(150, 53.25)];
    [bezier5Path addCurveToPoint: CGPointMake(191, 86) controlPoint1: CGPointMake(174, 66.75) controlPoint2: CGPointMake(180.5, 69.5)];
    [bezier5Path addCurveToPoint: CGPointMake(201, 107) controlPoint1: CGPointMake(195.27, 92.71) controlPoint2: CGPointMake(198.81, 100.03)];
    [bezier5Path addCurveToPoint: CGPointMake(204.5, 123.5) controlPoint1: CGPointMake(204.2, 117.18) controlPoint2: CGPointMake(204.5, 123.5)];
    [bezier5Path addCurveToPoint: CGPointMake(233.5, 128.5) controlPoint1: CGPointMake(204.5, 123.5) controlPoint2: CGPointMake(222.5, 125.5)];
    [bezier5Path addCurveToPoint: CGPointMake(248, 142) controlPoint1: CGPointMake(244.5, 131.5) controlPoint2: CGPointMake(248, 142)];
    [bezier5Path addCurveToPoint: CGPointMake(225.5, 139.5) controlPoint1: CGPointMake(248, 142) controlPoint2: CGPointMake(236.38, 139.88)];
    [bezier5Path addCurveToPoint: CGPointMake(204.5, 139.5) controlPoint1: CGPointMake(214.62, 139.12) controlPoint2: CGPointMake(204.5, 139.5)];
    [bezier5Path addCurveToPoint: CGPointMake(199, 169) controlPoint1: CGPointMake(204.5, 139.5) controlPoint2: CGPointMake(203.5, 158.25)];
    [bezier5Path addCurveToPoint: CGPointMake(187, 185) controlPoint1: CGPointMake(194.5, 179.75) controlPoint2: CGPointMake(187, 185)];
    [bezier5Path addCurveToPoint: CGPointMake(168, 190) controlPoint1: CGPointMake(187, 185) controlPoint2: CGPointMake(175.25, 191.75)];
    [bezier5Path addCurveToPoint: CGPointMake(158, 178) controlPoint1: CGPointMake(160.75, 188.25) controlPoint2: CGPointMake(158, 178)];
    [bezier5Path addCurveToPoint: CGPointMake(159, 170) controlPoint1: CGPointMake(158, 178) controlPoint2: CGPointMake(157, 173.5)];
    [bezier5Path addCurveToPoint: CGPointMake(166, 164) controlPoint1: CGPointMake(161, 166.5) controlPoint2: CGPointMake(166, 164)];
    [bezier5Path addCurveToPoint: CGPointMake(176, 152) controlPoint1: CGPointMake(166, 164) controlPoint2: CGPointMake(173, 158.25)];
    [bezier5Path addCurveToPoint: CGPointMake(178, 139) controlPoint1: CGPointMake(179, 145.75) controlPoint2: CGPointMake(178, 139)];
    [bezier5Path addLineToPoint: CGPointMake(134.5, 141.5)];
    [bezier5Path addLineToPoint: CGPointMake(137, 199)];
    [bezier5Path addCurveToPoint: CGPointMake(151.5, 199.5) controlPoint1: CGPointMake(137, 199) controlPoint2: CGPointMake(143.75, 199.75)];
    [bezier5Path addCurveToPoint: CGPointMake(168, 198) controlPoint1: CGPointMake(159.25, 199.25) controlPoint2: CGPointMake(168, 198)];
    [bezier5Path addCurveToPoint: CGPointMake(158, 203) controlPoint1: CGPointMake(168, 198) controlPoint2: CGPointMake(165.25, 200.75)];
    [bezier5Path addCurveToPoint: CGPointMake(138.5, 207.5) controlPoint1: CGPointMake(150.75, 205.25) controlPoint2: CGPointMake(138.5, 207.5)];
    [bezier5Path addLineToPoint: CGPointMake(141, 225)];
    [bezier5Path addCurveToPoint: CGPointMake(136, 232) controlPoint1: CGPointMake(141, 225) controlPoint2: CGPointMake(139.75, 228.5)];
    [bezier5Path addCurveToPoint: CGPointMake(126, 237) controlPoint1: CGPointMake(132.25, 235.5) controlPoint2: CGPointMake(126, 237)];
    [bezier5Path addCurveToPoint: CGPointMake(117, 237) controlPoint1: CGPointMake(126, 237) controlPoint2: CGPointMake(120.5, 238.5)];
    [bezier5Path addCurveToPoint: CGPointMake(112, 231) controlPoint1: CGPointMake(113.5, 235.5) controlPoint2: CGPointMake(112, 231)];
    [bezier5Path addLineToPoint: CGPointMake(112, 208)];
    [bezier5Path addCurveToPoint: CGPointMake(94, 204) controlPoint1: CGPointMake(112, 208) controlPoint2: CGPointMake(102.25, 206.5)];
    [bezier5Path addCurveToPoint: CGPointMake(79, 198) controlPoint1: CGPointMake(85.75, 201.5) controlPoint2: CGPointMake(79, 198)];
    [bezier5Path addCurveToPoint: CGPointMake(63, 185) controlPoint1: CGPointMake(79, 198) controlPoint2: CGPointMake(70.5, 193.5)];
    [bezier5Path addCurveToPoint: CGPointMake(49, 164) controlPoint1: CGPointMake(55.5, 176.5) controlPoint2: CGPointMake(49, 164)];
    [bezier5Path addCurveToPoint: CGPointMake(46, 153) controlPoint1: CGPointMake(49, 164) controlPoint2: CGPointMake(47.25, 158.5)];
    [bezier5Path addCurveToPoint: CGPointMake(45, 142) controlPoint1: CGPointMake(44.75, 147.5) controlPoint2: CGPointMake(45, 142)];
    [bezier5Path addCurveToPoint: CGPointMake(36, 143) controlPoint1: CGPointMake(45, 142) controlPoint2: CGPointMake(41.39, 142.02)];
    [bezier5Path addCurveToPoint: CGPointMake(22, 145) controlPoint1: CGPointMake(31.66, 143.79) controlPoint2: CGPointMake(25.9, 145.67)];
    [bezier5Path addCurveToPoint: CGPointMake(10, 136) controlPoint1: CGPointMake(13.25, 143.5) controlPoint2: CGPointMake(10, 136)];
    [bezier5Path addLineToPoint: CGPointMake(9, 130)];
    [bezier5Path addCurveToPoint: CGPointMake(12, 121) controlPoint1: CGPointMake(9, 130) controlPoint2: CGPointMake(9.5, 125)];
    [bezier5Path addCurveToPoint: CGPointMake(20, 114) controlPoint1: CGPointMake(14.5, 117) controlPoint2: CGPointMake(20, 114)];
    [bezier5Path addLineToPoint: CGPointMake(46, 114)];
    [bezier5Path addCurveToPoint: CGPointMake(55, 91) controlPoint1: CGPointMake(46, 114) controlPoint2: CGPointMake(48.22, 101.52)];
    [bezier5Path addCurveToPoint: CGPointMake(74, 70) controlPoint1: CGPointMake(62.21, 79.81) controlPoint2: CGPointMake(74, 70.52)];
    [bezier5Path addCurveToPoint: CGPointMake(88.12, 61.38) controlPoint1: CGPointMake(74, 69.55) controlPoint2: CGPointMake(79.73, 65.53)];
    [bezier5Path addCurveToPoint: CGPointMake(91, 60) controlPoint1: CGPointMake(89.05, 60.92) controlPoint2: CGPointMake(90.01, 60.46)];
    [bezier5Path addCurveToPoint: CGPointMake(112, 54) controlPoint1: CGPointMake(101.06, 55.34) controlPoint2: CGPointMake(112, 54)];
    [bezier5Path addLineToPoint: CGPointMake(112, 35)];
    [bezier5Path addCurveToPoint: CGPointMake(117, 26) controlPoint1: CGPointMake(112, 35) controlPoint2: CGPointMake(113.5, 30)];
    [bezier5Path addCurveToPoint: CGPointMake(125, 20) controlPoint1: CGPointMake(120.5, 22) controlPoint2: CGPointMake(125, 20)];
    [bezier5Path addCurveToPoint: CGPointMake(137, 23) controlPoint1: CGPointMake(125, 20) controlPoint2: CGPointMake(132, 19.75)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(113, 141)];
    [bezier5Path addLineToPoint: CGPointMake(68, 141)];
    [bezier5Path addCurveToPoint: CGPointMake(81, 174) controlPoint1: CGPointMake(68, 141) controlPoint2: CGPointMake(69.5, 160.25)];
    [bezier5Path addCurveToPoint: CGPointMake(98, 189) controlPoint1: CGPointMake(85.92, 179.88) controlPoint2: CGPointMake(92.1, 185.35)];
    [bezier5Path addCurveToPoint: CGPointMake(113, 196) controlPoint1: CGPointMake(105.9, 193.89) controlPoint2: CGPointMake(113, 196)];
    [bezier5Path addLineToPoint: CGPointMake(113, 141)];
    [bezier5Path closePath];
    //描边上色
//    [UIColor.blackColor setStroke];
//    bezier5Path.lineWidth = 1;
//    [bezier5Path stroke];
    
    return bezier5Path;
}
@end
