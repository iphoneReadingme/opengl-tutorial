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
    { {1, -1, 0}, {1, 0, 0, 1} },
    { {1, 1, 0}, {0, 1, 0, 1} },
    { {-1, 1, 0}, {0, 0, 1, 1} },
    { {-1, -1, 0}, {0, 0, 0, 1} }
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface HGLViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (readonly, strong, nonatomic) GLKView *glView;

@property (assign) GLuint vertexBuffer;
@property (assign) GLuint indexBuffer;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property (assign) float rotation;

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
    _rotation += 90 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 0, 1);
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

@end
