
var udp = require('dgram');
var osc = require('osc-min');
var util = require('util');

// listen for devices via TouchOSC on port 8000
 // listen for SonicPi on port 7000

var i =0;
var deviceList = [];  // array of connect devices



sock = udp.createSocket("udp4", function(msg, deviceInfo) {   //function to connect devices
    var error;
    var ip = deviceInfo.address;
    if (!deviceList[ip]) {                           //if device does not already exist, add as new
        console.log('adding new device: ' + ip);
        deviceList[ip] = {inst: 0, pat: 0, sync: true};
        deviceList.push(ip);                    // update connect devices array list

     //   refresh(ip);
    }
//   try {
        var data = osc.fromBuffer(msg);
        if(data.address == '/2' | data.address == '/1' | data.address == '/3' | data.address == '/4' | data.address == '/5') {} // dont send message to sonic pi about user changing pages
            else
    {
        console.log(ip + ' Device| button address: ' + data.address + ' | Value: ' + data.args[0].value);
        var button = data.address
        var value = parseFloat(data.args[0].value)

        runSPI(button, value); // send to sonic pi
    }
  //  } catch (err) {
   //     return console.log(err.stack.split("\n"));
  //  }

});
var sonicpiTimeout = null;
sonicpiSock = udp.createSocket("udp4",function(msg,deviceInfo) { // function to connect to sonic pi
    var error;

    if(sonicpiTimeout == null){
        console.log('SonicPi is online');
    }
    else console.log(err);
});

sock.bind(8000, function(err) {             //set up on port 8000
    if (err) console.log(err);
    else console.log('Listening for TouchOSC devices on port 8000');
});

sonicpiSock.bind(7000, function(err){   //set up on port 7000
    if(err) console.log(err);
    else console.log('Ready for Sonic Pi on port 7000')
});

function runSPI(button, value) {            // Code to send device data from node.js to Sonic Pi
    var sonicpiIP = "192.168.2.106"                // ip address of sonic pi
    console.log("SENT TO SONICPI " + button + " " + value);
    var msg = { address: button, args: [ { type: 'float', value: value } ], oscType: 'message' }; // package address and float value
    var buf = osc.toBuffer(msg); // convert msg to type buffer
    sock.send(buf, 4559, sonicpiIP);   // send address and float value to sonic pi
    //console.log("device list " + deviceList);
    deviceList.forEach(function(connectedDevice){ //step through array of connected devices
    sock.send(buf, 9000, connectedDevice);   // send address and float value to all other devices to update them
    });
}

/*
function pressButton(ip,button){
    device[ip].button = button;
    if(device[ip].pat == undefined){
        device[ip].pat = 0;
    }
}
*/



