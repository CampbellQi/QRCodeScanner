//
//  WQAlertView.m
//  SRBApp
//
//  Created by fengwanqi on 16/1/20.
//  Copyright © 2016年 BJshurenbang. All rights reserved.
//

#import "WQAlertView.h"

typedef void (^ConfirmBlock) (void);
typedef void (^CancelBlock) (void);

@interface WQAlertView()
{
    ConfirmBlock _confirmBlock;
    CancelBlock _cancelBlock;
}
@end
@implementation WQAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    static WQAlertView *_shareAlertView = nil;
    dispatch_once(&onceToken, ^{
        if (_shareAlertView == nil) {
            _shareAlertView = [super allocWithZone:zone];
        }
    });
    return _shareAlertView;
}
-(void)showAlertWithCurrentViewController:(UIViewController *)currentVC Title:(NSString *)title Message:(NSString *)message ConfirmName:(NSString *)confirmName CancelName:(NSString *)cancelName ConfirmBlock:(void(^)(void))confirm CancelBlock:(void(^)(void))cancel{
    _confirmBlock = confirm;
    _cancelBlock = cancel;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelName otherButtonTitles:confirmName, nil];
        [alert show];
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (cancelName) {
            [alert addAction:[UIAlertAction actionWithTitle:cancelName style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
        }
        if (confirmName) {
            [alert addAction:[UIAlertAction actionWithTitle:confirmName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (_confirmBlock) {
                    _confirmBlock();
                }
            }]];
        }
        
        [currentVC presentViewController:alert animated:YES completion:nil];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (_confirmBlock) {
            _confirmBlock();
        }
    }
}
@end
