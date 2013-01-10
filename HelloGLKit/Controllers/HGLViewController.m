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
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    // Front
    {{1, -1, 1}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, 1}, {0, 1, 0, 1}, {1, 1}},
    {{-1, 1, 1}, {0, 0, 1, 1}, {0, 1}},
    {{-1, -1, 1}, {0, 0, 0, 1}, {0, 0}},
    // Back
    {{1, 1, -1}, {1, 0, 0, 1}, {0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}, {1, 0}},
    {{1, -1, -1}, {0, 0, 1, 1}, {0, 0}},
    {{-1, 1, -1}, {0, 0, 0, 1}, {1, 1}},
    // Left
    {{-1, -1, 1}, {1, 0, 0, 1}, {1, 0}},
    {{-1, 1, 1}, {0, 1, 0, 1}, {1, 1}},
    {{-1, 1, -1}, {0, 0, 1, 1}, {0, 1}},
    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}},
    // Right
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, -1}, {0, 1, 0, 1}, {1, 1}},
    {{1, 1, 1}, {0, 0, 1, 1}, {0, 1}},
    {{1, -1, 1}, {0, 0, 0, 1}, {0, 0}},
    // Top
    {{1, 1, 1}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, -1}, {0, 1, 0, 1}, {1, 1}},
    {{-1, 1, -1}, {0, 0, 1, 1}, {0, 1}},
    {{-1, 1, 1}, {0, 0, 0, 1}, {0, 0}},
    // Bottom
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
    {{1, -1, 1}, {0, 1, 0, 1}, {1, 1}},
    {{-1, -1, 1}, {0, 0, 1, 1}, {0, 1}},
    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

@interface HGLViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (readonly, strong, nonatomic) GLKView *glView;

@property (assign) GLuint vertexBuffer;
@property (assign) GLuint indexBuffer;

@property (assign) GLuint vertexArray;

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
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
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
    
    glEnable(GL_CULL_FACE);
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft : @(YES) };
    
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tile_floor" ofType:@"png"];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (error != nil)
        NSLog(@"Error loading texture %@", error);
    self.effect.texture2d0.name = info.name;
    self.effect.texture2d0.enabled = true;
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Color));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, TexCoord));
    
    glBindVertexArrayOES(0);
    
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
    glClearColor(1.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
 
    [self.effect prepareToDraw];
    
    glBindVertexArrayOES(_vertexArray);    
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
