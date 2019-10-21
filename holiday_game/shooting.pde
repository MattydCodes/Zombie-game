ArrayList<projectile> bullets = new ArrayList<projectile>();
PShape bullet;
int shotcount = 0;
void setupbullet(){
  PImage text = createImage(1,1,RGB);
  text.loadPixels();
  text.pixels[0] = color(255,200,0);
  text.updatePixels();
  bullet = createShape();
  bullet.beginShape(QUAD);
  bullet.emissive(255,255,255);
  bullet.texture(text);
  bullet.textureMode(NORMAL);
  bullet.noFill();
  bullet.noStroke();
  bullet.vertex(0,0,0,0,0);
  bullet.vertex(1,0,0,1,0);
  bullet.vertex(1,0,1,1,1);
  bullet.vertex(0,0,1,0,1);
  bullet.endShape();
  bullet.scale(2);
}
boolean shooting = false;
boolean reloading = false;
float reloadtimer = 0;
float shottimer = 0;
void mousePressed(){
  if(mouseButton == LEFT && bulletcount > 0 && reloadtimer == 0 && reloading == false){
    shooting = true;
  }
}
void mouseReleased(){
  if(mouseButton == LEFT){
    shooting = false;
  }
}
void manageshooting(){
  shottimer+=0.016;
  if(shooting == false){
    shottimer = constrain(shottimer,0,weaponstats[weapon][1]);
  }
  if(shooting && bulletcount > 0){
    if(shottimer >= weaponstats[weapon][1]){
      shoot();
      bulletcount--;
      shottimer = 0;
      gunstate = 1;
    }
  }
  if(shottimer >= 0.05){
    gunstate = 0;
  }
  if(reloading){
    reloadtimer+=0.016;
    if(reloadtimer>=weaponstats[weapon][4]){
      bulletcount = weaponstats[weapon][3];
      reloading = false;
    }
  }else{
    reloadtimer-=0.016;
    reloadtimer = constrain(reloadtimer,0,weaponstats[weapon][3]);
  }
}
void shoot(){
  PVector facingdir = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)),player.y+sin(radians(mouse.x)),player.z+sin(radians(mouse.y))));
  facingdir.x*=weaponstats[weapon][2];
  facingdir.y*=weaponstats[weapon][2];
  facingdir.z*=weaponstats[weapon][2];
  PVector offset = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)+PI/4),player.y+sin(radians(mouse.x)+PI/4),player.z+sin(radians(mouse.y))-0.185));
  offset.x*=10;
  offset.y*=10;
  offset.z*=10;
  bullets.add(new projectile(new PVector(player.x+offset.x,player.y+offset.y,player.z+offset.z),facingdir,weaponstats[weapon][0]));
  client.write(createbmessage(myip,new PVector(player.x+offset.x,player.y+offset.y,player.z+offset.z),facingdir.copy()));
}
class projectile{
  float closesttree = radius*2*scale;
  float closestzomb = radius*2*scale;
  int treeindex = 0;
  int zombindex = 0;
  float damage;
  PVector pos;
  PVector dir;
  boolean hitzomb = false;
  boolean hittree = false;
  boolean out = false;
  projectile(PVector pos_, PVector dir_, float damage_){
    pos = pos_;
    dir = dir_;
    damage = damage_;
  }
  void move(){
    pos.x+=dir.x;
    pos.y+=dir.y;
    pos.z+=dir.z;
    if(dist(pos.x,pos.y,pos.z,w/2*scale,w/2*scale,depth/2) > radius*scale){
      out = true;
    }
    for(int i = 0; i < trees.length; i++){
      float d = dist(pos.x,pos.y,pos.z,trees[i].x,trees[i].y,trees[i].z);
      if(d < 30){
        hittree = true;
        if(d < closesttree){
          closesttree = d;
          treeindex = i;
        }
      }
    }
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(pos.x,pos.y,pos.z,current.pos.x,current.pos.y,current.pos.z+10);
      if(d < 20){
        hitzomb = true;
        if(d < closestzomb){
          closestzomb = d;
          zombindex = i;
        }
      }
    }
    if(hitzomb && damage > 0){
      if(closestzomb <= closesttree){
        zombie current = zombies.get(zombindex);
        current.hp-=damage;
        current.hit();
        if(current.hp <= 0){
          kills++;
        }
      }
    }
    if(hittree && damage > 0){
      if(closesttree < closestzomb){
        bullethittree(treeindex,20);
      }
    }
  }
  void display(){
    float b = radians(bearing(pos,player));
    d3.translate(pos.x,pos.y,pos.z);
    d3.rotateZ(b);
    d3.shape(bullet);
    d3.rotateZ(-b);
    d3.translate(-pos.x,-pos.y,-pos.z);
  }
}

void managebullets(){
  for(int i = bullets.size()-1; i > -1; i--){
    projectile current = bullets.get(i);
    if(current.hitzomb || current.hittree || current.out){
      bullets.remove(i);
      continue;
    }
    current.move();
    current.display();
  }
}
