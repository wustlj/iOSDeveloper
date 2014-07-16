attribute vec4 vPosition;
attribute vec4 color;
attribute vec2 textureCoord;

uniform mat4 modelViewMat;
uniform mat4 projectMat;

varying vec4 colorVarying;
varying vec2 textureCoordOut;

void main()
{
    gl_Position = projectMat * modelViewMat * vPosition;
    colorVarying = color;
    textureCoordOut = textureCoord;
}