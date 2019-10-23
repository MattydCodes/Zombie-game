PShape[] towerm = new PShape[1];
ArrayList<tower> towers = new ArrayList<tower>();
class tower{
  PVector pos;
  float hp;
  int type = 0;
  float id;
  tower(PVector pos_, int type_, float id_){
    pos = pos_.copy();
    type = type_;
    if(type == 0){
      hp = 1000;
    }
    id = id_;
  }
  void update(){
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(current.pos.x,current.pos.y,pos.x,pos.y);
      if(d < 60){
        PVector restrict = vectortowards(pos,current.pos);
        float t = 3*1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
        current.pos.x = lerp(current.pos.x,current.pos.x+restrict.x*zombspeed/speed*t,(1.0-d/60.0));
        current.pos.y = lerp(current.pos.y,current.pos.y+restrict.y*zombspeed/speed*t,(1.0-d/60.0));
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
    if(d < 25 && keys[4] == 1){
      intower = true;
      towerid = id;
      towerbox = pos.copy().add(0.0,0.0,93);
    }
  }
  void display(){
    d3.translate(pos.x,pos.y,pos.z);
    d3.shape(towerm[type]);
    d3.translate(-pos.x,-pos.y,-pos.z);
  }
}
void managetowers(){
  for(int i = towers.size()-1; i > -1; i--){
    tower current = towers.get(i);
    current.update();
    current.display();
    if(current.hp <= 0 && ishosting){
      client.write(removetower(current.id));
    }
  }
}

void placetower(PVector pos){
  pos = pos.copy();
  pos.z = nval(pos.x/scale,pos.y/scale)*scale+15;
  pos.x = round(pos.x/10)*10;
  pos.y = round(pos.y/10)*10;
  client.write(placetower(random(10000),pos));
}

void showtower(){
  if(keys[8] == 1 && points >= 200){
    PVector vec = player.copy().add(new PVector(cos(radians(mouse.x))*40,sin(radians(mouse.x))*40,0));
    vec.x = round(vec.x/10)*10;
    vec.y = round(vec.y/10)*10;
    vec.z = nval(vec.x/scale,vec.y/scale)*scale+40;
    d3.translate(vec.x,vec.y,vec.z);
    d3.shape(towerm[0]);
    d3.resetMatrix();
  }
}

void refreshtowers(){
  for(int i = 0; i < towers.size(); i++){
    client.write(placetower(towers.get(i).id,towers.get(i).pos));
  }
}
