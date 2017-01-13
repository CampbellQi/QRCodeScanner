//
//  WQScanRectDrawView.m
//  QRCodeScanner
//
//  Created by 冯万琦 on 2017/1/12.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "WQScanRectDrawView.h"

@implementation WQScanRectDrawView
{
    CGRect _drawRect;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (id)initWithFrame:(CGRect)frame DrawRect:(CGRect)drawRect {
    if (self = [super initWithFrame:frame]) {
        _drawRect = drawRect;
        //从相册选择按钮
        UIButton  *pickImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pickImageButton setFrame:CGRectMake(0, 0, drawRect.size.width, 30)];
        [pickImageButton setCenter:CGPointMake(CGRectGetMinX(frame)+CGRectGetWidth(frame)/2, CGRectGetMaxY(frame) - 30)];
        [pickImageButton setTitle:@"从 相 册 选" forState:UIControlStateNormal];
        [pickImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pickImageButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [pickImageButton setBackgroundColor:[UIColor whiteColor]];
        [pickImageButton addTarget:self action:@selector(pickImageFromPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
        pickImageButton.layer.cornerRadius = 8.0f;
        [self addSubview:pickImageButton];
    }
    return self;
}

- (void)pickImageFromPhotoLibrary {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickImageFromPhotoLibrary)]) {
        [self.delegate pickImageFromPhotoLibrary];
    }
}

- (void)drawRect:(CGRect)rect {
    //计算位置大小
    float x = _drawRect.origin.x;//左边距
    float y = _drawRect.origin.y;//左边距
    float maxX = _drawRect.origin.x + _drawRect.size.width;
    float maxY = _drawRect.origin.y + _drawRect.size.height;
    float length = _drawRect.size.width * 0.1;//角长
//    float heightMin = 0.25;//最小比例
//    float heightMax = 0.75;//最大比例
//    float height = self.frame.size.height;
//    float width = self.frame.size.width;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(ctx, 1);
    
        CGContextAddRect(ctx, _drawRect);

          CGContextStrokePath(ctx);
    
    int lineWidth = 4;
    int halfLine = lineWidth/2;
    //设置粗狂颜色
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    
    //左上角水平线
    CGContextMoveToPoint(ctx, x - halfLine, y );
    CGContextAddLineToPoint(ctx, x + length, y);
    //左上角垂直线
    CGContextMoveToPoint(ctx, x, y - halfLine );
    CGContextAddLineToPoint(ctx, x, y + length);
    //左下角水平线
    CGContextMoveToPoint(ctx, x - halfLine, maxY);
    CGContextAddLineToPoint(ctx, x + length, maxY);
    //左下角垂直线
    CGContextMoveToPoint(ctx, x, maxY + halfLine);
    CGContextAddLineToPoint(ctx, x, maxY - length);
    //右上角水平线
    CGContextMoveToPoint(ctx, maxX + halfLine, y);
    CGContextAddLineToPoint(ctx, maxX - length, y);
    //右上角垂直线
    CGContextMoveToPoint(ctx, maxX, y - halfLine);
    CGContextAddLineToPoint(ctx, maxX, y + length);
    //右下角水平线
    CGContextMoveToPoint(ctx, maxX + halfLine, maxY);
    CGContextAddLineToPoint(ctx, maxX - length, maxY);
    //右下角垂直线
    CGContextMoveToPoint(ctx, maxX, maxY + halfLine);
    CGContextAddLineToPoint(ctx,maxX, maxY - length);
    CGContextStrokePath(ctx);

    
}


@end
