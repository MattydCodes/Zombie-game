boolean started = false;
ArrayList<zombie> zombies = new ArrayList<zombie>();
PShape zombiem1;
PShape zombiem2;
PShape zombiea1;
PShape zombiea2;
float zombspeed = 0.5;
int round = 0;
int rounddelay = 0;
int zombsound = 0;
class zombie{
  int id;
  PVector pos;
  float hp;
  int frame;
  float timer = 0;
  float rot = 0;
  float attacktimer = 0;
  PVector target;
  zombie(PVector pos_, int id_, int hp_){
    pos = pos_;
    id = id_;
    hp = hp_;
    frame = round(random(1));
    timer = random(0.1);
  }
  zombie(PVector pos_, int id_, float hp_){
    pos = pos_;
    id = id_;
    hp = hp_;
    frame = round(random(1));
    timer = random(0.1);
  }
  void move(){
    if(random(zombies.size()/3.0*100) < 1){
      if(zombiesound[zombsound].isPlaying()){ 
        zombiesound[zombsound].stop();
      }
      zombiesound[zombsound].play();
      soundobjects.add(new soundobject(zombiesound[zombsound],pos));
      zombsound++;
      if(zombsound >= 199){
        zombsound = 0;
      }
    }
    target = closestClient(pos);
    PVector dir = vectortowards(pos,target);
    if(dist(target.x,target.y,pos.x,pos.y) < 35){
      attacktimer = 1.25;
    }else if(attacktimer == 0){
      if(sqrt((rot*rot)-(pow(bearing(target,pos),2))) > 180 || sqrt((rot*rot)-(pow(bearing(target,pos),2))) < -180){
        rot = bearing(target,pos);
      }else{
        rot = lerp(rot,bearing(target,pos),0.1);
      }
      pos.x+=dir.x*zombspeed;
      pos.y+=dir.y*zombspeed;
      pos.z = lerp(pos.z,nval(pos.x/scale,pos.y/scale)*scale+9,0.25);
    }else if(attacktimer != 0){
      attacktimer-=0.016;
      if(attacktimer <= 0){
        attacktimer = 0;
      }
    }
    for(int i = 0; i < trees.length; i++){
      float d = dist(pos.x,pos.y,trees[i].x,trees[i].y);
      if(d < 3*scale+2){
        PVector resist = vectortowards(trees[i],pos);
        float t = 1.0/(sqrt(pow(resist.x,2)+pow(resist.y,2)));
        pos.x = lerp(pos.x,pos.x+resist.x*zombspeed*t,(3*scale+2)/10.0-d/10.0);
        pos.y = lerp(pos.y,pos.y+resist.y*zombspeed*t,(3*scale+2)/10.0-d/10.0);
      }
    }
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      if(current == this || attacktimer != 0){
        continue;
      }
      float d = dist(pos.x,pos.y,current.pos.x,current.pos.y);
      if(d < 25){
        PVector resist = vectortowards(current.pos,pos);
        float t = 1.0/(sqrt(pow(resist.x,2)+pow(resist.y,2)));
        pos.x = lerp(pos.x,pos.x+resist.x*zombspeed*t,2.5-d/10.0);
        pos.y = lerp(pos.y,pos.y+resist.y*zombspeed*t,2.5-d/10.0);
      }
    }
    timer+=0.016;
    if(timer >= 0.25){
      if(frame == 1){
        frame = 0;
      }else{
        frame = 1;
      }
      timer = 0;
    }
  }
  void display(){
    if(frame == 0 && attacktimer == 0){
      zombiem1.resetMatrix();
      zombiem1.rotateX(PI/2);
      zombiem1.rotateZ(radians(rot));
      zombiem1.translate(pos.x,pos.y,pos.z);
      d3.shape(zombiem1);
    }else if(attacktimer == 0){
      zombiem2.resetMatrix();
      zombiem2.rotateX(PI/2);
      zombiem2.rotateZ(radians(rot));
      zombiem2.translate(pos.x,pos.y,pos.z);      
      d3.shape(zombiem2);
    }
    if(frame == 0 && attacktimer != 0){
      zombiea1.resetMatrix();
      zombiea1.rotateX(PI/2);
      zombiea1.rotateZ(radians(rot));
      zombiea1.translate(pos.x,pos.y,pos.z);    
      d3.shape(zombiea1);
      if(dist(player.x,player.y,player.z,pos.x,pos.y,pos.z) <= 40 && sqrt(pow(rot-bearing(player,pos),2)) <= 45){
        health-=0.1;
      }
    }else if(attacktimer != 0){
      zombiea2.resetMatrix();
      zombiea2.rotateX(PI/2);
      zombiea2.rotateZ(radians(rot));
      zombiea2.translate(pos.x,pos.y,pos.z);
      d3.shape(zombiea2);
    }
  }
  void hit(){
    client.write(createhmessage(id,hp));
    //particlesystems.add(new particlesystem(pos.copy(),new PVector(0,0,0),0.1,0.01,color(255,20,20),2,count,5,(count-(count-1))));
  }
}


PShape loadshape(String pathm, String textm){
  PShape l = loadShape(pathm);
  PImage text = loadImage(textm);
  PShape shape = createShape();
  shape.beginShape(TRIANGLES);
  shape.textureMode(IMAGE);
  shape.noStroke();
  shape.noFill();
  shape.texture(text);
  for(int j = 0; j < l.getChildCount(); j++){
    PShape c = l.getChild(j);
    for(int i = 0; i < c.getVertexCount(); i++){
      PVector vert = c.getVertex(i);
      PVector norm = c.getNormal(i);
      float U = int(c.getTextureU(i)*text.width);
      float V = int(c.getTextureV(i)*text.height);
      shape.normal(norm.x,norm.y,norm.z);
      shape.ambient(255,255,255);
      shape.specular(255,255,255);
      shape.vertex(vert.x,vert.y,vert.z,U,V);
    }
  }
  shape.endShape();
  return shape;
}

void managezombies(){
  if(zombies.size() == 0){
    rounddelay++;
    if(rounddelay > 300){
      round++;
      if(round > 3){
        zombspeed = 1.25+round*0.05;
      }else{
        zombspeed = 0.75+round*0.05;
      }
      for(int i = 0; i < round*5+5; i++){
        float degree = random(360);
        float x = cos(radians(degree)) * (radius + random(-40,50))*scale + w/2*scale;
        float y = sin(radians(degree)) * (radius + random(-40,50))*scale + w/2*scale;
        zombies.add(new zombie(new PVector(x,y,nval(x,y)),int(random(10000000)),50+round*5));
        client.write(createzmessage(str(zombies.get(zombies.size()-1).id),zombies.get(zombies.size()-1).pos));        
      }
      rounddelay = 0;
    }
  }
  for(int i = zombies.size()-1; i > -1; i--){
    zombie current = zombies.get(i);
    current.move();
    current.display();
    if(current.hp <= 0){
      client.write(createcmessage(current.pos.copy(),current.rot,current.id));
      deathparticles(current.pos);
      zombies.remove(i);
    }
  }
}

void movezombies(){
  if(round > 3){
    zombspeed = 1.25+round*0.05;
  }else{
    zombspeed = 0.75+round*0.05;
  }
  for(int i = zombies.size()-1; i > -1; i--){
    zombie current = zombies.get(i);
    current.move();
    current.display();
    if(current.hp <= 0){
      deathparticles(current.pos);
      zombies.remove(i);
    }
  }
}

void deathparticles(PVector pos){
  particlesystems.add(new particlesystem(pos.copy(),new PVector(0,0,0),1,0.5,color(255,20,20),60,120,1,60));
}

PVector closestClient(PVector pos){
  PVector p = pos.copy();
  float d = radius*scale*100;
  for(int i = 0; i < clients.size(); i++){
    playerc current = clients.get(i);
    float dis = dist(pos.x,pos.y,pos.z,current.pos.x,current.pos.y,current.pos.z);
    if(dis < d && current.alive == true){
      d = dis;
      p = current.pos.copy();
    }
  }
  return p;
}

float bearing(PVector a, PVector b) {
    float TWOPI = 6.2831853071795865;
    float RAD2DEG = 57.2957795130823209;
    float theta = atan2(b.x - a.x, a.y - b.y);
    if (theta < 0.0)
        theta += TWOPI;
    return RAD2DEG * theta;
}
