//
//  MiniBrowserViewController.m
//  MiniBrowser
//
//  Created by Alexey Boyko on 27.06.15.
//  Copyright (c) 2015 Alexey Boyko. All rights reserved.
//

#import "MiniBrowserViewController.h"
@import WebKit;

@interface MiniBrowserViewController ()
{
    WKWebView* _webView;
}

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation MiniBrowserViewController

static NSString * const estimatedProgressKey = @"estimatedProgress";

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_urlTextField addTarget:self
                      action:@selector(onButtonGo:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
    [self configureWebView];
    [_progressView setProgress:0.0f animated:NO];
    [_progressView setAlpha:0.0f];
}

- (void)configureWebView {
    [_webViewContainer addSubview:_webView];
    [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraintWithAttribute:NSLayoutAttributeWidth];
    [self addConstraintWithAttribute:NSLayoutAttributeHeight];
    [self addConstraintWithAttribute:NSLayoutAttributeCenterX];
    [self addConstraintWithAttribute:NSLayoutAttributeCenterY];
    [_webView addObserver:self
               forKeyPath:estimatedProgressKey
                  options:NSKeyValueObservingOptionNew
                  context:nil];
}

- (void)addConstraintWithAttribute:(NSLayoutAttribute)attr {
    NSLayoutConstraint* constraint =
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:attr
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_webViewContainer
                                     attribute:attr
                                    multiplier:1.0f
                                      constant:0];
    [_webViewContainer addConstraint:constraint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:estimatedProgressKey];
}

- (IBAction)onButtonGo:(id)sender {
    [_urlTextField resignFirstResponder];
    NSString* urlString = [self getURLString];
    NSLog(@"Loading %@", urlString);
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (NSString*)getURLString {
    NSString* schemaSign = @"://";
    NSString* url = _urlTextField.text;
    if ([url containsString:schemaSign])
        return url;
    return [NSString stringWithFormat:@"http://%@", url];
}

#pragma mark - WKWebView observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (![keyPath isEqualToString:estimatedProgressKey] || object != _webView) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    [_progressView setAlpha:1.0f];
    [_progressView setProgress:_webView.estimatedProgress animated:YES];
    if (_webView.estimatedProgress >= 1.0f) {
        [UIView animateWithDuration:0.3
                              delay:0.3
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{[_progressView setAlpha:0.0f];}
                         completion:^(BOOL finished){[_progressView setProgress:0.0f animated:NO];}];
    }
}

@end
