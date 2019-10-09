//========================================
// INIDIVIDUAL BUTTON CONTROL FUNCTIONS
void test(float theValue) {
  if (isRunning == 0 && time>(lastEvent+500)){
    sendSerialCode(6);
    println("Monitor is in test mode");
    if (pinLogic==0) {
      controlP5.controller("test").setColorBackground(0xff003652);
    } else {
      controlP5.controller("test").setColorBackground(color(240,0,180));
    }
  }else{
    println("Monitor must not be running for test to execute");
  }
  lastEvent = time;
}

//========================================
void run(float theValue) {
  testMode = 0;
  
  if(initialRun) {
    String fileName = fileLabelP.getText()+fileSuffix;
    println("Data will be saved to: "+fileName);

    // create a data file to keep track of data about behavioral performance    
    output = createWriter("../../../DataBuffer/"+fileName+".csv");
    String header = "fileName, "+str(param1)+str(param2)+str(param3)+str(param4)+str(param5);
    output.println(header);
    output.flush();
    String firstLine = "COL1:trial, COL2:start, COL3:event, COL4:end, COL5:lick,COL6:valve,COL7:type,COL8:reward,COL9:block";
    output.println(firstLine);
    output.flush(); // required for some reason
    
    // create a data file to keep track of data about behavioral performance    
    parameters = createWriter("../../../DataBuffer/"+fileName+"_p.csv");
    parameters.println(header);
    parameters.flush();

//    mm = new MovieMaker(this, width, height, fileName+".mov",30, MovieMaker.ANIMATION, MovieMaker.BEST,2);

    // store continuous data for the trajectories in case not recording elsewhere
    outputX = createWriter("../../../DataBuffer/"+fileName+"tX"+".csv");
    outputX.println("TRAJECTORIES IN X BEFORE EVENTS");
    outputX.flush(); // required for some reason
    outputY = createWriter("../../../DataBuffer/"+fileName+"tY"+".csv");
    outputY.println("TRAJECTORIES IN Y BEFORE EVENTS");
    outputY.flush(); // required for some reason

    // store continuous data for the trajectories in case not recording elsewhere
    compTraj = createWriter("../../../DataBuffer/"+fileName+"pXY"+".csv");
    compTraj.println("JOYSTICK POSITION");
    compTraj.flush(); // required for some reason
    String colData = "timeStamp(ms),x(au),y(au),lick(au)";
    compTraj.println(colData);
    compTraj.flush();
    
    paramWave[0] = interTrialInterval;
    paramWave[1] = stimDelay;
    paramWave[2] = stimDuration;
    paramWave[3] = xCenter;
    paramWave[4] = xWidth;
    paramWave[5] = yCenter;
    paramWave[6] = yWidth;
    paramWave[7] = valveOpenTime;
    paramWave[8] = valveDelayTime;
    paramWave[9] = responseMode;
//    paramWave[10] = omit;
    
    ParamDisp0.setValue(interTrialInterval);
    ParamDisp1.setValue(stimDelay);
    ParamDisp2.setValue(stimDuration);
    ParamDisp3.setValue(xCenter);
//    ParamDisp4.setValue(xWidth);
    ParamDisp5.setValue(yCenter);
//    ParamDisp6.setValue(yWidth);
    ParamDisp7.setValue(valveOpenTime);
    ParamDisp8.setValue(valveDelayTime);
    ParamDisp9.setValue(responseMode);
    
    betweenTrials = 1;
    initialRun = !initialRun;
  }
  
  isRunning = 1;
  betweenTrials = 1;
  
  controlP5.controller("run").setColorBackground(color(240,0,180));
  lastEvent = time;
  isRecording = true;

}

//========================================
void stop(float theValue) {
  controlP5.controller("run").setColorBackground(0xff003652);
  testMode = 1;
  isRunning = 0;
  initialRun=true;
  println("Stopped");
  lastEvent = time;
  isRecording = false;
}

//========================================
void record(float theValue) {
    if(recording==0) {
      // if you want to record video need to set it up
      controlP5.controller("record").setColorBackground(color(240,0,180));
      if(isRunning==1) {
        recording=1;
        println("Recording");
      }
    } else {
//      mm.finish();
      recording=0;
      controlP5.controller("record").setColorBackground(0xff003652);
    }
}

void keyPressed() { 
  if (key == 'c' || key == 'C') {
    controlCode = 2; // start streaming data
  }
}

// these are the default colors in controlP5 (from googlecode repository)
//        protected int colorBackground = 0xff003652;
//        protected int colorForeground = 0xff00698c;
//        protected int colorActive = 0xff08a2cf; // 0699C4;
