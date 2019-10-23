ArrayList<soundobject> soundobjects = new ArrayList<soundobject>();
PVector leftear;
PVector rightear;
class soundobject{
  boolean stereo = true;
  SoundFile sound;
  PVector pos;
  soundobject(SoundFile toplay, PVector pos_){
    pos = pos_.copy();
    sound = toplay;
    if(sound.isPlaying() == false){
      sound.play();
    }
    calculate();
  }
  void calculate(){
    float d = (1.0/(dist(player.x,player.y,player.z,pos.x,pos.y,pos.z)*soundfalloff));
    if(d > 1){
      d = 1.0;
    }
    sound.amp(d);
    PVector vecto = vectortowards(pos,player);
    PVector left = new PVector(vecto.x*leftear.x,vecto.y*leftear.y,vecto.z*leftear.z);
    PVector right = new PVector(vecto.x*rightear.x,vecto.y*rightear.y,vecto.z*rightear.z);
    float lefttotal = left.x+left.y+left.z;
    float righttotal = right.x+right.y+right.z;
    if(lefttotal <= 0.05){
      lefttotal = 0.05;
    }
    if(righttotal <= 0.05){
      righttotal = 0.05;
    }
    sound.pan(lefttotal-righttotal);
  }
}

void updatesounds(){
  leftear = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)-PI/1.95),player.y+sin(radians(mouse.x)-PI/1.95),player.z));
  rightear = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)+PI/1.95),player.y+sin(radians(mouse.x)+PI/1.95),player.z));
  for(int i = soundobjects.size()-1; i > -1; i--){
    soundobject current = soundobjects.get(i);
    if(current.sound.isPlaying() == false){
      current.sound.stop();
      soundobjects.remove(i);
    }else{
      current.calculate();
    }
  }
}
