ArrayList<corpse> corpses = new ArrayList<corpse>();
int duration = 300;
class corpse{
  PVector pos;
  int lifetime = 0;
  float rot;
  float anim;
  float h;
  int id = 0;
  corpse(PVector pos_, float rot_, int id_){
    pos = pos_;
    rot = rot_;
    id = id_;
  }
  void display(){
    lifetime++;
    anim+=0.006;
    anim+=anim*0.05;
    anim = constrain(anim,0,1);
    //d3.translate(pos.x,pos.y,pos.z-anim*5);
    //d3.rotateZ(radians(rot));
    //d3.rotateX(map(anim,0,1,0,PI/2));
    //d3.shape(zombiea1);
    //d3.rotateX(-map(anim,0,1,0,PI/2));
    //d3.rotateZ(-radians(rot));
    //d3.translate(-pos.x,-pos.y,-pos.z+anim*5);
    zombiea1.resetMatrix();
    zombiea1.rotateX(PI/2);
    zombiea1.rotateX(map(anim,0,1,0,PI/2));
    zombiea1.rotateZ(radians(rot));
    zombiea1.translate(pos.x,pos.y,pos.z-anim*5);
    d3.shape(zombiea1);
  }
}
void managecorpses(){
  for(int i = corpses.size()-1; i > -1; i--){
    corpse current = corpses.get(i);
    if(current.lifetime >= duration){
      corpses.remove(i);
      continue;
    }
    current.display();
  }
}
