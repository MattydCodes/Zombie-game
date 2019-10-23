uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

uniform vec4 lightPosition;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;
attribute vec4 emissive;

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