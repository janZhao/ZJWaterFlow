//
//  ZJWaterflowView.h
//  ZJWaterFlow
//
//  Created by jyd on 15/7/19.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ZJWaterflowViewMarginTop,
    ZJWaterflowViewMarginBottom,
    ZJWaterflowViewMarginLeft,
    ZJWaterflowViewMarginRight,
    ZJWaterflowViewMarginColumn,
    ZJWaterflowViewMarginRow,
} ZJWaterflowViewMarginType;

@class ZJWaterflowView,ZJWaterflowViewCell;

@protocol ZJWaterflowViewDataSource <NSObject>

@required

/**
 *  一共有多少个Cell
 */
- (NSUInteger)numberOfCellsInWaterflowView:(ZJWaterflowView *)waterflowView;

/**
 *  返回Index 对应的cell
 */
- (ZJWaterflowViewCell *)waterflowView:(ZJWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

/**
 *  一共有多少列
 */
-(NSUInteger)numberOfColumnsInWaterflowView:(ZJWaterflowView *)waterflowView;

@end

@protocol ZJWaterflowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  cell对应的高度
 */
-(CGFloat)waterflowView:(ZJWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;

/**
 *  选择Cell
 */
-(CGFloat)waterflowView:(ZJWaterflowView *)waterflowView didSelectedAtIndex:(NSUInteger)index;

/**
 *  Cell的间距
 */
-(CGFloat)waterflowView:(ZJWaterflowView *)waterflowView marginForType:(ZJWaterflowViewMarginType)type;

@end

@interface ZJWaterflowView : UIScrollView

/**
 *  数据源
 */
@property (nonatomic, weak) id<ZJWaterflowViewDataSource> dataSource;

/**
 *  代理
 */
@property (nonatomic, weak) id<ZJWaterflowViewDelegate> delegate;

@end
