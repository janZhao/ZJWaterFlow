//
//  ViewController.m
//  ZJWaterFlow
//
//  Created by jyd on 15/7/19.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import "ViewController.h"
#import "ZJWaterflowView.h"
#import "ZJWaterflowViewCell.h"

// 颜色
#define ZJColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define ZJColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// 随机色
#define ZJRandomColor ZJColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface ViewController ()<ZJWaterflowViewDataSource, ZJWaterflowViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ZJWaterflowView *waterflowView = [[ZJWaterflowView alloc]init];
    waterflowView.dataSource = self;
    waterflowView.delegate = self;
    waterflowView.frame = self.view.bounds;
    [self.view addSubview:waterflowView];
}

#pragma mark datasource
-(NSUInteger)numberOfCellsInWaterflowView:(ZJWaterflowView *)waterflowView
{
    return 200;
}

-(NSUInteger)numberOfColumnsInWaterflowView:(ZJWaterflowView *)waterflowView
{
    return 3;
}

-(ZJWaterflowViewCell *)waterflowView:(ZJWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
    ZJWaterflowViewCell *cell = [[ZJWaterflowViewCell alloc]init];
    cell.backgroundColor = ZJRandomColor;
    return cell;
}

#pragma mark delegate
-(CGFloat)waterflowView:(ZJWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    switch (index%3) {
        case 0:return 70;
            break;
        case 1:return 90;
            break;
        case 2:return 100;
            break;
        default:return 110;
            break;
    }
}

-(CGFloat)waterflowView:(ZJWaterflowView *)waterflowView marginForType:(ZJWaterflowViewMarginType)type
{
    switch (type) {
        case ZJWaterflowViewMarginTop:
        case ZJWaterflowViewMarginBottom:
        case ZJWaterflowViewMarginLeft:
        case ZJWaterflowViewMarginRight:
            return 5;
            
        default:return 10;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
