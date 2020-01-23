import processing.net.*;
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

void setup(){
  size(500,500,P2D);
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

void draw(){
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

void keyPressed(){
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

void managepipes(){
  for(int i = 0; i < pipes.length; i++){
    pipes[i].display();
  }
}

void resetpipes(){
  for(int i = 0; i < pipes.length; i++){
    pipes[i].avoided = false;
  }
}

void calcfall(){
  if(playerheight >= 475){
    playerheight = 475;
    fall = 0;
  }else{
    fall = fall + 0.45;
    playerheight = playerheight + fall;
  }  
  fall = min(fall,9.5);
}

boolean onground(){
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
  void display(){
    //x = x - 2.5; 
    fill(50);
    image(toppipe,x-20,y-gap/2.0-456,70,456);
    image(botpipe,x-20,y+gap/2.0,70,456);
    top = y-gap/2.0;
    bot = y+gap/2.0;
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

void createbirb(){
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

void managebirb(){
  float d = fall;
  d/=10.0;
  translate(player,playerheight);
  rotate(sin(d)-PI/10.0);
  shape(birb);
  rotate(-sin(d)+PI/10.0);
  translate(-player,-playerheight);
}

void displayScore(){
  fill(255);
  text("Score: " + str(score),50,50);
}
