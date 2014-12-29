//
//  GigWebViewController.m
//  Ensemble
//
//  Created by Adam on 9/28/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "GigWebViewController.h"

@interface GigWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation GigWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	NSString *urlString = self.passedConcert.concertURI;
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:urlRequest];
	
	self.webView.delegate = self;
	[self.webView canGoBack];
	[self.webView canGoForward];
	
	if ([Reachable wifiNetworkIsUnreachable] && [Reachable internetNetworkIsUnreachable])
	{

		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(UIButton *)sender
{
	[self.webView goBack];
}
- (IBAction)onForward:(UIButton *)sender
{
	[self.webView goForward];
}

- (IBAction)onBackButtonPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES
							 completion:nil];
}

#pragma mark - UIWebViewDelegate 

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self.activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if ([error code] == -999)
	{
		NSLog(@"%@", [error localizedDescription]);
	}
	else
	{
		[[[UIAlertView alloc] initWithTitle:@"Error Loading Page"
									message:@"Make sure you are connected to the internet"
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
		NSLog(@"%@", [error localizedDescription]);
	}
	
}

@end
