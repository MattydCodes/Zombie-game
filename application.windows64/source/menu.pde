boolean inmenu = true;

void drawmenu(){
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
