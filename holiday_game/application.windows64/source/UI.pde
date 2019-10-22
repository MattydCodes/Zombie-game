PGraphics ui;
PImage bulletico;
PImage crosshair;

void drawui(){
  ui.beginDraw();
  ui.clear();
  ui.stroke(0);
  ui.fill(0);
  ui.image(crosshair,944,524,32,32);
  ui.image(bulletico,80,910);
  ui.textSize(40);
  if(bulletcount < 10){
    ui.text("0"+int(bulletcount),200,955);
  }else{
    ui.text(int(bulletcount),200,955);
  }
  ui.text(int(weaponstats[weapon][3]),235,1000);
  ui.strokeWeight(10);
  ui.line(200,990,280,940);
  ui.fill(255);
  ui.textSize(20);
  ui.text("Score : " + int(points),50,80);
  ui.textSize(40);
  ui.fill(255,10,10,255-sin(radians(rounddelay*2))*245.0);
  ui.text("Round : " + int(round),45,40);
  if(started == false && ishosting){
    ui.fill(255,50,50);
    float v = (cos(millis()/1000.0)*20+40);
    ui.textSize(v);
    ui.text("Press Enter To Start",985-v*6,480-v);
  }
  ui.endDraw();
  image(ui,0,0,width,height);
}
