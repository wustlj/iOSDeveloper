varying vec4 colorVarying;
varying vec2 textureCoordOut;

uniform sampler2D sampler;

void main()
{
    gl_FragColor = texture2D(sampler, textureCoordOut) * colorVarying;
}