
/**
 * Import libraries
 */
import processing.serial.*;
import controlP5.*;
import muthesius.net.*;
import org.webbitserver.*;

/**
 * Event IDs
  */
final static int ID_REFRESH_BUTTON         =  101;  
final static int ID_SERVER_PORT_TEXTFIELD  =  102; 
final static int ID_CONNECT_BUTTON         =  103;
final static int ID_SERIALPORTS_COMBO      =  104;


/**
 * Default values
 */
int DEFAULT_PORT = 8887;
int DEFAULT_SERIAL_SPEED = 57600;

/**
 * Status variables
 */
boolean isSerialConnected;
boolean isServerRunning;
String serialPortName;
int serverPortNumber;

/**
 * Objects
 */
Serial serialPort;
WebSocketP5 websocket;
ControlP5 gui;
DropdownList serialPortsCombo;
Button connectButton;
Button refreshButton;
Button createServerButton;
Textfield socketPortTextfield;
Textarea logTextarea;


/**
 * Setup
 */
void setup() {
  
  frame.setTitle("Serial2Websocket_proxy 0.1");
 
  serialPortName = null;
  isSerialConnected = false;
  isServerRunning = false;
  serverPortNumber = DEFAULT_PORT;
  
  // GUI instance
  gui = new ControlP5(this);
  
  // Create GUI interface  
  size(320, 250);

  Textlabel socketPortTextfieldLabel = gui.addTextlabel("socketPortTextfieldLabel", "Socket", 15, 20);
  socketPortTextfieldLabel.setColorValue(0x444444);

  Textlabel serialListLabel = gui.addTextlabel("serialListLabel", "Serial port", 60, 20);
  serialListLabel.setColorValue(0x444444);

  // Textfield for socket port number
  socketPortTextfield = gui.addTextfield("Socket Port", 10, 30, 40, 19);
  socketPortTextfield.setId(ID_SERVER_PORT_TEXTFIELD);
  socketPortTextfield.setText(str(DEFAULT_PORT));
  socketPortTextfield.setAutoClear(false);
  socketPortTextfield.captionLabel().setVisible(false);
  //socketPortTextfield.valueLabel().setWithCursorPosition(socketPortTextfield.getText(), 0);

  // Button for refresh serial ports list     
  refreshButton = gui.addButton("Refresh list", ID_REFRESH_BUTTON, 235, 30, 75, 20);
  refreshButton.setId(ID_REFRESH_BUTTON); 
  refreshButton.captionLabel().style().paddingLeft = 6;

  // Button for refresh serial ports list     
  createServerButton = gui.addButton("createServerButton", ID_CONNECT_BUTTON, 10, 60, 300, 20);
  createServerButton.setId(ID_CONNECT_BUTTON); 
  createServerButton.setLabel("connect");
  createServerButton.captionLabel().style().paddingLeft = 120;

  // Logging area
  logTextarea = gui.addTextarea("logTextarea", "", 10, 90, 290, 150);                                      
  logTextarea.setColorBackground(color(0));
  logTextarea.showScrollbar();
  logTextarea.scroll(1);

  // Combos from here to fix z-index
  serialPortsCombo = gui.addDropdownList("serialPortList", 55, 51, 170, 250);
  serialPortsCombo.setId(ID_SERIALPORTS_COMBO);
  serialPortsCombo.setLabel("Select");
  serialPortsCombo.setBarHeight(20);
  serialPortsCombo.captionLabel().style().paddingTop = 5;
  serialPortsCombo.captionLabel().style().paddingLeft = 5;
  serialPortsCombo.setItemHeight(20);    
  serialPortsCombo.setColorBackground(color(60));
  serialPortsCombo.setColorActive(color(255, 128));
  
  // Update the serial port list
  updateSerialPortsCombo();
}

/**
 * Redraw 
 */
void draw() {
  background(0xcecece);
  fill(0);
  rect(10, 90, 300, 150);
  gui.draw();
}

/**
 * On stop applet
 */
void stop() {
  websocket.stop();
  serialPort.clear();
  serialPort.stop();
}

/**
 * Catch for serial data
 */
void serialEvent(Serial serialPort) {
  if (isSerialConnected) {
    while (serialPort.available () > 0) {
      int whatSerialSaid = serialPort.read();
      websocket.sendAll(Integer.toString(whatSerialSaid));
    }
  }
}

/**
 * Catch released keys
 */
void keyReleased() {
  if (socketPortTextfield.isFocus()) {
    socketPortTextfield.setText(removeNotNumbersAndCheckMaxlength(socketPortTextfield.getText(), 5));
    //socketPortTextfield.valueLabel().setWithCursorPosition(socketPortTextfield.getText(), 0);
  }
}

/**
 * When is a new websocket connection
 */
void websocketOnOpen(WebSocketConnection con) {
  logActivity("A client joined of "+websocket.howManyConnections());
}

/**
 * When a websocket connection closes
 */
void websocketOnClosed(WebSocketConnection con) {
  logActivity("A client left");
}

/**
 * Catch for websocket messages
 */
void websocketOnMessage(WebSocketConnection con, String message) {
  
  if (message.indexOf(',') > -1) {
    String data[] = message.split(",");
    for (int i=0; i<data.length; i++) {
      serialSend(Integer.parseInt(data[i]));
    }
  } 
  else {
    serialSend(Integer.parseInt(message));
  }
}

/**
 * Create server
 */
void createServer(int _serverPortNumber, String _serialPortName) {
  
  removeServer();
  
  // Create serial connection
  try {
    serialPortName = _serialPortName;
    serialPort = new Serial(this, serialPortName, DEFAULT_SERIAL_SPEED);
    logActivity("Connected to serial port "+serialPortName);
    isSerialConnected = true;
  }
  catch(Exception e) {
    logActivity(">> ERROR: Connecting to "+serialPortName);
    logActivity(">> "+e.getMessage());
    e.printStackTrace();
    serialPortName = null;
    serialPort = null;
  }
  
  // create a new server instance
  websocket = new WebSocketP5(this, serverPortNumber, "websocket");
  isServerRunning = true;
  logActivity("Running server at: "+websocket.getUri());
  
  logActivity("");
}

/** 
 * Remove server
 */
void removeServer(){
  
  // Remove connection if previously connected
  if (serialPort != null) {
    isSerialConnected = false;
    logActivity("Removing connection to "+serialPortName);
    logActivity("");
    serialPort.clear();
    serialPort.stop();
    serialPort = null;
    serialPortName = null;
  }
  
  // Remove any previous server
  if (websocket!=null) {
    websocket.stop();
    websocket = null;
    isServerRunning = false;
    logActivity("Removing server");
    logActivity("");
  }
  
}

/**
 * Send a char to serial port
 */
public int serialSend(int data) {
  if (isSerialConnected) {
    serialPort.write((byte)data);
    return 0;
  } 
  else {
    return -1;
  }
}


/**
 * Update the serial port list combo with the current serial ports list
 */
void updateSerialPortsCombo() {
  String[] serialPortsList =  Serial.list(); 
  serialPortsCombo.clear();     
  for (int i=0; i< serialPortsList.length; i++) {
    if (!serialPortsList[i].startsWith("/dev/tty.") ) {
      serialPortsCombo.addItem(serialPortsList[i], i+1);
    }
  }
}

/**
 * Log activity
 */
public void logActivity(String inText) {
  this.logTextarea.setText(logTextarea.text()+inText+"\n");
  println(inText);
}

/**
 * Clean not numbers and limit the number of chars
 */
String removeNotNumbersAndCheckMaxlength(String strToClean, int maxlength) {
  String cleanedStr = "";
  for (int i=0;i<strToClean.length()&&i<maxlength;i++) {
    if ('0' <= strToClean.charAt(i) && strToClean.charAt(i) <= '9') {
      cleanedStr = cleanedStr+strToClean.charAt(i);
    }
  }
  return cleanedStr;
}

/**
 * GUI event listener
 */
public void controlEvent(ControlEvent event) {

  int idControl;

  if (event.isGroup()) idControl = event.group().id();
  else idControl = event.controller().id();

  switch(idControl) {

    case ID_REFRESH_BUTTON : 
      updateSerialPortsCombo();
      logActivity("Serial port list is updated");
      break; 
  
    case ID_CONNECT_BUTTON :
  
      if (serialPortsCombo.value()==0) { 
        logActivity("> Please, select a serial port"); 
        break;
      }
      
      int socketPort = int(socketPortTextfield.getText());
      if (!(socketPort>=2 && socketPort<=65535)) { 
        logActivity("> Please, set a server port number between 2 and 65535"); 
        break;
      }
      
      if(isServerRunning) {
        removeServer();
        createServerButton.setLabel("connect");
      } else {
        String[] serialPortsList = Serial.list();
        String portName = serialPortsList[parseInt(serialPortsCombo.getValue()-1)];
        createServer(socketPort, portName);
        createServerButton.setLabel("disconnect");
      }
      
      break;
 
    default: break;
  }
}


