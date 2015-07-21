//
//  ZJWaterflowView.m
//  ZJWaterFlow
//
//  Created by jyd on 15/7/19.
//  Copyright (c) 2015年 jyd. All rights reserved.


/**
 重用实现分析
 　　查看UITableView头文件，会找到NSMutableArray*  visiableCells，和NSMutableDictnery* reusableTableCells两个结构。visiableCells内保存当前显示的cells，reusableTableCells保存可重用的cells。
 
 　　TableView显示之初，reusableTableCells为空，那么tableView dequeueReusableCellWithIdentifier:CellIdentifier返回nil。开始的cell都是通过[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]来创建，而且cellForRowAtIndexPath只是调用最大显示cell数的次数。
 
 　　比如：有100条数据，iPhone一屏最多显示10个cell。程序最开始显示TableView的情况是：
 　　1. 用[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]创建10次cell，并给cell指定同样的重用标识(当然，可以为不同显示类型的cell指定不同的标识)。并且10个cell全部都加入到visiableCells数组，reusableTableCells为空。
 　　2. 向下拖动tableView，当cell1完全移出屏幕，并且cell11(它也是alloc出来的，原因同上)完全显示出来的时候。cell11加入到visiableCells，cell1移出visiableCells，cell1加入到reusableTableCells。
 　　3. 接着向下拖动tableView，因为reusableTableCells中已经有值，所以，当需要显示新的cell，cellForRowAtIndexPath再次被调用的时候，tableView dequeueReusableCellWithIdentifier:CellIdentifier，返回cell1。cell1加入到visiableCells，cell1移出reusableTableCells；cell2移出visiableCells，cell2加入到reusableTableCells。之后再需要显示的Cell就可以正常重用了。
 　　所以整个过程并不难理解，但需要注意正是因为这样的原因：配置Cell的时候一定要注意，对取出的重用的cell做重新赋值，不要遗留老数据。

 */

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
@property (nonatomic, strong) NSMutableDictionary *displayingVisiableCells;
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

- (NSMutableDictionary *)displayingVisiableCells
{
    if (_displayingVisiableCells == nil) {
        self.displayingVisiableCells = [NSMutableDictionary dictionary];
    }
    return _displayingVisiableCells;
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
    /**
     　使用过程中，我注意到，并不是只有拖动超出屏幕的时候才会更新reusableTableCells表，还有：
     　　1. reloadData，这种情况比较特殊。一般是部分数据发生变化，需要重新刷新cell显示的内容时调用。在cellForRowAtIndexPath调用中，所有cell都是重用的。我估计reloadData调用后，把visiableCells中所有cell移入reusableTableCells，visiableCells清空。cellForRowAtIndexPath调用后，再把reuse的cell从reusableTableCells取出来，放入到visiableCells。
     　　2. reloadRowsAtIndex，刷新指定的IndexPath。如果调用时reusableTableCells为空，那么cellForRowAtIndexPath调用后，是新创建cell，新的cell加入到visiableCells。老的cell移出visiableCells，加入到reusableTableCells。于是，之后的刷新就有cell做reuse了。
     */
    // 清空之前的所有数据
    // 移除正在正在显示cell
    [self.displayingVisiableCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingVisiableCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    //Cell总数
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
    
    //Cell总共的列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    
    // 间距
    CGFloat topM = [self marginForType:ZJWaterflowViewMarginTop];
    CGFloat bottomM = [self marginForType:ZJWaterflowViewMarginBottom];
    CGFloat leftM = [self marginForType:ZJWaterflowViewMarginLeft];
    CGFloat rightM = [self marginForType:ZJWaterflowViewMarginRight];
    CGFloat columnM = [self marginForType:ZJWaterflowViewMarginColumn];
    CGFloat rowM = [self marginForType:ZJWaterflowViewMarginRow];
    
    //Cell的宽度(瀑布流中所有的cell宽度都一样)
    CGFloat cellW = (self.width - leftM - rightM - (numberOfColumns - 1)*columnM)/numberOfColumns;
    
    //用一个C语言数组存放Cell所有列最大的Y的数值
    CGFloat maxYOfColumns[numberOfColumns];
    
    for (int i=0; i<numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    for (int i=0; i<numberOfCells; i++) {
        
        //Cell处在最短的那一列 默认第0列
        NSUInteger cellColumn = 0;
        
        //Cell所处最短那一列的最大Y值 默认第0列
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
        
        //ZJWaterflowViewCell *cell = [self.dataSource waterflowView:self cellAtIndex:i];
        //cell.frame = cellFrame;
        //[self addSubview:cell];
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
        ZJWaterflowViewCell *cell = self.displayingVisiableCells[@(i)];
        
        // 判断i位置对应的frame在不在屏幕上（能否看见）
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                // 存放到字典中
                self.displayingVisiableCells[@(i)] = cell;
            }
        } else {  // 不在屏幕上
            if (cell) {
                // 从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingVisiableCells removeObjectForKey:@(i)];
                
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
    [self.displayingVisiableCells enumerateKeysAndObjectsUsingBlock:^(id key, ZJWaterflowViewCell *cell, BOOL *stop) {
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
