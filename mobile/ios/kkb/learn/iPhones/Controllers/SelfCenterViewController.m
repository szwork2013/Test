//
//  SelfCenterViewController.m
//  learn
//
//  Created by zxj on 14-7-23.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "SelfCenterViewController.h"
#import "CertificateCell.h"
#import "CourseCell.h"
#import "KKBHttpClient.h"
//#import "CourseInfoViewController.h"
#import "KKBUserInfo.h"
@interface SelfCenterViewController ()

@end

@implementation SelfCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.centerTableView setTableHeaderView:self.headView];
    [[KKBHttpClient shareInstance]requestCertificationFromCache:NO success:^(id result) {
        certificationArray = result;
        [self.centerTableView reloadData];
    } failure:^(id result) {
        NSLog(@"lose");
    }];
    
    [self.navigationController.navigationBar setHidden:NO];
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        return 0;
    }
    if (section == 1 || section == 2 || section == 3) {
        return certificationArray.count*2-1;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID2 = @"SOME_STUPID_ID2";
    // even rows will be invisible
    if (indexPath.row % 2 == 1)
    {
        UITableViewCell * cell2 = [tableView dequeueReusableCellWithIdentifier:CELL_ID2];
        
        if (cell2 == nil)
        {
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CELL_ID2];
            [cell2.contentView setAlpha:0];
            [cell2 setUserInteractionEnabled:NO]; // prevent selection and other stuff
        }
        return cell2;
    }
    
    if (indexPath.section ==1) {
        static NSString *identify = @"CertificateCell";
        CertificateCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"CertificateCell" owner:self options:nil]lastObject];
            [cell setBackgroundColor:[UIColor darkGrayColor]];
            NSDictionary *dic = [certificationArray objectAtIndex:indexPath.row];
            cell.courseNameLabel.text = [dic objectForKey:@"name"];
            cell.dateLabel.text = [dic objectForKey:@"getCertificateAt"];
//            NSString *imageUrl = [dic objectForKey:@"imageUrl"];
//            UIImage *image = [self getImageFromURL:imageUrl];
//            cell.courseImageView.image = image;
            if ([[dic objectForKey:@"type"]isEqualToString:@"InstructiveCourse"]) {
                cell.certTypeLabel.text = @"导学课证书";
            }
            else cell.certTypeLabel.text = @"微专业证书";
            

        } return cell;

    }
    if (indexPath.section ==2 ||indexPath.section ==3) {
        static NSString *identify = @"CourseCell";
        CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"CourseCell" owner:self options:nil]lastObject];
            [cell setBackgroundColor:[UIColor darkGrayColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        return cell;

    }return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 == 1){
        return 10;
    }
    else{
    return 100;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section !=0) {
       // return self.headerTitleView;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        [view setBackgroundColor:[UIColor clearColor]];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 120, 20)];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(270, 10, 40, 20)];
        [button setTitle:@"查看" forState:UIControlStateNormal];
        [view addSubview:label];
        [view addSubview:button];
        if (section ==1) {
        label.text = @"获得的证书";
        }else if (section ==2){
            label.text = @"学习的导学课";
        }else if (section == 3){
            label.text = @"观看的公开课";
        }
        
        return view;
    }
    return nil;

    
}
-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section ==1 || section ==2 || section == 3) {
        return 40;
    }

    return 0;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    CourseInfoViewController * controller = [[CourseInfoViewController alloc]initWithNibName:@"CourseInfoViewController" bundle:nil];
    NSDictionary *dic = [certificationArray objectAtIndex:indexPath.row];
    controller.courseId = [dic objectForKey:@"courseId"];
    
    [self.navigationController pushViewController:controller animated:YES];
     */
}


#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed{
    return YES;
}

@end
