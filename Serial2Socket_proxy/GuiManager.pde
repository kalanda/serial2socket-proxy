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
 
 class GuiManager implements ControlListener {
 
 //The event refs
 final static int ID_SERIALPORTS_COMBO      =  101;
 final static int ID_REFRESH_BUTTON         =  102;  
 final static int ID_SERVER_PORT_TEXTFIELD  =  103; 
 final static int ID_CREATE_SERVER_BUTTON   =  104;
 final static int ID_SERIALSPEEDS_COMBO     =  105;
 final static int ID_CREDITS_BUTTON         =  106;
  
 // Parent PApplet
 private PApplet parent;
 
 // Interface object
 private ControlP5 gui;
 
 // Interface controls
 private DropdownList serialPortsCombo;
 private DropdownList serialSpeedsCombo;
 private Button connectButton;
 private Button refreshButton;
 private Button createServerButton;
 private Button creditsButton;
 private Textfield socketPortTextfield;
 private Textarea logTextarea;
 
 // Configuration variables
 private boolean serialPortMonitoring = true;
 
 // Constructor
 public GuiManager(PApplet coreApplet) {
     parent = coreApplet;
     gui = new ControlP5(parent);
     gui.addListener(this);
     createInterface();
     updateSerialPortsCombo();
 } 
 
 // Called in every draw() of the PApplet
 public void draw(){
   background(0xcecece);
   fill(0);
   rect(10, 90, 350, 210);
   gui.draw();
 }
 
 // Create controls
 public void createInterface(){
   
   size(370, 330);
   
   Textlabel infoLabel = gui.addTextlabel("infoLabel","Developed by Kalanda (2011) - This opensource is under GNU GPL v3 License", 10, 310);
   infoLabel.setColorValue(0x444444);
    
   Textlabel socketPortTextfieldLabel = gui.addTextlabel("socketPortTextfieldLabel","Socket", 15, 20);
   socketPortTextfieldLabel.setColorValue(0x444444);
   
   Textlabel serialListLabel = gui.addTextlabel("serialListLabel","Serial port", 60, 20);
   serialListLabel.setColorValue(0x444444);
   
   Textlabel speedLabel = gui.addTextlabel("speedLabel","Speed", 235, 20);
   speedLabel.setColorValue(0x444444);
   
   // Textfield for socket port number
   socketPortTextfield = gui.addTextfield("Socket Port", 10, 30, 40, 20);
   socketPortTextfield.setId(ID_SERVER_PORT_TEXTFIELD);
   socketPortTextfield.setText(str(serverManager.DEFAULT_PORT));
   socketPortTextfield.setAutoClear(false);
   socketPortTextfield.captionLabel().setVisible(false);
   
   // Button for refresh serial ports list     
   refreshButton = gui.addButton("Refresh list",ID_REFRESH_BUTTON , 285, 30, 75, 20);
   refreshButton.setId(ID_REFRESH_BUTTON); 
   refreshButton.captionLabel().style().paddingLeft = 6;

   // Button for refresh serial ports list     
   createServerButton = gui.addButton("createServerButton",ID_CREATE_SERVER_BUTTON , 10, 60, 290, 20);
   createServerButton.setId(ID_CREATE_SERVER_BUTTON); 
   createServerButton.setLabel("> Create Serial2Socket proxy <");
   createServerButton.captionLabel().style().paddingLeft = 80;
   
   // Button for refresh serial ports list     
   creditsButton = gui.addButton("Credits",ID_CREDITS_BUTTON , 310, 60, 50, 20);
   creditsButton.setId(ID_CREDITS_BUTTON); 
   creditsButton.captionLabel().style().paddingLeft = 6;
   
   // Logging area
   logTextarea = gui.addTextarea("logTextarea", "", 10, 90, 340, 210);                                      
   logTextarea.setColorBackground(color(0));
   logTextarea.showScrollbar();
   logTextarea.scroll(1);
   
   /*
     Combos from here to avoid z-index
   */
   
   // Combo of serial ports list  
   serialPortsCombo = gui.addDropdownList("seriallist", 55, 51, 170, 250);
   serialPortsCombo.setId(ID_SERIALPORTS_COMBO);
   serialPortsCombo.setLabel("Select");
   serialPortsCombo.setBarHeight(20);
   serialPortsCombo.captionLabel().style().paddingTop = 5;
   serialPortsCombo.captionLabel().style().paddingLeft = 5;
   serialPortsCombo.setItemHeight(20);    
   serialPortsCombo.setColorBackground(color(60));
   serialPortsCombo.setColorActive(color(255,128));  
   
   // Combo of serial ports speeds  
   serialSpeedsCombo = gui.addDropdownList("speedlist", 230, 51, 50, 250);
   serialSpeedsCombo.setId(ID_SERIALSPEEDS_COMBO);
   serialSpeedsCombo.setLabel("Select");
   serialSpeedsCombo.setBarHeight(20);
   serialSpeedsCombo.captionLabel().style().paddingTop = 5;
   serialSpeedsCombo.captionLabel().style().paddingLeft = 5;
   serialSpeedsCombo.setItemHeight(20);    
   serialSpeedsCombo.setColorBackground(color(60));
   serialSpeedsCombo.setColorActive(color(255,128));
   String[] serialSpeedsList = serialManager.getSerialSpeedsList();
   for(int i=0;i<serialSpeedsList.length;i++){
       serialSpeedsCombo.addItem(serialSpeedsList[i],i+1);
   }
 }

 // Update the combo with the current serial ports list
 void updateSerialPortsCombo(){
     String[] serialPortsList = serialManager.getSerialPortsList();
     serialPortsCombo.clear();     
     for (int i=0; i< serialPortsList.length; i++){
         serialPortsCombo.addItem(serialPortsList[i],i+1);
      }
 }
 
 // Log activity
 public void logActivity(String inText){
   this.logTextarea.setText(logTextarea.text()+inText+"\n");
   println(inText);
 }
 
 // Catch keys
 void keyReleased() {
   
   if(socketPortTextfield.isFocus()) {
        socketPortTextfield.setText(removeNotNumbersAndCheckMaxlength(socketPortTextfield.getText(),5));
   }
 }
 
 // For clean not number and limit the number of chars
 String removeNotNumbersAndCheckMaxlength(String strToClean, int maxlength){
   String cleanedStr = "";
   for (int i=0;i<strToClean.length()&&i<maxlength;i++){
     if ('0' <= strToClean.charAt(i) && strToClean.charAt(i) <= '9'){
       cleanedStr = cleanedStr+strToClean.charAt(i);
     }
   }
   return cleanedStr;
 }
 
 // Interface listener
 public void controlEvent(ControlEvent event) {

    int idControl;

    if (event.isGroup()) {
      idControl = event.group().id();
    } 
    else {
      idControl = event.controller().id();
    }
    
    switch(idControl){
           
      case ID_REFRESH_BUTTON : 
           updateSerialPortsCombo();
           logActivity("Serial port list is updated");
           break; 
      
      case ID_CREATE_SERVER_BUTTON :
           
           if(serialPortsCombo.value()==0) { logActivity("> Please, select a serial port"); break; }
           if(serialSpeedsCombo.value()==0) { logActivity("> Please, select a serial speed"); break; }
           int socketPort = int(socketPortTextfield.getText());
           if(!(socketPort>=2 && socketPort<=65535)) { logActivity("> Please, set a server port number between 2 and 65535"); break; }
           serverManager.createServer(socketPort); 
           
           String[] serialPortsList = serialManager.getSerialPortsList();
           String[] serialSpeedsList = serialManager.getSerialSpeedsList();
           
           String portName = serialPortsList[parseInt(serialPortsCombo.getValue()-1)];
           String portSpeed = serialSpeedsList[parseInt(serialSpeedsCombo.getValue()-1)];
          
           serialManager.connectToSerialPort(portName,portSpeed);
           break;
           
      case ID_CREDITS_BUTTON :
           link("https://github.com/kalanda/serial2socket-proxy");
         
      default:
           //println(idControl);
    }
 }
 
}
