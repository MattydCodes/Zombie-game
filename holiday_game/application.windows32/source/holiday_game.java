import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 
import processing.net.*; 
import java.awt.Robot; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class holiday_game extends PApplet {


SoundFile[] gunshot;
SoundFile[] zombiesound;
SoundFile song;

Server server;
Client client;

Robot robot;
chunk c;
int seed;
PShader shader;
public void setup(){
  
  createmyip();
  blood = loadShader("data/shaders/health.glsl");
  song = new SoundFile(this,"data/sounds/song.mp3");
  shader = loadShader("shaders/frag.glsl", "shaders/vert.glsl");
  gunshot = new SoundFile[30];
  zombiesound = new SoundFile[200];
  for(int i = 0; i < gunshot.length; i++){
    gunshot[i] = new SoundFile(this,"data/sounds/gunshot.wav");
  }
  for(int i = 0; i < zombiesound.length; i++){
    zombiesound[i] = new SoundFile(this,"data/sounds/zomb" + str(round(random(1,5))) + ".wav"); 
  }
  song.amp(0.07f);
  setupbullet();
  seed = PApplet.parseInt(random(1000));
  noiseSeed(seed);
  trees = new PVector[10000];
  c = new chunk(new PVector(0,0));
  try{
    robot = new Robot();
    robot.setAutoDelay(0);
  }catch(Exception e){
    println(e);
  }
  barrel[0] = loadshape("data/barrel1.obj","data/Barreltext.png");
  barrel[0].rotateX(PI/2);
  barrel[0].scale(2);
  towerm[0] = loadshape("data/watchtower1.obj","data/towertext1.png");
  towerm[0].rotateX(PI/2);
  towerm[0].scale(2);  
  pmodel = loadshape("data/playermodel.obj","data/playertext.png");
  pmodel.rotateX(PI/2);
  pmodel.rotateZ(PI);
  pmodel.scale(1.1f);
  zombiem1 = loadshape("data/zombiewalk1.obj","data/texture.png");
  zombiem1.rotateX(PI/2);
  zombiem2 = loadshape("data/zombiewalk2.obj","data/texture.png");
  zombiem2.rotateX(PI/2);
  zombiea1 = loadshape("data/zombieattack1.obj","data/texture.png");
  zombiea1.rotateX(PI/2);
  zombiea2 = loadshape("data/zombieattack2.obj","data/texture.png");
  zombiea2.rotateX(PI/2);
  pistol1 = loadshape("data/pistol1R.obj","data/PistolTextR.png");
  pistol1.rotateX(PI/2);
  pistol1.rotateZ(PI);
  pistol2 = loadshape("data/Pistol2R.obj","data/PistolTextR.png");
  pistol2.rotateX(PI/2);
  pistol2.rotateZ(PI);
  pistol1.scale(0.75f);
  pistol2.scale(0.75f);
  pistol1.translate(0.05f,0,1.3f);
  pistol2.translate(0.05f,0,1.3f);
  smg1 = loadshape("data/smg1R.obj","data/smgtextR.png");
  smg2 = loadshape("data/smg2R.obj","data/smgtextR.png");
  smg1.rotateX(PI/2);
  smg2.rotateX(PI/2);
  smg1.translate(0.05f,0,0.6f);
  smg2.translate(0.05f,0,0.6f);
  smg1.rotateZ(PI);
  smg2.rotateZ(PI);
  smg1.scale(0.75f);
  smg2.scale(0.75f);
  sniper1 = loadshape("data/sniper1R.obj","data/snipertextR.png");
  sniper2 = loadshape("data/sniper2R.obj","data/snipertextR.png");
  sniper1.rotateX(PI/2);
  sniper2.rotateX(PI/2);
  sniper1.rotateZ(PI);
  sniper2.rotateZ(PI);
  sniper1.translate(0.05f,0,1.1f);
  sniper2.translate(0.05f,0,1.1f);
  sniper1.scale(0.75f);
  sniper2.scale(0.75f);
  weaponcrate = loadshape("data/weaponcrate.obj","data/cratetext.png");
  weaponcrate.rotateX(PI/2);
  setupweapons();
  bulletico = loadImage("data/images/bulletico.png");
  crosshair = loadImage("data/images/crosshair.png");
  loadmenu();
  ui = createGraphics(1920,1080,P2D);
  textrenderer = createGraphics(300,150,P2D);
  d3 = createGraphics(1920,1080,P3D);
  d3.smooth(4);
  ui.smooth(4);
  textrenderer.smooth(4);
}
public void draw(){
  if(menu){
    drawmenu();
  }else if(alldead){
    outro();
    if(ishosting){
      manageserver();
      updateclient();
    }else{
      updateclient();
    }    
  }else{
    draw3d();
    if(ishosting){
      manageserver();
      updateclient();
    }else{
      updateclient();
    }
  }
}

public void draw3d(){
  d3.beginDraw();
  d3.shader(shader);
  if(alive){
    move();
  }
  treehitboxes();
  d3.background(63.75f);
  d3.directionalLight(180,150,150,0,0.05f,-1);
  d3.shape(c.terrain);
  managedrops();
  if(alive){
    manageshooting();
  }
  managebullets();
  if(ishosting && started){
    managezombies();
  }else{
    movezombies();
  }
  removedeadzombies();
  managebarriers();
  managetowers();
  managecorpses();
  manageparticles();
  drawplayers();
  if(alive){
    showbarrel();
    showtower();
    cam();
    displayweapon();
  }else{
    deadcam();
    playerdead(myip);
    boolean found = false;
    for(int i = 0; i < clients.size(); i++){
      playerc current = clients.get(i);
      if(current.alive){
        found = true;
      }
    }
    if(found == false){
      alldead = true;
    }
  }
  d3.endDraw();
  image(d3,0,0,width,height);
  if(alive){
    blood.set("hp",health/100.0f);
    health = constrain(health,0,100);
    blood.set("millis",PApplet.parseFloat(millis()));
  }
  if(alive){
    filter(blood);
    drawui();
  }
  updatesounds();
}
PShape[] barrel = new PShape[1];
ArrayList<barrier> barriers = new ArrayList<barrier>();
class barrier{
  PVector pos;
  float hp;
  int type = 0;
  float id;
  barrier(PVector pos_, int type_, float id_){
    pos = pos_.copy();
    type = type_;
    if(type == 0){
      hp = 750;
    }
    id = id_;
  }
  public void update(){
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(current.pos.x,current.pos.y,pos.x,pos.y);
      if(d < 20){
        PVector restrict = vectortowards(pos,current.pos);
        float t = 9*1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
        current.pos.x = lerp(current.pos.x,current.pos.x+restrict.x*zombspeed/speed*t,(1.0f-d/20.0f));
        current.pos.y = lerp(current.pos.y,current.pos.y+restrict.y*zombspeed/speed*t,(1.0f-d/20.0f));
        if(ishosting){
          hp-=0.5f*(round/10.0f);
        }
      }
    }
    float d = dist(player.x,player.y,player.z,pos.x,pos.y,pos.z);
    if(d < 20){
      PVector restrict = vectortowards(pos,player);
      float t = 9*1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));   
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,(1.0f-d/20.0f));
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,(1.0f-d/20.0f));
      player.z = lerp(player.z,player.z+restrict.y*movespeed/speed*t,(1.0f-d/20.0f));
      fall-=restrict.z*0.25f;
    }
  }
  public void display(){
    d3.translate(pos.x,pos.y,pos.z);
    d3.shape(barrel[type]);
    d3.translate(-pos.x,-pos.y,-pos.z);
  }
}
public void managebarriers(){
  for(int i = barriers.size()-1; i > -1; i--){
    barrier current = barriers.get(i);
    current.update();
    current.display();
    if(current.hp <= 0 && ishosting){
      client.write(removebarrier(current.id));
    }
  }
}

public void placebarrel(PVector pos){
  pos = pos.copy();
  pos.z = nval(pos.x/scale,pos.y/scale)*scale+15;
  pos.x = round(pos.x/10)*10;
  pos.y = round(pos.y/10)*10;
  client.write(placebarrier(random(10000),pos));
}

public void showbarrel(){
  if(keys[7] == 1 && points >= 50){
    PVector vec = player.copy().add(new PVector(cos(radians(mouse.x))*40,sin(radians(mouse.x))*40,0));
    vec.x = round(vec.x/10)*10;
    vec.y = round(vec.y/10)*10;
    vec.z = nval(vec.x/scale,vec.y/scale)*scale+18;
    d3.translate(vec.x,vec.y,vec.z);
    d3.shape(barrel[0]);
    d3.resetMatrix();
  }
}

public void refreshbarriers(){
  for(int i = 0; i < barriers.size(); i++){
    client.write(placebarrier(barriers.get(i).id,barriers.get(i).pos));
  }
}
boolean alldead = false;
int outroframe = 0;
public void outro(){
   client.write(killsreport(myip,kills));
   d3.beginDraw();
   menudraw();
   for(int i = 0; i < zombies.size(); i++){
     zombie current = zombies.get(i);
     current.display();
   }
   d3.endDraw();
   ui.beginDraw();
   ui.clear();
   for(int i = 0; i < clients.size(); i++){
     playerc current = clients.get(i);
     ui.fill(current.colour);
     ui.noStroke();
     ui.beginShape();
     ui.vertex(720,230+i*100);
     ui.vertex(730,240+i*100);
     ui.vertex(720,250+i*100);
     ui.vertex(710,240+i*100);    
     ui.endShape();
     ui.fill(255);
     ui.textSize(30);
     ui.text("Name: " + current.name + "  Kills: " + str(current.kills), 740, 250+i*100);
   }
   ui.endDraw();
   outroframe++;
   image(d3,0,0,width,height);
   image(ui,0,0,width,height);
   if(outroframe >= 600){
     outroframe = 0;
     alldead = false;
     health = 100;
     alive = true;
     started = false;
     round = 0;
     kills = 0;
     weapon = 0;
     points = 500;
     player.x = 2000+random(-100,100);
     player.y = 2000+random(-100,100);
     for(int i = zombies.size()-1; i > -1; i--){
       zombies.remove(i);
     }
     for(int i = barriers.size()-1; i > -1; i--){
       barriers.remove(i);
     }
   }
}
boolean menu = true;
PImage hostd;
PImage hosts;
PImage joind;
PImage joins;
boolean ipselect = false;
boolean nameselect = false;
  //m:¬ h:` a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
String typeable = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ1234567890.,/<>?'@#~-_+=!^*() ";
public boolean istypeable(String key_){
  for(int i = 0; i < typeable.length(); i++){
    if(key_.equals(typeable.substring(i,i+1))){
      return true;
    }
  }
  return false;
}

public void loadmenu(){
  hostd = loadImage("images/hostd.png");
  hosts = loadImage("images/hosts.png");
  joind = loadImage("images/joind.png");
  joins = loadImage("images/joins.png");
}

public void drawmenu(){
  menudraw();
  image(d3,0,0,width,height);
  ui.beginDraw();
  ui.clear();
  if(mouseX > 720 && mouseX < 1220){
    if(mouseY > 300 && mouseY < 500){
      ui.image(hosts,720,300);
      if(mousePressed && mouseButton == LEFT){
        ishosting = true;
        setupserver();
        menu = false;
        myname = myname + " ";
        noCursor();
      }      
    }else{
      ui.image(hostd,720,300);
    }
    if(mouseY > 500 && mouseY < 700){
      ui.image(joins,720,500);
      if(mousePressed && mouseButton == LEFT){
        ishosting = false;
        setupclient();
        menu = false;
        myname = myname + " ";
        noCursor();
      }
    }else{
      ui.image(joind,720,500);
    }
    
    if(mouseY > 710 && mouseY < 723){
      if(mousePressed && mouseButton == LEFT){
        ipselect = true;
        nameselect = false;
      }
    }   
    if(mouseY > 760 && mouseY < 783){
      if(mousePressed && mouseButton == LEFT){
        nameselect = true;
        ipselect = false;
      }
    }
  }else{
    ui.image(hostd,720,300);
    ui.image(joind,720,500);
  }
  ui.fill(0);
  ui.textSize(20);
  ui.text("IP: " + serverip,820,730);
  ui.text("UserName: " + myname,820,780);
  if(ipselect){
    ui.fill(255,255,255,100);
    ui.stroke(0);
    ui.rect(820,710,300,23);
    if(PApplet.parseInt(frameCount/30)%2 == 0){
      ui.line(842+serverip.length()*12,712,842+serverip.length()*12,731);
    }
  }else{
    ui.noFill();
    ui.stroke(0);
    ui.rect(820,710,300,23);
  }
  if(nameselect){
    ui.fill(255,255,255,100);
    ui.stroke(0);
    ui.rect(820,760,300,23);  
    if(PApplet.parseInt(frameCount/30)%2 == 0){
      ui.line(930+myname.length()*12,762,930+myname.length()*12,781);
    }
  }else{
    ui.noFill();
    ui.stroke(0);
    ui.rect(820,760,300,23);       
  }
  ui.endDraw();
  image(ui,0,0,width,height);
}
public void menudraw(){
  d3.beginDraw();
  d3.shader(shader);
  d3.background(63.75f);
  d3.directionalLight(180,150,150,0,0.05f,-1);
  d3.shape(c.terrain);
  menucam();
  d3.endDraw();
}
PVector mouse = new PVector(0,0);
//camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0)
//camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
public void cam(){
  d3.perspective(lerp(PI/3.0f,PI/6.0f,scopelerp), PApplet.parseFloat(width)/PApplet.parseFloat(height), (height/2.0f) / tan(PI/3.0f/2.0f)/500.0f, (height/2.0f) / tan(PI/3.0f/2.0f)*30.0f);
  d3.camera(player.x,player.y,player.z,player.x+cos(radians(mouse.x)),player.y+sin(radians(mouse.x)),player.z+sin(radians(mouse.y)),0,0,-1);
}

public void deadcam(){
  d3.camera(player.x,player.y,player.z+radius*scale+cos(millis()/5000.0f)*500,player.x-100,player.y,player.z,0,0,-1);
}

public void menucam(){
  d3.camera(2000+cos(millis()/10000.0f)*radius*scale*0.9f,2000+sin(millis()/10000.0f)*radius*scale*0.9f,600,2000,2000,150,0,0,-1);
}

public void mouseMoved(){
  if(menu == false){
    if(scoping){
      mouse.x-=(width/2-mouseX)/50.0f*0.5f;
      mouse.y+=(height/2-mouseY)/50.0f*0.5f;
    }else{
      mouse.x-=(width/2-mouseX)/50.0f;
      mouse.y+=(height/2-mouseY)/50.0f;
    }
    mouse.y = constrain(mouse.y,-90,90);
    robot.mouseMove(width/2,height/2);
  }
}

public void mouseDragged(){
  if(menu == false){
    if(scoping){
      mouse.x-=(width/2-mouseX)/50.0f*0.3f;
      mouse.y+=(height/2-mouseY)/50.0f*0.3f;
    }else{
      mouse.x-=(width/2-mouseX)/50.0f;
      mouse.y+=(height/2-mouseY)/50.0f;
    }
    mouse.y = constrain(mouse.y,-90,90);
    robot.mouseMove(width/2,height/2);
  }
}
boolean ishosting = true;
ArrayList<playerc> clients = new ArrayList<playerc>();
int port = 7878;
String serverip = "";
String myip;
String myname = "";
PGraphics textrenderer;
public void createmyip(){
  int numb1 = PApplet.parseInt(constrain((pow(random(0.2f,1)+0.25f,2))*255.0f,0,255));
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
  int numb2 = PApplet.parseInt(constrain((pow(random(0.2f,1)+0.25f,2))*255.0f,0,255));
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
  int numb3 = PApplet.parseInt(constrain((pow(random(0.2f,1)+0.25f,2))*255.0f,0,255));
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

public void setupserver(){
  server = new Server(this,port);
  serverip = server.ip();
  client = new Client(this,serverip,port);
}

public void setupclient(){
  client = new Client(this,serverip,port);
  println("connected");
}

public void serverEvent(Server someServer, Client someClient) {
  println("New connection: " + someClient.ip());
  updatezombiepositions();
  refreshbarriers();
  refreshtowers();
  server.write(sendseed(seed));
}

public void joinServer(String ip_,int port_){
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
  int colour;
  PShape nametext;
  String name = "";
  playerc(PVector pos_,String ip_){
    ip = ip_;
    pos = pos_;
    colour = color(PApplet.parseInt(ip.substring(0,3)),PApplet.parseInt(ip.substring(3,6)),PApplet.parseInt(ip.substring(6,9)));
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
  public PImage createtexture(){
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
    textrenderer.rect(20,75,hp*2.6f,25);
    textrenderer.endDraw();
    return textrenderer;
  }
  public void display(){
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
    d3.translate(2,-4-sht*2.5f,2.5f);
    d3.rotateX(radians(-roty));
    d3.translate(2,-4-sht*2.5f,2.5f);
    d3.shape(weapons[wpn][wpnstate]);
    d3.resetMatrix();
  }
}

//m:¬ h:¬ a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
                    
public String createmessage(String ip, String name, PVector pos, PVector m, float rld, int wpn, int wpnstate, float sht, float hp){
  String msg = "p" + ip + "i" + name + "¬" +  str(hp) + "`" + str(m.x) + "£" + str(m.y) + "$" + str(rld) + "{" + str(wpn) + ";" + str(wpnstate) + ":" + str(sht) + "|" + str(pos.x) + "&" + str(pos.y) + "%" + str(pos.z) + "]";
  return(msg);
}

public String createzmessage(String ip, PVector pos){
  String msg = "m" + ip + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return(msg);
}

public String createcmessage(PVector pos, float rot, int id){
  String msg = "c" + str(id) + "i" + str(rot) + "r" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return(msg);
}

public String createhmessage(int id, float hp){
  String msg = "d" + str(id) + "h" + str(hp) + "]";
  return(msg);
}

public String createbmessage(String ip,PVector pos, PVector vel){
  String msg = "o" + ip + "i" + str(pos.x) + "a" + str(pos.y) + "b" + str(pos.z) + "c" + str(vel.x) + "x" + str(vel.y) + "y" + str(vel.z) + "]";
  return(msg);
}

public String removebarrier(float id){
  String msg = "e" + str(id) + "]"; //Used:pmcdoequlntsva   Available: bfghijkruwxyz
  return msg;
}

public String removetower(float id){
  String msg = "a" + str(id) + "]";
  return msg;
}

public String placebarrier(float id, PVector pos){
  String msg = "q" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return msg;
}

public String placetower(float id, PVector pos){
  String msg = "b" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "]";
  return msg;
}

public String playerdead(String ip){
  return "u" + ip + "]";
}

public String disconnect(String ip){
  return "l" + ip + "]";
}

public String killsreport(String ip, int killc){
  return "n" + ip + "i" + str(killc) + "]";
}

public String sendseed(int sed){
  return "t" + str(sed) + "]";
}

public void playthesong(){
  client.write("s]");
}

public void updatescore(){
  client.write("v" + str(points) + "r" + str(round) + "]");
}

public void updateclient(){
  if(client.available() != 0){
    String msg = client.readString();
    while(msg.length() != 0){
      String submsg = msg.substring(0,msg.indexOf("]")+1);
      actonmessage(submsg);
      msg = msg.substring(msg.indexOf("]")+1);
    }
  }
  String snt = createmessage(myip,myname,player.copy(),mouse.copy(),reloadtimer,weapon,gunstate,shottimer,health);
  client.write(snt);
  if(ishosting){
    updatescore();
  }
}

public void actonmessage(String msg){
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
      float hp = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('`'); 
      index2 = msg.indexOf('£'); //a
      float a = PApplet.parseFloat(msg.substring(index1+1,index2)); //m.x
      index1 = msg.indexOf('£');
      index2 = msg.indexOf('$'); //b
      float b = PApplet.parseFloat(msg.substring(index1+1,index2)); //m.y
      index1 = msg.indexOf('$');
      index2 = msg.indexOf('{'); //c
      float c = PApplet.parseFloat(msg.substring(index1+1,index2)); //rld
      index1 = msg.indexOf('{');
      index2 = msg.indexOf(';'); //d
      int d = PApplet.parseInt(msg.substring(index1+1,index2)); //wpn
      index1 = msg.indexOf(';');
      index2 = msg.indexOf(':'); //e
      int e = PApplet.parseInt(msg.substring(index1+1,index2)); //wpnstate
      index1 = msg.indexOf(':');
      index2 = msg.indexOf('|'); //f
      float f = PApplet.parseFloat(msg.substring(index1+1,index2)); //sht
      index1 = msg.indexOf('|'); 
      index2 = msg.indexOf('&'); //x
      float x = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('&');
      index2 = msg.indexOf('%'); //y
      float y = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('%'); 
      index2 = msg.indexOf(']'); //z
      float z = PApplet.parseFloat(msg.substring(index1+1,index2));
      clients.add(new playerc(new PVector(x,y,z),ip));
      playerc current = clients.get(clients.size()-1);
      current.rotx = a;
      current.roty = b;
      current.rld = c;
      current.wpn = d;
      current.wpnstate = e;
      current.sht = f;
      current.hp = hp;
      current.name = name;
      current.nametext.setTexture(current.createtexture());
    }else{
      int index1 = msg.indexOf('i'); //m:¬ h:` a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
      int index2 = msg.indexOf('¬'); //m  
      String name = msg.substring(index1+1,index2);
      index1 = msg.indexOf('¬'); //m
      index2 = msg.indexOf('`'); //h
      float hp = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('`'); 
      index2 = msg.indexOf('£'); //a
      float a = PApplet.parseFloat(msg.substring(index1+1,index2)); //m.x
      index1 = msg.indexOf('£');
      index2 = msg.indexOf('$'); //b
      float b = PApplet.parseFloat(msg.substring(index1+1,index2)); //m.y
      index1 = msg.indexOf('$');
      index2 = msg.indexOf('{'); //c
      float c = PApplet.parseFloat(msg.substring(index1+1,index2)); //rld
      index1 = msg.indexOf('{');
      index2 = msg.indexOf(';'); //d
      int d = PApplet.parseInt(msg.substring(index1+1,index2)); //wpn
      index1 = msg.indexOf(';');
      index2 = msg.indexOf(':'); //e
      int e = PApplet.parseInt(msg.substring(index1+1,index2)); //wpnstate
      index1 = msg.indexOf(':');
      index2 = msg.indexOf('|'); //f
      float f = PApplet.parseFloat(msg.substring(index1+1,index2)); //sht
      index1 = msg.indexOf('|'); 
      index2 = msg.indexOf('&'); //x
      float x = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('&');
      index2 = msg.indexOf('%'); //y
      float y = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('%'); 
      index2 = msg.indexOf(']'); //z
      float z = PApplet.parseFloat(msg.substring(index1+1,index2));
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
    int id = PApplet.parseInt(msg.substring(1,index));
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
      float x = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('x');
      index2 = msg.indexOf('y');
      float y = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('y');;
      index2 = msg.indexOf(']');
      float z = PApplet.parseFloat(msg.substring(index1+1,index2));
      zombies.add(new zombie(new PVector(x,y,z),PApplet.parseInt(id),100));
    }else if(isdead == false){
      zombie current = zombies.get(j);
      if(current.hp > 0){
        int index1 = msg.indexOf('i');
        int index2 = msg.indexOf('x');
        float x = PApplet.parseFloat(msg.substring(index1+1,index2));
        index1 = index2;
        index2 = msg.indexOf('y');
        float y = PApplet.parseFloat(msg.substring(index1+1,index2));
        index1 = index2;
        index2 = msg.indexOf(']');
        float z = PApplet.parseFloat(msg.substring(index1+1,index2));
        current.pos.x = x;
        current.pos.y = y;
        current.pos.z = z;
      }
    }
  }else if(st.equals("c")){
      int index1 = msg.indexOf('c');
      int index2 = msg.indexOf('i');
      int id = PApplet.parseInt(msg.substring(index1+1,index2));
      index1 = msg.indexOf('i');
      index2 = msg.indexOf('r');
      float rot = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('r'); 
      index2 = msg.indexOf('x');
      float x = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('x');
      index2 = msg.indexOf('y');
      float y = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('y');
      index2 = msg.indexOf(']');
      float z = PApplet.parseFloat(msg.substring(index1+1,index2));
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
    int id = PApplet.parseInt(msg.substring(index1+1,index2));
    index1 = msg.indexOf('h');
    index2 = msg.indexOf(']');
    float hp = PApplet.parseFloat(msg.substring(index1+1,index2));
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      if(current.id == id){
        current.hp = hp;
        points+=10;
        particlesystems.add(new particlesystem(current.pos.copy(),new PVector(0,0,0),0.1f,0.01f,color(255,20,20),2,10,5,5));
      }
    }
  }else if(st.equals("o")){
      int index1 = msg.indexOf('o');
      int index2 = msg.indexOf('i');
      String id = msg.substring(index1+1,index2);
      index1 = msg.indexOf('i');
      index2 = msg.indexOf('a');
      float a = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('a');
      index2 = msg.indexOf('b');
      float b = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('b');
      index2 = msg.indexOf('c');
      float c = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('c'); 
      index2 = msg.indexOf('x');
      float x = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('x');
      index2 = msg.indexOf('y');
      float y = PApplet.parseFloat(msg.substring(index1+1,index2));
      index1 = msg.indexOf('y');
      index2 = msg.indexOf(']');
      float z = PApplet.parseFloat(msg.substring(index1+1,index2));
      if(id.equals(myip) == false){
        bullets.add(new projectile(new PVector(a,b,c),new PVector(x,y,z),0));
      }
      if(gunshot[shotcount].isPlaying()){
        gunshot[shotcount].stop();
      }
      gunshot[shotcount].play();
      soundobjects.add(new soundobject(gunshot[shotcount],new PVector(a+x,b+y,c+z)));
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
      points = PApplet.parseFloat(msg.substring(msg.indexOf('v')+1,msg.indexOf('r')));
      round = PApplet.parseInt(msg.substring(msg.indexOf('r')+1,msg.indexOf(']')));
    }
  }else if(st.equals("e")){
    float id = PApplet.parseFloat(msg.substring(msg.indexOf('e')+1,msg.indexOf(']')));
    for(int i = 0; i < barriers.size(); i++){
      if(barriers.get(i).id == id){
        barriers.remove(i);
        i--;
      }
    }
  }else if(st.equals("q")){//msg = "q" + str(id) + "i" + str(pos.x) + "x" + str(pos.y) + "y" + str(pos.z) + "z";
    int index1 = msg.indexOf('q');
    int index2 = msg.indexOf('i');
    float id = PApplet.parseFloat(msg.substring(index1+1,index2));
    index1 = msg.indexOf('i');
    index2 = msg.indexOf('x');
    float x = PApplet.parseFloat(msg.substring(index1+1,index2));
    index1 = msg.indexOf('x');
    index2 = msg.indexOf('y');
    float y = PApplet.parseFloat(msg.substring(index1+1,index2));
    index1 = msg.indexOf('y');
    index2 = msg.indexOf(']');
    float z = PApplet.parseFloat(msg.substring(index1+1,index2));
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
    int kills = PApplet.parseInt(msg.substring(index1+1,index2));
    for(int i = 0; i < clients.size(); i++){
      playerc current = clients.get(i);
      if(current.ip.equals(ip)){
        current.kills = kills;
      }
    }
  }else if(st.equals("t")){
    int serverseed = PApplet.parseInt(msg.substring(1,msg.length()-1));
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
    float id = PApplet.parseFloat(msg.substring(index1+1,index2));
    index1 = msg.indexOf('i');
    index2 = msg.indexOf('x');
    float x = PApplet.parseFloat(msg.substring(index1+1,index2));
    index1 = msg.indexOf('x');
    index2 = msg.indexOf('y');
    float y = PApplet.parseFloat(msg.substring(index1+1,index2));
    index1 = msg.indexOf('y');
    index2 = msg.indexOf(']');
    float z = PApplet.parseFloat(msg.substring(index1+1,index2));
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
    float id = PApplet.parseFloat(msg.substring(msg.indexOf('a')+1,msg.indexOf(']')));
    for(int i = 0; i < towers.size(); i++){
      if(id == towerid){
        intower = false;
      }
      if(towers.get(i).id == id){
        towers.remove(i);
        i--;
      }
    }
  }else{
    println("ERROR : " + msg);
  }
}

public void updatezombiepositions(){
  for(int i = 0; i < zombies.size(); i++){
    zombie current = zombies.get(i);
    String msg = createzmessage(str(current.id),current.pos);
    server.write(msg);
  }
}

public void manageserver(){
  Client msg;
  msg = server.available();
  while(msg != null){
    server.write(msg.readString());
    msg = server.available();
  }
  if(frameCount%5==0){
    updatezombiepositions();
  }
}

public void drawplayers(){
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
int kills = 0;
float points = 1000;
PVector player = new PVector(2000+random(-100,100),2000+random(-100,100),50);
float health = 100;
boolean alive = true;
PShape pmodel;
PShape pistol1;
PShape pistol2;
PShape smg1;
PShape smg2;
PShape sniper1;
PShape sniper2;
PShape[][] weapons = new PShape[3][2];
float[][] weaponstats = new float[3][5];
int weapon = 2;
int gunstate = 0;
float bulletcount = 0;
float scopelerp = 0;
boolean scoping = false;
public void setupweapons(){
  weapons[0][0] = pistol1;
  weapons[0][1] = pistol2;
  weapons[1][0] = smg1;
  weapons[1][1] = smg2;
  weapons[2][0] = sniper1;
  weapons[2][1] = sniper2;
  createweapon(0,40,0.25f,30,16,0.75f);
  createweapon(1,20,0.125f,30,60,0.25f);
  createweapon(2,200,0.6f,40,8,1.0f);
}
public void createweapon(int index, int damage, float firerate, float bulletspeed, float bulletcount, float reloadtimer){
  weaponstats[index][0] = damage;
  weaponstats[index][1] = firerate;
  weaponstats[index][2] = bulletspeed;
  weaponstats[index][3] = bulletcount;
  weaponstats[index][4] = reloadtimer;
}
public void displayweapon(){
  if(scoping && scopelerp < 1){
    scopelerp+=0.1f;
    if(scopelerp > 1){
      scopelerp = 1;
    }
  }else if(scoping == false && scopelerp > 0){
    scopelerp-=0.1f;
    if(scopelerp < 0){
      scopelerp = 0;
    }
  }
  d3.translate(player.x,player.y,player.z);
  d3.rotateZ(radians(mouse.x)+PI/2);
  d3.rotateX(-sin(radians(mouse.y))-map(reloadtimer,0,weaponstats[weapon][4],0,PI));
  d3.translate(lerp(5,0,scopelerp),lerp(-10-shottimer*2.5f,-6-shottimer*1.5f,scopelerp),lerp(0,-0.2f,scopelerp)); //5
  d3.shape(weapons[weapon][gunstate]);
  d3.translate(-lerp(5,0,scopelerp),-lerp(-10-shottimer*2.5f,-6-shottimer*1.5f,scopelerp),-lerp(0,-0.2f,scopelerp));
  d3.rotateX(sin(radians(mouse.y))+map(reloadtimer,0,weaponstats[weapon][4],0,PI));
  d3.rotateZ(-(radians(mouse.x)+PI/2));
  d3.translate(-player.x,-player.y,-player.z);
}
PShader blood;
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
  public void calculate(){
    float d = (1.0f/(dist(player.x,player.y,player.z,pos.x,pos.y,pos.z)/(scale*12.5f)))*1.0f;
    if(d > 1){
      d = 1.0f;
    }
    sound.amp(d);
    PVector vecto = vectortowards(pos,player);
    PVector left = new PVector(vecto.x*leftear.x,vecto.y*leftear.y,vecto.z*leftear.z);
    PVector right = new PVector(vecto.x*rightear.x,vecto.y*rightear.y,vecto.z*rightear.z);
    float lefttotal = left.x+left.y+left.z;
    float righttotal = right.x+right.y+right.z;
    if(lefttotal <= 0.05f){
      lefttotal = 0.05f;
    }
    if(righttotal <= 0.05f){
      righttotal = 0.05f;
    }
    sound.pan(lefttotal-righttotal);
  }
}

public void updatesounds(){
  leftear = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)-PI/1.95f),player.y+sin(radians(mouse.x)-PI/1.95f),player.z));
  rightear = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)+PI/1.95f),player.y+sin(radians(mouse.x)+PI/1.95f),player.z));
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
PGraphics ui;
PImage bulletico;
PImage crosshair;

public void drawui(){
  ui.beginDraw();
  ui.clear();
  ui.stroke(0);
  ui.fill(0);
  if(scoping == false){
    ui.image(crosshair,944,524,32,32);
  }
  ui.image(bulletico,80,910);
  ui.textSize(40);
  if(bulletcount < 10){
    ui.text("0"+PApplet.parseInt(bulletcount),200,955);
  }else{
    ui.text(PApplet.parseInt(bulletcount),200,955);
  }
  ui.text(PApplet.parseInt(weaponstats[weapon][3]),235,1000);
  ui.strokeWeight(10);
  ui.line(200,990,280,940);
  ui.fill(255);
  ui.textSize(20);
  ui.text("Score : " + PApplet.parseInt(points),50,80);
  ui.textSize(40);
  ui.fill(255,10,10,255-(sin(radians(rounddelay*2)))*245.0f);
  ui.text("Round : " + PApplet.parseInt(round),45,40);
  if(started == false && ishosting){
    ui.fill(255,50,50);
    float v = (cos(millis()/1000.0f)*20+40);
    ui.textSize(v);
    ui.text("Press Enter To Start",985-v*6,480-v);
  }
  ui.endDraw();
  image(ui,0,0,width,height);
}
PShape[] towerm = new PShape[1];
ArrayList<tower> towers = new ArrayList<tower>();
class tower{
  PVector pos;
  float hp;
  int type = 0;
  float id;
  tower(PVector pos_, int type_, float id_){
    pos = pos_.copy();
    type = type_;
    if(type == 0){
      hp = 1000;
    }
    id = id_;
  }
  public void update(){
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(current.pos.x,current.pos.y,pos.x,pos.y);
      if(d < 60){
        PVector restrict = vectortowards(pos,current.pos);
        float t = 3*1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
        current.pos.x = lerp(current.pos.x,current.pos.x+restrict.x*zombspeed/speed*t,(1.0f-d/60.0f));
        current.pos.y = lerp(current.pos.y,current.pos.y+restrict.y*zombspeed/speed*t,(1.0f-d/60.0f));
        if(ishosting){
          hp-=0.5f*(round/10.0f);
        }
      }
    }
    float d = dist(player.x,player.y,player.z,pos.x,pos.y,pos.z);
    if(d < 20){
      PVector restrict = vectortowards(pos,player);
      float t = 9*1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));   
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,(1.0f-d/20.0f));
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,(1.0f-d/20.0f));
      player.z = lerp(player.z,player.z+restrict.y*movespeed/speed*t,(1.0f-d/20.0f));
      fall-=restrict.z*0.25f;
    }
    if(d < 25 && keys[4] == 1){
      intower = true;
      towerbox = pos.copy().add(0.0f,0.0f,93);
    }
  }
  public void display(){
    d3.translate(pos.x,pos.y,pos.z);
    d3.shape(towerm[type]);
    d3.translate(-pos.x,-pos.y,-pos.z);
  }
}
public void managetowers(){
  for(int i = towers.size()-1; i > -1; i--){
    tower current = towers.get(i);
    current.update();
    current.display();
    if(current.hp <= 0 && ishosting){
      client.write(removetower(current.id));
    }
  }
}

public void placetower(PVector pos){
  pos = pos.copy();
  pos.z = nval(pos.x/scale,pos.y/scale)*scale+15;
  pos.x = round(pos.x/10)*10;
  pos.y = round(pos.y/10)*10;
  client.write(placetower(random(10000),pos));
}

public void showtower(){
  if(keys[8] == 1 && points >= 200){
    PVector vec = player.copy().add(new PVector(cos(radians(mouse.x))*40,sin(radians(mouse.x))*40,0));
    vec.x = round(vec.x/10)*10;
    vec.y = round(vec.y/10)*10;
    vec.z = nval(vec.x/scale,vec.y/scale)*scale+40;
    d3.translate(vec.x,vec.y,vec.z);
    d3.shape(towerm[0]);
    d3.resetMatrix();
  }
}

public void refreshtowers(){
  for(int i = 0; i < towers.size(); i++){
    client.write(placetower(towers.get(i).id,towers.get(i).pos));
  }
}
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
  public void display(){
    lifetime++;
    anim+=0.006f;
    anim+=anim*0.05f;
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
public void managecorpses(){
  for(int i = corpses.size()-1; i > -1; i--){
    corpse current = corpses.get(i);
    if(current.lifetime >= duration){
      corpses.remove(i);
      continue;
    }
    current.display();
  }
}
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
  public void display(){
    anim+=0.016f;
    d3.translate(pos.x,pos.y,pos.z+15+sin(anim)*4);
    shader.set("translate",pos.x,pos.y,pos.z+15+sin(anim)*4);
    d3.rotateZ(cos(anim));
    d3.shape(weaponcrate);
    d3.rotateZ(-cos(anim));
    shader.set("translate",0,0,0,0);
    d3.translate(-pos.x,-pos.y,-(pos.z+15+sin(anim)*4));
    if(dist(pos.x,pos.y,pos.z,player.x,player.y,player.z) < 40 && keys[4] == 1){
      weapon = dweapon;
      gunstate = 0;
      bulletcount = weaponstats[weapon][3];
      reloading = true;
      reloadtimer = weaponstats[weapon][4]/2.0f;
      picked = true;
    }
  }
}

public void managedrops(){
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
int[] keys = new int[9];
float movespeed = 2;
float speed = 0;
float fall = 0;
boolean intower = false;
PVector towerbox = new PVector(0,0,0);
int towerid = 0;
public void move(){
  if(health <= 0){
    alive = false;
    playerdead(myip);
    for(int i = 0; i < clients.size(); i++){
      playerc current = clients.get(i);
      if(current.ip.equals(myip)){
        current.alive = false;
      }
    }
  }else{
    health+=0.032f;
    health = constrain(health,0,100);
  }
  speed = 0;
  for(int i = 0; i < 4; i++){
    if(keys[i] == 1){
      speed++;
    }
  }
  speed = constrain(speed,1,2);
  if(keys[5] == 1){
    movespeed=1.8f;
  }else{
    movespeed=1;
  }
  if(keys[0] == 1){
    player.x+=cos(radians(mouse.x))*movespeed/speed;
    player.y+=sin(radians(mouse.x))*movespeed/speed;
  }
  if(keys[1] == 1){
    player.x-=cos(radians(mouse.x))*movespeed/speed;
    player.y-=sin(radians(mouse.x))*movespeed/speed;
  }
  if(keys[2] == 1){
    player.x+=cos(radians(mouse.x-90))*movespeed/speed;
    player.y+=sin(radians(mouse.x-90))*movespeed/speed;
  }
  if(keys[3] == 1){
    player.x+=cos(radians(mouse.x+90))*movespeed/speed;
    player.y+=sin(radians(mouse.x+90))*movespeed/speed;
  }
  if(intower){
    if(player.z <= towerbox.z){
      player.z = lerp(player.z,towerbox.z,0.35f);
      fall = 0;
      if(keys[6] == 1){
        fall = -1.8f;
        player.z+=0.1f;
      }
    }else if(player.z >= towerbox.z+7){
      player.z = towerbox.z+6.9f;
      fall = 0;
    }else{
      fall+=0.14f;
      player.z-=fall;
    }
    if(dist(player.x,player.y,towerbox.x,towerbox.y) > 18){
      PVector restrict = vectortowards(player,towerbox);
      float t = 1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,1*constrain((dist(player.x,player.y,towerbox.x,towerbox.y)-18),0,2));        
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,1*constrain((dist(player.x,player.y,towerbox.x,towerbox.y)-18),0,2));
    }
  }else{
    if(player.z <= nval(player.x/scale,player.y/scale)*scale+30){
      player.z = lerp(player.z,nval(player.x/scale,player.y/scale)*scale+20,0.35f);
      fall = 0;
      if(keys[6] == 1){
        fall = -2;
        player.z+=11;
      }
    }else{
      fall+=0.14f;
      player.z-=fall;
    }
    if(dist(player.x,player.y,w/2.0f*scale,w/2.0f*scale) > (radius-54)*scale){
      PVector restrict = vectortowards(player,new PVector(w/2.0f*scale,w/2.0f*scale));
      float t = 1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,1*constrain((dist(player.x,player.y,w/2.0f*scale,w/2.0f*scale)-((radius-54)*scale)),0,2));        
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,1*constrain((dist(player.x,player.y,w/2.0f*scale,w/2.0f*scale)-((radius-54)*scale)),0,2));
    }
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(player.x,player.y,player.z,current.pos.x,current.pos.y,current.pos.z);
      if(d < 20){
        PVector restrict = vectortowards(current.pos,player);
        float t = 3*1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));     
        player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,2.0f-d/10.0f);
        player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,2.0f-d/10.0f);
        player.z = lerp(player.z,player.z+restrict.z*movespeed/speed*t,2.0f-d/10.0f);
        fall-=restrict.z*0.1f;
      }
    }
  }
  for(int i = 0; i < clients.size(); i++){
    if(clients.get(i).ip.equals(myip) == false){
      playerc current = clients.get(i);
      float d = dist(player.x,player.y,player.z,current.pos.x,current.pos.y,current.pos.z);
      if(d < 15){
        PVector restrict = vectortowards(current.pos,player);
        float t = 3*1.0f/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));   
        player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,1.5f-d/10.0f);
        player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,1.5f-d/10.0f);
        player.z = lerp(player.z,player.z+restrict.y*movespeed/speed*t,1.5f-d/10.0f);
        fall-=restrict.z*0.1f;
      }
    }
  }
}
public void keyPressed(){
  if(menu == false){
    if(key == 'w' || key == 'W'){
      keys[0] = 1;
    }else if(key == 's' || key == 'S'){
      keys[1] = 1;
    }else if(key == 'a' || key == 'A'){
      keys[2] = 1;
    }else if(key == 'd' || key == 'D'){
      keys[3] = 1;
    }else if(key == 'r' || key == 'R'){
      if(reloading == false && bulletcount < weaponstats[weapon][3]){
        reloading = true;
        shooting = false;
      }
    }else if(key == 'e' || key == 'E'){
      keys[4] = 1;
      if(intower){
        player.x = towerbox.x;
        player.y = towerbox.y;
        intower = false;
      }
    }else if(key == 'p' || key == 'P'){
      playthesong();
    }else if(keyCode == ENTER){
      started = true;
    }else if(keyCode == 16){
      keys[5] = 1;
    }else if(keyCode == 32){
      keys[6] = 1;
    }else if(key == 'q' || key == 'Q'){
      keys[7] = 1;
    }else if(keyCode == 27){
      disconnect(myip);
      exit();
    }
  }else{
    if(keyCode == 8){
      if(ipselect){
        if(serverip.length() > 0){
          serverip = serverip.substring(0,serverip.length()-1);
        }
      }
      if(nameselect){
        if(myname.length() > 0){
          myname = myname.substring(0,myname.length()-1);
        }        
      }
    }else{
      if(ipselect && istypeable(str(key))){
        serverip = serverip+key;
      }
      if(nameselect && istypeable(str(key))){
        myname = myname+key;
      }
    }
  }
}
public void keyReleased(){
  if(menu == false){
    if(key == 'w' || key == 'W'){
      keys[0] = 0;
    }else if(key == 's' || key == 'S'){
      keys[1] = 0;
    }else if(key == 'a' || key == 'A'){
      keys[2] = 0;
    }else if(key == 'd' || key == 'D'){
      keys[3] = 0;
    }else if(keyCode == 32){
      keys[6] = 0;
    }else if(key == 'e' || key == 'E'){
      keys[4] = 0;
    }else if(keyCode == 16){
      keys[5] = 0;
    }else if(key == 'q' || key == 'Q'){
      keys[7] = 0;
      if(points >= 50){
        placebarrel(player.copy().add(new PVector(cos(radians(mouse.x))*40,sin(radians(mouse.x))*40,0)));
      }
    }else if(key == 't' || key == 'T'){
      keys[8] = 0;
      if(points >= 200){
        placetower(player.copy().add(new PVector(cos(radians(mouse.x))*40,sin(radians(mouse.x))*40,0)));
      }
    }
  }
}

public PVector vectortowards(PVector pos1, PVector pos2){
  PVector pos3 = new PVector();
  pos3.x = pos2.x - pos1.x;
  pos3.y = pos2.y - pos1.y;
  pos3.z = pos2.z - pos1.z;
  return pos3.normalize();
}
ArrayList<particlesystem> particlesystems = new ArrayList<particlesystem>();
class particle{
  PShape p;
  PImage t;
  PVector pos;
  PVector dir;
  int col;
  float drag;
  float gravity;
  int lifetime;
  particle(PVector pos_, PVector dir_, float gravity_, float drag_, int col_, int lifetime_){
    pos = pos_.copy();
    dir = dir_.copy();
    gravity = gravity_;
    drag = drag_;
    col = col_;
    lifetime = lifetime_;
    t = createImage(1,1,RGB);
    t.loadPixels();
    t.pixels[0] = col_;
    t.updatePixels();
    p = createShape();
    p.beginShape(QUAD);
    p.noStroke();
    p.noFill();
    p.texture(t);
    p.emissive(255,255,255);
    p.vertex(0,0,0,0);
    p.vertex(1,0,1,0);
    p.vertex(1,1,1,1);
    p.vertex(0,1,0,1);
    p.endShape();
  }
  public void move(){
    lifetime--;
    if(lifetime > 0){
      dir.x = lerp(dir.x,0,drag*0.016f);
      dir.y = lerp(dir.y,0,drag*0.016f);
      dir.z = lerp(dir.z,0,drag*0.016f);
      dir.z -= gravity*0.016f;
      pos.x+=dir.x;
      pos.y+=dir.y;
      pos.z+=dir.z;
      p.resetMatrix();
      p.rotateY(PI/2);
      p.rotateZ(radians(bearing(pos,player))+PI/2);
      p.translate(pos.x,pos.y,pos.z);
    }
  }
  public void display(){
    if(lifetime > 0){
      d3.shape(p);
    }
  }
}

class particlesystem{
  particle[] particles;
  int lifetime;
  particlesystem(PVector pos, PVector dire, float gravity, float drag, int col, int count,int lifetime_,float var_,int lsv_){
    lifetime = lifetime_;
    particles = new particle[count];
    for(int i = 0; i < count; i++){
      PVector dir = dire.copy();
      particles[i] = new particle(pos,new PVector(dir.x+random(-var_,var_),dir.y+random(-var_,var_),dir.z+random(-var_,var_)),gravity,drag,col,PApplet.parseInt(lifetime-random(lsv_)));                       
    }
  }
  public void updateparticles(){
    lifetime--;
    for(int i = 0; i < particles.length; i++){
      particles[i].move();
      particles[i].display();
    }
  }
}

public void manageparticles(){
  for(int i = particlesystems.size()-1; i > -1; i--){
    particlesystem current = particlesystems.get(i);
    if(current.lifetime < 0){
      particlesystems.remove(i);
      continue;
    }
    current.updateparticles();
  }
}
ArrayList<projectile> bullets = new ArrayList<projectile>();
PShape bullet;
int shotcount = 0;
public void setupbullet(){
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
public void mousePressed(){
  if(mouseButton == LEFT && bulletcount > 0 && reloadtimer == 0 && reloading == false){
    shooting = true;
  }if(mouseButton == RIGHT && reloadtimer == 0 && reloading == false){
    scoping = true;
  }
}
public void mouseReleased(){
  if(mouseButton == LEFT){
    shooting = false;
  }else if(mouseButton == RIGHT){
    scoping = false;
  }
}
public void manageshooting(){
  shottimer+=0.016f;
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
  if(shottimer >= 0.05f){
    gunstate = 0;
  }
  if(reloading){
    reloadtimer+=0.016f;
    if(reloadtimer>=weaponstats[weapon][4]){
      bulletcount = weaponstats[weapon][3];
      reloading = false;
    }
  }else{
    reloadtimer-=0.016f;
    reloadtimer = constrain(reloadtimer,0,weaponstats[weapon][3]);
  }
}
public void shoot(){
  PVector facingdir = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)),player.y+sin(radians(mouse.x)),player.z+sin(radians(mouse.y))));
  facingdir.x*=weaponstats[weapon][2];
  facingdir.y*=weaponstats[weapon][2];
  facingdir.z*=weaponstats[weapon][2];
  PVector offset = vectortowards(player,new PVector(player.x+cos(radians(mouse.x)+PI/4),player.y+sin(radians(mouse.x)+PI/4),player.z+sin(radians(mouse.y))-0.185f));
  offset.x*=10;
  offset.y*=10;
  offset.z*=10;
  if(scoping){
    bullets.add(new projectile(new PVector(player.x+offset.x*0.15f,player.y+offset.y*0.15f,player.z+offset.z-0.6f),facingdir,weaponstats[weapon][0]));
  }else{
    bullets.add(new projectile(new PVector(player.x+offset.x,player.y+offset.y,player.z+offset.z),facingdir,weaponstats[weapon][0]));
  }
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
  public void move(){
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
  public void display(){
    float b = radians(bearing(pos,player));
    d3.translate(pos.x,pos.y,pos.z);
    d3.rotateZ(b);
    d3.shape(bullet);
    d3.rotateZ(-b);
    d3.translate(-pos.x,-pos.y,-pos.z);
  }
}

public void managebullets(){
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
PGraphics d3;
int w = 500;
int radius = 225;
float scale = 8;
float rate = 3.8f;
float depth = 100;
int grass = color(64, 227, 102);
int rock = color(122, 112, 103);
int snow = color(224, 221, 218);
float gh = 0;
float rh = 28;
float sh = 58;
PVector[] trees;
PShape fog;
class chunk{
  PShape terrain;
  chunk(PVector pos){
    float[][] values = new float[w+1][w+1];
    PImage texture = createImage(w+1,w+1,RGB);
    texture.loadPixels();
    for(int x = 0; x < w; x++){
      for(int y = 0; y < w; y++){
        values[x][y] = nval(pos.x/scale+x,pos.y/scale+y);
        int index = x + y * (w+1);
        if(values[x][y] < rh){
          texture.pixels[index] = color(red(grass)+random(-10,10),green(grass)+random(-30,30),blue(grass)+random(-30,30));
        }else if(values[x][y] >= rh && values[x][y] < sh){
          texture.pixels[index] = color(red(rock)+random(-5,5),green(rock)+random(-5,5),blue(rock)+random(-5,5));
        }else if(values[x][y] >= sh){
          texture.pixels[index] = color(red(snow)+random(-2,2),green(snow)+random(-2,2),blue(snow)+random(-2,2));
        }
      }
    }
    int index = (w) + (w) * (w+1);
    texture.pixels[index-1] = color(10,255,80);
    index = (w-1) + (w) * (w+1);
    texture.pixels[index-1] = color(117,59,0);
    for(int r = radius-50; r > radius-52; r--){
      for(float d = 0; d < 360; d+=0.25f){
        int x = w/2 + PApplet.parseInt(r * cos(radians(d)));
        int y = w/2 + PApplet.parseInt(r * sin(radians(d)));
        index = x + y * (w+1);
        texture.pixels[index] = color(255,20,20);
      }
    }
    texture.updatePixels();
    terrain = createShape();
    terrain.beginShape(TRIANGLES);
    terrain.ambient(255,255,255);
    terrain.specular(255,255,255);
    terrain.textureMode(IMAGE);
    terrain.noFill();
    terrain.noStroke();
    terrain.texture(texture);
    for(int x = 0; x < w-1; x++){
      for(int y = 0; y < w-1; y++){
        if(dist(x,y,w/2,w/2) < radius){
          int index1 = x + y * (w+1);
          index1 = constrain(index1,0,texture.pixels.length-1);
          if(texture.pixels[index1] == color(255,20,20)){
            terrain.emissive(color(255,80,80));
          }else{
            terrain.emissive(color(0,0,0));
          }
          terrain.vertex(x,y,values[x][y],x,y);
          terrain.vertex(x+1,y,values[x+1][y],x,y);
          terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
          terrain.vertex(x,y,values[x][y],x,y);
          terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
          terrain.vertex(x,y+1,values[x][y+1],x,y);
          
          if(x > 0 && y > 0 && nval(x*1000,y*1000)/depth > 0.4f){
            int rndx = round(random(-1,1));
            int rndy = round(random(-1,1));
            if(rndx == 0){
              rndx = 1;
            }
            if(rndy == 0){
              rndy = 1;
            }
            if(values[x][y] < rh){
              terrain.vertex(x,y,values[x][y],x,y);
              terrain.vertex(x+rndx/4.0f,y+rndy/4.0f,values[x][y]+1,x,y);
              terrain.vertex(x+rndx/2.0f,y+rndy/2.0f,(values[x][y]+values[x+rndx][y+rndy])/2.0f,x,y);
            }else if(values[x][y] >=rh && nval(x*200,y*200)/depth > 0.55f){
              terrain.vertex(x,y,values[x][y],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5f,x,y);
              terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5f,x,y);
              terrain.vertex(x+2,y,values[x+2][y],x,y);
              terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5f,x,y);
              terrain.vertex(x+1,y-1,values[x+1][y-1],x,y);
              terrain.vertex(x+2,y,values[x+2][y],x,y);
              terrain.vertex(x,y,values[x][y],x,y);
              terrain.vertex(x+1,y-1,values[x+1][y-1],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5f,x,y);
            }
          }
        }
      }
    }
    int count = 0;
    for(int x = 0; x < w; x+=5){
      for(int y = 0; y < w; y+=5){
        if(nval(x*1000,y*1000)/depth > 0.4f && dist(x,y,w/2,w/2) < radius){
          trees[count] = new PVector(x*scale,y*scale);
          count++;
          float h = values[x][y]-1;
          for(int l = 0; l < 6; l++){
            for(int r = 0; r < 360; r+=72){
              float x1 = cos(radians(r));
              float y1 = sin(radians(r));
              float x2 = cos(radians(r+72));
              float y2 = sin(radians(r+72));
              terrain.vertex(x+x1,y+y1,h+l,w-2,w+1);
              terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
              terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
              terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
              terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
              terrain.vertex(x+x2,y+y2,h+l+1,w-2,w+1);
            }
          }
          for(int l = 0; l < 6; l+=2){
            for(int r = 0; r < 360; r+=72){
              float x1 = cos(radians(r))*(3-l/2);
              float y1 = sin(radians(r))*(3-l/2);
              float x2 = cos(radians(r+72))*(3-l/2);
              float y2 = sin(radians(r+72))*(3-l/2);
              terrain.vertex(x+x1,y+y1,h+l+3-0.5f,w-1,w+1);
              terrain.vertex(x+x2,y+y2,h+l+3-0.5f,w-1,w+1);
              terrain.vertex(x,y,h+l+6,w-1,w);
            }
          }
        }
      }
    }
    for(float i = 0; i < 360; i+=0.25f){
      float x = cos(radians(i))*(radius+random(-50,0))+w/2;
      float y = sin(radians(i))*(radius+random(-50,0))+w/2;
      float h = values[PApplet.parseInt(x)][PApplet.parseInt(y)]-1;
      for(int l = 0; l < 6; l++){
        for(int r = 0; r < 360; r+=72){
          float x1 = cos(radians(r));
          float y1 = sin(radians(r));
          float x2 = cos(radians(r+72));
          float y2 = sin(radians(r+72));
          terrain.vertex(x+x1,y+y1,h+l,w-2,w+1);
          terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
          terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
          terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
          terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
          terrain.vertex(x+x2,y+y2,h+l+1,w-2,w+1);
        }
      }
      for(int l = 0; l < 6; l+=2){
        for(int r = 0; r < 360; r+=72){
          float x1 = cos(radians(r))*(3-l/2);
          float y1 = sin(radians(r))*(3-l/2);
          float x2 = cos(radians(r+72))*(3-l/2);
          float y2 = sin(radians(r+72))*(3-l/2);
          terrain.vertex(x+x1,y+y1,h+l+3-0.5f,w-1,w+1);
          terrain.vertex(x+x2,y+y2,h+l+3-0.5f,w-1,w+1);
          terrain.vertex(x,y,h+l+6,w-1,w);
        }
      }
    }
    terrain.endShape();
    terrain.scale(scale,scale,scale);
    PVector[] treescopy = new PVector[count];
    for(int i = 0; i < count; i++){
      treescopy[i] = trees[i];
    } 
    trees = treescopy;
  }
}
public void treehitboxes(){
  for(int i = 0; i < trees.length; i++){
    float d = dist(player.x,player.y,trees[i].x,trees[i].y);
    if(d < 3*scale+2){
      PVector resist = vectortowards(trees[i],player);
      float t = 1.0f/(sqrt(pow(resist.x,2)+pow(resist.y,2)));
      player.x = lerp(player.x,player.x+resist.x*movespeed/speed*t,(3*scale+2)/10.0f-d/10.0f);
      player.y = lerp(player.y,player.y+resist.y*movespeed/speed*t,(3*scale+2)/10.0f-d/10.0f);
    }
  }
}
public void bullethittree(int index, int count){
  particlesystems.add(new particlesystem(new PVector(trees[index].x,trees[index].y,trees[index].z+5),new PVector(0,0,5),0.025f,0.01f,color(194, 100, 0),10,count,4,(count-(count-1))));            
}
public float nval(float x, float y){
  float h2 = noise(x/w*rate*3,y/w*rate*3);
  h2*=h2*(h2+0.35f);
  h2*=0.15f;  
  float h3 = noise(x/w*rate*9,y/w*rate*9);
  h3*=h3*(h3+0.4f);
  h3*=0.035f;  
  float h1 = noise(x/w*rate,y/w*rate);
  h1*=h1*(h1+(h2+h3)/8.0f);
  h1*=0.825f;
  return (h1+h2+h3)*depth;
}
boolean started = false;
ArrayList<zombie> zombies = new ArrayList<zombie>();
PShape zombiem1;
PShape zombiem2;
PShape zombiea1;
PShape zombiea2;
float zombspeed = 0.5f;
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
    timer = random(0.1f);
  }
  zombie(PVector pos_, int id_, float hp_){
    pos = pos_;
    id = id_;
    hp = hp_;
    frame = round(random(1));
    timer = random(0.1f);
  }
  public void move(){
    if(random(zombies.size()/1.5f*200) < 1){
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
    if(dist(target.x,target.y,target.z,pos.x,pos.y,pos.z) < 20){
      attacktimer = 1.25f;
    }else if(attacktimer == 0){
      if(sqrt((rot*rot)-(pow(bearing(target,pos),2))) > 180 || sqrt((rot*rot)-(pow(bearing(target,pos),2))) < -180){
        rot = bearing(target,pos);
      }else{
        rot = lerp(rot,bearing(target,pos),0.1f);
      }
      pos.x+=dir.x*zombspeed;
      pos.y+=dir.y*zombspeed;
      pos.z = lerp(pos.z,nval(pos.x/scale,pos.y/scale)*scale+9,0.25f);
    }else if(attacktimer != 0){
      attacktimer-=0.016f;
      if(attacktimer <= 0){
        attacktimer = 0;
      }
    }
    for(int i = 0; i < trees.length; i++){
      float d = dist(pos.x,pos.y,trees[i].x,trees[i].y);
      if(d < 3*scale+2){
        PVector resist = vectortowards(trees[i],pos);
        float t = 1.0f/(sqrt(pow(resist.x,2)+pow(resist.y,2)));
        pos.x = lerp(pos.x,pos.x+resist.x*zombspeed*t,(3*scale+2)/10.0f-d/10.0f);
        pos.y = lerp(pos.y,pos.y+resist.y*zombspeed*t,(3*scale+2)/10.0f-d/10.0f);
      }
    }
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      if(current == this || attacktimer != 0){
        continue;
      }
      float d = dist(pos.x,pos.y,pos.z,current.pos.x,current.pos.y,current.pos.z);
      if(d < 25){
        PVector resist = vectortowards(current.pos,pos);
        float t = 1.0f/(sqrt(pow(resist.x,2)+pow(resist.y,2)));
        pos.x = lerp(pos.x,pos.x+resist.x*zombspeed*t,2.5f-d/10.0f);
        pos.y = lerp(pos.y,pos.y+resist.y*zombspeed*t,2.5f-d/10.0f);
        pos.y = lerp(pos.z,pos.z+resist.z*zombspeed*t,2.5f-d/10.0f);
      }
    }
    timer+=0.016f;
    if(timer >= 0.25f){
      if(frame == 1){
        frame = 0;
      }else{
        frame = 1;
      }
      timer = 0;
    }
  }
  public void display(){
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
        health-=1.0f+round*0.1f;
      }
    }else if(attacktimer != 0){
      zombiea2.resetMatrix();
      zombiea2.rotateX(PI/2);
      zombiea2.rotateZ(radians(rot));
      zombiea2.translate(pos.x,pos.y,pos.z);
      d3.shape(zombiea2);
    }
  }
  public void hit(){
    client.write(createhmessage(id,hp));
    //particlesystems.add(new particlesystem(pos.copy(),new PVector(0,0,0),0.1,0.01,color(255,20,20),2,count,5,(count-(count-1))));
  }
}


public PShape loadshape(String pathm, String textm){
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
      float U = PApplet.parseInt(c.getTextureU(i)*text.width);
      float V = PApplet.parseInt(c.getTextureV(i)*text.height);
      shape.normal(norm.x,norm.y,norm.z);
      shape.ambient(255,255,255);
      shape.specular(255,255,255);
      shape.vertex(vert.x,vert.y,vert.z,U,V);
    }
  }
  shape.endShape();
  return shape;
}

public void managezombies(){
  if(zombies.size() == 0){
    rounddelay++;
    if(rounddelay > 360){
      round++;
      if(round > 3){
        zombspeed = 1.25f+round*0.05f;
      }else{
        zombspeed = 0.75f+round*0.05f;
      }
      for(int i = 0; i < round*5+5; i++){
        float degree = random(360);
        float x = cos(radians(degree)) * (radius + random(-40,50))*scale + w/2*scale;
        float y = sin(radians(degree)) * (radius + random(-40,50))*scale + w/2*scale;
        zombies.add(new zombie(new PVector(x,y,nval(x,y)),PApplet.parseInt(random(10000000)),50+round*5));
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

public void movezombies(){
  if(round > 5){
    zombspeed = 1.15f+round*0.025f;
  }else{
    zombspeed = 0.55f+round*0.05f;
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

public void removedeadzombies(){
  for(int i = zombies.size()-1; i > -1; i--){
    for(int j = 0; j < corpses.size(); j++){
      if(zombies.get(i).id == corpses.get(j).id){
        zombies.remove(i);
      }
    }
  }
}

public void deathparticles(PVector pos){
  particlesystems.add(new particlesystem(pos.copy(),new PVector(0,0,0),1,0.5f,color(255,20,20),60,120,1,60));
}

public PVector closestClient(PVector pos){
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

public float bearing(PVector a, PVector b) {
    float TWOPI = 6.2831853071795865f;
    float RAD2DEG = 57.2957795130823209f;
    float theta = atan2(b.x - a.x, a.y - b.y);
    if (theta < 0.0f)
        theta += TWOPI;
    return RAD2DEG * theta;
}
  public void settings() {  fullScreen(P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "holiday_game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
