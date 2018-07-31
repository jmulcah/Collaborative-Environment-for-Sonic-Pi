Creating a Collaborative Environment for Live Music Composition Using Sonic Pi

server.js
Is a node.js server which handles OSC packets from mobile devices to Sonic Pi and Sonic Pi OSC
packets to all mobile devices. It also makes sure all mobile devices stay in sync with each other. 
It uses UDP to send and receive packets.

Mobile Layout.OSC
Is the mobile layout uses on the application TouchOSC

final sonic pi code.rb
Is the Sonic Pi code which takes all the incoming packets and processes them into sound.

The report accompanying this code goes into great details of the state of collaboration within Live Coding
as well as the theory behind decisions made within this project and future work that can be done.
