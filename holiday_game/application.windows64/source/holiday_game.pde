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
  fullScreen(P3D);
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
  song.amp(0.07);
  setupbullet();
  seed = int(random(1000));
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
  torchm[0] = loadshape("data/tikitorch1.obj","data/tikitext.png");
  torchm[0].rotateX(PI/2);
  torchm[0].scale(2);
  torchm[1] = loadshape("data/tikitorch2.obj","data/tikitext.png");
  torchm[1].rotateX(PI/2);
  torchm[1].scale(2);
  torchm[2] = loadshape("data/tikitorch3.obj","data/tikitext.png");
  torchm[2].rotateX(PI/2);
  torchm[2].scale(2);
  emberm = loadshape("data/ember.obj","data/embertext.png");
  emberm.scale(2);
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
  pistol1 = loadshape("data/pistol1R.obj","data/PistolTextR.png");
  pistol1.rotateX(PI/2);
  pistol1.rotateZ(PI);
  pistol2 = loadshape("data/Pistol2R.obj","data/PistolTextR.png");
  pistol2.rotateX(PI/2);
  pistol2.rotateZ(PI);
  pistol1.scale(0.75);
  pistol2.scale(0.75);
  pistol1.translate(0.05,0,1.3);
  pistol2.translate(0.05,0,1.3);
  smg1 = loadshape("data/smg1R.obj","data/smgtextR.png");
  smg2 = loadshape("data/smg2R.obj","data/smgtextR.png");
  smg1.rotateX(PI/2);
  smg2.rotateX(PI/2);
  smg1.translate(0.05,0,0.6);
  smg2.translate(0.05,0,0.6);
  smg1.rotateZ(PI);
  smg2.rotateZ(PI);
  smg1.scale(0.75);
  smg2.scale(0.75);
  sniper1 = loadshape("data/sniper1R.obj","data/snipertextR.png");
  sniper2 = loadshape("data/sniper2R.obj","data/snipertextR.png");
  sniper1.rotateX(PI/2);
  sniper2.rotateX(PI/2);
  sniper1.rotateZ(PI);
  sniper2.rotateZ(PI);
  sniper1.translate(0.05,0,1.1);
  sniper2.translate(0.05,0,1.1);
  sniper1.scale(0.75);
  sniper2.scale(0.75);
  weaponcrate = loadshape("data/weaponcrate.obj","data/cratetext.png");
  weaponcrate.rotateX(PI/2);
  setupweapons();
  bulletico = loadImage("data/images/bulletico.png");
  crosshair = loadImage("data/images/crosshair.png");
  loadmenu();
  ui = createGraphics(1920,1080,P2D);
  d3 = createGraphics(1920,1080,P3D);
  d3.smooth(4);
  ui.smooth(4);
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
  setlightsources();
  d3.shader(shader);
  if(alive){
    move();
  }
  treehitboxes();
  d3.background(0);
  d3.directionalLight(2,2,2,0,0.001,-1);
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
  managetorches();
  manageembers();
  managecorpses();
  manageparticles();
  drawplayers();
  if(alive){
    showbarrel();
    showtower();
    showtorch();
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
