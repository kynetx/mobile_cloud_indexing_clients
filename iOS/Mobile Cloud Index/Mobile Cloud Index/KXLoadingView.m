//
//  KXLoadingView.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation KXLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView;
{
    [[self layer] setBorderWidth:1];
    [[self layer] setCornerRadius:9.0];
    [self setBackgroundColor:[UIColor grayColor]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    [spinner startAnimating];
    
    [self addSubview:spinner];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
