//
//  ZJShopCell.h
//  ZJWaterFlow
//
//  Created by jyd on 15/7/20.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import "ZJWaterflowViewCell.h"

@class ZJShop,ZJWaterflowView;

@interface ZJShopCell : ZJWaterflowViewCell

+(instancetype)cellWithWaterflowView:(ZJWaterflowView *)waterflowView;

@property (strong, nonatomic) ZJShop *shop;

@end
