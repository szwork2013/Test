//
//  IFlyViewController.m
//  learn
//
//  Created by 翟鹏程 on 14-7-18.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "IFlyViewController.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"

@interface IFlyViewController ()

@end

@implementation IFlyViewController

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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    _textTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
    _textTF.placeholder = @"语音结果";
    [self.view addSubview:_textTF];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 100)];
    _label.numberOfLines = 0;
    [self.view addSubview:_label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 200, 300, 50);
    [button setTitle:@"开始识别" forState:UIControlStateNormal];
    [button setTitle:@"开始识别" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(startListenning:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
    
    [_iflyRecognizerView setParameter: @"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflyRecognizerView setParameter: @"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    // | result_type   | 返回结果的数据格式，可设置为json，xml，plain，默认为json。
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //    [_iflyRecognizerView setParameter:@"asr_audio_path" value:nil];   当你再不需要保存音频时，请在必要的地方加上这行。

}

- (void)startListenning:(UIButton *)button{
    [_iflyRecognizerView start];
}
#pragma mark IFlyRecognizerViewDelegate
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    _label.text = [NSString stringWithFormat:@"%@",resultArray];
    NSLog(@"resultArray is %@",resultArray);
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
//    NSString *resultStr = Regex.Replace(result,@"[,.?;!，。？；！]","");
//    NSString *resultStr = string.Replace();
    _textTF.text = [NSString stringWithFormat:@"%@",result];
}

- (void)onError:(IFlySpeechError *)error{
    NSLog(@"errorCode:%d",[error errorCode]);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
