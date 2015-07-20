//
//  ZJWaterflowView.m
//  ZJWaterFlow
//
//  Created by jyd on 15/7/19.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import "ZJWaterflowView.h"
#import "ZJWaterflowViewCell.h"

#define ZJWaterflowViewDefaultCellH 70
#define ZJWaterflowViewDefaultNumOfColumns 3
#define ZJWaterflowViewDefaultMargin 8

@interface ZJWaterflowView ()

@property (strong, nonatomic) NSMutableArray *cellFrames;

/**
 *  正在展示的cell
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
/**
 *  缓存池（用Set，存放离开屏幕的cell）
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;

@end

@implementation ZJWaterflowView


-(NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        _cellFrames = [NSMutableArray array];
    }
    
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells
{
    if (_reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

/**
 *  cell的宽度
 */
- (CGFloat)cellWidth
{
    // 总列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    CGFloat leftM = [self marginForType:ZJWaterflowViewMarginLeft];
    CGFloat rightM = [self marginForType:ZJWaterflowViewMarginRight];
    CGFloat columnM = [self marginForType:ZJWaterflowViewMarginColumn];
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
}


-(void)reloadData
{
    //Cell总数
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
    
    NSUInteger numberOfColumns = [self numberOfColumns];
    
    // 间距
    CGFloat topM = [self marginForType:ZJWaterflowViewMarginTop];
    CGFloat bottomM = [self marginForType:ZJWaterflowViewMarginBottom];
    CGFloat leftM = [self marginForType:ZJWaterflowViewMarginLeft];
    CGFloat rightM = [self marginForType:ZJWaterflowViewMarginRight];
    CGFloat columnM = [self marginForType:ZJWaterflowViewMarginColumn];
    CGFloat rowM = [self marginForType:ZJWaterflowViewMarginRow];
    
    //Cell的宽度
    CGFloat cellW = (self.width - leftM - rightM - (numberOfColumns - 1)*columnM)/numberOfColumns;
    
    //用一个C语言数组存放 所有列最大的Y数值
    CGFloat maxYOfColumns[numberOfColumns];
    
    for (int i=0; i<numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    for (int i=0; i<numberOfCells; i++) {
        
        //Cell处在最短的那一列
        NSUInteger cellColumn = 0;
        
        //Cell所处最短那一列的最大Y值
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        
        for (int j=1; j<numberOfColumns; j++) {
            if (maxYOfColumns[j]< maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
       CGFloat cellH = [self heightAtIndex:i];

        //cell的位置
        CGFloat cellX = leftM + cellColumn*(cellW + columnM);
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) {
            cellY = topM;
        }
        else{
            cellY = maxYOfCellColumn + rowM;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        //更新最短的那一列的Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
        ZJWaterflowViewCell *cell = [self.dataSource waterflowView:self cellAtIndex:i];
        cell.frame = cellFrame;
        [self addSubview:cell];
    }

    CGFloat contentH = maxYOfColumns[0];
    for (int i=1; i<numberOfColumns; i++) {
        if (contentH < maxYOfColumns[i]) {
            contentH = maxYOfColumns[i];
        }
    }
    
    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);

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

/**
 *  当UIScrollview滚动的时候也会调用此方法
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0; i<numberOfCells; i++) {
        // 取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        // 优先从字典中取出i位置的cell
        ZJWaterflowViewCell *cell = self.displayingCells[@(i)];
        
        // 判断i位置对应的frame在不在屏幕上（能否看见）
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                // 存放到字典中
                self.displayingCells[@(i)] = cell;
            }
        } else {  // 不在屏幕上
            if (cell) {
                // 从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 存放进缓存池(这一点不要忘记了，相当于从可视列表拿走到缓存池)
                [self.reusableCells addObject:cell];
            }
        }
    }

}

/**
 *  判断一个frame有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) &&
    (CGRectGetMinY(frame) < self.contentOffset.y + self.height);
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block ZJWaterflowViewCell *reusableCell = nil;
    
    [self.reusableCells enumerateObjectsUsingBlock:^(ZJWaterflowViewCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) { // 记得从缓存池中移除
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma mark - 事件处理
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectedAtIndex:)]) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, ZJWaterflowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectedAtIndex:selectIndex.unsignedIntegerValue];
    }
}

@end
