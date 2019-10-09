/*
fixLeverOp
Behavioral task waits for a serial command to begin trials and looks for some movement of a joystick to trigger
an output response.
*/

//// include the library code:
//#include <SPI.h>
//// pick up the SPI pins from the arduino header file
//#include <pins_arduino.h>

#define BEAM1     3
#define SOLENOID1 22
#define LASER     42
#define ADC_PIN   49
#define DAC_PIN   48


//=======================
// Set the protocol name
char protocolName[] = "FixLever_v11_LL"; // should be less than 20 characters
unsigned long beginLoopTime;
unsigned long loopTime;
//=======================

//=======================
// set pin numbers for relevant inputs and outputs:
int analogPins[] = {0,1,2,3};
int digitalPins[] = {4,5,6,7,8,41,43,45,36,38,39,40};
//=======================

//=======================
// Arrays that will hold the current values of the AO and DIO
int CurrAIValue[] = {0,0,0,0};
int aiThresh[] =  {512,512,512,512};
int bufferLength = 100;
int bufferEndIndex = bufferLength-1;
int first=0;
int bufferAI0[100];
int bufferAI1[100];
int bufferAI2[100];
int bufferAI3[100];
int bufferLoc = 0;
//=======================

//=======================
// PARAMETERS OF TASK
unsigned long interTrialInterval = 15000;
unsigned long stimDelay = 500;
unsigned long stimDuration = 500;
unsigned long valveOpenTime = 200;
unsigned long valveOpenTimeX = 600;
unsigned long valveOpenTimeY = 600;
unsigned long valveDelayTime = 1000;
int placeHolder = 0;
int xCenter = 0;
int xWidth = 10;
int yCenter = 0;
int yWidth = 10;
int xUpperWidth = xWidth+10;
int yUpperWidth = yWidth+10;
boolean success = false;
int boundaryWidth = 10;
int holdDur = 100;
int responseMode = 3;
int leftTrial = 0;
int valveDelayTmp = 0;
int stimType = 0;
//=======================

//=======================
// VARIABLES OF TASK
unsigned long time;                 // all values that will do math with time need to be unsigned long datatype
unsigned long crossTime = 0; 
unsigned long rewardDelivered = 0;
boolean firstLickLogic = false;
unsigned long trialEnd = 0;
unsigned long trialStart = 0;
unsigned long firstLickTime = 0;
int ParadigmMode = 0;
int testMode = 0;
int jsZeroX = 512;
int jsZeroY = 512;
int xDisp = 0;
int yDisp = 0;
int xDispS = 0;
int yDispS = 0;
int prevXDisp = 0; // added 09.12 KM 
int prevYDisp = 0; // added 09.12 KM
int count = 0;
long displacement = 0;
//=======================

//=======================
// PARAMETERS OF HARDWARE
int lThresh = 300;
//=======================

//=======================
// VARIABLES FOR SERIAL COM
int code = 0;
int assertPinNum = 0;
int assertPinState = 0;
//=======================

//==========================================================================================================================
// SETUP LOOP
//==========================================================================================================================
void setup() {
  
      //=======================
      // prep DIGITAL outs and ins
        pinMode(digitalPins[0], OUTPUT);
        pinMode(digitalPins[1], OUTPUT);
        pinMode(digitalPins[2], OUTPUT);
        pinMode(digitalPins[3], OUTPUT);
        pinMode(digitalPins[4], OUTPUT);
        pinMode(digitalPins[5], OUTPUT);
        pinMode(digitalPins[6], OUTPUT);
        pinMode(digitalPins[7], OUTPUT);
        digitalWrite(digitalPins[0], LOW);
        digitalWrite(digitalPins[1], LOW);
        analogWrite(digitalPins[2], 0);
        digitalWrite(digitalPins[3], LOW);        
        digitalWrite(digitalPins[4], LOW);        
        digitalWrite(digitalPins[5], LOW);        
        digitalWrite(digitalPins[6], LOW);        
        digitalWrite(digitalPins[7], LOW);  
  
        pinMode(BEAM1, INPUT);      
      //=======================

      //=======================
      // two logic pins set high for testing digital signals
        pinMode(26, OUTPUT);
        pinMode(28, OUTPUT);
        digitalWrite(26, HIGH);
        digitalWrite(28, HIGH);     
        pinMode(SOLENOID1, OUTPUT);
        digitalWrite(SOLENOID1, LOW);
        pinMode(LASER, OUTPUT);
        digitalWrite(LASER, LOW);
      //=======================

      //=======================
      // prep ANALOG inputs
        analogReference(DEFAULT );
      //=======================
      
      //=======================
      // initialize the SERIAL communication
        Serial.begin(115200);
      //=======================
      
//      //=======================
//      // prep SPI for AD control
//      startSPI();
//      //=======================
      
  
    //=======================
    // initialize SERIAL for LCD
      Serial1.begin(19200); 
      Serial1.print(0x0c, DEC); // clear the display
      delay(5);
      Serial1.print(0x11, DEC); // Back-light on
      Serial1.print(0x80, DEC); // col 0, row 0    
      Serial1.print(protocolName);
    //=======================
  
    //=======================
      // initialize zero positions
        jsZeroX = analogRead(1);
        jsZeroY = analogRead(3);
      //=======================

      
      count = 0; // initialize the trial counter
      
      //=======================
      // initialize analog read buffer
      for (int j=0;j<bufferLength;j++) {
        bufferAI0[j] = 0;
        bufferAI1[j] = 0;
        bufferAI2[j] = 0;
        bufferAI3[j] = 0;        
      }
      bufferLoc = 0;
      //=======================
      
      CurrAIValue[0] = analogRead(1);
      CurrAIValue[1] = analogRead(3);
//      CurrAIValue[2] = analogRead(2);
      CurrAIValue[3] = 0;
      
}


//==========================================================================================================================
// MAIN EXECUTION LOOP
//==========================================================================================================================
void loop() {
  
      beginLoopTime = micros();
      time = millis();         

      prevXDisp = CurrAIValue[0];
      prevYDisp = CurrAIValue[1];

      CurrAIValue[0] = int(analogRead(1));
      CurrAIValue[1] = int(analogRead(3));
      CurrAIValue[3] = int(analogRead(0)); // lick port

      if(CurrAIValue[3]<255) {
        digitalWrite(digitalPins[4], HIGH); // signal a lick
        if(firstLickLogic) {
         firstLickTime = time;
         firstLickLogic = false; 
        }
      }    
    

      switch (ParadigmMode) {
      
        case 0: // just idle in this state waiting for controller to start next trial
            Serial1.print(0x94, DEC); // col 0, row 0
            Serial1.print("ITI...");
            Serial1.print(constrain(CurrAIValue[0],0,999));
            Serial1.print(".");
            Serial1.print(constrain(CurrAIValue[1],0,999));
            
            if (time > trialEnd+1000) {
              if (stimType==1) {
                digitalWrite(LASER, HIGH);
              }
            }
            
            break;
            
        case 1: // if controller tells you to start, then start      

            jsZeroX = CurrAIValue[0];
            jsZeroY = CurrAIValue[1];
            trialStart = time;
            digitalWrite(digitalPins[0], HIGH); // trial cue light 4            
            digitalWrite(digitalPins[5], HIGH); // trial cue indicator to send to the recording system
            ParadigmMode = 2;
            Serial1.print(0x0c, DEC); // clear the display
            Serial1.print(0x94, DEC); // col 0, row 0
            Serial1.print("START");
            break;
        
//==========================================================================================================================
// RULES FOR EVENT TRIGGERS
//==========================================================================================================================
        case 2: // look for lever threshold crossings and open valve in response

            switch(responseMode) { 
              
              case 0:
                
                xDisp = abs(CurrAIValue[0]-jsZeroX);     // find X displacement of previous sample
                yDisp = abs(CurrAIValue[1]-jsZeroY);     // find Y displacement of previous sample
                xDispS = abs(prevXDisp-jsZeroX);     // find X displacement of previous sample
                yDispS = abs(prevYDisp-jsZeroY);     // find Y displacement of previous sample
                                
                if (xDisp>10 || yDisp>10) { 
                  if (stimType==2) {
                    digitalWrite(LASER, HIGH);
                  }
                }
                
                
                if (!success) {
                
                  if (xDisp > xWidth & xDispS < xWidth) { 
                      crossTime = time;                             // mark cross time to check if the next buff samples go above upper threshold
                      success   = true;                             // for the time being, success = success
                  }
                    
                  if (yDisp > yWidth & yDispS < yWidth) { 
                      crossTime = time;                             // mark cross time to check if the next buff samples go above upper threshold
                      success   = true;                             // for the time being, success = success
                  }
                
                } else {

                  if (time < crossTime+holdDur) {
                      Serial1.print(0x0c, DEC); // clear the display
                      Serial1.print(0x94, DEC); // col 0, row 0
                      Serial1.print("SUCCESS"); 

                    if (xDisp > xUpperWidth || yDisp > yUpperWidth)  {
                      success = false;
                      Serial1.print(0x0c, DEC); // clear the display
                      Serial1.print(0x94, DEC); // col 0, row 0
                      Serial1.print("WAIT"); 
                    }
                  } else {
                    firstLickLogic = true;
                    digitalWrite(digitalPins[1], HIGH);  // success event pulse
                    digitalWrite(digitalPins[0], LOW); // trial cue 
                    digitalWrite(digitalPins[6], HIGH); // performance cue indicator to send to the recording system
                    ParadigmMode = 3;
                    Serial1.print(0x0c, DEC); // clear the display
                    Serial1.print(0x94, DEC); // col 0, row 0
                    Serial1.print("->REWARD"); 
                    success = false;                    
                  }
                  
                }
                
                break;
                              
            }
            
            break;
//==========================================================================================================================
// RULES FOR EVENT TRIGGERS
//==========================================================================================================================
    
        case 3:
                        
            if(CurrAIValue[3]<lThresh && first==0) {
              trialEnd = time;
              first = 1;
            }
            
            if(time > (crossTime+500) ) {
              if (stimType==3) {
                digitalWrite(LASER, HIGH);
              }
              analogWrite(digitalPins[2], 0);              
            }
            
            if(time > (crossTime+valveDelayTime) ) {
              digitalWrite(SOLENOID1, HIGH);  // valve opens
              rewardDelivered = time;
              digitalWrite(digitalPins[7], HIGH); // trial cue indicator to send to the recording system
              ParadigmMode = 4; 
              
              Serial1.print(0x0c, DEC); // clear the display
              Serial1.print(0x94, DEC); // col 0, row 0
              Serial1.print("REWARD");
            }

            break;
    
        case 4: // close valve once the reward has had sufficient time to be delivered
            
            if(CurrAIValue[3]<lThresh && first==0) {
              trialEnd = time;
              first = 1;
            }
            
            if(valveOpenTime<10) {
              valveOpenTime=10;
            }
            
            
            if(time > (crossTime+valveDelayTime+valveOpenTime) ) {
              digitalWrite(SOLENOID1, LOW);  // valve closes                            
              Serial1.print(0x0c, DEC); // clear the display
              Serial1.print(0x94, DEC); // col 0, row 0
              Serial1.print("POST-REWARD");
              ParadigmMode = 5;
            }      

            break;
              
        case 5: // this is the end of trial state

            if(CurrAIValue[3]<lThresh && first==0) {
              trialEnd = time;
              first = 1;
            }

            trialEnd = time;

            // send a notice of trial end
            Serial.flush();
            delay(100);
            Serial.print(5);
            Serial.print(",");
            Serial.print("*");
              
            ParadigmMode = 0;
//            Serial1.print(0x0c, BYTE); // clear the display
//            Serial1.print(0x94, BYTE); // col 0, row 0
            count++;
            break;
    
      }
           
      if (Serial.available() > 0) {

        code = Serial.read();

        switch (code) {
        
          case 89: // stop execution
            ParadigmMode = 0;
            Serial.print(3);
            Serial.print(",");     
            Serial.print("*");
           
            digitalWrite(digitalPins[0], LOW); // success event
            digitalWrite(digitalPins[1], LOW); // trial cue light
//            digitalWrite(digitalPins[2], LOW); // performance cue light
            digitalWrite(digitalPins[3], LOW); // valve
            digitalWrite(digitalPins[4], LOW); // reset the lick indicator
            break;
            
        // all other codes are handshaking codes either requesting data or sending data 
          case 87:
            RunSerialCom(code); 
            break;
    
          case 88:
            RunSerialCom(code); 
            break;

          case 90:
            RunSerialCom(code); 
            break;
    
          case 91:
            RunSerialCom(code);
            break;
    
          case 92:
            RunSerialCom(code);
            break;
            
        }
        
        Serial.flush();
    
      }
    
    
    // pause until 1ms has elapsed without locking up the processor
      while(loopTime<1000 && loopTime>0) {
        loopTime = micros() - (beginLoopTime*1000);
      }
      loopTime = 1;    
      
//    THESE SHOULD JUST BE CONTROLLED BY PROTOCOL
//    digitalWrite(digitalPins[0], LOW); // trial cue light
//    digitalWrite(digitalPins[2], LOW); // performance cue light
//    digitalWrite(digitalPins[3], LOW); // valve 
    digitalWrite(digitalPins[1], LOW); // success event
    digitalWrite(digitalPins[4], LOW); // reset the lick indicator
    digitalWrite(digitalPins[5], LOW); // 
    digitalWrite(digitalPins[6], LOW); // 
    digitalWrite(digitalPins[7], LOW); // 
    digitalWrite(LASER, LOW);
}


