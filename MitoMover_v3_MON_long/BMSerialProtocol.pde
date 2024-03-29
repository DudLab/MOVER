/*
Serial codes are currently being modified to allow for the host computer to control the initiation and termination of trials.
*/

void serialEvent(Serial p) {
  serialEventLogic = true;
}

//========================================
// CONTROLLER FOR SENDING OUT THE SERIAL CODES
void sendSerialCode(int type) {

  switch(type) {

    case 1: // REQUEST DATA
      port.write(87);
      break;
      
    case 2: // BEGIN A TRIAL
      // MUST BE A SINGLE BYTE (-127->128) FOR THIS TRANSFER SCHEME
      //port.clear();
      port.write(90);
      port.write(0);
      port.write(0);
      port.write(paramWave[2]);
      port.write(paramWave[3]);
      port.write(paramWave[4]);
      port.write(paramWave[5]);
      port.write(paramWave[6]);
      port.write(paramWave[7]);
      port.write(responseMode);
      port.write(int(sqrt(valveDelayTime)));
      port.write(1);
      println("Trial Start...");
      break;
      
    case 3: // EMERGENCY BREAK
      println("STOP");
      //port.clear();
      port.write(89);
      isRunning = 0;
      break;

    case 4: // REQUEST END OF TRIAL DATA
      //port.clear();
      port.write(88);
      println("Request end of trial data");
      println(controlCode);
      break;
    
    case 5: // RETRIEVE CURRENT BURNED CODE DETAILS
      println("Request name of protcol");
      //port.clear();
      port.write(91);
      break;
      
    case 6: // DIRECTLY ASSERT PIN VALUES & STATES
      pinNumber = 22;
      if(pinLogic==1){
        pinLogic=0;
      }else{
        pinLogic=1;
      }
      println("Set pin: "+pinNumber+" to state: "+pinLogic);      
      //port.clear();
      port.write(92);
      port.write(pinNumber);
      port.write(pinLogic);
      break;
  }  
  
}
//========================================

//========================================
// GATHER DATA FROM INCOMING SERIAL DATA
void parseSerialData() {

    String input = port.readStringUntil('*');   
      
    if (input != null) {
      int[] serialVals = int(split(input, ","));
      String[] parameters = split(input, ',');
      
      switch (serialVals[0]) {
        case 1:
          varA = serialVals[1];
          varB = serialVals[2];
          varC = serialVals[3];
          varD = serialVals[4];
    
          digA = serialVals[5];
          digB = serialVals[6];
          digC = serialVals[7];
          digD = serialVals[8];
          digE = serialVals[9];
          digF = serialVals[10];
          digG = serialVals[11];
          digH = serialVals[12]; 
          digI = serialVals[13]; 
          digJ = serialVals[14]; 
          digK = serialVals[15]; 
          digL = serialVals[16]; 
          break;
                  
        case 3:
          if (time>lastEvent+500) {
            println("===========BOARD IS STOPPED===========");
            isRunning = 0;
          }
          break;
          
        case 4:
          trialData[0] = serialVals[1];
          trialData[1] = serialVals[2];
          trialData[2] = serialVals[3];
          trialData[3] = serialVals[4];
          trialData[4] = serialVals[5];
          trialData[5] = serialVals[6];
          trialData[6] = serialVals[7];
          println("Recieved end of trial data.");
          println(controlCode);
          controlCode = 1;
          betweenTrials = 1;
          break;
          
        case 5:
          println("End of trial code received");
          // Request the rest of the trial information
          controlCode = 3;
          break;
          
        case 6:
          println(parameters[0]);
          protName.setText(parameters[0]);
          break;
      }
            
    }
}
//========================================

      // need to send trial parameters here
      //paramWave[0] = interTrialInterval;
      //paramWave[1] = stimDelay;
      //paramWave[2] = stimDuration;
      //paramWave[3] = xCenter;
      //paramWave[4] = xWidth;
      //paramWave[5] = yCenter;
      //paramWave[6] = yWidth;
      //paramWave[7] = valveOpenTime;
      //paramWave[8] = valveDelayTime;
      //reponseMode
