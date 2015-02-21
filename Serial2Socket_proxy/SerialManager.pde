/**
 *
 * - serial2socket-proxy
 * - https://github.com/kalanda/serial2socket-proxy
 *
 * This file is part of serial2socket proxy.
 *
 * serial2socket-proxy is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * serial2socket-proxy is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with serial2socket-proxy.  If not, see <http://www.gnu.org/licenses/>.
 */
 
 public class SerialManager {

  // Parent PApplet   
  private PApplet parent;
  
  // Object for the serial port connection
  private Serial serialPort;
  private String serialPortName;
  private String[] serialSpeedsList = { "115200","57600","38400","28800","19200","14400","9600","4800","2400","1200","300"};
  private boolean isConnected;
  
  // Constructor
  public SerialManager(PApplet parent) {
    this.parent = parent;
    serialPortName = null;
    isConnected = false;
    start();
  }
  
  // Return the serial ports list
  public String[] getSerialPortsList(){
    return Serial.list(); 
  }
  
  public String[] getSerialSpeedsList(){
    return  serialSpeedsList;
  }
  
  // Send a string to serial port
  public int send(String data){
    if (isConnected){
      serialPort.write(data);
      return 0;
    } else {
      return -1;
    }
  }
  
  // Connects to serial port
  public void connectToSerialPort(String strPort, String strSpeed){

    // Remove connection if previously connected
    if (serialPort != null){
      isConnected = false;
      guiManager.logActivity("Removing connection to "+serialPortName);
      serialPort.clear();
      serialPort.stop();
      serialPort = null;
      serialPortName = null;
    } 

    // Create connection
    try{
      serialPortName = strPort;
      serialPort = new Serial(parent, serialPortName, int(strSpeed));
      guiManager.logActivity("Connected to serial port "+serialPortName);
      isConnected = true;
    }
    catch(Exception e) {
      guiManager.logActivity(">> ERROR: Connecting to "+serialPortName);
      guiManager.logActivity(">> "+e.getMessage());
      e.printStackTrace();
      serialPortName = null;
      serialPort = null;
    } 
  }
  
  public void checkForSerialData(Serial thePort){
  
    if(isConnected && thePort==serialPort){
          while (serialPort.available() > 0) {
            String whatSerialSaid = serialPort.readString();
            serverManager.send(whatSerialSaid);
          }
    }
  } 
} 
