//
//  YMsgBox.h
//  YMsgBox
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 YuanHongQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import "UIViewExt.h"
#import "YTargetAndAction.h"
#import "YFonc.h"
typedef NS_ENUM(NSInteger,YMsgBoxMsgType){
    YMsgBoxMsgTypeButtonBeClick
};
@interface YMsgBox : UIViewController<UITextFieldDelegate>
@property(nonatomic,assign)NSInteger theTag;
@property(nonatomic,copy,nullable)NSString* theTagString;
@property(nonatomic,strong,nullable)NSMutableDictionary<NSString*,id>* theTagUserInfo;
@property(nonatomic,assign)CGFloat yMsgWidth;//弹窗宽度,默认为275像素
@property(nonatomic,assign)CGFloat yMsgMinHeight;//弹窗的最小高度,默认为140
@property(nonatomic,strong,nullable)UIColor* yMsgBackgroundColor;//弹窗的背景,默认为半透明黑色
@property(nonatomic,assign)BOOL yMsgShowAeroGlass;//显示Aero特效,默认为不显示
@property(nonatomic,strong,nullable)UIFont* yMsgInputFont;//输入框的字体,默认13号
@property(nonatomic,strong,nullable)UITextField* yMsgTextField;//输入框,把输入框的地址暴露出来是为了让外部监控这个输入框,注意,一旦它的delegate被替换之后,消息窗自身将无法再监听之

@property(nonatomic,strong,nullable)UIColor* yMsgButtonBorderColor;//按钮边线的颜色,默认无
@property(nonatomic,strong,nullable)UIColor* yMsgTextFieldBorderColor;//输入框边线的颜色,默认无
@property(nonatomic,strong,nullable)UIColor* yMsgTextFieldBottomLineColor;//输入框底线的颜色,默认为 154,162,193

@property(nonatomic,copy,nullable)NSAttributedString* yMsgTitle;//弹窗的标题
@property(nonatomic,copy,nullable)NSAttributedString* yMsgText;//弹窗的正文内容
@property(nonatomic,copy,nullable)NSString* yMsgInputText;//输入框的文本
@property(nonatomic,copy,nullable)NSString* yMsgInputPlaceholder;//输入框的提示语
@property(nonatomic,copy,nullable)NSArray<UIButton*>* yMsgButtons;
/**-1表示单击了背景,-2表示单击了键盘的return键,其它按钮索引从0开始*/
@property(nonatomic,assign,readonly)NSInteger yMsgButtonIndex;

-(void)showMsgBoxInViewController:(nullable UIViewController*)vc;//显示弹窗
-(void)showMsgBox;//显示弹窗
-(void)hideMsgBox;//销毁弹窗
-(void)hideKeyBoard;//隐藏键盘
-(void)addTarget:(nullable id)target withAction:(nullable SEL)action forEvent:(YMsgBoxMsgType)type;//添加事件回调
@end
