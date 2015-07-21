//
//  ZJShopCell.m
//  ZJWaterFlow
//
//  Created by jyd on 15/7/20.
//  Copyright (c) 2015年 jyd. All rights reserved.
//

#import "ZJShopCell.h"
#import "ZJWaterflowView.h"
#import "ZJShop.h"
#import "UIImageView+WebCache.h"

@interface ZJShopCell()

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UILabel *priceLabel;


@end

@implementation ZJShopCell

+ (instancetype)cellWithWaterflowView:(ZJWaterflowView *)waterflowView
{
    static NSString *ID = @"SHOP";
    ZJShopCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[ZJShopCell alloc] init];
        cell.identifier = ID;
    }
    return cell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor whiteColor];
        [self addSubview:priceLabel];
        self.priceLabel = priceLabel;
    }
    return self;
}

- (void)setShop:(ZJShop *)shop
{
    _shop = shop;
    
    self.priceLabel.text = shop.price;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
    CGFloat priceX = 0;
    CGFloat priceH = 25;
    CGFloat priceY = self.bounds.size.height - priceH;
    CGFloat priceW = self.bounds.size.width;
    self.priceLabel.frame = CGRectMake(priceX, priceY, priceW, priceH);
}


@end
