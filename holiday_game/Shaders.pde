PShader blood;

void setlightsources(){
  float[] x = new float[clients.size()+torches.size()+embers.size()];
  float[] y = new float[clients.size()+torches.size()+embers.size()];
  float[] z = new float[clients.size()+torches.size()+embers.size()];
  float[] r = new float[clients.size()+torches.size()+embers.size()];
  float[] g = new float[clients.size()+torches.size()+embers.size()];
  float[] b = new float[clients.size()+torches.size()+embers.size()];
  float[] d = new float[clients.size()+torches.size()+embers.size()];
  for(int i = 0; i < clients.size(); i++){
    playerc current = clients.get(i);
    x[i] = current.pos.x;
    y[i] = current.pos.y;
    z[i] = current.pos.z+45;
    r[i] = 1;
    g[i] = 0.54;
    b[i] = 0.02;
    d[i] = 300;
  }
  for(int i = clients.size(); i < clients.size()+torches.size(); i++){
    torch current = torches.get(i-clients.size()); 
    x[i] = current.pos.x;
    y[i] = current.pos.y;
    z[i] = current.pos.z+45;
    r[i] = red(current.emitting)/255.0;
    g[i] = green(current.emitting)/255.0;
    b[i] = blue(current.emitting)/255.0;
    d[i] = current.diametre;
  }
  for(int i = clients.size()+torches.size(); i < clients.size()+torches.size()+embers.size(); i++){
    ember current = embers.get(i-clients.size()-torches.size()); 
    x[i] = current.pos.x;
    y[i] = current.pos.y;
    z[i] = current.pos.z+20;
    r[i] = 1;
    g[i] = 0.0;
    b[i] = 0.0;
    d[i] = 150-current.lifetime/2.0+cos(current.lifetime/10.0)*20;
  }
  shader.set("xpos",x);
  shader.set("ypos",y);
  shader.set("zpos",z);
  shader.set("r",r);
  shader.set("g",g);
  shader.set("b",b);
  shader.set("di",d);
  if(menu == true){
    shader.set("light",0);
  }else{
    shader.set("light",clients.size()+torches.size()+embers.size());
  }
}
