//
//  ZJWaterflowView.m
//  ZJWaterFlow
//
//  Created by jyd on 15/7/19.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import "ZJWaterflowView.h"
#define ZJWaterflowViewDefaultCellH 70
#define ZJWaterflowViewDefaultNumOfColumns 3
#define ZJWaterflowViewDefaultMargin 8

@interface ZJWaterflowView ()

@property (strong, nonatomic) NSMutableArray *cellFrames;

@end

@implementation ZJWaterflowView


-(NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        _cellFrames = [NSMutableArray array];
    }
    
    return _cellFrames;
}

-(void)reloadData
{
    //Cell总数
    int numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
    
    int numberOfColumns = [self numberOfColumns];
    
    // 间距
    CGFloat topM = [self marginForType:ZJWaterflowViewMarginTop];
    CGFloat bottomM = [self marginForType:ZJWaterflowViewMarginBottom];
    CGFloat leftM = [self marginForType:ZJWaterflowViewMarginLeft];
    CGFloat rightM = [self marginForType:ZJWaterflowViewMarginRight];
    CGFloat columnM = [self marginForType:ZJWaterflowViewMarginColumn];
    CGFloat rowM = [self marginForType:ZJWaterflowViewMarginRow];
    
    //Cell的宽度
    CGFloat cellW = (self.width - leftM - rightM - (numberOfColumns - 1)*columnM)/numberOfColumns;
    
    for (int i=0; i<numberOfCells; i++) {
       CGFloat cellH = [self heightAtIndex:i];

    }


}

#pragma mark 私有方法
-(CGFloat)marginForType:(ZJWaterflowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    }
    else{
        return ZJWaterflowViewDefaultMargin;
    }
}

-(NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    }
    else{
        return ZJWaterflowViewDefaultNumOfColumns;
    }
}

-(CGFloat)heightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    }
    else{
        return ZJWaterflowViewDefaultCellH;
    }
}

@end
