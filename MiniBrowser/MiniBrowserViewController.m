//
//  MiniBrowserViewController.m
//  MiniBrowser
//
//  Created by Alexey Boyko on 27.06.15.
//  Copyright (c) 2015 Alexey Boyko. All rights reserved.
//

#import "MiniBrowserViewController.h"

@interface MiniBrowserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation MiniBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_urlTextField addTarget:self
                      action:@selector(onButtonGo:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonGo:(id)sender {
    [_urlTextField resignFirstResponder];
    NSLog(@"Loading %@", _urlTextField.text);
    NSURL* url = [NSURL URLWithString:_urlTextField.text];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

@end
