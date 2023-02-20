

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// called this way, it uses the default address 0x40
//Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
// you can also call it with a different address you want
//Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver(0x41);
// you can also call it with a different address and I2C interface
//Adafruit_PWMServoDriver pwm1 = Adafruit_PWMServoDriver(0x40, Wire);
Adafruit_PWMServoDriver pwm1 = Adafruit_PWMServoDriver(0x40);
Adafruit_PWMServoDriver pwm2 = Adafruit_PWMServoDriver(0x41);



//PWM1(0x40) contains Box 1 and Box 2
#define REDB1P1   5
#define BLUEB1P1  4
#define UVB1P1    3
#define REDB1P2   1
#define BLUEB1P2  2
#define UVB1P2    0
 
#define REDB2P1   10
#define BLUEB2P1  11
#define UVB2P1    9
#define REDB2P2   7
#define BLUEB2P2  8
#define UVB2P2    6
   
//PWM2(0x41) contains Box 3 and Box 4
#define REDB3P1   1
#define BLUEB3P1  2
#define UVB3P1    0
#define REDB3P2   4
#define BLUEB3P2  5
#define UVB3P2    3
    
#define REDB4P1   7
#define BLUEB4P1  8
#define UVB4P1    6
#define REDB4P2   10
#define BLUEB4P2  11
#define UVB4P2    9

// 
// ** CPU running at 84Mhz
// This is to compensate the 
// propagation delay in ms
//
#define PROPAGATION_DELAY_MS1 0
#define PROPAGATION_DELAY_MS2 3
#define T_OFFSET 100

char recvchars[32];
boolean newdata=false;
int p=0;

unsigned long SecTime=0;
unsigned long SecTimeStart=0;
 
unsigned long TimeOneB1P1S=0;
unsigned long TimeTwoB1P1S=0;
unsigned long TimeOneB1P2S=0;
unsigned long TimeTwoB1P2S=0;

unsigned long TimeOneB2P1S=0;
unsigned long TimeTwoB2P1S=0;
unsigned long TimeOneB2P2S=0;
unsigned long TimeTwoB2P2S=0;

unsigned long TimeOneB3P1S=0;
unsigned long TimeTwoB3P1S=0;
unsigned long TimeOneB3P2S=0;
unsigned long TimeTwoB3P2S=0;

unsigned long TimeOneB4P1S=0;
unsigned long TimeTwoB4P1S=0;
unsigned long TimeOneB4P2S=0;
unsigned long TimeTwoB4P2S=0;

int B1P1=1;
int B1P2=1;
int B2P1=1;
int B2P2=1;
int B3P1=1;
int B3P2=1;
int B4P1=1;
int B4P2=1;

int timetest1=5;

/*
//Minimum value to TimeOneBxPx and TimeTwoBxPx is 5mS. Max frequency is 100Hz
static int parameters[65]={30000,   timetest1,   timetest1,   0,4095,4095,   4095,   0,4095,
                                     timetest1,   timetest1,   0,4095,4095,   4095,   100,4095,
                                     timetest1,   timetest1,   0,4095,4095,   0,   0,0,
                                     timetest1,   timetest1,   0,4095,4095,   0,   0,0,
                                     timetest1,   timetest1,   0,4095,4095,   0,   0,0,
                                     timetest1,   timetest1,   0,4095,4095,   0,   0,0,
                                     timetest1,   timetest1,   0,4095,4095,   0,   0,0,
                                     timetest1,   timetest1,   0,4095,4095,   0,   0,0};
                                     
/* <Sessiontime(0),TimeOneB1P1(1),TimeTwoB1P1(2),intensityTimeONER(3),intensityTimeTWOR(4),intensityTimeONEB(5),intensityTimeTWOB(6),intensityTimeONEU(7),intensityTimeTWOU(8),
 *                 TimeOneB1P2(9),TimeTwoB1P2(10),intensityTimeONER(11),intensityTimeTWOR(12),intensityTimeONEB(13),intensityTimeTWOB(14),intensityTimeONEU(15),intensityTimeTWOU(16),
 *                 TimeOneB2P1(17),TimeTwoB2P1(18),intensityTimeONER(19),intensityTimeTWOR(20),intensityTimeONEB(21),intensityTimeTWOB(22),intensityTimeONEU(23),intensityTimeTWOU(24),
 *                 TimeOneB2P2(25),TimeTwoB2P2(26),intensityTimeONER(27),intensityTimeTWOR(28),intensityTimeONEB(29),intensityTimeTWOB(30),intensityTimeONEU(31),intensityTimeTWOU(32),
 *                 TimeOneB3P1(33),TimeTwoB3P1(34),intensityTimeONER(35),intensityTimeTWOR(36),intensityTimeONEB(37),intensityTimeTWOB(38),intensityTimeONEU(39),intensityTimeTWOU(40),
 *                 TimeOneB3P2(41),TimeTwoB3P2(42),intensityTimeONER(43),intensityTimeTWOR(44),intensityTimeONEB(45),intensityTimeTWOB(46),intensityTimeONEU(47),intensityTimeTWOU(48),
 *                 TimeOneB4P1(49),TimeTwoB4P1(50),intensityTimeONER(51),intensityTimeTWOR(52),intensityTimeONEB(53),intensityTimeTWOB(54),intensityTimeONEU(55),intensityTimeTWOU(56),
 *                 TimeOneB4P2(57),TimeTwoB4P2(58),intensityTimeONER(59),intensityTimeTWOR(60),intensityTimeONEB(61),intensityTimeTWOB(62),intensityTimeONEU(63),intensityTimeTWOU(64)>
 */

static int parameters[65];
 
int F=1;
void setup() {
  Serial.begin(115200);
  //recvdata();

  //parameters[]

  pwm1.begin();
  pwm2.begin();
  /*
   * In theory the internal oscillator (clock) is 25MHz but it really isn't
   * that precise. You can 'calibrate' this by tweaking this number until
   * you get the PWM update frequency you're expecting!
   * The int.osc. for the PCA9685 chip is a range between about 23-27MHz and
   * is used for calculating things like writeMicroseconds()
   * Analog servos run at ~50 Hz updates, It is importaint to use an
   * oscilloscope in setting the int.osc frequency for the I2C PCA9685 chip.
   * 1) Attach the oscilloscope to one of the PWM signal pins and ground on
   *    the I2C PCA9685 chip you are setting the value for.
   * 2) Adjust setOscillatorFrequency() until the PWM update frequency is the
   *    expected value (50Hz for most ESCs)
   * Setting the value here is specific to each individual I2C PCA9685 chip and
   * affects the calculations for the PWM update frequency. 
   * Failure to correctly set the int.osc value will cause unexpected PWM results
   */
  pwm1.setOscillatorFrequency(25000000);
  pwm2.setOscillatorFrequency(25000000);
  pwm1.setPWMFreq(1600);  // This is the maximum PWM frequency (1600)
  pwm2.setPWMFreq(1600);
  // if you want to really speed stuff up, you can go into 'fast 400khz I2C' mode
  // some i2c devices dont like this so much so if you're sharing the bus, watch
  // out for this!
  Wire.setClock(400000);
  ChannelsOFF();
  ChannelsON();
  delay(1000);
  ChannelsOFF();
pinMode(47, OUTPUT);   //RED LED       
pinMode(46, OUTPUT);  //Green LED
digitalWrite(46,LOW); //Green LED
digitalWrite(47,HIGH);  //RED LED       
while(Serial.read() != 'H')
{
Serial.println("A");
}
digitalWrite(47,LOW); // RED LED
digitalWrite(46,HIGH); //Green LED
//ChannelsON();
//delay(2000);
//ChannelsOFF();
  recvdata();
 

  
}

void loop() {
SecTimeStart=millis();
TimeOneB1P1S=millis()+parameters[1]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB1P2S=millis()+parameters[9]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB2P1S=millis()+parameters[17]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB2P2S=millis()+parameters[25]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB3P1S=millis()+parameters[33]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB3P2S=millis()+parameters[41]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB4P1S=millis()+parameters[49]+T_OFFSET-PROPAGATION_DELAY_MS1;
TimeOneB4P2S=millis()+parameters[57]+T_OFFSET-PROPAGATION_DELAY_MS1;



  while(((millis()-SecTimeStart) < parameters[0])&& F==1){
 
   //Box 1 Panel 1 
    if(((TimeOneB1P1S-millis())>T_OFFSET) && B1P1==1){
      pwm1.setPWM(REDB1P1, 4095-parameters[3],parameters[3]);
      pwm1.setPWM(BLUEB1P1, 4095-parameters[5], parameters[5]);
      pwm1.setPWM(UVB1P1, 4095-parameters[7], parameters[7]);  
    }
    else if(((TimeOneB1P1S-millis())<T_OFFSET) && B1P1==1){
      TimeTwoB1P1S=millis()+parameters[2]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B1P1=2;
    }

    if(((TimeTwoB1P1S-millis())>T_OFFSET) && B1P1==2){
      pwm1.setPWM(REDB1P1, 4095-parameters[4],parameters[4]);
      pwm1.setPWM(BLUEB1P1, 4095-parameters[6], parameters[6]);
      pwm1.setPWM(UVB1P1, 4095-parameters[8], parameters[8]);  
    }
    else if(((TimeTwoB1P1S-millis())<T_OFFSET) && B1P1==2){
      TimeOneB1P1S=millis()+parameters[1]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B1P1=1;
    }



   //Box 1 Panel 2
    if(((TimeOneB1P2S-millis())>T_OFFSET) && B1P2==1){
      pwm1.setPWM(REDB1P2, 4095-parameters[11],parameters[11]);
      pwm1.setPWM(BLUEB1P2, 4095-parameters[13], parameters[13]);
      pwm1.setPWM(UVB1P2, 4095-parameters[15], parameters[15]);    
    }
    else if(((TimeOneB1P2S-millis())<T_OFFSET) && B1P2==1){
      TimeTwoB1P2S=millis()+parameters[10]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B1P2=2;
    }

    if(((TimeTwoB1P2S-millis())>T_OFFSET) && B1P2==2){
      pwm1.setPWM(REDB1P2, 4095-parameters[12],parameters[12]);
      pwm1.setPWM(BLUEB1P2, 4095-parameters[14], parameters[14]);
      pwm1.setPWM(UVB1P2, 4095-parameters[16], parameters[16]);
    }
    else if(((TimeTwoB1P2S-millis())<T_OFFSET) && B1P2==2){
      TimeOneB1P2S=millis()+parameters[9]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B1P2=1;
    }

    

   //Box 2 Panel 1
    if(((TimeOneB2P1S-millis())>T_OFFSET) && B2P1==1){
      pwm1.setPWM(REDB2P1, 4095-parameters[19],parameters[19]);
      pwm1.setPWM(BLUEB2P1, 4095-parameters[21], parameters[21]);
      pwm1.setPWM(UVB2P1, 4095-parameters[23], parameters[23]);
    }
    else if(((TimeOneB2P1S-millis())<T_OFFSET) && B2P1==1){
      TimeTwoB2P1S=millis()+parameters[18]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B2P1=2;
    }

    if(((TimeTwoB2P1S-millis())>T_OFFSET) && B2P1==2){
      pwm1.setPWM(REDB2P1, 4095-parameters[20],parameters[20]);
      pwm1.setPWM(BLUEB2P1, 4095-parameters[22], parameters[22]);
      pwm1.setPWM(UVB2P1, 4095-parameters[24], parameters[24]);
     
    }
    else if(((TimeTwoB2P1S-millis())<T_OFFSET) && B2P1==2){
      TimeOneB2P1S=millis()+parameters[17]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B2P1=1;
    }



    //Box 2 Panel 2
    if(((TimeOneB2P2S-millis())>T_OFFSET) && B2P2==1){
      pwm1.setPWM(REDB2P2, 4095-parameters[27],parameters[27]);
      pwm1.setPWM(BLUEB2P2, 4095-parameters[29], parameters[29]);
      pwm1.setPWM(UVB2P2, 4095-parameters[31], parameters[31]);
    }
    else if(((TimeOneB2P2S-millis())<T_OFFSET) && B2P2==1){
      TimeTwoB2P2S=millis()+parameters[26]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B2P2=2;
    }

    if(((TimeTwoB2P2S-millis())>T_OFFSET) && B2P2==2){
      pwm1.setPWM(REDB2P2, 4095-parameters[28],parameters[28]);
      pwm1.setPWM(BLUEB2P2, 4095-parameters[30], parameters[30]);
      pwm1.setPWM(UVB2P2, 4095-parameters[32], parameters[32]);
     
    }
    else if(((TimeTwoB2P2S-millis())<T_OFFSET) && B2P2==2){
      TimeOneB2P2S=millis()+parameters[25]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B2P2=1;
    }




    //Box 3 Panel 1
    if(((TimeOneB3P1S-millis())>T_OFFSET) && B3P1==1){
      pwm2.setPWM(REDB3P1, 4095-parameters[35],parameters[35]);
      pwm2.setPWM(BLUEB3P1, 4095-parameters[37], parameters[37]);
      pwm2.setPWM(UVB3P1, 4095-parameters[39], parameters[39]);
    }
    else if(((TimeOneB3P1S-millis())<T_OFFSET) && B3P1==1){
      TimeTwoB3P1S=millis()+parameters[34]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B3P1=2;
    }

    if(((TimeTwoB3P1S-millis())>T_OFFSET) && B3P1==2){
      pwm2.setPWM(REDB3P1, 4095-parameters[36],parameters[36]);
      pwm2.setPWM(BLUEB3P1, 4095-parameters[38], parameters[38]);
      pwm2.setPWM(UVB3P1, 4095-parameters[40], parameters[40]);
     
    }
    else if(((TimeTwoB3P1S-millis())<T_OFFSET) && B3P1==2){
      TimeOneB3P1S=millis()+parameters[33]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B3P1=1;
    }




    //Box 3 Panel 2
    if(((TimeOneB3P2S-millis())>T_OFFSET) && B3P2==1){
      pwm2.setPWM(REDB3P2, 4095-parameters[43],parameters[43]);
      pwm2.setPWM(BLUEB3P2, 4095-parameters[45], parameters[45]);
      pwm2.setPWM(UVB3P2, 4095-parameters[47], parameters[47]);
    }
    else if(((TimeOneB3P2S-millis())<T_OFFSET) && B3P2==1){
      TimeTwoB3P2S=millis()+parameters[42]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B3P2=2;
    }

    if(((TimeTwoB3P2S-millis())>T_OFFSET) && B3P2==2){
      pwm2.setPWM(REDB3P2, 4095-parameters[44],parameters[44]);
      pwm2.setPWM(BLUEB3P2, 4095-parameters[46], parameters[46]);
      pwm2.setPWM(UVB3P2, 4095-parameters[48], parameters[48]);
     
    }
    else if(((TimeTwoB3P2S-millis())<T_OFFSET) && B3P2==2){
      TimeOneB3P2S=millis()+parameters[41]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B3P2=1;
    }




   //Box 4 Panel 1
    if(((TimeOneB4P1S-millis())>T_OFFSET) && B4P1==1){
      pwm2.setPWM(REDB4P1, 4095-parameters[51],parameters[51]);
      pwm2.setPWM(BLUEB4P1, 4095-parameters[53], parameters[53]);
      pwm2.setPWM(UVB4P1, 4095-parameters[55], parameters[55]);
    }
    else if(((TimeOneB4P1S-millis())<T_OFFSET) && B4P1==1){
      TimeTwoB4P1S=millis()+parameters[50]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B4P1=2;
    }

    if(((TimeTwoB4P1S-millis())>T_OFFSET) && B4P1==2){
      pwm2.setPWM(REDB4P1, 4095-parameters[52],parameters[52]);
      pwm2.setPWM(BLUEB4P1, 4095-parameters[54], parameters[54]);
      pwm2.setPWM(UVB4P1, 4095-parameters[56], parameters[56]);
     
    }
    else if(((TimeTwoB4P1S-millis())<T_OFFSET) && B4P1==2){
      TimeOneB4P1S=millis()+parameters[49]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B4P1=1;
    }




   //Box 4 Panel 2
    if(((TimeOneB4P2S-millis())>T_OFFSET) && B4P2==1){
      pwm2.setPWM(REDB4P2, 4095-parameters[59],parameters[59]);
      pwm2.setPWM(BLUEB4P2, 4095-parameters[61], parameters[61]);
      pwm2.setPWM(UVB4P2, 4095-parameters[63], parameters[63]);
    }
    else if(((TimeOneB4P2S-millis())<T_OFFSET) && B4P2==1){
      TimeTwoB4P2S=millis()+parameters[58]+T_OFFSET-PROPAGATION_DELAY_MS2;
      B4P2=2;
    }

    if(((TimeTwoB4P2S-millis())>T_OFFSET) && B4P2==2){
      pwm2.setPWM(REDB4P2, 4095-parameters[60],parameters[60]);
      pwm2.setPWM(BLUEB4P2, 4095-parameters[62], parameters[62]);
      pwm2.setPWM(UVB4P2, 4095-parameters[64], parameters[64]);
     
    }
    else if(((TimeTwoB4P2S-millis())<T_OFFSET) && B4P2==2){
      TimeOneB4P2S=millis()+parameters[57]+T_OFFSET-PROPAGATION_DELAY_MS1;
      B4P2=1;
    }
    
    
  }
 F=0;
 ChannelsOFF();
}
