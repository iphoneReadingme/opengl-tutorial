//
//  GLViewController.m
//  HelloGLKit
//
//  Created by Jesse Armand on 10/10/12.
//  Copyright (c) 2012 Jesse Armand. All rights reserved.
//

#import "HGLViewController.h"

@interface HGLViewController ()

@property (nonatomic, strong) EAGLContext *context;

@property (assign) BOOL shouldIncrease;
@property (assign) float redValue;

@property (readonly, nonatomic, strong) GLKView *glView;

@end

@implementation HGLViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.preferredFramesPerSecond = 60;
    }
    return self;
}

- (void)dealloc
{
    [self teardownGL];
    
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
}

- (void)loadView
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.view = [[GLKView alloc] initWithFrame:screenBounds context:self.context];
    
    [self setupGL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - GL Setup

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.glView.enableSetNeedsDisplay = NO;
}

- (void)teardownGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (GLKView *)glView
{
    return (GLKView *)self.view;
}

#pragma mark - GLKViewDelegate

- (void)update
{
    [self.glView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (self.shouldIncrease)
        self.redValue += 1.0 * self.timeSinceLastUpdate;
    else
        self.redValue -= 1.0 * self.timeSinceLastUpdate;
    
    if (self.redValue >= 1.0) {
        self.redValue = 1.0;
        self.shouldIncrease = NO;
    }
    
    if (self.redValue <= 0.0) {
        self.redValue = 0.0;
        self.shouldIncrease = YES;
    }    
    
    glClearColor(self.redValue, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
