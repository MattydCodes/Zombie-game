ArrayList<gundrop> gundrops = new ArrayList<gundrop>();
PShape weaponcrate;
int dropcount = 10;
class gundrop{
  boolean picked = false;
  PVector pos;
  int dweapon;
  float anim;
  gundrop(PVector pos_, int weapon_){
    pos = pos_;
    anim = random(2);
    dweapon = weapon_;
  }
  void display(){
    anim+=0.016;
    weaponcrate.rotateX(PI/2);
    weaponcrate.rotateZ(cos(anim));
    weaponcrate.translate(pos.x,pos.y,pos.z+15+sin(anim)*4);
    d3.shape(weaponcrate);
    weaponcrate.resetMatrix();
    if(dist(pos.x,pos.y,pos.z,player.x,player.y,player.z) < 40 && keys[4] == 1){
      weapon = dweapon;
      gunstate = 0;
      bulletcount = weaponstats[weapon][3];
      reloading = true;
      reloadtimer = weaponstats[weapon][4]/2.0;
      picked = true;
    }
  }
}

void managedrops(){
  if(gundrops.size() < dropcount){
    float r = radians(random(360));
    float d = random(-(radius-50)*scale,(radius-50)*scale);
    float x = cos(r)*d+w/2*scale;
    float y = sin(r)*d+w/2*scale;
    float rnd = random(1);
    rnd*=rnd*rnd*rnd;
    rnd*=2;
    int weapon = round(rnd); 
    gundrops.add(new gundrop(new PVector(x,y,nval(x/scale,y/scale)*scale),weapon));
  }
  for(int i = gundrops.size()-1; i > -1; i--){
    gundrop current = gundrops.get(i);
    if(current.picked){
      gundrops.remove(i);
      continue;
    }
    current.display();
  }
}
