import controlP5.*;

ControlP5 cp5;
int myColor = color(0,0,0);

int sliderValue = 100;

void setupGUI(){

 cp5.addSlider("offsetX")
     .setPosition(100,50)
     .setRange(-4,4)
     .setSize(800,30)
     .setValue(0.20)
     ;
      cp5.addSlider("offsetY")
     .setPosition(100,100)
     .setRange(-4,4)
     ;
      cp5.addSlider("offsetZ")
     .setPosition(100,150)
     .setSize(400,30)
     .setRange(-3,3)
     .setValue(-2.0)
     ;

cp5.setAutoDraw(false);
}
