//
//  WQAlertView.h
//  SRBApp
//
//  Created by fengwanqi on 16/1/20.
//  Copyright © 2016年 BJshurenbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WQAlertView : NSObject<UIAlertViewDelegate>
-(void)showAlertWithCurrentViewController:(UIViewController *)currentVC Title:(NSString *)title Message:(NSString *)message ConfirmName:(NSString *)confirmName CancelName:(NSString *)cancelName ConfirmBlock:(void(^)(void))confirm CancelBlock:(void(^)(void))cancel;
@end
