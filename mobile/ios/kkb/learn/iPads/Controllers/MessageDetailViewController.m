//
//  MessageDetailViewController.m
//  learn
//
//  Created by User on 14-1-8.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "AppUtilities.h"
#import "DiscussionTopicStructs.h"
#import "UIImageView+WebCache.h"
@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController

@synthesize discussionTopic;
@synthesize webView, timeTitle;
@synthesize announcementTitle, avatarImage, user_name;
@synthesize fileView, fileLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.announcementTitle.text = discussionTopic.title;
    self.user_name.text = discussionTopic.user_name;
    //    self.messageTitle.text = [ToolsObject cleanHtml:(NSMutableString
    //    *)discussionTopicItem.message];

    [webView loadHTMLString:discussionTopic.message baseURL:nil];
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:discussionTopic.author
                                                             .avatar_image_url]
                   placeholderImage:[UIImage imageNamed:@"avatar_default"]];

    timeTitle.text = [AppUtilities convertTimeStyleGo:discussionTopic.posted_at];

    if ([self.discussionTopic.attachments count] > 0) {
        fileView.hidden = NO;
        DiscussionTopicAttachmentsItem *attachmentsItem =
            [self.discussionTopic.attachments objectAtIndex:0];
        fileLabel.text = attachmentsItem.filename;

    } else {
        fileView.hidden = YES;
        [self.webView setFrame:CGRectMake(20, 116, 725, 504)];
    }
}
- (IBAction)fileButtonOnClick {
    if ([self.discussionTopic.attachments count] > 0) {
        DiscussionTopicAttachmentsItem *attachmentsItem =
            [self.discussionTopic.attachments objectAtIndex:0];

        NSURL *url = [[NSURL alloc] initWithString:attachmentsItem.url];
        [[UIApplication sharedApplication] openURL:url];
    }

    //    UIDocumentInteractionController *documentController =
    //    [UIDocumentInteractionController
    //     interactionControllerWithURL:[NSURL
    //     URLWithString:attachmentsItem.url]];
    ////    documentController.delegate = self;
    //    [documentController retain];
    //    documentController.UTI = attachmentsItem.filename;
    //    [documentController presentOpenInMenuFromRect:CGRectZero
    //                                           inView:self.view
    //                                         animated:YES];
}

- (IBAction)goback {
    [self dismissViewControllerAnimated:NO completion:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
