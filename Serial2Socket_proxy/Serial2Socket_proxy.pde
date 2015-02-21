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

import processing.serial.*;
import processing.net.*;
import controlP5.*;

GuiManager guiManager;
SerialManager serialManager;
ServerManager serverManager;

// Setup core applet
void setup(){

  // Create serial manager
  serialManager = new SerialManager(this);
  
  // Create server manager
  serverManager = new ServerManager(this);
  
  // Create gui manager  
  guiManager = new GuiManager(this);
  
}

// Draw method
void draw(){
  guiManager.draw();
  serverManager.checkForClientData();
}

// Catch for serial data
void serialEvent(Serial serialPort){
  serialManager.checkForSerialData(serialPort); 
}

// For catch new clients
void serverEvent(Server someServer, Client someClient) {
  serverManager.manageNewClients(someServer, someClient);
}

// For catch released keys
void keyReleased() {
  guiManager.keyReleased();
}

