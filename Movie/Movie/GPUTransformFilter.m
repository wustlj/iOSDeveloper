//
//  GPUTransformFilter.m
//  Movie
//
//  Created by lijian on 14-7-24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUTransformFilter.h"

#import "matrix.h"

NSString *const kTransformVertexShaderString = SHADER_STRING
(
 attribute vec4 vPosition;
 attribute vec2 textureCoord;
 
 uniform mat4 modelViewMatrix;
 uniform mat4 projectMatrix;
 
 varying vec2 textureCoordOut;
 
 void main()
 {
     gl_Position = projectMatrix * modelViewMatrix * vec4(vPosition.xyz, 1.0);
     textureCoordOut = textureCoord;
 }
 );

@implementation GPUTransformFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    
    modelViewMatrix = (float *)malloc(16 * sizeof(float));
    projectMatrix = (float *)malloc(16 * sizeof(float));
    mat4f_LoadIdentity(projectMatrix);
    mat4f_LoadIdentity(modelViewMatrix);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        _modelViewMatrixSlot = [_filterProgram uniformIndex:@"modelViewMatrix"];
        _projectMatrixSlot = [_filterProgram uniformIndex:@"projectMatrix"];
    });
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [self initWithVertexShaderFromString:kTransformVertexShaderString fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    return self;
}

- (id)init {
    if (!(self = [self initWithFragmentShaderFromString:kFilterFragmentShaderString])) {
        return nil;
    }
    return self;
}

- (void)dealloc {
    free(modelViewMatrix);
    free(projectMatrix);
    
    [super dealloc];
}

#pragma mark - Draw

- (void)draw {
    static const GLfloat squarVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordies[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    [self renderToTextureWithVertices:squarVertices textureCoordinates:textureCoordies];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [GPUContext setActiveShaderProgram:_filterProgram];
    
    if (!_outputFramebuffer) {
        _outputFramebuffer = [[GPUFramebuffer alloc] initWithSize:_textureSize];
    }
    
    [_outputFramebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_firstInputFramebuffer texture]);
    glUniform1i(_samplerSlot, 2);
    
    glUniformMatrix4fv(_modelViewMatrixSlot, 1, 0, modelViewMatrix);
    glUniformMatrix4fv(_projectMatrixSlot, 1, 0, projectMatrix);
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)setTransform3D:(CATransform3D)newValue {
    _transform3D = newValue;
    
    mat4f_LoadIdentity(projectMatrix);
    mat4f_LoadIdentity(modelViewMatrix);
    [self convert3DTransform:&_transform3D toMatrix:modelViewMatrix];
}

- (void)convert3DTransform:(CATransform3D *)transform3D toMatrix:(GLfloat *)matrix;
{
	//	struct CATransform3D
	//	{
	//		CGFloat m11, m12, m13, m14;
	//		CGFloat m21, m22, m23, m24;
	//		CGFloat m31, m32, m33, m34;
	//		CGFloat m41, m42, m43, m44;
	//	};
    
    GLfloat *mappedMatrix = (GLfloat *)matrix;
	
	mappedMatrix[0] = (GLfloat)transform3D->m11;
	mappedMatrix[1] = (GLfloat)transform3D->m12;
	mappedMatrix[2] = (GLfloat)transform3D->m13;
	mappedMatrix[3] = (GLfloat)transform3D->m14;
	mappedMatrix[4] = (GLfloat)transform3D->m21;
	mappedMatrix[5] = (GLfloat)transform3D->m22;
	mappedMatrix[6] = (GLfloat)transform3D->m23;
	mappedMatrix[7] = (GLfloat)transform3D->m24;
	mappedMatrix[8] = (GLfloat)transform3D->m31;
	mappedMatrix[9] = (GLfloat)transform3D->m32;
	mappedMatrix[10] = (GLfloat)transform3D->m33;
	mappedMatrix[11] = (GLfloat)transform3D->m34;
	mappedMatrix[12] = (GLfloat)transform3D->m41;
	mappedMatrix[13] = (GLfloat)transform3D->m42;
	mappedMatrix[14] = (GLfloat)transform3D->m43;
	mappedMatrix[15] = (GLfloat)transform3D->m44;
}

@end
