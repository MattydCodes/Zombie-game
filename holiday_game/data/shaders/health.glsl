#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
#define PROCESSING_TEXTURE_SHADER
uniform sampler2D texture;
uniform float millis;
uniform float hp;
varying vec4 vertColor;
varying vec4 vertTexCoord;
float dist(float x1, float y1, float x2, float y2){
  float t = 0;
  float x = 0;
  float y = 0;
  if(x1 >= x2){
    x+=x1-x2;
  }else{
    x+=x2-x1;
  }
  if(y1 >= y2){
    y+=y1-y2;
  }else{
    y+=y2-y1;
  }  
  t = sqrt(x*x+y*y);
  return t;
}

void main(void) {
  float b = dist(vertTexCoord.x,vertTexCoord.y,0.5f,0.5f)+cos(millis/1000.0f)/20.0f;
  float v = (b-hp*0.71f);
  if(v > 1){
    v = 1f;
  }
  if(v < 0){
    v = 0f;
  }
  gl_FragColor = vec4(1.0f,0.01f,0.01f,1.0f)*v+texture2D(texture,vertTexCoord.st)*(hp*0.71f+0.29f);
}



