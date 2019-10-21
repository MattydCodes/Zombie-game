boolean alldead = false;
int outroframe = 0;
void outro(){
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
