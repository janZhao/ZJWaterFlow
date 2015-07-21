//
//  ZJShopViewController.m
//  ZJWaterFlow
//
//  Created by jyd on 15/7/20.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import "ZJShopViewController.h"
#import "ZJWaterflowView.h"
#import "ZJShop.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "ZJShopCell.h"

@interface ZJShopViewController ()<ZJWaterflowViewDataSource, ZJWaterflowViewDelegate>

@property (nonatomic, strong) NSMutableArray *shops;
@property (nonatomic, weak) ZJWaterflowView *waterflowView;

@end

@implementation ZJShopViewController

- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 0.初始化数据
    NSArray *newShops = [ZJShop objectArrayWithFilename:@"2.plist"];
    [self.shops addObjectsFromArray:newShops];
    
    // 1.瀑布流控件
    ZJWaterflowView *waterflowView = [[ZJWaterflowView alloc] init];
    waterflowView.backgroundColor = [UIColor blueColor];
    waterflowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    waterflowView.frame = self.view.bounds;
    waterflowView.dataSource = self;
    waterflowView.delegate = self;
    [self.view addSubview:waterflowView];
    self.waterflowView = waterflowView;
    
    [waterflowView addHeaderWithTarget:self action:@selector(loadNewShops)];
    [waterflowView addFooterWithTarget:self action:@selector(loadMoreShops)];
    
    [self loadNewShops];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    NSLog(@"屏幕旋转完毕");
    [self.waterflowView reloadData];
}

- (void)loadNewShops
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 加载1.plist
        NSArray *newShops = [ZJShop objectArrayWithFilename:@"1.plist"];
        [self.shops insertObjects:newShops atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新瀑布流控件
        [self.waterflowView reloadData];
        
        // 停止刷新
        [self.waterflowView headerEndRefreshing];
    });
}

- (void)loadMoreShops
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 加载3.plist
        NSArray *newShops = [ZJShop objectArrayWithFilename:@"3.plist"];
        [self.shops addObjectsFromArray:newShops];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新瀑布流控件
        [self.waterflowView reloadData];
        
        // 停止刷新
        [self.waterflowView footerEndRefreshing];
    });
}

#pragma mark - 数据源方法
- (NSUInteger)numberOfCellsInWaterflowView:(ZJWaterflowView *)waterflowView
{
    return self.shops.count;
}

- (ZJWaterflowViewCell *)waterflowView:(ZJWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
    ZJShopCell *cell = [ZJShopCell cellWithWaterflowView:waterflowView];
    
    cell.shop = self.shops[index];
    
    return cell;
}

- (NSUInteger)numberOfColumnsInWaterflowView:(ZJWaterflowView *)waterflowView
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // 竖屏
        return 3;
    } else {
        return 5;
    }
}

#pragma mark - 代理方法
- (CGFloat)waterflowView:(ZJWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    ZJShop *shop = self.shops[index];
    // 根据cell的宽度 和 图片的宽高比 算出 cell的高度
    return waterflowView.cellWidth * shop.h / shop.w;
}


@end
