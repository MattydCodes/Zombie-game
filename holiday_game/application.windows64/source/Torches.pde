PShape[] torchm = new PShape[3];
ArrayList<torch> torches = new ArrayList<torch>();
class torch{
  PVector pos;
  float hp;
  int type = 0;
  float id;
  color emitting;
  float diametre;
  float frame = 0;
  float c = 0;
  int model = 0;
  torch(PVector pos_, int type_, float id_){
    pos = pos_.copy();
    type = type_;
    if(type == 0){
      hp = 500;
    }
    id = id_;
  }
  void update(){
    frame+=0.5;
    if(frame > 10){
      model++;
      if(c > 0.3){
        float r = random(360);
        float d = random(100);
        float x = cos(radians(r))*d*0.016;
        float y = sin(radians(r))*d*0.016;
        embers.add(new ember(new PVector(pos.x+8,pos.y+8,pos.z+30),new PVector(x,y,random(0,1.25))));
      }
      if(model > 2){
        model = 0;
      }
      frame = 0;
    }
    c = lerp(c,noise(pos.x*pos.y+millis()/300.0),0.25);
    c*=c;
    c+=0.125;
    emitting = lerpColor(color(250, 30, 27),color(255, 80, 36),c);
    diametre=(0.5+c)*500;
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(current.pos.x,current.pos.y,pos.x,pos.y);
      if(d < 20){
        PVector restrict = vectortowards(pos,current.pos);
        float t = 9*1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
        current.pos.x = lerp(current.pos.x,current.pos.x+restrict.x*zombspeed/speed*t,(1.0-d/20.0));
        current.pos.y = lerp(current.pos.y,current.pos.y+restrict.y*zombspeed/speed*t,(1.0-d/20.0));
        if(ishosting){
          hp-=0.5*(round/10.0);
        }
      }
    }
    float d = dist(player.x,player.y,player.z,pos.x,pos.y,pos.z);
    if(d < 20){
      PVector restrict = vectortowards(pos,player);
      float t = 9*1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));   
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,(1.0-d/20.0));
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,(1.0-d/20.0));
      player.z = lerp(player.z,player.z+restrict.y*movespeed/speed*t,(1.0-d/20.0));
      fall-=restrict.z*0.25;
    }
  }
  void display(){
    torchm[model].translate(pos.x,pos.y,pos.z);
    d3.shape(torchm[model]);
    torchm[model].translate(-pos.x,-pos.y,-pos.z);
  }
}
void managetorches(){
  for(int i = torches.size()-1; i > -1; i--){
    torch current = torches.get(i);
    current.update();
    current.display();
    if(current.hp <= 0 && ishosting){
      client.write(removetorch(current.id));
    }
  }
}

void placetorch(PVector pos){
  pos = pos.copy();
  pos.z = nval(pos.x/scale,pos.y/scale)*scale+15;
  pos.x = round(pos.x/10)*10;
  pos.y = round(pos.y/10)*10;
  client.write(placetorch(random(10000),pos));
}

void showtorch(){
  if(keys[9] == 1 && points >= 50){
    PVector vec = player.copy().add(new PVector(cos(radians(mouse.x))*40,sin(radians(mouse.x))*40,0));
    vec.x = round(vec.x/10)*10;
    vec.y = round(vec.y/10)*10;
    vec.z = nval(vec.x/scale,vec.y/scale)*scale+18;
    torchm[0].translate(vec.x,vec.y,vec.z);
    d3.shape(torchm[0]);
    torchm[0].translate(-vec.x,-vec.y,-vec.z);
  }
}

void refreshtorch(){
  for(int i = 0; i < torches.size(); i++){
    client.write(placebarrier(torches.get(i).id,torches.get(i).pos));
  }
}
