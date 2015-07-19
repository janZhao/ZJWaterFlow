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
    waterflowView.frame = self.view.bounds;
    waterflowView.dataSource = self;
    waterflowView.delegate = self;
    [self.view addSubview:waterflowView];
    
    [waterflowView reloadData];
}

#pragma mark datasource
-(NSUInteger)numberOfCellsInWaterflowView:(ZJWaterflowView *)waterflowView
{
    return 50;
}

-(NSUInteger)numberOfColumnsInWaterflowView:(ZJWaterflowView *)waterflowView
{
    return 3;
}

-(ZJWaterflowViewCell *)waterflowView:(ZJWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
    static NSString *ID = @"ZJWaterflowViewCell";
    ZJWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[ZJWaterflowViewCell alloc] init];
        cell.identifier = ID;
        cell.backgroundColor = ZJRandomColor;
        [cell addSubview:[UIButton buttonWithType:UIButtonTypeContactAdd]];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = 10;
        label.frame = CGRectMake(0, 0, 50, 20);
        [cell addSubview:label];
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:10];
    label.text = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    
    NSLog(@"%lu %p", (unsigned long)index, cell);
    
    return cell;
}

#pragma mark delegate
-(CGFloat)waterflowView:(ZJWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    switch (index%3) {
        case 0:return 110;
        case 1:return 80;
        case 2:return 100;
        default:return 110;
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

-(void)waterflowView:(ZJWaterflowView *)waterflowView didSelectedAtIndex:(NSUInteger)index
{
        NSLog(@"点击了第%lu个cell", (unsigned long)index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
