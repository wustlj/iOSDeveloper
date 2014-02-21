precision mediump float;

varying vec4 colorVarying;
varying vec2 textureCoordOut;

uniform sampler2D Sampler;

void main()
{
    gl_FragColor = texture2D(Sampler, textureCoordOut) * colorVarying;
}