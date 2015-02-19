//
//  RAPLinkViewController.m
//  redditAPI
//
//  Created by Woudini on 2/18/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPLinkViewController.h"

@interface RAPLinkViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation RAPLinkViewController

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self.webView loadData:[NSData dataWithContentsOfURL:location] MIMEType:downloadTask.response.MIMEType textEncodingName:downloadTask.response.textEncodingName baseURL:downloadTask.response.URL];
}

-(void)loadWebpage
{
    NSURL *url = [NSURL URLWithString:self.URLstring];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadWebpage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
