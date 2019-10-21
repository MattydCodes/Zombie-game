import processing.sound.*;
SoundFile[] gunshot;
SoundFile[] zombiesound;
SoundFile song;
import processing.net.*;
Server server;
Client client;
import java.awt.Robot;
Robot robot;
chunk c;
int seed;
PShader shader;
void setup(){
  size(1920,1080,P3D);
  createmyip();
  blood = loadShader("data/shaders/health.glsl");
  song = new SoundFile(this,"data/sounds/song.mp3");
  shader = loadShader("shaders/frag.glsl", "shaders/vert.glsl");
  gunshot = new SoundFile[20];
  zombiesound = new SoundFile[300];
  for(int i = 0; i < gunshot.length; i++){
    gunshot[i] = new SoundFile(this,"data/sounds/gunshot.wav");
    gunshot[i].amp(0.2);
  }
  for(int i = 0; i < zombiesound.length; i++){
    zombiesound[i] = new SoundFile(this,"data/sounds/zomb" + str(round(random(1,5))) + ".wav"); 
  }
  song.amp(0.1);
  setupbullet();
  seed = 50;
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
  pmodel = loadshape("data/playermodel.obj","data/playertext.png");
  pmodel.rotateX(PI/2);
  pmodel.rotateZ(PI);
  pmodel.scale(1.1);
  zombiem1 = loadshape("data/zombiewalk1.obj","data/texture.png");
  zombiem1.rotateX(PI/2);
  zombiem2 = loadshape("data/zombiewalk2.obj","data/texture.png");
  zombiem2.rotateX(PI/2);
  zombiea1 = loadshape("data/zombieattack1.obj","data/texture.png");
  zombiea1.rotateX(PI/2);
  zombiea2 = loadshape("data/zombieattack2.obj","data/texture.png");
  zombiea2.rotateX(PI/2);
  pistol1 = loadshape("data/pistol1.obj","data/pistoltext.png");
  pistol1.rotateX(PI/2);
  pistol2 = loadshape("data/pistol2.obj","data/pistoltext.png");
  pistol2.rotateX(PI/2);
  pistol1.scale(0.5);
  pistol2.scale(0.5);
  smg1 = loadshape("data/smg1.obj","data/smgtext.png");
  smg2 = loadshape("data/smg2.obj","data/smgtext.png");
  smg1.rotateX(PI/2);
  smg2.rotateX(PI/2);
  smg1.scale(0.5);
  smg2.scale(0.5);
  sniper1 = loadshape("data/sniper1.obj","data/snipertext.png");
  sniper2 = loadshape("data/sniper2.obj","data/snipertext.png");
  sniper1.rotateX(PI/2);
  sniper2.rotateX(PI/2);
  sniper1.scale(0.7);
  sniper2.scale(0.7);
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
void draw(){
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

void draw3d(){
  d3.beginDraw();
  d3.shader(shader);
  if(alive){
    move();
  }
  treehitboxes();
  d3.background(63.75);
  d3.directionalLight(180,150,150,0,0.05,-1);
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
  managebarriers();
  managecorpses();
  manageparticles();
  drawplayers();
  if(alive){
    showbarrel();
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
    blood.set("hp",health/100.0);
    health = constrain(health,0,100);
    blood.set("millis",float(millis()));
  }
  if(alive){
    filter(blood);
    drawui();
  }
  updatesounds();
}
