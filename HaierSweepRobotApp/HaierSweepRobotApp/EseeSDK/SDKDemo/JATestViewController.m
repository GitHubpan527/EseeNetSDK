//
//  JATestViewController.m
//  EseeNetSDK
//
//  Created by Wynton on 2016/11/16.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "JATestViewController.h"
#import "EseeNetLive.h"

@interface JATestViewController ()

@end

@implementation JATestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    EseeNetLive *live = [[EseeNetLive alloc] initEseeNetLiveVideoWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.width)];
    [live setDeviceInfoWithDeviceID:@"762214618" Passwords:@"" UserName:@"admin" Channel:1 Port:0];
    [live connectWithPlay:YES BitRate:1 Completion:^(EseeNetState result) {
        
    }];
    [self.view addSubview:live];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
