//
//  MyInfoSetPhoneVC.h
//  ProjectPublic
//
//  Created by ac-hu on 2018/8/6.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "ARModelVC.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "xionglaifeng.h"
#import "xionglaifeng1.h"
#import "xionglaifeng2.h"
#import "xionglaifeng3.h"
#import "xionglaifeng4.h"
#import "xionglaifeng5.h"

#define ISPX (ScreenHeight == 812.0f ? YES : NO)
#define ScreenHeight [UIScreen mainScreen].bounds.size.height//屏幕高

@interface ARModelVC ()
{
    int index;
    
}
@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong)NSMutableArray *bufferArr;
@property (nonatomic , assign)int numVerts;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;//纹理

//@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *xxVertexPositionBuffer;
//@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *xxVertexNormalBuffer;
//@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *xxVertexTextureCoordBuffer;
//
//@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *oneVertexPositionBuffer;
//@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *oneVertexNormalBuffer;
//@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *oneVertexTextureCoordBuffer;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *xxTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *oneTextureInfo;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;

@property(nonatomic,strong)NSTimer *timer;

@property(nonatomic,strong)NSMutableArray *texCoords;
@property(nonatomic,strong)NSMutableArray *normals;
@property(nonatomic,strong)NSMutableArray *verts;
@property(nonatomic,assign)int allNumVerts;
@end

@implementation ARModelVC

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"加载完成");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    _sceneEarthAxialTiltDeg = 0.f;
    _earthRotationAngleDegrees = -90.;
    index = 0;
    //新建视图->上下文
    [self creatUI];
    //光照
    [self configureLight];
    //顶点数组
    [self bufferData];
    //    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.f,0.f,0.f,0.0f);
    
    
}

-(void)addTimer{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:1. target:self selector:@selector(timeMethod) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
}

-(void)removeTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)creatUI{
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.mContext];
    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.delegate = self;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.mContext];
    glEnable(GL_DEPTH_TEST);
    
    if (ISPX) {
        self.view.bounds = CGRectMake(0, 0, 1 * ScreenHeight,1 * ScreenHeight);
    }else{
        self.view.bounds = CGRectMake(0, 0, 1.5 * ScreenHeight,1.5 * ScreenHeight);
    }
    
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    GLfloat aspectRatio = (self.view.bounds.size.width) / (self.view.bounds.size.height);
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspectRatio,1.0 * aspectRatio,-1.0,1.0,1.0,120.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
}

-(void)setBounds:(CGRect)bounds{
    _bounds = bounds;
    self.view.bounds = bounds;
    
}

- (void)configureLight
{
    self.baseEffect.light0.enabled = GL_TRUE;
    //    GL_TRUE;->RGB-A
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,1.0f,1.0f,1.0f);//光照颜色
    self.baseEffect.light0.position = GLKVector4Make(0.f,0.0f,1.f,1.f);//方向
    self.baseEffect.light0.ambientColor = GLKVector4Make(1.f,1.f,1.f,1.0f);//周围颜色
    
//    self.baseEffect.light1.enabled = GL_FALSE;
//    //    GL_TRUE;->RGB-A
//    self.baseEffect.light1.diffuseColor = GLKVector4Make(1.,1.,1.,1.f);//光照颜色
//    self.baseEffect.light1.position = GLKVector4Make(0.f,1.0f,0.f,0.f);//方向
//    self.baseEffect.light1.ambientColor = GLKVector4Make(1.f,1.f,1.f,1.0f);//周围颜色
}

//-(void)setVerts:(GLsizei)verts normals:(GLsizei)normals texCoords:(GLsizei)texCoords numVerts:(int)numVerts{
//    self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                   initWithAttribStride:(3 * sizeof(GLfloat))
//                                   numberOfVertices:sizeof(verts) / (3 * sizeof(GLfloat))
//                                   bytes:verts
//                                   usage:GL_STATIC_DRAW];
//    self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                 initWithAttribStride:(3 * sizeof(GLfloat))
//                                 numberOfVertices:sizeof(normals) / (3 * sizeof(GLfloat))
//                                 bytes:normals
//                                 usage:GL_STATIC_DRAW];
//    self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                       initWithAttribStride:(2 * sizeof(GLfloat))
//                                       numberOfVertices:sizeof(texCoords) / (2 * sizeof(GLfloat))
//                                       bytes:texCoords
//                                       usage:GL_STATIC_DRAW];
//    _numVerts = numVerts;
//}

-(void)setModelType:(int)modelType{
    NSArray *buff = _bufferArr[modelType];
    self.vertexPositionBuffer = buff[0];
    self.vertexNormalBuffer = buff[1];
    self.vertexTextureCoordBuffer = buff[2];
    _numVerts = [buff[3] intValue];
//    switch (modelType) {
//        case 1:
//            //            [self setVerts:&xionglaifeng1Verts normals:xionglaifeng1Normals texCoords:xionglaifeng1TexCoords numVerts:xionglaifeng1NumVerts];
//            self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                           initWithAttribStride:(3 * sizeof(GLfloat))
//                                           numberOfVertices:sizeof(xionglaifeng1Verts) / (3 * sizeof(GLfloat))
//                                           bytes:xionglaifeng1Verts
//                                           usage:GL_STATIC_DRAW];
//            self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                         initWithAttribStride:(3 * sizeof(GLfloat))
//                                         numberOfVertices:sizeof(xionglaifeng1Normals) / (3 * sizeof(GLfloat))
//                                         bytes:xionglaifeng1Normals
//                                         usage:GL_STATIC_DRAW];
//            self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                               initWithAttribStride:(2 * sizeof(GLfloat))
//                                               numberOfVertices:sizeof(xionglaifeng1TexCoords) / (2 * sizeof(GLfloat))
//                                               bytes:xionglaifeng1TexCoords
//                                               usage:GL_STATIC_DRAW];
//            _numVerts = xionglaifeng1NumVerts;
//            break;
//        case 2:
//            //            [self setVerts:&xionglaifeng2Verts normals:xionglaifeng2Normals texCoords:xionglaifeng2TexCoords numVerts:xionglaifeng2NumVerts];
//            self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                           initWithAttribStride:(3 * sizeof(GLfloat))
//                                           numberOfVertices:sizeof(xionglaifeng2Verts) / (3 * sizeof(GLfloat))
//                                           bytes:xionglaifeng2Verts
//                                           usage:GL_STATIC_DRAW];
//            self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                         initWithAttribStride:(3 * sizeof(GLfloat))
//                                         numberOfVertices:sizeof(xionglaifeng2Normals) / (3 * sizeof(GLfloat))
//                                         bytes:xionglaifeng2Normals
//                                         usage:GL_STATIC_DRAW];
//            self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                               initWithAttribStride:(2 * sizeof(GLfloat))
//                                               numberOfVertices:sizeof(xionglaifeng2TexCoords) / (2 * sizeof(GLfloat))
//                                               bytes:xionglaifeng2TexCoords
//                                               usage:GL_STATIC_DRAW];
//            _numVerts = xionglaifeng2NumVerts;
//            break;
//        case 3:
//            //            [self setVerts:xionglaifeng3Verts normals:xionglaifeng3Normals texCoords:xionglaifeng3TexCoords numVerts:xionglaifeng3NumVerts];
//            self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                           initWithAttribStride:(3 * sizeof(GLfloat))
//                                           numberOfVertices:sizeof(xionglaifeng2Verts) / (3 * sizeof(GLfloat))
//                                           bytes:xionglaifeng2Verts
//                                           usage:GL_STATIC_DRAW];
//            self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                         initWithAttribStride:(3 * sizeof(GLfloat))
//                                         numberOfVertices:sizeof(xionglaifeng3Normals) / (3 * sizeof(GLfloat))
//                                         bytes:xionglaifeng3Normals
//                                         usage:GL_STATIC_DRAW];
//            self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                               initWithAttribStride:(2 * sizeof(GLfloat))
//                                               numberOfVertices:sizeof(xionglaifeng3TexCoords) / (2 * sizeof(GLfloat))
//                                               bytes:xionglaifeng3TexCoords
//                                               usage:GL_STATIC_DRAW];
//            _numVerts = xionglaifeng3NumVerts;
//            break;
//        case 4:
//            //            [self setVerts:xionglaifeng4Verts normals:xionglaifeng4Normals texCoords:xionglaifeng4TexCoords numVerts:xionglaifeng4NumVerts];
//            self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                           initWithAttribStride:(3 * sizeof(GLfloat))
//                                           numberOfVertices:sizeof(xionglaifeng4Verts) / (3 * sizeof(GLfloat))
//                                           bytes:xionglaifeng4Verts
//                                           usage:GL_STATIC_DRAW];
//            self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                         initWithAttribStride:(3 * sizeof(GLfloat))
//                                         numberOfVertices:sizeof(xionglaifeng4Normals) / (3 * sizeof(GLfloat))
//                                         bytes:xionglaifeng4Normals
//                                         usage:GL_STATIC_DRAW];
//            self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                               initWithAttribStride:(2 * sizeof(GLfloat))
//                                               numberOfVertices:sizeof(xionglaifeng4TexCoords) / (2 * sizeof(GLfloat))
//                                               bytes:xionglaifeng4TexCoords
//                                               usage:GL_STATIC_DRAW];
//            _numVerts = xionglaifeng4NumVerts;
//            break;
//        case 5:
//            //            [self setVerts:xionglaifeng5Verts normals:xionglaifeng5Normals texCoords:xionglaifeng5TexCoords numVerts:xionglaifeng5NumVerts];
//            self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                           initWithAttribStride:(3 * sizeof(GLfloat))
//                                           numberOfVertices:sizeof(xionglaifeng5Verts) / (3 * sizeof(GLfloat))
//                                           bytes:xionglaifeng5Verts
//                                           usage:GL_STATIC_DRAW];
//            self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                         initWithAttribStride:(3 * sizeof(GLfloat))
//                                         numberOfVertices:sizeof(xionglaifeng5Normals) / (3 * sizeof(GLfloat))
//                                         bytes:xionglaifeng5Normals
//                                         usage:GL_STATIC_DRAW];
//            self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                               initWithAttribStride:(2 * sizeof(GLfloat))
//                                               numberOfVertices:sizeof(xionglaifeng5TexCoords) / (2 * sizeof(GLfloat))
//                                               bytes:xionglaifeng5TexCoords
//                                               usage:GL_STATIC_DRAW];
//            _numVerts = xionglaifeng5NumVerts;
//            break;
//        default:
//            //            [self setVerts:xionglaifeng1Verts normals:xionglaifeng1Normals texCoords:xionglaifeng1TexCoords numVerts:xionglaifeng1NumVerts];
//            self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                           initWithAttribStride:(3 * sizeof(GLfloat))
//                                           numberOfVertices:sizeof(xionglaifeng1Verts) / (3 * sizeof(GLfloat))
//                                           bytes:xionglaifeng1Verts
//                                           usage:GL_STATIC_DRAW];
//            self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                         initWithAttribStride:(3 * sizeof(GLfloat))
//                                         numberOfVertices:sizeof(xionglaifeng1Normals) / (3 * sizeof(GLfloat))
//                                         bytes:xionglaifeng1Normals
//                                         usage:GL_STATIC_DRAW];
//            self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
//                                               initWithAttribStride:(2 * sizeof(GLfloat))
//                                               numberOfVertices:sizeof(xionglaifeng1TexCoords) / (2 * sizeof(GLfloat))
//                                               bytes:xionglaifeng1TexCoords
//                                               usage:GL_STATIC_DRAW];
//            _numVerts = xionglaifeng1NumVerts;
//            break;
//    }
//    //    if (modelType == 1) {
//    //
//    //    }else{
//    //        [self changeModelTwo];
//    //    }
}

- (void)bufferData {
    
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    _bufferArr = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 5; i ++) {
        if (i == 0) {
            AGLKVertexAttribArrayBuffer *vert= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                                   numberOfVertices:sizeof(xionglaifeng1Verts) / (3 * sizeof(GLfloat))
                                                                                              bytes:xionglaifeng1Verts
                                                                                              usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *norma = [[AGLKVertexAttribArrayBuffer alloc]
                                         initWithAttribStride:(3 * sizeof(GLfloat))
                                         numberOfVertices:sizeof(xionglaifeng1Normals) / (3 * sizeof(GLfloat))
                                         bytes:xionglaifeng1Normals
                                         usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *tex = [[AGLKVertexAttribArrayBuffer alloc]
                                               initWithAttribStride:(2 * sizeof(GLfloat))
                                               numberOfVertices:sizeof(xionglaifeng1TexCoords) / (2 * sizeof(GLfloat))
                                               bytes:xionglaifeng1TexCoords
                                               usage:GL_STATIC_DRAW];
            
//            _vertexPositionBuffer = vert;
//            _vertexNormalBuffer = norma;
//            _vertexTextureCoordBuffer = tex;
//            _numVerts = xionglaifeng1NumVerts;
            [_bufferArr addObject:@[vert,norma,tex,@(xionglaifeng1NumVerts)]];
        }else if (i == 1) {
            AGLKVertexAttribArrayBuffer *vert= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                                        numberOfVertices:sizeof(xionglaifeng2Verts) / (3 * sizeof(GLfloat))
                                                                                                   bytes:xionglaifeng2Verts
                                                                                                   usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *norma = [[AGLKVertexAttribArrayBuffer alloc]
                                                  initWithAttribStride:(3 * sizeof(GLfloat))
                                                  numberOfVertices:sizeof(xionglaifeng2Normals) / (3 * sizeof(GLfloat))
                                                  bytes:xionglaifeng2Normals
                                                  usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *tex = [[AGLKVertexAttribArrayBuffer alloc]
                                                initWithAttribStride:(2 * sizeof(GLfloat))
                                                numberOfVertices:sizeof(xionglaifeng2TexCoords) / (2 * sizeof(GLfloat))
                                                bytes:xionglaifeng2TexCoords
                                                usage:GL_STATIC_DRAW];
//            _vertexPositionBuffer = vert;
//            _vertexNormalBuffer = norma;
//            _vertexTextureCoordBuffer = tex;
//            _numVerts = xionglaifeng2NumVerts;
            [_bufferArr addObject:@[vert,norma,tex,@(xionglaifeng2NumVerts)]];
        }else if (i == 2) {
            AGLKVertexAttribArrayBuffer *vert= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                                        numberOfVertices:sizeof(xionglaifeng3Verts) / (3 * sizeof(GLfloat))
                                                                                                   bytes:xionglaifeng3Verts
                                                                                                   usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *norma = [[AGLKVertexAttribArrayBuffer alloc]
                                                  initWithAttribStride:(3 * sizeof(GLfloat))
                                                  numberOfVertices:sizeof(xionglaifeng3Normals) / (3 * sizeof(GLfloat))
                                                  bytes:xionglaifeng3Normals
                                                  usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *tex = [[AGLKVertexAttribArrayBuffer alloc]
                                                initWithAttribStride:(2 * sizeof(GLfloat))
                                                numberOfVertices:sizeof(xionglaifeng3TexCoords) / (2 * sizeof(GLfloat))
                                                bytes:xionglaifeng3TexCoords
                                                usage:GL_STATIC_DRAW];
            _vertexPositionBuffer = vert;
            _vertexNormalBuffer = norma;
            _vertexTextureCoordBuffer = tex;
            _numVerts = xionglaifeng3NumVerts;
            [_bufferArr addObject:@[vert,norma,tex,@(xionglaifeng3NumVerts)]];
        }else if (i == 3) {
            AGLKVertexAttribArrayBuffer *vert= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                                        numberOfVertices:sizeof(xionglaifeng4Verts) / (3 * sizeof(GLfloat))
                                                                                                   bytes:xionglaifeng4Verts
                                                                                                   usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *norma = [[AGLKVertexAttribArrayBuffer alloc]
                                                  initWithAttribStride:(3 * sizeof(GLfloat))
                                                  numberOfVertices:sizeof(xionglaifeng4Normals) / (3 * sizeof(GLfloat))
                                                  bytes:xionglaifeng4Normals
                                                  usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *tex = [[AGLKVertexAttribArrayBuffer alloc]
                                                initWithAttribStride:(2 * sizeof(GLfloat))
                                                numberOfVertices:sizeof(xionglaifeng4TexCoords) / (2 * sizeof(GLfloat))
                                                bytes:xionglaifeng4TexCoords
                                                usage:GL_STATIC_DRAW];
//            _vertexPositionBuffer = vert;
//            _vertexNormalBuffer = norma;
//            _vertexTextureCoordBuffer = tex;
//            _numVerts = xionglaifeng4NumVerts;
            [_bufferArr addObject:@[vert,norma,tex,@(xionglaifeng4NumVerts)]];
        }else if (i == 4) {
            AGLKVertexAttribArrayBuffer *vert= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                                        numberOfVertices:sizeof(xionglaifeng5Verts) / (3 * sizeof(GLfloat))
                                                                                                   bytes:xionglaifeng5Verts
                                                                                                   usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *norma = [[AGLKVertexAttribArrayBuffer alloc]
                                                  initWithAttribStride:(3 * sizeof(GLfloat))
                                                  numberOfVertices:sizeof(xionglaifeng5Normals) / (3 * sizeof(GLfloat))
                                                  bytes:xionglaifeng5Normals
                                                  usage:GL_STATIC_DRAW];
            AGLKVertexAttribArrayBuffer *tex = [[AGLKVertexAttribArrayBuffer alloc]
                                                initWithAttribStride:(2 * sizeof(GLfloat))
                                                numberOfVertices:sizeof(xionglaifeng5TexCoords) / (2 * sizeof(GLfloat))
                                                bytes:xionglaifeng5TexCoords
                                                usage:GL_STATIC_DRAW];
//            _vertexPositionBuffer = vert;
//            _vertexNormalBuffer = norma;
//            _vertexTextureCoordBuffer = tex;
//            _numVerts = xionglaifeng5NumVerts;
            [_bufferArr addObject:@[vert,norma,tex,@(xionglaifeng5NumVerts)]];
        }
    }
    ////    顶点数据缓存
    //    self.xxVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
    //                                   initWithAttribStride:(3 * sizeof(GLfloat))
    //                                   numberOfVertices:sizeof(xionglaifeng1Verts) / (3 * sizeof(GLfloat))
    //                                   bytes:xionglaifeng1Verts
    //                                   usage:GL_STATIC_DRAW];
    //    self.xxVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
    //                                 initWithAttribStride:(3 * sizeof(GLfloat))
    //                                 numberOfVertices:sizeof(xionglaifeng1Normals) / (3 * sizeof(GLfloat))
    //                                 bytes:xionglaifeng1Normals
    //                                 usage:GL_STATIC_DRAW];
    //    self.xxVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
    //                                       initWithAttribStride:(2 * sizeof(GLfloat))
    //                                       numberOfVertices:sizeof(xionglaifeng1TexCoords) / (2 * sizeof(GLfloat))
    //                                       bytes:xionglaifeng1TexCoords
    //                                       usage:GL_STATIC_DRAW];
    //
    //    _vertexPositionBuffer = _xxVertexPositionBuffer;
    //    _vertexNormalBuffer = _xxVertexNormalBuffer;
    //    _vertexTextureCoordBuffer = _xxVertexTextureCoordBuffer;
    //    _numVerts = xionglaifeng1NumVerts;
    ////
    //    self.oneVertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
    //                                   initWithAttribStride:(3 * sizeof(GLfloat))
    //                                   numberOfVertices:sizeof(xionglaifeng2Verts) / (3 * sizeof(GLfloat))
    //                                   bytes:xionglaifeng2Verts
    //                                   usage:GL_STATIC_DRAW];
    //    self.oneVertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
    //                                 initWithAttribStride:(3 * sizeof(GLfloat))
    //                                 numberOfVertices:sizeof(xionglaifeng2Normals) / (3 * sizeof(GLfloat))
    //                                 bytes:xionglaifeng2Normals
    //                                 usage:GL_STATIC_DRAW];
    //    self.oneVertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
    //                                       initWithAttribStride:(2 * sizeof(GLfloat))
    //                                       numberOfVertices:sizeof(xionglaifeng2TexCoords) / (2 * sizeof(GLfloat))
    //                                       bytes:xionglaifeng2TexCoords
    //                                       usage:GL_STATIC_DRAW];
    
    //纹理一
    CGImageRef earthImageRef = [[UIImage imageNamed:@"xionglaifeng1.jpg"] CGImage];
    self.xxTextureInfo = [GLKTextureLoader
                          textureWithCGImage:earthImageRef
                          options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderGenerateMipmaps, nil]
                          error:NULL];
    self.earthTextureInfo = _xxTextureInfo;
    
    ////    纹理二
    //    earthImageRef =
    //    [[UIImage imageNamed:@"xionglaifeng2.png"] CGImage];
    //    self.oneTextureInfo = [GLKTextureLoader
    //                           textureWithCGImage:earthImageRef
    //                           options:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                    [NSNumber numberWithBool:YES],
    //                                    GLKTextureLoaderApplyPremultiplication, nil]
    //                           error:NULL];
    //矩阵堆
    GLKMatrixStackLoadMatrix4(
                              self.modelviewMatrixStack,
                              self.baseEffect.transform.modelviewMatrix);
}

-(void)timeMethod{
    if(index%2 == 0){
        self.modelType = 0;
    }else{
        self.modelType = 1;
    }
    index ++;
}

-(void)changeModel{
    if (self.earthTextureInfo == _oneTextureInfo) {
        self.earthTextureInfo = _xxTextureInfo;
    }else{
        self.earthTextureInfo = _oneTextureInfo;
    }
}

//-(void)changeModelOne{
//    //    self.earthTextureInfo = _xxTextureInfo;
//    _vertexPositionBuffer = _xxVertexPositionBuffer;
//    _vertexNormalBuffer = _xxVertexNormalBuffer;
//    _vertexTextureCoordBuffer = _xxVertexTextureCoordBuffer;
//    //        self.earthTextureInfo = _xxTextureInfo;
//    _numVerts = xionglaifeng1NumVerts;
//}
//
//-(void)changeModelTwo{
//    //    self.earthTextureInfo = _oneTextureInfo;
//    _vertexPositionBuffer = _oneVertexPositionBuffer;
//    _vertexNormalBuffer = _oneVertexNormalBuffer;
//    _vertexTextureCoordBuffer = _oneVertexTextureCoordBuffer;
//    _numVerts = xionglaifeng2NumVerts;
//}

- (void)setClearColor:(GLKVector4)clearColorRGBA{
    glClearColor(clearColorRGBA.r,clearColorRGBA.g,clearColorRGBA.b,clearColorRGBA.a);
}

//地球
- (void)drawEarth{
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
        self.baseEffect.texture2d0.envMode = GLKTextureEnvModeDecal;
    
    //    GLKMatrixStackMultiplyMatrix4(<#GLKMatrixStackRef  _Nonnull stack#>, <#GLKMatrix4 matrix#>)
    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 1.000000 0.000000 0.000000
     0.000000 0.000000 1.000000 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack,GLKMathDegreesToRadians(_sceneEarthAxialTiltDeg),1.0, 0.0, 0.0);
    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.000000 -0.398749 0.917060 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */ GLKMatrixStackRotate(self.modelviewMatrixStack,GLKMathDegreesToRadians(self.earthRotationAngleDegrees),0.0, 1.0, 0.0);
    /*
     current matrix:
     0.994522 0.041681 -0.095859 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.104528 -0.396565 0.912036 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    //    GLKMatrixStackRotate(self.modelviewMatrixStack,GLKMathDegreesToRadians(self.sceneZAngle),1.0, 1.0, 0.0);
    //    NSLog(@"%f",self.sceneZAngle);
    //放大缩小
    GLKMatrixStackScale(self.modelviewMatrixStack,1., 1., 1.);
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:_numVerts];
    
    /*
     
     current matrix:
     0.994522 0.041681 -0.095859 0.000000
     0.000000 0.917060 0.398749 0.000000
     0.104528 -0.396565 0.912036 0.000000
     0.000000 0.000000 -5.000000 1.000000
     */
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    /*
     current matrix:
     1.000000 0.000000 0.000000 0.000000
     0.000000 1.000000 0.000000 0.000000
     0.000000 0.000000 1.000000 0.000000
     0.000000 0.000000 -5.000000 1.000000
     
     */
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}

/**
 *  场景数据变化
 */
- (void)update {}

//渲染场景代码
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //    glClearColor(0.5f,0.5f,0.5f,0.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //    glBlendColor(0., 0., 0., 0.);
    //    glColorMask(0., 0., 0., 0.);
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    [self drawEarth];
}

@end


