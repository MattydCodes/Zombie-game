boolean menu = true;
PImage hostd;
PImage hosts;
PImage joind;
PImage joins;
boolean ipselect = false;
boolean nameselect = false;
  //m:¬ h:` a:£ b:$ c:{ d:; e: : f:| x:& y:% z:]
String typeable = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ1234567890.,/<>?'@#~-_+=!^*() ";
boolean istypeable(String key_){
  for(int i = 0; i < typeable.length(); i++){
    if(key_.equals(typeable.substring(i,i+1))){
      return true;
    }
  }
  return false;
}

void loadmenu(){
  hostd = loadImage("images/hostd.png");
  hosts = loadImage("images/hosts.png");
  joind = loadImage("images/joind.png");
  joins = loadImage("images/joins.png");
}

void drawmenu(){
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
    if(int(frameCount/30)%2 == 0){
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
    if(int(frameCount/30)%2 == 0){
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
void menudraw(){
  d3.beginDraw();
  d3.shader(shader);
  d3.background(63.75);
  d3.directionalLight(180,150,150,0,0.05,-1);
  d3.shape(c.terrain);
  menucam();
  d3.endDraw();
}
