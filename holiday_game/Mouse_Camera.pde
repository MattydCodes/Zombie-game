PVector mouse = new PVector(0,0);
//camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0)
//camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
void cam(){
  d3.perspective(PI/3.0, float(width)/float(height), (height/2.0) / tan(PI/3.0/2.0)/500.0, (height/2.0) / tan(PI/3.0/2.0)*30.0);
  d3.camera(player.x,player.y,player.z,player.x+cos(radians(mouse.x)),player.y+sin(radians(mouse.x)),player.z+sin(radians(mouse.y)),0,0,-1);
}

void deadcam(){
  d3.camera(player.x,player.y,player.z+radius*scale+cos(millis()/5000.0)*500,player.x-100,player.y,player.z,0,0,-1);
}

void menucam(){
  d3.camera(2000+cos(millis()/10000.0)*radius*scale*0.9,2000+sin(millis()/10000.0)*radius*scale*0.9,600,2000,2000,150,0,0,-1);
}

void mouseMoved(){
  if(menu == false){
    mouse.x-=(width/2-mouseX)/50.0;
    mouse.y+=(height/2-mouseY)/50.0;
    mouse.y = constrain(mouse.y,-90,90);
    robot.mouseMove(width/2,height/2);
  }
}

void mouseDragged(){
  if(menu == false){
    mouse.x-=(width/2-mouseX)/50.0;
    mouse.y+=(height/2-mouseY)/50.0;
    mouse.y = constrain(mouse.y,-90,90);
    robot.mouseMove(width/2,height/2);
  }
}
