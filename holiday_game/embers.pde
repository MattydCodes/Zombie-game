ArrayList<ember> embers = new ArrayList<ember>();
PShape emberm;
class ember{
  PVector pos;
  PVector dir;
  boolean move = true;
  int lifetime = 0;
  ember(PVector pos_, PVector dir_){
    pos = pos_.copy();
    dir = dir_.copy();
  }
  void update(){
    if(move){
      pos.add(dir);
      dir.z-=0.032;
      dir.x = lerp(dir.x,0,0.016);
      dir.y = lerp(dir.y,0,0.016);
      if(pos.z <= nval(pos.x/scale,pos.y/scale)*scale){
        move = false;
        pos.z = nval(pos.x/scale,pos.y/scale)*scale+5;
      }
      emberm.translate(pos.x,pos.y,pos.z);
      d3.shape(emberm);
      emberm.translate(-pos.x,-pos.y,-pos.z);
    }else{
      lifetime++;
      emberm.translate(pos.x,pos.y,pos.z);
      d3.shape(emberm);
      emberm.translate(-pos.x,-pos.y,-pos.z);
    }
  }
}

void manageembers(){
  for(int i = embers.size()-1; i > -1; i--){
    ember current = embers.get(i);
    if(current.lifetime > 300){
      embers.remove(i);
    }else{
      current.update();
    }
  }
}
