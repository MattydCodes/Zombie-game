#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying float bonus;
varying vec4 Emissive;
varying vec4 vertColor;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec4 vertTexCoord;
varying float fog;

void main() {
  vec3 direction = normalize(lightDir);
  vec3 normal = normalize(ecNormal);
  float intensity = max(0.0f, dot(direction, normal));
  intensity+=0.7f;
  if(intensity >= 1f){
    intensity = 1f;
  }
  vec4 tintColor;
  float v = 0f;
  if(Emissive.r > 0.05f && Emissive.g > 0.05f && Emissive.b > 0.05f){
	tintColor = Emissive*vertColor;
  }else{//255, 148, 33
  	tintColor = vec4(intensity*0.05f+bonus, intensity*0.05f+bonus*0.58f, intensity*0.05f+bonus*0.13f, 1f) * vertColor;
	 v = fog;
   	 v/=2000f;
   	 v+=0.2f;
   	 v*=v*v;
   	 if(v > 1){
  	   v = 1f;
  	 }
  }
  vec4 col = (texture2D(texture, vertTexCoord.st) * tintColor) * (1f-v) + (vec4(0.0f,0.0f,0.0f,1f)) * (v);
  gl_FragColor = col;
}