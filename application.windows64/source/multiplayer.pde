String serverip = "";
boolean ishost = false;
ArrayList<playerc> players = new ArrayList<playerc>();
float myid;

void setupmulti(){
  serverip = trim(loadStrings("data/serverip.txt")[0]);
  myid = random(1000);
}

void joinServer(){
  client = new Client(this,serverip,7777);
}

void hostServer(){
  server = new Server(this,7777);
  client = new Client(this,serverip,7777);
  ishost = true;
}

void managemulti(){
  if(ishost){
    updateclient();
    updateserver();
  }else{
    updateclient();
  }
}

void updateclient(){
  String data = "";
  StringList array = new StringList();
  if(client.available() > 0){
    data = client.readString();
    boolean active = true;
    while(active){
      try{
        if(data.length() > 0){
          int endindex = data.indexOf('|');
          String msg = data.substring(0,endindex);
          data = data.substring(endindex+1);
          array.append(msg);
        }else{
          active = false;
        }
      }catch(Exception e){
        active = false;
      }
    }
    for(int i = 0; i < array.size(); i++){
      String msg = array.get(i);
      int index1 = msg.indexOf('i');
      int index2 = msg.indexOf('x');
      float id = float(msg.substring(index1+1,index2));
      index1 = index2;
      index2 = msg.indexOf('y');
      float x = float(msg.substring(index1+1,index2));
      index1 = index2;
      index2 = msg.indexOf('r');
      float y = float(msg.substring(index1+1,index2));
      float r = float(msg.substring(index2+1));
      int index = clientFound(id);
      if(index != -1){
        players.get(index).update(x,y,r);
      }else{
        players.add(new playerc(id));
      }
    }
  }
  String clientmsg = "i"+str(myid)+"x"+str(player)+"y"+str(playerheight)+"r"+str(fall/10.0)+"|";
  client.write(clientmsg);
}

int clientFound(float id){
  for(int i = players.size()-1; i > -1; i--){
    if(players.get(i).id == id){
      return i;
    }
  }
  return -1;
}

//Message format: i_id_x_playerx_y_playery_r_rotation_|

void updateserver(){
  Client msg = server.available();
  if(msg != null){
    server.write(msg.readString());
  }
}

class playerc{
  float x;
  float y;
  float d;
  float id;
  
  playerc(float id_){
    id = id_;
  }
  
  void display(){
    if(id != myid){
      translate(x,y);
      rotate(sin(d)-PI/10.0);
      shape(birb);
      rotate(-sin(d)+PI/10.0);
      translate(-x,-y);  
    }
  }
  
  void update(float x_,float y_,float d_){
    x = x_; 
    y = y_;
    d = d_;
  }
}

void displayplayers(){
  for(int i = players.size()-1; i > -1; i--){
    players.get(i).display();
  }
}
