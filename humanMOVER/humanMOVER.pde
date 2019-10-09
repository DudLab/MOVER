import controlP5.*;

// Human version of the MOVER task

// Basic design:

//===================================================================================================
// INITIALIZE GLOBAL VARIABLES
//===================================================================================================
long    time = 0;
long    newTrialTime = 10000000;
long    trialStart = 0;
long    startTime = 0;
float[] trialData = {0,0,0,0,0,0,0};
int     trialCount = 0;
int     probeTrialCnt = 5;
int     sumTarget = 0;
int[]   blockPoss = {400, 300, 200, 300, 400};
int[]   blocklong = {10, 10, 10, 10, 10};
int     blockVar = 1;
int     state = 100;
long    rewDeliveryTime = 1000000000;

boolean running = false;
boolean trialMayBeEnded = false;
boolean inTrial = false;
boolean primed = false;
boolean probeTrial = false;
boolean initialRun = true;
boolean training = false;
boolean canBePrimed = false;
boolean inTargetInit = false;
boolean inTargetHarvest = false;
boolean clicked = false;
  
PVector  initTarget = new PVector(720, 600, 0); 
PVector  harvTarget = new PVector(720, 400, 0); 
PVector  mouse = new PVector(0, 0, 0);

int[]   inTargetLogic = {0,0,0,0,0,0,0,0,0,0};

PrintWriter trial_output;
PrintWriter continuous;

ControlP5 controlP5;
Numberbox TimeRemaining;
Numberbox SessIncome;
Textfield fileLabelP;

//===================================================================================================
//===================================================================================================
void setup() {

  frameRate(75);
  background(0);
  size(1400, 800);
  smooth();
  println(blockVar);
  ellipseMode(CENTER);
  strokeWeight(5);
  noCursor();

  controlP5 = new ControlP5(this);
  fileLabelP = controlP5.addTextfield("USER",1250,10,100,50);
  fileLabelP.setText("user"+str(int(random(1,1000000))));
  
  TimeRemaining = controlP5.addNumberbox("Time Remaining",30.000,1250,85,100,50);
  SessIncome = controlP5.addNumberbox("Session Income",30.000,1250,160,100,50);
  
}

//===================================================================================================
//===================================================================================================
void draw() {
  
  background(0);
  time = millis();
  
//===================================================================================================
// draw the targets
  fill(0);
  if (inTrial) {
    stroke(0,125,255,255);
  } else {
    stroke(0,125,255,50);    
  }
  ellipse(initTarget.x,initTarget.y,100,100);
  
//===================================================================================================
// where is the cursor?
  mouse.set(mouseX, mouseY, 0.0);
  float dI = PVector.dist(mouse,initTarget);
  float dH = PVector.dist(mouse,harvTarget);
  
  if (dI<50) {
    inTargetInit = true;
  } else {
    inTargetInit = false;
  }
  
  if (dH<50) {
    inTargetHarvest = true;
  } else {
    inTargetHarvest = false;
  }  
  
  for (int i = 0; i < 9; i++) {
    inTargetLogic[i] = inTargetLogic[i+1];
  }
  inTargetLogic[9] = int(inTargetHarvest);
  
//===================================================================================================
// draw some user feedback / debugging
  fill(255); textSize(18);
  text("Cursor in BLUE to INITIATE a trial / HARVEST reward.",5,25);
  text("Move to hidden target to release reward.",5,60);
  text(trialCount,5,95);

//===================================================================================================
// state machine for the trials 

switch(state) {
  
  case 0: // iti

    if (inTargetInit & inTrial) {
      state = 1;
      trialStart = time;
    }
    break;
    
  case 1: // waiting for trigger to harvest
    sumTarget = 0; 
    for (int i = 0; i < 10; i++) {
      sumTarget += inTargetLogic[i];
    }
    if (sumTarget>8) {
      rewDeliveryTime = time+1000;
      state = 2;
    }
    break;
    
  case 2: // delay period
    if(time>rewDeliveryTime & inTargetInit) {
      state = 3;
    }
    break;
    
  case 3: // deliver reward
    fill(255);
    ellipse(initTarget.x,initTarget.y,100,100);
    delay(400);
    state = 4;
    break;
  
  case 4: // end of trial
  
    trialData[0] = trialCount;
    trialData[1] = trialStart;
    trialData[2] = time - trialStart;
    trialData[3] = blockVar;
    trialData[4] = harvTarget.x;
    trialData[5] = harvTarget.y;
    
    inTrial = false;
    
    fill(255);
    stroke(255,0,0);
    ellipse(initTarget.x,initTarget.y,100,100);
    fill(0);

    eot_parser();
    eot_parameter(); 
    
    state = 100;
    newTrialTime = time+2000;
    break;
    
  case 100: //do nothing, idle
    if (time>newTrialTime) {
      inTrial = true;
      state = 0;
      rewDeliveryTime=1000000000;
    }
    break;
    
}

    
//===================================================================================================
// draw the cursor and indicate if it is within a target
  stroke(0);
  if (inTargetInit) {
    fill(0,125,255,255);
  //} else if (inTargetHarvest) {
    //fill(255,125,125,255); // for debugging let me see the cursor
  } else {
    fill(255,255,255);    
  }

  ellipse(mouseX,mouseY,25,25);

  
//===================================================================================================
// write out continuous data
  if (running) {
      String dataC = time + "," + int(mouse.x) + "," + int(mouse.y) + "," + int(inTargetInit) + "," + int(inTargetHarvest) + "," + int(inTrial) + "," + int(harvTarget.x) + "," + int(harvTarget.y) + "," + int(blockVar);
      continuous.println(dataC);
      continuous.flush();
    }

} // draw loop

//===================================================================================================
//===================================================================================================
void eot_parser() {  
  
  // STORE THE TRIAL DATA IN AN ASSOCIATED TEXT FILE
  String data = trialData[0] + "," + trialData[1] + "," + trialData[2] + "," + trialData[3] + "," + trialData[4] + "," + trialData[5] + "," + trialData[6];
  trial_output.println(data);
  trial_output.flush();
  
}


//===================================================================================================
//===================================================================================================
void eot_parameter() {
    
  trialData[6] = blockVar;
  trialCount++;
  blockVar = floor(trialCount / 10);
  if (blockVar <= blockPoss.length) {
    harvTarget.y = blockPoss[blockVar];
  } else {
    running = false;
    continuous.close();
  }
  println(harvTarget.y);

}


//===================================================================================================
//===================================================================================================
int GenerateGaussianDelay(float variance, float mean) {

  float x = 0;
  float y = 0;
  float s = 2;

  while (s>1) {
    x=random(-1,1);
    y=random(-1,1);
    s = (x*x) + (y*y);
  }  
  
  float unscaledRandNum = x*( sqrt(-2*log(s) / s) );
  int constrainedValue = int( constrain( (unscaledRandNum*variance) + mean, 250, 10000) );
  return int(constrainedValue);
}

//===================================================================================================
//===================================================================================================
void keyPressed() { 
  
  if (key == 's' || key == 'S') {

    startTime     = time;
    newTrialTime  = time + 2000;
    running       = true;
    state         = 100;
    
    if(initialRun) {
      String fileName = fileLabelP.getText() + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute();
      println("Data will be saved to: "+fileName);

      // create a data file to keep track of data about behavioral performance    
      trial_output = createWriter("DataBuffer/"+fileName+".csv");
    //trialData[0] = trialCount;
    //trialData[1] = trialStart;
    //trialData[2] = time - trialStart;
    //trialData[3] = blockVar;
    //trialData[4] = harvTarget.x;
    //trialData[5] = harvTarget.y;      
      String firstLine = "trial_number , trial_start , thresh_cross , blockvar , target_x , target_y ";
      trial_output.println(firstLine);
      trial_output.flush(); // required for some reason
      
      // create a data file to keep track of data about behavioral performance    
      continuous = createWriter("DataBuffer/"+fileName+"_p.csv");
      
      String dataC = time + "," + int(mouse.x) + "," + int(mouse.y) + "," + int(inTargetInit) + "," + int(inTargetHarvest) + "," + int(inTrial) + "," + int(harvTarget.x) + "," + int(harvTarget.y) + "," + int(blockVar);

      String firstLine2 = "time,mousex,mousey,inittarget,harvtarget,intrial,targetx,targety,blockvar";
      continuous.println(firstLine2);
      continuous.flush(); // required for some reason

    }
  }
  
}
