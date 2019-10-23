int[] keys = new int[9];
float movespeed = 2;
float speed = 0;
float fall = 0;
boolean intower = false;
PVector towerbox = new PVector(0,0,0);
float towerid = 0;
void move(){
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
    health+=0.032;
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
    movespeed=1.8;
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
      player.z = lerp(player.z,towerbox.z,0.35);
      fall = 0;
      if(keys[6] == 1){
        fall = -1.8;
        player.z+=0.1;
      }
    }else if(player.z >= towerbox.z+7){
      player.z = towerbox.z+6.9;
      fall = 0;
    }else{
      fall+=0.14;
      player.z-=fall;
    }
    if(dist(player.x,player.y,towerbox.x,towerbox.y) > 18){
      PVector restrict = vectortowards(player,towerbox);
      float t = 1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,1*constrain((dist(player.x,player.y,towerbox.x,towerbox.y)-18),0,2));        
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,1*constrain((dist(player.x,player.y,towerbox.x,towerbox.y)-18),0,2));
    }
  }else{
    if(player.z <= nval(player.x/scale,player.y/scale)*scale+30){
      player.z = lerp(player.z,nval(player.x/scale,player.y/scale)*scale+20,0.35);
      fall = 0;
      if(keys[6] == 1){
        fall = -2;
        player.z+=11;
      }
    }else{
      fall+=0.14;
      player.z-=fall;
    }
    if(dist(player.x,player.y,w/2.0*scale,w/2.0*scale) > (radius-54)*scale){
      PVector restrict = vectortowards(player,new PVector(w/2.0*scale,w/2.0*scale));
      float t = 1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)));
      player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,1*constrain((dist(player.x,player.y,w/2.0*scale,w/2.0*scale)-((radius-54)*scale)),0,2));        
      player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,1*constrain((dist(player.x,player.y,w/2.0*scale,w/2.0*scale)-((radius-54)*scale)),0,2));
    }
    for(int i = 0; i < zombies.size(); i++){
      zombie current = zombies.get(i);
      float d = dist(player.x,player.y,player.z,current.pos.x,current.pos.y,current.pos.z);
      if(d < 30){
        PVector restrict = vectortowards(current.pos,player);
        float t = 3*1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));     
        player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,3.0-d/10.0);
        player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,3.0-d/10.0);
        player.z = lerp(player.z,player.z+restrict.z*movespeed/speed*t,3.0-d/10.0);
        fall-=restrict.z*0.1;
      }
    }
  }
  for(int i = 0; i < clients.size(); i++){
    if(clients.get(i).ip.equals(myip) == false){
      playerc current = clients.get(i);
      float d = dist(player.x,player.y,player.z,current.pos.x,current.pos.y,current.pos.z);
      if(d < 20){
        PVector restrict = vectortowards(current.pos,player);
        float t = 3*1.0/(sqrt(pow(restrict.x,2)+pow(restrict.y,2)+pow(restrict.z,2)));   
        player.x = lerp(player.x,player.x+restrict.x*movespeed/speed*t,2-d/10.0);
        player.y = lerp(player.y,player.y+restrict.y*movespeed/speed*t,2-d/10.0);
        player.z = lerp(player.z,player.z+restrict.y*movespeed/speed*t,2-d/10.0);
        fall-=restrict.z*0.1;
      }
    }
  }
}
void keyPressed(){
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
    }else if(key == '#'){
      client.stop();
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
void keyReleased(){
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

PVector vectortowards(PVector pos1, PVector pos2){
  PVector pos3 = new PVector();
  pos3.x = pos2.x - pos1.x;
  pos3.y = pos2.y - pos1.y;
  pos3.z = pos2.z - pos1.z;
  return pos3.normalize();
}
