// Thomas Sanchez Lengeling //<>// //<>//
// Multi Kinect with all features
// Example connecting multiple Kinects v1 on a single Mac

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;


ArrayList<Kinect> multiKinect;


boolean ir = false;
boolean colorDepth = false;

int numDevices = 0;

//index to change the current device changes
int deviceIndex = 0;

float deg = 0;

Kinect tmpKinect;

boolean showKinect2 = false;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

// Angle for rotation
float a = 0;

ArrayList<PVector> depth1 = new ArrayList<PVector>(); 
ArrayList<PVector> depth2 = new ArrayList<PVector>(); 

boolean recorded = false;

float offsetX, offsetY, offsetZ, minX, maxX, minY, maxY, minZ, maxZ;

float factor = 200;

void setup() {
  size(1024, 720, P3D);
  cp5 = new ControlP5(this);
  setupGUI();
  //get the actual number of devices before creating them
  numDevices = Kinect.countDevices();
  println("number of Kinect v1 devices  "+numDevices);

  //creat the arraylist
  multiKinect = new ArrayList<Kinect>();

  //iterate though all the devices and activate them
  //for (int i  = 0; i < numDevices; i++) {
  //  Kinect tmpKinect = new Kinect(this);
  //  tmpKinect.activateDevice(i);
  //  tmpKinect.initDepth();
  //  tmpKinect.initVideo();
  //  tmpKinect.enableColorDepth(colorDepth);

  //  multiKinect.add(tmpKinect);
  //}

  tmpKinect = new Kinect(this);
  tmpKinect.enableColorDepth(colorDepth);
  tmpKinect.activateDevice(0);
  tmpKinect.initDepth();
  tmpKinect.initVideo();

  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}


void draw() {
  background(0);

  //iterat though the array of kinects
  //for (int i  = 0; i < multiKinect.size(); i++) {
  //  Kinect tmpKinect = (Kinect)multiKinect.get(i);

  //  //make the kinects capture smaller to fit the window
  //  image(tmpKinect.getVideoImage(), 0, 240*i, 320, 240);
  //  image(tmpKinect.getDepthImage(), 320, 240*i, 320, 240);
  //}





  //Kinect tmpKinect = (Kinect)multiKinect.get(0);
  if (mousePressed & !showKinect2) {
    showKinect2 = true;
    tmpKinect.stopDepth();
    tmpKinect.stopVideo();
    tmpKinect = new Kinect(this);
    //tmpKinect.enableColorDepth(colorDepth);
    tmpKinect.activateDevice(1);
    tmpKinect.initDepth();
    tmpKinect.initVideo();
    println("kinect 1");
  } 



  image(tmpKinect.getVideoImage(), 0, 240*1, 320, 240);
  image(tmpKinect.getDepthImage(), 640, 0);


  // drawPoinCloud();

  if (!recorded) {

    recordPointCloud1();
    showKinect2 = true;
    tmpKinect.stopDepth();
    tmpKinect.stopVideo();
    tmpKinect = new Kinect(this);
    //tmpKinect.enableColorDepth(colorDepth);
    tmpKinect.activateDevice(1);
    tmpKinect.initDepth();
    tmpKinect.initVideo();
    println("kinect 1");
    recordPointCloud2();
    recorded = true;
  }

  if (recorded) {
    drawMergedPoinCloud();
  }

  fill(255);
  text("Device Count: " +numDevices + "  \n" +
    "Current Index: "+deviceIndex, 660, 50, 150, 50);

  text(
    "Press 'i' to enable/disable between video image and IR image  \n" +
    "Press 'c' to enable/disable between color depth and gray scale depth \n" +
    "UP and DOWN to tilt camera : "+deg+"  \n" +
    "Framerate: " + int(frameRate), 660, 100, 280, 250);

  gui();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);

  cp5.draw();

  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {

  if (key == 'e') {


    exportMergedPointCloud();
  }


  if (key == '-') {
    if (deviceIndex > 0 && numDevices > 0) {
      deviceIndex--;
      deg = multiKinect.get(deviceIndex).getTilt();
    }
  }

  if (key == '+') {
    if (deviceIndex < numDevices - 1) {
      deviceIndex++;
      deg = multiKinect.get(deviceIndex).getTilt();
    }
  }


  if (key == 'i') {
    ir = !ir;
    multiKinect.get(deviceIndex).enableIR(ir);
  } else if (key == 'c') {
    colorDepth = !colorDepth;
    multiKinect.get(deviceIndex).enableColorDepth(colorDepth);
  } else if (key == CODED) {
    if (keyCode == UP) {
      deg++;
    } else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg, 0, 30);
    multiKinect.get(deviceIndex).setTilt(deg);
  }
}


void recordPointCloud1() {

  // Get the raw depth as array of integers
  int[] depth = tmpKinect.getRawDepth();

  for (int x = 0; x < tmpKinect.width; x ++) {
    for (int y = 0; y < tmpKinect.height; y ++) {
      int offset = x + y*tmpKinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);

      depth1.add(v);
    }
  }
}

void recordPointCloud2() {

  // Get the raw depth as array of integers
  int[] depth = tmpKinect.getRawDepth();

  for (int x = 0; x < tmpKinect.width; x ++) {
    for (int y = 0; y < tmpKinect.height; y ++) {
      int offset = x + y*tmpKinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);

      depth2.add(v);
    }
  }
}

void exportMergedPointCloud() {

  String[] pointCloud = new String[2 * tmpKinect.width * tmpKinect.height + 1];
  pointCloud[0] = "X Y Z";
  for (int x = 0; x < tmpKinect.width; x ++) {
    for (int y = 0; y < tmpKinect.height; y ++) {
      int offset = x + y*tmpKinect.width;
      PVector v1 = depth1.get(offset);
      if (v1.x > minX && v1.x < maxX && v1.y > minY && v1.y < maxY && v1.z > minZ && v1.z < maxZ) {

        pointCloud[2*offset+1] = v1.x*factor + " " + v1.y*factor + " " + (factor-v1.z*factor);
      } else {      
        pointCloud[2*offset+1] = "-10 -10 -10";
      }
      PVector v2 = depth2.get(offset);

      PVector v2Offset = PVector.add(v2, new PVector(offsetX, offsetY, offsetZ));
      if (-v2Offset.x > minX && -v2Offset.x < maxX && v2Offset.y > minY && v2Offset.y < maxY && -v2Offset.z > minZ && -v2Offset.z < maxZ) {
        pointCloud[2*offset+2] = -v2Offset.x*factor + " " + v2Offset.y*factor + " " + (factor + v2Offset.z*factor);
      } else {
        pointCloud[2*offset+2] = "-10 -10 -10";
      }
    }
  }


saveStrings("pointCloud " + millis() + ".XYZ", pointCloud);
println("exported point cloud");
}


void drawMergedPoinCloud() {

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 4;
  pushMatrix();
  // Translate and rotate
  translate(width/2, height/2, -50);
  rotateY(a);

  for (int x = 0; x < tmpKinect.width; x += skip) {
    for (int y = 0; y < tmpKinect.height; y += skip) {
      int offset = x + y*tmpKinect.width;
      PVector v1 = depth1.get(offset);
      PVector v2 = depth2.get(offset);
      PVector v22D = new PVector(v2.x, v2.z);
      //v22D.rotate(PI);
      //v2.x = -v2.x;
      //v2.set(v2.x,v2.y,-v22D.y);

      PVector v2Offset = PVector.add(v2, new PVector(offsetX, offsetY, offsetZ));
      stroke(255);
      pushMatrix();
      // Scale up by 200

      translate(v1.x*factor, v1.y*factor, factor-v1.z*factor);
      // Draw a point
      if (v1.x > minX && v1.x < maxX && v1.y > minY && v1.y < maxY && v1.z > minZ && v1.z < maxZ) {
        stroke(255, 100, 0);
      }
      point(0, 0);
      popMatrix();
      pushMatrix();
      stroke(255);
      translate(-v2Offset.x*factor, v2Offset.y*factor, factor + v2Offset.z*factor);
      if (-v2Offset.x > minX && -v2Offset.x < maxX && v2Offset.y > minY && v2Offset.y < maxY && -v2Offset.z > minZ && -v2Offset.z < maxZ) {
        stroke(255, 100, 0);
      }
      // Draw a point
      point(0, 0);
      popMatrix();
    }
  }
  popMatrix();
  // Rotate
  //a += 0.015f;
} 


void drawPoinCloud() {


  // Get the raw depth as array of integers
  int[] depth = tmpKinect.getRawDepth();

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 4;

  // Translate and rotate
  translate(width/2, height/2, -50);
  rotateY(a);

  for (int x = 0; x < tmpKinect.width; x += skip) {
    for (int y = 0; y < tmpKinect.height; y += skip) {
      int offset = x + y*tmpKinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);

      stroke(255);
      pushMatrix();
      // Scale up by 200
      float factor = 200;
      translate(v.x*factor, v.y*factor, factor-v.z*factor);
      // Draw a point
      point(0, 0);
      popMatrix();
    }
  }

  // Rotate
  a += 0.015f;
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}
