//
//  MiniBrowserViewController.m
//  MiniBrowser
//
//  Created by Alexey Boyko on 27.06.15.
//  Copyright (c) 2015 Alexey Boyko. All rights reserved.
//

#import "MiniBrowserViewController.h"
@import WebKit;

@interface MiniBrowserViewController () <WKUIDelegate, UITextFieldDelegate>
{
    WKWebView* _webView;
    BOOL _urlTextFieldActive;
}

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonZeroWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forwardButtonZeroWidth;

@end

@implementation MiniBrowserViewController

static NSString * const estimatedProgressKey = @"estimatedProgress";
static UILayoutPriority priorityHigh = 900;
static UILayoutPriority priorityLow = 1;
static NSTimeInterval animationDuration = 0.3;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _urlTextFieldActive = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _urlTextField.delegate = self;
    [_urlTextField addTarget:self
                      action:@selector(onButtonGo:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
    [_backButton addTarget:_webView
                    action:@selector(goBack)
          forControlEvents:UIControlEventTouchDown];
    [_forwardButton addTarget:_webView
                       action:@selector(goForward)
             forControlEvents:UIControlEventTouchDown];
    [self configureWebView];
    [_progressView setProgress:0.0f animated:NO];
    [_progressView setAlpha:0.0f];
    _backButton.enabled = NO;
    _backButtonZeroWidth.priority = priorityHigh;
    _forwardButton.enabled = NO;
    _forwardButtonZeroWidth.priority = priorityHigh;
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
    _webView.UIDelegate = self;
//    _webView.scrollView.delegate = self;
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

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:estimatedProgressKey];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _urlTextFieldActive = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    _urlTextFieldActive = NO;
    return YES;
}

#pragma mark - UITextField observing

- (IBAction)onButtonGo:(id)sender {
    [_urlTextField resignFirstResponder];
    NSString* urlString = [self getURLString];
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
    if ([keyPath isEqualToString:estimatedProgressKey] && object == _webView) {
        [_progressView setAlpha:1.0f];
        [_progressView setProgress:_webView.estimatedProgress animated:YES];
        if (_webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:animationDuration
                                  delay:animationDuration
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[_progressView setAlpha:0.0f];}
                             completion:^(BOOL finished){[_progressView setProgress:0.0f animated:NO];}];
        }
        if (!_urlTextFieldActive)
            _urlTextField.text = _webView.URL.absoluteString;
        [self.view layoutIfNeeded];
        if (_webView.canGoBack) {
            _backButton.enabled = YES;
            _backButtonZeroWidth.priority = priorityLow;
        } else {
            _backButton.enabled = NO;
            _backButtonZeroWidth.priority = priorityHigh;
        }
        if (_webView.canGoForward) {
            _forwardButton.enabled = YES;
            _forwardButtonZeroWidth.priority = priorityLow;
        } else {
            _forwardButton.enabled = NO;
            _forwardButtonZeroWidth.priority = priorityHigh;
        }
        [UIView animateWithDuration:animationDuration animations:^{[self.view layoutIfNeeded];}];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
}

#pragma mark - WKWebView UI delegate

- (WKWebView*)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame)
        [webView loadRequest:navigationAction.request];
    return nil;
}

@end
