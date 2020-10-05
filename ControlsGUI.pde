import controlP5.*;

ControlP5 cp5;
int myColor = color(0, 0, 0);

int sliderValue = 100;

void setupGUI() {

  cp5.addSlider("offsetX")
    .setPosition(100, 50)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(0.13)
    ;
  cp5.addSlider("offsetY")
    .setPosition(100, 100)
    .setRange(-4, 4)
     .setSize(800, 30)
    .setValue(-0.16)
    ;
  cp5.addSlider("offsetZ")
    .setPosition(100, 150)
    .setSize(400, 30)
    .setRange(-8, 0)
    .setValue(-3.54)
    ;

  cp5.addSlider("minX")
    .setPosition(100, 200)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(-2.20)
    ;
  cp5.addSlider("maxX")
    .setPosition(100, 240)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(2.20)
    ;
  cp5.addSlider("minY")
    .setPosition(100, 280)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(-2.20)
    ;
  cp5.addSlider("maxY")
    .setPosition(100, 320)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(2.20)
    ;
  cp5.addSlider("minZ")
    .setPosition(100, 360)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(1.2)
    ;
  cp5.addSlider("maxZ")
    .setPosition(100, 400)
    .setRange(-4, 4)
    .setSize(800, 30)
    .setValue(2.2)
    ;

  cp5.setAutoDraw(false);
}
