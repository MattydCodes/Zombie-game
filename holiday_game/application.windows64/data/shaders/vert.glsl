uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

uniform vec4 lightPosition;
uniform float xpos[10];
uniform float ypos[10];
uniform float zpos[10];
uniform int light = 0;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;
attribute vec4 emissive;

varying float bonus;
varying vec4 Emissive;
varying vec4 vertColor;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec4 vertTexCoord;
varying float fog;

float dist(vec4 pos1, vec4 pos2){
  float t = 0;
  float x = 0;
  float y = 0;
  float z = 0;
  if(pos1.x >= pos2.x){
    x+=pos1.x-pos2.x;
  }else{
    x+=pos2.x-pos1.x;
  }
  if(pos1.y >= pos2.y){
    y+=pos1.y-pos2.y;
  }else{
    y+=pos2.y-pos1.y;
  }  
  if(pos1.z >= pos2.z){
    z+=pos1.z-pos2.z;
  }else{
    z+=pos2.z-pos1.z;
  }
  t = sqrt(x*x+y*y+z*z);
  return t;
}

void main() {
  if(light == 1){
    float bonuslight = 0f;
    vec4 pos = position;
    for(int i = 0; i < xpos.length(); i++){
      float d = dist(vec4(xpos[i],ypos[i],zpos[i],0),pos);
      if(d < 500){
        vec3 direction = normalize(vec3(xpos[i]-pos.x,ypos[i]-pos.y,zpos[i]-pos.z));
        float val = max(0.0f, dot(direction,normalize(normal))/(d/80.0f));
        bonuslight = bonuslight + val*val*val*0.9;
      }
    }
    bonus = bonuslight;
  }
  gl_Position = transform * position;
  vec3 ecPosition = vec3(modelview * position);
  Emissive = emissive;
  ecNormal = normalize(normalMatrix * normal);
  lightDir = normalize(lightPosition.xyz - ecPosition);
  vertColor = color;
  fog = dist(position,vec4(2000f,2000f,0f,0f));
  if(fog > 2800){
    fog = 0;
  }
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}



