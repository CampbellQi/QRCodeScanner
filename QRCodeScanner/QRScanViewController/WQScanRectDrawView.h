//
//  WQScanRectDrawView.h
//  QRCodeScanner
//  扫描矩形区域框
//  Created by 冯万琦 on 2017/1/12.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WQScanRectDrawViewDelegate <NSObject>
//相册选择调用方法
-(void)pickImageFromPhotoLibrary;
@end
@interface WQScanRectDrawView : UIView

@property (nonatomic, assign) id<WQScanRectDrawViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame DrawRect:(CGRect)drawRect;
@end
