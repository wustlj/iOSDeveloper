//
//  GLViewController.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "GLViewController.h"
#import "ConstantsAndMacros.h"
#import "OpenGLCommon.h"
@implementation GLViewController
- (void)drawView:(UIView *)theView
{    
//    glColor4f(0.0, 0.0, 0.0, 0.0);
//	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Drawing code here
    
    Vertex3D vertex1 = Vertex3DMake(0, 1, -3.0);
    Vertex3D vertex2 = Vertex3DMake(-1, 0, -3.0);
    Vertex3D vertex3 = Vertex3DMake(1, 0, -3.0); 
    Triangle3D triangle = Triangle3DMake(vertex1, vertex2, vertex3); 

 
/*
    Triangle3D triangle[2];
    triangle[0].v1 = Vertex3DMake(0, 1, -3.0);
    triangle[0].v2 = Vertex3DMake(-1, 0, -3.0);
    triangle[0].v3 = Vertex3DMake(1, 0, -3.0);
    triangle[1].v1 = Vertex3DMake(-1, 0, -3.0);
    triangle[1].v2 = Vertex3DMake(0, -1, -3.0);
    triangle[1].v3 = Vertex3DMake(1, 0, -3.0);
*/
     
/*    
    Vertex3D *vertex = malloc(sizeof(Vertex3D)*4);
    Vertex3DSet(&vertex[0], 0.0, 1.0, -3.0);
    Vertex3DSet(&vertex[1], -1.0, 0.0, -3.0);
    Vertex3DSet(&vertex[2], 1.0, 0.0, -3.0);
    Vertex3DSet(&vertex[3], 0.0, -1.0, -3.0);
*/
    
    Vertex3D vertexs[] = {0.0, 1.0, -3.0, 1.0, 0.0, -3.0, -1.0, 0.0, -3.0, 0.0, -1.0, -3.0};
  
/*
    Color3D *colors = malloc(sizeof(Color3D)*3);
    colors[0] = Color3DMake(1.0, 0.0, 0.0, 1.0);
    colors[1] = Color3DMake(0.0, 1.0, 0.0, 1.0);
    colors[2] = Color3DMake(0.0, 0.0, 1.0, 1.0);
*/
    static GLfloat rot = 0.0;
    
    static const Vertex3D vertices[]= {
        {0, -0.525731, 0.850651},             // vertices[0]
        {0.850651, 0, 0.525731},              // vertices[1]
        {0.850651, 0, -0.525731},             // vertices[2]
        {-0.850651, 0, -0.525731},            // vertices[3]
        {-0.850651, 0, 0.525731},             // vertices[4]
        {-0.525731, 0.850651, 0},             // vertices[5]
        {0.525731, 0.850651, 0},              // vertices[6]
        {0.525731, -0.850651, 0},             // vertices[7]
        {-0.525731, -0.850651, 0},            // vertices[8]
        {0, -0.525731, -0.850651},            // vertices[9]
        {0, 0.525731, -0.850651},             // vertices[10]
        {0, 0.525731, 0.850651}               // vertices[11]
    };
    
    static const Color3D colors[] = {
        {1.0, 0.0, 0.0, 1.0},
        {1.0, 0.5, 0.0, 1.0},
        {1.0, 1.0, 0.0, 1.0},
        {0.5, 1.0, 0.0, 1.0},
        {0.0, 1.0, 0.0, 1.0},
        {0.0, 1.0, 0.5, 1.0},
        {0.0, 1.0, 1.0, 1.0},
        {0.0, 0.5, 1.0, 1.0},
        {0.0, 0.0, 1.0, 1.0},
        {0.5, 0.0, 1.0, 1.0},
        {1.0, 0.0, 1.0, 1.0},
        {1.0, 0.0, 0.5, 1.0}
    };

    static const GLubyte icosahedronFaces[] = {
        1, 2, 6,
        1, 7, 2,
        3, 4, 5,
        3, 4, 8,
        6, 5, 11,
        5, 6, 10,
        9, 10, 2,
        10, 9, 3,
        7, 8, 9,
        8, 7, 0,
        11, 0, 1,
        0, 11, 4,
        6, 2, 10,
        1, 6, 11,
        3, 5, 10,
        5, 4, 11,
        2, 7, 9,
        7, 1, 0,
        3, 9, 8,
        4, 8, 0,
    };
    
    //法线向量
    static const Vector3D normals[] = {
        {0.000000, -0.417775, 0.675974},
        {0.675973, 0.000000, 0.417775},
        {0.675973, -0.000000, -0.417775},
        {-0.675973, 0.000000, -0.417775},
        {-0.675973, -0.000000, 0.417775},
        {-0.417775, 0.675974, 0.000000},
        {0.417775, 0.675973, -0.000000},
        {0.417775, -0.675974, 0.000000},
        {-0.417775, -0.675974, 0.000000},
        {0.000000, -0.417775, -0.675973},
        {0.000000, 0.417775, -0.675974},
        {0.000000, 0.417775, 0.675973},
    };
    
    static const Vertex3D cube[] = {
        {-1.0, 1.0, 0.0},
        {1.0, 1.0, 0.0},
        {1.0, -1.0, 0.0},
        {-1.0, -1.0, 0.0},
        {-1.0, 1.0, -3.0},
        {1.0, 1.0, -3.0},
        {1.0, -1.0, -3.0},
        {-1.0, -1.0, -3.0}
    };
    
    static const GLubyte cubeFaces[] = {
        0, 1, 2,
        0, 2, 3,
        4, 5, 6,
        4, 5, 7,
        1, 5, 6,
        1, 2, 6,
        0, 4, 7,
        0, 3, 7,
        0, 1, 5,
        0, 4, 5,
        2, 6, 7,
        2, 3, 7
    };
    
    glLoadIdentity();
    
//    glTranslatef(0.0f,0.0f,-3.0f);
//    glRotatef(rot,1.0f,1.0f,1.0f);
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnableClientState(GL_VERTEX_ARRAY);
//    glEnableClientState(GL_COLOR_ARRAY);
//    glEnableClientState(GL_NORMAL_ARRAY);
    
    glColor4f(1.0, 0.0, 0.0, 1.0);
    
//    glVertexPointer(3, GL_FLOAT, 0, vertices);
//    glColorPointer(4, GL_FLOAT, 0, colors);
//    glNormalPointer(GL_FLOAT, 0, normals);
    
    glVertexPointer(3, GL_FLOAT, 0, &triangle);
    glDrawArrays(GL_TRIANGLES, 0, 9);
    
//    glDrawElements(GL_TRIANGLES, 60, GL_UNSIGNED_BYTE, icosahedronFaces);
    
    glDisableClientState(GL_VERTEX_ARRAY);
//    glDisableClientState(GL_COLOR_ARRAY);
//    glDisableClientState(GL_NORMAL_ARRAY);
    
//    static NSTimeInterval lastDrawTime;
//    if (lastDrawTime)
//    {
//        NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
//        rot+=50 * timeSinceLastDraw;
//    }
//    lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
    
//    if (vertex!=NULL) {
//        free(vertex);
//    }
//    if (colors!=NULL) {
//        free(colors);
//    }
}

-(void)setupView:(GLView*)view
{
	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
	GLfloat size; 
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION); 
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	CGRect rect = view.bounds; 
    
//    glOrthox(-1.0, 1.0, -1.0 / (rect.size.width / rect.size.height), 1.0 / (rect.size.width / rect.size.height), 3.0, -3.0);
    
    //投影变换
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
			   (rect.size.width / rect.size.height), zNear, zFar); 
    
    //视口变换
	glViewport(0, 0, rect.size.width, rect.size.height);  
    
	glMatrixMode(GL_MODELVIEW);

//    //开启光效
//    glEnable(GL_LIGHTING);
//    
//    //打开0光源
//    glEnable(GL_LIGHT0);
//    
//    //环境光
//    const GLfloat light0Ambient[] = {0.1, 0.1, 0.1, 1};
//    glLightfv(GL_LIGHT0, GL_AMBIENT, light0Ambient);
//    
//    //散射光
//    const GLfloat light0Diffuse[] = {0.7, 0.7, 0.7, 1.0};
//    glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diffuse);
//    
//    //高光
//    const GLfloat light0Specular[] = {0.7, 0.7, 0.7, 1.0};
//    glLightfv(GL_LIGHT0, GL_SPECULAR, light0Specular);
//    
//    //光源位置
//    const GLfloat light0Position[] = {10.0, 10.0, 10.0, 0.0};
//    glLightfv(GL_LIGHT0, GL_POSITION, light0Position);
//    
//    //光源方向
//    const GLfloat light0Direction[] = {0.0, 0.0, -1.0};
//    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light0Direction);
//    
//    //光源角度
//    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 45.0);
    
	glLoadIdentity();
}
- (void)dealloc 
{
    [super dealloc];
}
@end
