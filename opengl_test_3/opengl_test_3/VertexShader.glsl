attribute vec4 vPosition; 
 
void main(void)
{
//    gl_Position = vec4(vPosition.x * 2.0, vPosition.y * 2.0, vPosition.z, vPosition.w) ;
    gl_Position = vPosition;
}