/*  
 *  ------ WIFI Example -------- 
 *  
 *  Explanation: This example shows how to get time settings from internet
 *  and set up time and date into Waspmote's RTC 
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 *  
 *  Version:           3.0
 *  Design:            David Gascon 
 *  Implementation:    Yuri Carmona
 */

// Put your libraries here (#include ...)
#include <WaspWIFI_PRO.h>


// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////
char ESSID[] = "SmartAgro";
char PASSW[] = "SA123456";


// choose NTP server settings
///////////////////////////////////////
char SERVERS[][25] = 
{
  "time.nist.gov",
  "wwv.nist.gov"
};
char server[25], serbuf[64];
///////////////////////////////////////

// Define Time Zone from -12 to 12 (i.e. GMT+2)
///////////////////////////////////////
uint8_t time_zone = 3;///for ROMANIA
///////////////////////////////////////


uint8_t error, errorSetTimeServer, errorEnableTimeSync, errorSetGMT, errorsetTimefromWiFi, errorsetSSID, errorsetpass, errorsoftreset, errorresetdef;
uint8_t statusWiFiconn, statusSetTimeServer, statusTimeSync, statusSetGMT, statussetTimefromWiFi;
unsigned long previous;


void setup() 
{
int NServers=sizeof(SERVERS)/sizeof(SERVERS[0]);  
sprintf (serbuf, "The number of available servers in the list is %d \r\n", NServers);
USB.println(serbuf);
start_prog();
do
{
switchon_WiFi();
WiFi_resetdefault();
setSSID_pass_reset();
statusWiFiconn=check_WiFi_conn();
  // Check if module is connected
  if (statusWiFiconn == true)
  {for (int cnt = 0; cnt < NServers; cnt++)
    statusSetTimeServer = RTC_setTimeServer(SERVERS[cnt]);
    if (statusSetTimeServer == true)
     { statusTimeSync=RTC_EnableTimeSync();
      if (statusTimeSync == true)
        {RTC_setGMT();
        goto SWITCHOFF;
        }
     }
   }
 SWITCHOFF:
  switchoff_WiFi();  
} while (statusSetTimeServer == false);
  delay(5000);
  RTC_init();
}



void loop()
{ 

  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////  
  switchon_WiFi();
//////////////////////////////////////////////////
  // 2. Check if connected
  //////////////////////////////////////////////////  
  statusWiFiconn=check_WiFi_conn();
  // Check if module is connected
  if (statusWiFiconn == true)
  {   
    RTC_setTimefromWiFi(); ////setTime
  }
  //////////////////////////////////////////////////
  // 4. Switch OFF WiFi
  switchoff_WiFi;
  delay(10000);
}


////////////////////FUNCTII///////////////////////////
/////////////////////////////FUNCTII WIFI///////////////////////////
void switchon_WiFi()
{  // 1. Switch ON
  //////////////////////////////////////////////////  
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }
}

boolean check_WiFi_conn()
{ // 2. Check if connected
  //////////////////////////////////////////////////  

  // get actual time
  previous = millis();

  // check connectivity
  statusWiFiconn =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (statusWiFiconn == true)
  {    
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous); 
  }
  return statusWiFiconn;
}

void switchoff_WiFi()
{USB.println(F("4. WiFi switched OFF\n")); 
  WIFI_PRO.OFF(socket);


  USB.println(F("-----------------------------------------------------------")); 
  USB.println(F("Once the module has the correct Time Server Settings"));
  USB.println(F("it is always possible to request for the Time and"));
  USB.println(F("synchronize it to the Waspmote's RTC")); 
  USB.println(F("-----------------------------------------------------------\n")); 
  }

  void WiFi_resetdefault()
{
errorresetdef = WIFI_PRO.resetValues();

  if (errorresetdef == 0)
  {    
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.println(F("2. WiFi reset to default ERROR"));
  }
}

void setSSID_pass_reset()
{// 3. Set ESSID
  //////////////////////////////////////////////////
  errorsetSSID = WIFI_PRO.setESSID(ESSID);

  if (errorsetSSID == 0)
  {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }


  //////////////////////////////////////////////////
  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  //////////////////////////////////////////////////
  errorsetpass = WIFI_PRO.setPassword(WPA2, PASSW);

  if (errorsetpass == 0)
  {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }


  //////////////////////////////////////////////////
  // 5. Software Reset 
  // Parameters take effect following either a 
  // hardware or software reset
  //////////////////////////////////////////////////
  errorsoftreset = WIFI_PRO.softReset();

  if (errorsoftreset == 0)
  {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else
  {
    USB.println(F("5. WiFi softReset ERROR"));
  }


  USB.println(F("*******************************************"));
  USB.println(F("Once the module is configured with ESSID"));
  USB.println(F("and PASSWORD, the module will attempt to "));
  USB.println(F("join the specified Access Point on power up"));
  USB.println(F("*******************************************\n"));

}


/////////////////////////////ALTE FUNCTII DE START///////////////////////////
void start_prog()
{USB.ON();
  USB.println(F("Start program"));  
  USB.println(F("***************************************"));  
  USB.println(F("Once the module is set with one or more"));
  USB.println(F("AP settings, it attempts to join the AP"));
  USB.println(F("automatically once it is powered on"));    
  USB.println(F("Refer to example 'WIFI_PRO_01' to configure"));  
  USB.println(F("the WiFi module with proper settings"));
  USB.println(F("***************************************")); }
/////////////////////////////FUNCTII RTC///////////////////////////
 boolean RTC_setTimeServer(char *server)
 {// 3.1. Set NTP Server (option1)
    errorSetTimeServer = WIFI_PRO.setTimeServer(1, server);

    // check response
    if (errorSetTimeServer == 0)
    { sprintf (serbuf, "3.1. Time Server %s set OK \r\n", server);
      USB.println(serbuf);   
      statusSetTimeServer = true;
    }
    else
    {
      USB.println(F("3.1. Error calling 'setTimeServer' function"));
      WIFI_PRO.printErrorCode();
      statusSetTimeServer = false;   
    }
    return statusSetTimeServer;
    }

boolean RTC_EnableTimeSync()
{     errorEnableTimeSync = WIFI_PRO.timeActivationFlag(true);

      // check response
      if( errorEnableTimeSync == 0 )
      {
        USB.println(F("3.3. Network Time-of-Day Activation Flag set OK"));   
        statusTimeSync = true;
      }
      else
      {
        USB.println(F("3.3. Error calling 'timeActivationFlag' function"));
        WIFI_PRO.printErrorCode();  
        statusTimeSync = false;        
      }
      return statusTimeSync;
      }

void RTC_setGMT()
{errorSetGMT = WIFI_PRO.setGMT(time_zone);

      // check response
      if (errorSetGMT == 0)
      {
        USB.print(F("3.4. GMT set OK to "));   
        USB.println(time_zone, DEC);
      }
      else
      {
        USB.println(F("3.4. Error calling 'setGMT' function"));
        WIFI_PRO.printErrorCode();       
      }
  }

void RTC_init()
{ // Init RTC
  RTC.ON();
  USB.print(F("Current RTC settings:"));
  USB.println(RTC.getTime());
  }


void RTC_setTimefromWiFi()
{// 3.1. Open FTP session
    errorsetTimefromWiFi = WIFI_PRO.setTimeFromWIFI();

    // check response
    if (errorsetTimefromWiFi == 0)
    {
      USB.print(F("3. Set RTC time OK. Time:"));
      USB.println(RTC.getTime());
      statussetTimefromWiFi = true;
    }
    else
    {
      USB.println(F("3. Error calling 'setTimeFromWIFI' function"));
      WIFI_PRO.printErrorCode();
      statussetTimefromWiFi = false;   
    }
  }

