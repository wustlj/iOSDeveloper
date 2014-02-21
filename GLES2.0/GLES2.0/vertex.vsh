attribute vec4 position;
attribute vec4 color;
attribute vec2 textureCoord;

uniform mat4 modelViewMatrix;
uniform mat4 projectMatrix;

varying vec4 colorVarying;
varying vec2 textureCoordOut;

void main()
{
    gl_Position = projectMatrix * modelViewMatrix * position;
    colorVarying = color;
    textureCoordOut = textureCoord;
}