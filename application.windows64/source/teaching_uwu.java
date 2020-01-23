import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class teaching_uwu extends PApplet {


Server server;
Client client;

float playerheight = 4;
float fall = 0;
boolean state = false;
int score = 0;
PImage flappy;
PShape birb;
PImage toppipe;
PImage botpipe;
PImage backg;
pipe[] pipes;
// > greater than, < lessthan , == equal too, >= greater than or equal too, <= less than or equal too

public void setup(){
  
  textSize(20);
  noise(100);
  flappy = loadImage("birb.png");
  toppipe = loadImage("toppipe.png");
  botpipe = loadImage("botpipe.png");
  backg = loadImage("backg.png");
  createbirb();
  setuptiles();
  setupmulti();
  pipes = new pipe[200];
  for(int i = 0; i < 200; i++){
    pipes[i] = new pipe(750+i*250);
  }
}

public void draw(){
  if(inmenu){
    drawmenu();
  }else{
    managemulti();
    if(state == false){
      calcfall();
      manageplayer();
      state = onground();
      translate(-(player-250),0);
      tilemanager();
      managepipes();
      displayplayers();
      managebirb();
      translate(player-250,0);
      displayScore();
    }else{
      translate(-(player-250),0);
      tilestill();
      managepipes();
      displayplayers();
      managebirb();
      translate(player-250,0);
      displayScore();
    }
  }
}

public void keyPressed(){
  if(state == false){
    playerheight = playerheight - 1;
    fall = fall - 14;
  }else{
    state = false;
    playerheight = 250;
    score = 0;
    resetpipes();
    resettiles();
    player = 250;
  }
}

public void managepipes(){
  for(int i = 0; i < pipes.length; i++){
    pipes[i].display();
  }
}

public void resetpipes(){
  for(int i = 0; i < pipes.length; i++){
    pipes[i].avoided = false;
  }
}

public void calcfall(){
  if(playerheight >= 475){
    playerheight = 475;
    fall = 0;
  }else{
    fall = fall + 0.45f;
    playerheight = playerheight + fall;
  }  
  fall = min(fall,9.5f);
}

public boolean onground(){
  if(playerheight == 475 || playerheight == 25){
    return true;
  }else{
    return false;
  }
}

class pipe{
  float x;
  float y;
  float top;
  float bot;
  float gap; 
  boolean avoided = false;
  pipe(float x_){
    x = x_;
    gap = noise(x)*80+120;
    y = noise(x*2)*280+110;
    avoided = false;
  }
  public void display(){
    //x = x - 2.5; 
    fill(50);
    image(toppipe,x-20,y-gap/2.0f-456,70,456);
    image(botpipe,x-20,y+gap/2.0f,70,456);
    top = y-gap/2.0f;
    bot = y+gap/2.0f;
    if(x < -55){
      x = 500;
      y = random(110,390);
      gap = random(120,200);
      avoided = false;
    }
    if(x < player+45 && x > player-80 && (playerheight+23 > bot || playerheight-23 < top)){
      state = true;
    }
    if(x < player-80 && avoided == false){
      avoided = true;
      score = score + 1;
    }
  }
}

public void createbirb(){
  birb = createShape();
  birb.beginShape(QUAD);
  birb.texture(flappy);
  birb.textureMode(NORMAL);
  birb.noFill();
  birb.noStroke();
  birb.vertex(-30,-30,0,0);
  birb.vertex(30,-30,1,0);
  birb.vertex(30,30,1,1);
  birb.vertex(-30,30,0,1);
  birb.endShape();
}

public void managebirb(){
  float d = fall;
  d/=10.0f;
  translate(player,playerheight);
  rotate(sin(d)-PI/10.0f);
  shape(birb);
  rotate(-sin(d)+PI/10.0f);
  translate(-player,-playerheight);
}

public void displayScore(){
  fill(255);
  text("Score: " + str(score),50,50);
}
tile t1;
tile t2;
public void setuptiles(){
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
  
  public void display(){
    x = x + 2.0f ;
    image(backg,x,0);
    if(player-250 > x+874){
      if(id == 1){
        x = t2.x+874;
      }else{
        x = t1.x+874;
      }
    }
  }
  
  public void still(){
    image(backg,x,0);
  }
}

public void resettiles(){
  t1 = new tile(0,1);
  t2 = new tile(874,2);
}

public void tilemanager(){
  t1.display();
  t2.display();
}

public void tilestill(){
  t1.still();
  t2.still();
}

boolean inmenu = true;

public void drawmenu(){
  background(0);
  if(dist(mouseX,mouseY,150,350) < 100){
    fill(255);
    if(mousePressed){
      joinServer();
      inmenu = false;
    }
  }else{
    fill(150);
  }
  text("Join",150,350);
  if(dist(mouseX,mouseY,150,150) < 100){
    fill(255);
    if(mousePressed){
      hostServer();
      inmenu = false;
    }
  }else{
    fill(150);
  }
  text("Play",150,150);
}
String serverip = "";
boolean ishost = false;
ArrayList<playerc> players = new ArrayList<playerc>();
float myid;

public void setupmulti(){
  serverip = trim(loadStrings("data/serverip.txt")[0]);
  myid = random(1000);
}

public void joinServer(){
  client = new Client(this,serverip,7777);
}

public void hostServer(){
  server = new Server(this,7777);
  client = new Client(this,serverip,7777);
  ishost = true;
}

public void managemulti(){
  if(ishost){
    updateclient();
    updateserver();
  }else{
    updateclient();
  }
}

public void updateclient(){
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
      float id = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = index2;
      index2 = msg.indexOf('y');
      float x = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = index2;
      index2 = msg.indexOf('r');
      float y = PApplet.parseFloat(msg.substring(index1+1,index2));
      float r = PApplet.parseFloat(msg.substring(index2+1));
      int index = clientFound(id);
      if(index != -1){
        players.get(index).update(x,y,r);
      }else{
        players.add(new playerc(id));
      }
    }
  }
  String clientmsg = "i"+str(myid)+"x"+str(player)+"y"+str(playerheight)+"r"+str(fall/10.0f)+"|";
  client.write(clientmsg);
}

public int clientFound(float id){
  for(int i = players.size()-1; i > -1; i--){
    if(players.get(i).id == id){
      return i;
    }
  }
  return -1;
}

//Message format: i_id_x_playerx_y_playery_r_rotation_|

public void updateserver(){
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
  
  public void display(){
    if(id != myid){
      translate(x,y);
      rotate(sin(d)-PI/10.0f);
      shape(birb);
      rotate(-sin(d)+PI/10.0f);
      translate(-x,-y);  
    }
  }
  
  public void update(float x_,float y_,float d_){
    x = x_; 
    y = y_;
    d = d_;
  }
}

public void displayplayers(){
  for(int i = players.size()-1; i > -1; i--){
    players.get(i).display();
  }
}



float player = 0;
public void manageplayer(){
  player+=2.5f;
}
  public void settings() {  size(500,500,P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "teaching_uwu" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
