//
//  RAPLinkViewController.m
//  redditAPI
//
//  Created by Woudini on 2/18/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPLinkViewController.h"

@interface RAPTiltToScrollViewController()
-(void)adjustTableView;
@end

@interface RAPLinkViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL isInWebView;
@end

@implementation RAPLinkViewController

-(void)startSpinner
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor grayColor];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{

}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error loading page" message:@"Page could not be loaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self.webView loadData:[NSData dataWithContentsOfURL:location] MIMEType:downloadTask.response.MIMEType textEncodingName:downloadTask.response.textEncodingName baseURL:downloadTask.response.URL];
    [self.spinner stopAnimating];
}

-(void)loadWebpage
{
    [self startSpinner];
    NSURL *url = [NSURL URLWithString:self.URLstring];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInWebView = YES;
    [self adjustTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadWebpage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
