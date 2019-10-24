boolean ishosting = true;
ArrayList<playerc> clients = new ArrayList<playerc>();
int port = 7878;
String serverip = "";
String myip;
String myname = "";
void createmyip(){
  int numb1 = int(constrain((pow(random(0.2,1)+0.25,2))*255.0,0,255));
  String n1;
  if(numb1 > 9){
    if(numb1 > 99){
      n1 = str(numb1);
    }else{
      n1 = "0" + str(numb1);
    }
  }else{
    n1 = "00" + str(numb1);
  }
  int numb2 = int(constrain((pow(random(0.2,1)+0.25,2))*255.0,0,255));
  String n2;
  if(numb2 > 9){
    if(numb2 > 99){
      n2 = str(numb2);
    }else{
      n2 = "0" + str(numb2);
    }
  }else{
    n2 = "00" + str(numb2);
  }
  int numb3 = int(constrain((pow(random(0.2,1)+0.25,2))*255.0,0,255));
  String n3;
  if(numb3 > 9){
    if(numb3 > 99){
      n3 = str(numb3);
    }else{
      n3 = "0" + str(numb3);
    }
  }else{
    n3 = "00" + str(numb3);
  }
  myip = n1+n2+n3;
}

void setupserver(){
  server = new Server(this,port);
  serverip = server.ip();
  client = new Client(this,serverip,port);
}

void setupclient(){
  client = new Client(this,serverip,port);
  println("connected");
}

void serverEvent(Server someServer, Client someClient) {
  println("New connection: " + someClient.ip());
  updatezombiepositions();
  refreshbarriers();
  refreshtowers();
  refreshtorch();
  server.write(sendseed(seed));
}

void joinServer(String ip_,int port_){
  client = new Client(this, ip_, port_);
}

class playerc{
  PVector pos;
  float rotx;
  float roty;
  float rld = 0;
  float sht = 0;
  int wpn = 0;
  int wpnstate = 0;
  String ip;
  int lifetime = 180;
  float hp = 100;
  boolean alive = true;
  int kills = 0;
  color colour;
  PShape nametext;
  String name = "";
  PGraphics textrenderer;
  playerc(PVector pos_,String ip_){
    ip = ip_;
    pos = pos_;
    textrenderer = createGraphics(300,150,P2D);
    textrenderer.smooth(4);
    colour = color(int(ip.substring(0,3)),int(ip.substring(3,6)),int(ip.substring(6,9)));
    nametext = createShape();
    nametext.beginShape(QUAD);
    nametext.textureMode(NORMAL);
    nametext.emissive(255,255,255);
    nametext.noStroke();
    nametext.vertex(-10,0,1,1);
    nametext.vertex(10,0,0,1);
    nametext.vertex(10,10,0,0);
    nametext.vertex(-10,10,1,0);
    nametext.endShape();
  }
  PImage createtexture(){
    textrenderer.beginDraw();
    textrenderer.clear();
    textrenderer.fill(colour);
    textrenderer.noStroke();
    textrenderer.beginShape(QUAD);
    textrenderer.vertex(30,30);
    textrenderer.vertex(40,40);
    textrenderer.vertex(30,50);
    textrenderer.vertex(20,40);    
    textrenderer.endShape();
    textrenderer.fill(255);
    textrenderer.textSize(30);
    textrenderer.text(name,45,50);
    textrenderer.fill(255,0,0);
    textrenderer.rect(20,75,hp*2.6,25);
    textrenderer.endDraw();
    return textrenderer;
  }
  void display(){
    lifetime--;
    d3.translate(pos.x,pos.y,pos.z-10);
    d3.translate(0,0,18);
    d3.rotateZ(radians(bearing(pos,player)));
    d3.rotateX(PI/2);
    d3.shape(nametext);
    d3.rotateX(-PI/2);
    d3.rotateZ(radians(-bearing(pos,player)));
    d3.translate(0,0,-18);
    d3.rotateZ(radians(rotx)+PI/2);
    d3.shape(pmodel);
    d3.translate(2,-4-sht*2.5,2.5);
    d3.rotateX(radians(-roty));
    d3.translate(2,-4-sht*2.5,2.5);
    d3.shape(weapons[wpn][wpnstate]);
    d3.resetMatrix();
  }
}

//m:¬ h:¬ a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
                    
String createmessage(String ip, String name, PVector pos, PVector m, float rld, int wpn, int wpnstate, float sht, float hp){
  String msg = "p" + ip + "i" + name + "¬" +  str(hp) + "`" + str(m.x) + "£" + str(m.y) + "$" + str(rld) + "{" + str(wpn) + ";" + str(wpnstate) + ":" + str(sht) + "|" + str(pos.x) + "&" + str(pos.y) + "%" + str(pos.z) + "]";
  return(msg);
}

String createzmessage(String ip, PVector pos){
  String msg = "m" + ip + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return(msg);
}

String createcmessage(PVector pos, float rot, int id){
  String msg = "c" + str(id) + "i" + str(rot) + "r" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return(msg);
}

String createhmessage(int id, float hp){
  String msg = "d" + str(id) + "h" + str(hp) + "]";
  return(msg);
}

String createbmessage(String ip,PVector pos, PVector vel){
  String msg = "o" + ip + "i" + str(pos.x) + "a" + str(pos.y) + "b" + str(pos.z) + "c" + str(vel.x) + "x" + str(vel.y) + "y" + str(vel.z) + "]";
  return(msg);
}

String removebarrier(float id){
  String msg = "e" + str(id) + "]"; //Used:pmcdoequlntsvabfij   Available: ghkruwxyz
  return msg;
}

String removetower(float id){
  String msg = "a" + str(id) + "]";
  return msg;
}

String placebarrier(float id, PVector pos){
  String msg = "q" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return msg;
}

String placetower(float id, PVector pos){
  String msg = "b" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return msg;
}

String placetorch(float id, PVector pos){
  String msg = "j" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return msg;
}

String removetorch(float id){
  String msg = "f" + str(id) + "]"; //Used:pmcdoequlntsvab   Available: fghijkruwxyz
  return msg;
}

String playerdead(String ip){
  return "u" + ip + "]";
}

String disconnect(String ip){
  return "l" + ip + "]";
}

String killsreport(String ip, int killc){
  return "n" + ip + "i" + str(killc) + "]";
}

String sendseed(int sed){
  return "t" + str(sed) + "]";
}

void playthesong(){
  client.write("s]");
}

void updatescore(){
  client.write("v" + str(points) + "r" + str(round) + "]");
}

void updateclient(){
  if(client.available() != 0){
    String msg = client.readString();
    while(msg.length() != 0 && msg.indexOf("]") != -1){
      String submsg = msg.substring(0,msg.indexOf("]")+1);
      actonmessage(submsg);
      msg = msg.substring(msg.indexOf("]")+1);
    }
    if(msg.length() > 0){
      println(msg);
    }
    client.clear();
  }
  String snt = createmessage(myip,myname,player.copy(),mouse.copy(),reloadtimer,weapon,gunstate,shottimer,health);
  client.write(snt);
  if(ishosting){
    updatescore();
  }
}

void actonmessage(String msg){
  String st = msg.substring(0,1);
  if(st.equals("p")){
    int j = 0;
    boolean foundp = false;
    int index = msg.indexOf('i');
    String ip = msg.substring(1,index); 
    for(int i = 0; i < clients.size(); i++){
      if(clients.get(i).ip.equals(ip)){
        foundp = true;
        j = i;
        break;
      }
    }
    if(foundp == false){
      int index1 = msg.indexOf('i'); //m:¬ h:` a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
      int index2 = msg.indexOf('¬'); //m  
      String name = msg.substring(index1+1,index2);
      index1 = msg.indexOf('¬'); //m
      index2 = msg.indexOf('`'); //h
      float hp = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('`'); 
      index2 = msg.indexOf('£'); //a
      float a = float(msg.substring(index1+1,index2)); //m.x
      index1 = msg.indexOf('£');
      index2 = msg.indexOf('$'); //b
      float b = float(msg.substring(index1+1,index2)); //m.y
      index1 = msg.indexOf('$');
      index2 = msg.indexOf('{'); //c
      float c = float(msg.substring(index1+1,index2)); //rld
      index1 = msg.indexOf('{');
      index2 = msg.indexOf(';'); //d
      int d = int(msg.substring(index1+1,index2)); //wpn
      index1 = msg.indexOf(';');
      index2 = msg.indexOf(':'); //e
      int e = int(msg.substring(index1+1,index2)); //wpnstate
      index1 = msg.indexOf(':');
      index2 = msg.indexOf('|'); //f
      float f = float(msg.substring(index1+1,index2)); //sht
      index1 = msg.indexOf('|'); 
      index2 = msg.indexOf('&'); //x
      float x = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('&');
      index2 = msg.indexOf('%'); //y
      float y = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('%'); 
      index2 = msg.indexOf(']'); //z
      float z = float(msg.substring(index1+1,index2));
      clients.add(new playerc(new PVector(x,y,z),ip));
      playerc current = clients.get(clients.size()-1);
      current.rotx = a;
      current.roty = b;
      current.rld = c;
      current.wpn = d;
      current.wpnstate = e;
      current.sht = f;
      current.hp = hp;
      PImage copy = current.createtexture();
      current.nametext.setTexture(copy);
    }else{
      int index1 = msg.indexOf('i'); //m:¬ h:` a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
      int index2 = msg.indexOf('¬'); //m  
      String name = msg.substring(index1+1,index2);
      index1 = msg.indexOf('¬'); //m
      index2 = msg.indexOf('`'); //h
      float hp = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('`'); 
      index2 = msg.indexOf('£'); //a
      float a = float(msg.substring(index1+1,index2)); //m.x
      index1 = msg.indexOf('£');
      index2 = msg.indexOf('$'); //b
      float b = float(msg.substring(index1+1,index2)); //m.y
      index1 = msg.indexOf('$');
      index2 = msg.indexOf('{'); //c
      float c = float(msg.substring(index1+1,index2)); //rld
      index1 = msg.indexOf('{');
      index2 = msg.indexOf(';'); //d
      int d = int(msg.substring(index1+1,index2)); //wpn
      index1 = msg.indexOf(';');
      index2 = msg.indexOf(':'); //e
      int e = int(msg.substring(index1+1,index2)); //wpnstate
      index1 = msg.indexOf(':');
      index2 = msg.indexOf('|'); //f
      float f = float(msg.substring(index1+1,index2)); //sht
      index1 = msg.indexOf('|'); 
      index2 = msg.indexOf('&'); //x
      float x = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('&');
      index2 = msg.indexOf('%'); //y
      float y = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('%'); 
      index2 = msg.indexOf(']'); //z
      float z = float(msg.substring(index1+1,index2));
      playerc current = clients.get(j);
      current.pos.set(x,y,z);
      current.hp = hp;
      if(current.hp <= 0){
        current.alive = false;
      }else{
        current.alive = true;
      }
      current.rotx = a;
      current.roty = b;
      current.rld = c;
      current.wpn = d;
      current.wpnstate = e;
      current.sht = f;
      current.lifetime = 180;
      current.name = name;
      current.nametext.setTexture(current.createtexture());
    }
  }else if(st.equals("m")){
    boolean foundz = false;
    boolean isdead = false;
    int j = 0;
    int index = msg.indexOf('i');
    int id = int(msg.substring(1,index));
    for(int i = 0; i < zombies.size(); i++){
      if(zombies.get(i).id == id){
        foundz = true;
        j = i;
        break;
      }
    }
    for(int n = 0; n < corpses.size(); n++){
      corpse current = corpses.get(n);
      if(current.id == id){
        isdead = true;
        break;
      }
    }
    if(foundz == false && isdead == false){
      int index1 = msg.indexOf('i'); 
      int index2 = msg.indexOf('x');
      float x = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('x');
      index2 = msg.indexOf('y');
      float y = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('y');;
      index2 = msg.indexOf(']');
      float z = float(msg.substring(index1+1,index2));
      zombies.add(new zombie(new PVector(x,y,z),int(id),100));
    }else if(isdead == false){
      zombie current = zombies.get(j);
      if(current.hp > 0){
        int index1 = msg.indexOf('i');
        int index2 = msg.indexOf('x');
        float x = float(msg.substring(index1+1,index2));
        index1 = index2;
        index2 = msg.indexOf('y');
        float y = float(msg.substring(index1+1,index2));
        index1 = index2;
        index2 = msg.indexOf(']');
        float z = float(msg.substring(index1+1,index2));
        current.pos.x = x;
        current.pos.y = y;
        current.pos.z = z;
      }
    }
  }else if(st.equals("c")){
      int index1 = msg.indexOf('c');
      int index2 = msg.indexOf('i');
      int id = int(msg.substring(index1+1,index2));
      index1 = msg.indexOf('i');
      index2 = msg.indexOf('r');
      float rot = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('r'); 
      index2 = msg.indexOf('x');
      float x = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('x');
      index2 = msg.indexOf('y');
      float y = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('y');
      index2 = msg.indexOf(']');
      float z = float(msg.substring(index1+1,index2));
      boolean f = false;
      for(int i = 0; i < corpses.size(); i++){
        if(corpses.get(i).id == id){
          f = true;
        }
      }
      if(f == false){
        corpses.add(new corpse(new PVector(x,y,z),rot,id));
      }
  }else if(st.equals("d")){
    int index1 = msg.indexOf('d');
    int index2 = msg.indexOf('h');
    int id = int(msg.substring(index1+1,index2));
    index1 = msg.indexOf('h');
    index2 = msg.indexOf(']');
    float hp = float(msg.substring(index1+1,index2));
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      if(current.id == id){
        current.hp = hp;
        points+=20;
        particlesystems.add(new particlesystem(current.pos.copy(),new PVector(0,0,0),0.1,0.01,color(255,20,20),2,10,5,5));
      }
    }
  }else if(st.equals("o")){
      int index1 = msg.indexOf('o');
      int index2 = msg.indexOf('i');
      String id = msg.substring(index1+1,index2);
      index1 = msg.indexOf('i');
      index2 = msg.indexOf('a');
      float a = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('a');
      index2 = msg.indexOf('b');
      float b = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('b');
      index2 = msg.indexOf('c');
      float c = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('c'); 
      index2 = msg.indexOf('x');
      float x = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('x');
      index2 = msg.indexOf('y');
      float y = float(msg.substring(index1+1,index2));
      index1 = msg.indexOf('y');
      index2 = msg.indexOf(']');
      float z = float(msg.substring(index1+1,index2));
      if(id.equals(myip) == false){
        bullets.add(new projectile(new PVector(a,b,c),new PVector(x,y,z),0));
      }
      //if(gunshot[shotcount].isPlaying()){
      //  gunshot[shotcount].stop();
      //}
      gunshot[shotcount].play();
      soundobjects.add(new soundobject(gunshot[shotcount],new PVector(a+x,b+y,c+z)));
      println("Shot"+millis());
      shotcount++;
      if(shotcount > gunshot.length-1){
        shotcount = 0;
      }
  }else if(st.equals("s")){
    if(song.isPlaying()){
      song.stop();
    }
    song.play();
  }else if(st.equals("v")){ //("v" + str(points) + "r" + str(round) + "z");
    if(ishosting == false){
      points = float(msg.substring(msg.indexOf('v')+1,msg.indexOf('r')));
      int newround = int(msg.substring(msg.indexOf('r')+1,msg.indexOf(']')));
      if(newround != round){
        for(int i = zombies.size()-1; i > -1; i--){
          zombies.remove(i);
        }
        if(alive == false){
          alive = true;
          weapon = 0;
          gunstate = 1;
        }
      }
    }
  }else if(st.equals("e")){
    float id = float(msg.substring(msg.indexOf('e')+1,msg.indexOf(']')));
    for(int i = 0; i < barriers.size(); i++){
      if(barriers.get(i).id == id){
        barriers.remove(i);
        i--;
      }
    }
  }else if(st.equals("q")){//msg = "q" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "z";
    int index1 = msg.indexOf('q');
    int index2 = msg.indexOf('i');
    float id = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('i');
    index2 = msg.indexOf('x');
    float x = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('x');
    index2 = msg.indexOf('y');
    float y = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('y');
    index2 = msg.indexOf(']');
    float z = float(msg.substring(index1+1,index2));
    boolean f = false;
    for(int i = 0; i < barriers.size(); i++){
      if(barriers.get(i).id == id){
        f = true;
      }
    }
    if(f == false){
      barriers.add(new barrier(new PVector(x,y,z),0,id));
      points-=50;
    }
  }else if(st.equals("u")){
    int index1 = msg.indexOf('u');
    int index2 = msg.indexOf(']');
    String ip = msg.substring(index1+1,index2);
    for(int i = 0; i < clients.size(); i++){
      if(ip.equals(clients.get(i).ip)){
        println("DEAD");
        clients.get(i).alive = false;
      }
    }
  }else if(st.equals("l")){
    int index1 = msg.indexOf('l');
    int index2 = msg.indexOf(']');
    String ip = msg.substring(index1+1,index2);
    for(int i = clients.size()-1; i > -1; i--){
      if(ip.equals(clients.get(i).ip)){
        clients.remove(i);
      }
    }
  }else if(st.equals("n")){
    int index1 = 0;
    int index2 = msg.indexOf('i');
    String ip = msg.substring(index1+1,index2);
    index1 = msg.indexOf('i');
    index2 = msg.indexOf(']');
    int kills = int(msg.substring(index1+1,index2));
    for(int i = 0; i < clients.size(); i++){
      playerc current = clients.get(i);
      if(current.ip.equals(ip)){
        current.kills = kills;
      }
    }
  }else if(st.equals("t")){
    int serverseed = int(msg.substring(1,msg.length()-1));
    println(serverseed,msg);
    if(seed != serverseed){
      seed = serverseed;
      noiseSeed(seed);
      println("Seed change!");
      trees = new PVector[10000];
      c = new chunk(new PVector(0,0));
    }
  }else if(st.equals("b")){//msg = "q" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "z";
    int index1 = msg.indexOf('b');
    int index2 = msg.indexOf('i');
    float id = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('i');
    index2 = msg.indexOf('x');
    float x = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('x');
    index2 = msg.indexOf('y');
    float y = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('y');
    index2 = msg.indexOf(']');
    float z = float(msg.substring(index1+1,index2));
    boolean f = false;
    for(int i = 0; i < towers.size(); i++){
      if(towers.get(i).id == id){
        f = true;
      }
    }
    if(f == false){
      towers.add(new tower(new PVector(x,y,z),0,id));
      points-=200;
    }
  }else if(st.equals("a")){
    float id = float(msg.substring(msg.indexOf('a')+1,msg.indexOf(']')));
    for(int i = 0; i < towers.size(); i++){
      if(id == towerid){
        intower = false;
      }
      if(towers.get(i).id == id){
        towers.remove(i);
        i--;
      }
    }
  }else if(st.equals("j")){//msg = "q" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "z";
    int index1 = msg.indexOf('j');
    int index2 = msg.indexOf('i');
    float id = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('i');
    index2 = msg.indexOf('x');
    float x = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('x');
    index2 = msg.indexOf('y');
    float y = float(msg.substring(index1+1,index2));
    index1 = msg.indexOf('y');
    index2 = msg.indexOf(']');
    float z = float(msg.substring(index1+1,index2));
    boolean f = false;
    for(int i = 0; i < torches.size(); i++){
      if(torches.get(i).id == id){
        f = true;
      }
    }
    if(f == false){
      torches.add(new torch(new PVector(x,y,z),0,id));
      points-=200;
    }
  }else if(st.equals("f")){
    float id = float(msg.substring(msg.indexOf('f')+1,msg.indexOf(']')));
    for(int i = 0; i < torches.size(); i++){
      if(torches.get(i).id == id){
        torches.remove(i);
        i--;
      }
    }
  }else{
    println("ERROR : " + msg);
  }
}

void updatezombiepositions(){
  for(int i = 0; i < zombies.size(); i++){
    zombie current = zombies.get(i);
    String msg = createzmessage(str(current.id),current.pos);
    server.write(msg);
  }
}

void manageserver(){
  Client msg;
  msg = server.available();
  while(msg != null){
    server.write(msg.readString());
    msg = server.available();
  }
  updatezombiepositions();
}

void drawplayers(){
  for(int i = clients.size()-1; i > -1; i--){
    if(clients.get(i).lifetime <= 0){
      clients.remove(i);
    }else{
      if(clients.get(i).ip.equals(myip) == false && clients.get(i).alive){
        clients.get(i).display();
      }
    }
  }
}
