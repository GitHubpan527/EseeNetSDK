//
//  BaseInfoViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseInfoViewController.h"

#import "BaseInfoOneCell.h"
#import "BaseInfoTwoCell.h"

#pragma mark - 账户安全
#import "AccountViewController.h"

#pragma mark - 修改姓名
#import "ModifyNameViewController.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

@interface BaseInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *baseInfoTB;
@property (strong, nonatomic) IBOutlet UIView *sexPickerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;


@end

@implementation BaseInfoViewController

{
    UIButton *iconBtn;
    NSString *iconStr;
    NSMutableArray *infoArray;
    NSArray *sexArray;
    NSArray *sexStr;
    NSString *realName;

    NSInteger sexIndex;

    
    NSString *iconLabel;
    NSArray  *baseArray;
    NSString *cancel;
    NSString *sure;
    NSString *man;
    NSString *woman;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#pragma mark - 用户信息
    [self requestInfoData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"basicInformation", nil);

#pragma mark  - 性别
    
    iconLabel = CustomLocalizedString(@"Icon", nil);
    baseArray = @[CustomLocalizedString(@"Name", nil),CustomLocalizedString(@"Sex", nil),CustomLocalizedString(@"Cellphone", nil),CustomLocalizedString(@"AccountSecurity", nil)];
    sexArray = @[CustomLocalizedString(@"man", nil),CustomLocalizedString(@"woman", nil)];
    cancel = CustomLocalizedString(@"cancel", nil);
    sure = CustomLocalizedString(@"sure", nil);
    woman = CustomLocalizedString(@"woman", nil);
    man = CustomLocalizedString(@"man", nil);
    
    /*
    if (HLLanguageIsEN) {
        iconLabel = CustomLocalizedString(@"Icon", nil);
        baseArray = @[CustomLocalizedString(@"Name", nil),CustomLocalizedString(@"Sex", nil),CustomLocalizedString(@"Cellphone", nil),CustomLocalizedString(@"AccountSecurity", nil)];
        sexArray = @[CustomLocalizedString(@"man", nil),CustomLocalizedString(@"woman", nil)];
        cancel = CustomLocalizedString(@"cancel", nil);
        sure = CustomLocalizedString(@"sure", nil);
        woman = CustomLocalizedString(@"woman", nil);
        man = CustomLocalizedString(@"man", nil);
        
    } else {
        iconLabel = @"头像";
        baseArray = @[@"昵称",@"性别",@"手机号",@"账户安全"];
        sexArray = @[@"男",@"女"];
        cancel = @"取消";
        sure = @"确认";
        woman = @"女";
        man = @"男";
    }
    */
    
    sexStr = sexArray[0];
    sexIndex = 1;
    self.sexPickerView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    [self.navigationController.view addSubview:self.sexPickerView];
    
    [self.cancelBtn setTitle:cancel forState:UIControlStateNormal];
    [self.sureBtn setTitle:sure forState:UIControlStateNormal];
   
}

- (void)requestInfoData
{
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"id":userModel.id};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserFrontDetail parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            
            
            infoArray = [NSMutableArray array];
            if (![successObject[@"object"][@"realName"] isKindOfClass:[NSNull class]]) {
                realName = successObject[@"object"][@"realName"];
                [infoArray addObject:realName];
                //保存姓名
                [JPUserDefaults jp_setObject:realName forKey:@"RealNameKey"];
            } else {
                [infoArray addObject:@""];
            }
            if (![successObject[@"object"][@"sex"] isKindOfClass:[NSNull class]]) {
                if ([successObject[@"object"][@"sex"] integerValue] == 1) {
                    [infoArray addObject:man];
                } else {
                    [infoArray addObject:woman];
                }
            } else {
                [infoArray addObject:@""];
            }
            if (![successObject[@"object"][@"telephone"] isKindOfClass:[NSNull class]]) {
                [infoArray addObject:successObject[@"object"][@"telephone"]];
            } else {
                [infoArray addObject:@""];
            }
            //保存头像
            iconStr = successObject[@"object"][@"headUrl"];
            [JPUserDefaults jp_setObject:iconStr forKey:@"HeadUrlKey"];
            [self.baseInfoTB reloadData];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIde = @"cell1";
        BaseInfoOneCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"BaseInfoOneCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.iconLabel.text = iconLabel;
        
        iconBtn = (UIButton *)[cell viewWithTag:10];
        [iconBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:iconStr] forState:UIControlStateNormal placeholderImage:LCImage(@"默认头像")];
        [iconBtn lc_block:^(id sender) {
            
            //CustomLocalizedString(@"FromTheSelectionOfPhotoAlbum", nil)
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:CustomLocalizedString(@"camera", nil), CustomLocalizedString(@"FromTheSelectionOfPhotoAlbum", nil),nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
            /*
            if (HLLanguageIsEN) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"camera", @"FromTheSelectionOfPhotoAlbum",nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [actionSheet showInView:self.view];
            } else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机", @"从相册选取",nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [actionSheet showInView:self.view];
            }
             */
        }];
        
        return cell;
    } else {
        static NSString *cellIde = @"cell2";
        BaseInfoTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"BaseInfoTwoCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        UILabel *leftL = (UILabel *)[cell viewWithTag:10];
        leftL.text = baseArray[indexPath.row-1];
        
        UILabel *centerL = (UILabel *)[cell viewWithTag:20];
        if (indexPath.row >0 && indexPath.row < 4 && infoArray.count != 0) {
            centerL.text = infoArray[indexPath.row-1];
        }
        
        UIImageView *arrowImageV = (UIImageView *)[cell viewWithTag:30];
        if (indexPath.row == 3) {
            arrowImageV.hidden = YES;
            cell.rightConstraint.constant = 15;
        }

        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:CustomLocalizedString(@"camera", nil), CustomLocalizedString(@"FromTheSelectionOfPhotoAlbum", nil),nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
            /*
            if (HLLanguageIsEN) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"camera", @"FromTheSelectionOfPhotoAlbum",nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [actionSheet showInView:self.view];
            } else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机", @"从相册选取",nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [actionSheet showInView:self.view];
            }
             */
        }
            break;
        case 1:
        {
            ModifyNameViewController *vc = [[ModifyNameViewController alloc] init];
            vc.realName = realName;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 2:
        {
            [self pickerViewUp];
        }
            break;
            
//        case 4:AccountSec
//        {
//            EmailViewController *vc = [[EmailViewController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
            
        case 4:
        {
            AccountViewController *vc = [[AccountViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


/** UIActionSheetDelegate */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self cameraImage];
    }else if (buttonIndex == 1) {
        [self pickImage];
    }
}

- (void)cameraImage {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;//设置UIImagePickerController的代理，同时要遵循UIImagePickerControllerDelegate，UINavigationControllerDelegate协议
        picker.allowsEditing = NO;//设置拍照之后图片是否可编辑，如果设置成可编辑的话会在代理方法返回的字典里面多一些键值。PS：如果在调用相机的时候允许照片可编辑，那么用户能编辑的照片的位置并不包括边角。
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;//UIImagePicker选择器的类型，UIImagePickerControllerSourceTypeCamera调用系统相机
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        //如果当前设备没有摄像头
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"哎呀，当前设备没有摄像头。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)pickImage {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = NO;//是否可以对原图进行编辑
        
        //打开相册选择照片
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片库不可用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *uploadImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self uploadHeadWithImage:uploadImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 上传头像
- (void)uploadHeadWithImage:(UIImage *)image
{
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"userId":userModel.id};
    [[RequestManager shareRequestManager] uploadImagesWithDic:requestDic shortURL:UploadUserHead imagesArray:@[image] imageName:@"hand" successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self mb_show:@"上传成功"];
            [iconBtn setBackgroundImage:image forState:UIControlStateNormal];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

#pragma mark - picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return sexArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return sexArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"%@",sexArray[row]);
    sexStr = sexArray[row];
    sexIndex = row+1;
}

- (void)pickerViewUp
{
    [UIView animateWithDuration:0.3 animations:^{
        self.sexPickerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }];
}

- (void)pickerViewDown
{
    [UIView animateWithDuration:0.3 animations:^{
        self.sexPickerView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
}

- (IBAction)cancelAction:(id)sender {
    [self pickerViewDown];
}

- (IBAction)sureAction:(id)sender {
    [self pickerViewDown];
    [self modifySexRequest];
}

- (void)modifySexRequest
{
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"id":userModel.id,
                                 @"sex":LCStrValue(sexIndex)};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserFrontUpdate parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self requestInfoData];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
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
