tile t1;
tile t2;
void setuptiles(){
  t1 = new tile(-250,1);
  t2 = new tile(624,2);
}

class tile{
  float x;
  int id;
  tile(float x_, int id_){
    x = x_;
    id = id_;
  }
  
  void display(){
    x = x + 2.0 ;
    image(backg,x,0);
    if(player-250 > x+874){
      if(id == 1){
        x = t2.x+874;
      }else{
        x = t1.x+874;
      }
    }
  }
  
  void still(){
    image(backg,x,0);
  }
}

void resettiles(){
  t1 = new tile(0,1);
  t2 = new tile(874,2);
}

void tilemanager(){
  t1.display();
  t2.display();
}

void tilestill(){
  t1.still();
  t2.still();
}
