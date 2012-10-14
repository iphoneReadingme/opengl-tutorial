//
//  GLViewController.m
//  HelloGLKit
//
//  Created by Jesse Armand on 10/10/12.
//  Copyright (c) 2012 Jesse Armand. All rights reserved.
//

#import "HGLViewController.h"

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    { {1, -1, -1}, {1, 0, 0, 1} },
    { {1, 1, -1}, {0, 1, 0, 1} },
    { {-1, 1, -1}, {0, 0, 1, 1} },
    { {-1, -1, -1}, {0, 0, 0, 1} },
    { {1, -1, 1}, {1, 0, 0, 1} },
    { {1, 1, 1}, {0, 1, 0, 1} },
    { {-1, 1, 1}, {0, 0, 1, 1} },
    { {-1, -1, 1}, {0, 0, 0, 1} }
};

const GLubyte Indices[] = {
    // Back
    0, 1, 2,
    2, 3, 0,
    // Front
    4, 5, 6,
    6, 7, 4,
    // Right
    0, 1, 5,
    5, 4, 0,
    // Left
    3, 2, 6,
    6, 7, 3,
    // Top
    1, 2, 6,
    6, 5, 1,
    // Bottom
    0, 3, 7,
    7, 4, 0
};

@interface HGLViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (readonly, strong, nonatomic) GLKView *glView;

@property (assign) GLuint vertexBuffer;
@property (assign) GLuint indexBuffer;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property (assign) float rotation;
@property (assign) GLKMatrix4 rotationMatrix;

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
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    self.rotationMatrix = GLKMatrix4Identity;
}

- (void)teardownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    
    self.effect = nil;
}

- (GLKView *)glView
{
    return (GLKView *)self.view;
}

#pragma mark - GLKViewDelegate

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.f), aspect, 4.f, 10.f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.f, 0.f, -6.f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, _rotationMatrix);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.effect prepareToDraw];
    
    glClearColor(0.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Color));
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices) / sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGPoint lastLoc = [touch previousLocationInView:self.view];
    CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
    
    float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
    float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
    
    bool isInvertible;
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotationMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
    _rotationMatrix = GLKMatrix4Rotate(_rotationMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotationMatrix, &isInvertible), GLKVector3Make(0, 1, 0));
    _rotationMatrix = GLKMatrix4Rotate(_rotationMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
}

@end
