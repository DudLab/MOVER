
//===========================================
//===========================================
// parse the end of trial serial data
void eot_parser() {
  TrialCounter.setValue(trialData[0]);
  TrialStart.setValue(trialData[1]/1000);
  TrialEvent.setValue(trialData[2]/1000);
  TrialEnd.setValue(trialData[3]/1000);
  
  trialD[int(trialData[0]-1)] = int((trialData[2]-trialData[1])); // will be approximately bounded at 3*12            
  monD[int(trialData[0]-1)]   = yWidth;
  
  // STORE THE TRIAL DATA IN AN ASSOCIATED TEXT FILE
  String data = trialData[0] + "," + trialData[1] + "," + trialData[2] + "," + trialData[3] + "," + trialData[4] + "," + trialData[5] + "," + trialData[6]+ ","+ paramWave[8]+ ","+ variable;
  output.println(data);
  output.flush();
  
  // also need to store parameters of previous trial
  String dataP = trialData[0] + "," + paramWave[0] + "," + paramWave[1] + "," + paramWave[2] + "," + paramWave[3] + "," + paramWave[4] + "," + paramWave[5] + "," + paramWave[6] + "," + paramWave[7] + "," + paramWave[8] + "," + paramWave[9];
  parameters.println(dataP);
  parameters.flush();
  
  // store the end of the last trial
  lastTrialCompletion = time; // no local punishment for long delay trials

  println("Updated log file with trial data.");   
          
  if (endSessionLogic) {
    controlP5.controller("run").setColorBackground(0xff003652);
    testMode = 1;
    isRunning = 0;
    initialRun=true;
    println("Stopped");
    lastEvent = time;
    controlCode = 4;
  } else {
    controlCode = 2;
  }

  println(controlCode);
  
}


//===========================================
//===========================================
// this function is used to determine the parameters for the subsequent trial
void eot_parameter() {

  responseMode = int(ParamDisp9.value());
  interTrialInterval = int(ParamDisp0.value());

  // set stimulus parameters
  stimDelay = 500;
  stimDuration = 500;

// FOR MITOMOVER ///////////////////////////////////////
// FOR MITOMOVER ///////////////////////////////////////

  valveOpenTimeX = int(ParamDisp7.value()); // should be set by user
  valveOpenTimeY = int(ParamDisp7.value()); // should be set by user
  valveDelayTime = 1000;

  xCenter = int(ParamDisp3.value());
  yCenter = int(ParamDisp5.value());
  xWidth = int(ParamDisp4.value());
  yWidth = int(ParamDisp6.value());


 // SWITCH TO THE STAIRCASE PARADIGM
 
  blockType = floor(count/30);
  
  if (blockType>=4) {
    // session is complete
    endSessionLogic = true;
  } else {
    yWidth = thresholds[blockType];
    xWidth = thresholds[blockType];
    
    ParamDisp4.setValue(xWidth);
    ParamDisp6.setValue(yWidth);
  }
  
// FOR MITOMOVER ///////////////////////////////////////
// FOR MITOMOVER ///////////////////////////////////////
  
  paramWave[0] = stimDelay;
  paramWave[1] = stimDuration;
  paramWave[2] = valveOpenTimeX;
  paramWave[3] = xCenter;
  paramWave[4] = xWidth;
  paramWave[5] = yCenter;
  paramWave[6] = yWidth;
  paramWave[7] = valveOpenTimeY;
  paramWave[8] = valveDelayTime;
  paramWave[9] = responseMode;
  
//  ParamDisp0.setValue(interTrialInterval);
  ParamDisp1.setValue(stimDelay);
//  ParamDisp2.setValue(stimDuration);
//  ParamDisp3.setValue(xCenter);
//  ParamDisp4.setValue(xWidth);
//  ParamDisp5.setValue(yCenter);
//  ParamDisp6.setValue(yWidth);
//  ParamDisp7.setValue(valveOpenTime);
  ParamDisp8.setValue(valveDelayTime);
//  ParamDisp9.setValue(responseMode);
}




//===========================================
//===========================================
void eot_analysis() {
// this is a function to calculate any online analysis needed...

// at minimum need a trial counter; also would like a running average of latencies for example
  count++;
  
//  //===========================================
//  // SEND CURRENT INFO
//  transmittedPacket = str(trialData[1])+","+str(TrialCounter.value())+",*";
//  myServer.write(transmittedPacket);
//  //===========================================

}

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
  int constrainedValue = int( constrain( (unscaledRandNum*variance) + mean, 250, 3950) );
  return int(constrainedValue);
}

