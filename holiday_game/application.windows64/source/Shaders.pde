PShader blood;

void setlightsources(){
  float[] x = new float[10];
  float[] y = new float[10];
  float[] z = new float[10];
  for(int i = 0; i < 10; i++){
    if(clients.size() <= i){
      x[i] = -10000;
      y[i] = -10000;
      z[i] = -10000;
    }else{
      playerc current = clients.get(i);
      x[i] = current.pos.x;
      y[i] = current.pos.y;
      z[i] = current.pos.z+45;
    }
  }
  shader.set("xpos",x);
  shader.set("ypos",y);
  shader.set("zpos",z);
  shader.set("light",1);
}
