# MOVER

! Under development !

Uploading files related to running the variable amplitude operant tasks described in http://www.cell.com/abstract/S0092-8674(15)01027-2

Implementation is divided into high level code that implements interfaces for the users and has a number of dependencies, most crucially Processing; can be downloaded and installed for free here: https://processing.org/download/

Low level code (generally indicated with a LL suffix) runs on custom behavior control system 'BCS' hardware developed in DudLab (details cab be found here http://dudmanlab.org/html/resources.html). This hardware is developed around Arduino (https://www.arduino.cc) or Teensy (https://www.pjrc.com/teensy/) based micropprocessors.

Human version of the code uses just a mouse input for control and thus runs only in Processing. Interaction with a bluetooth controller is possible. We have used the SteelSeries Nimbus controller and the Joystick Mapper (https://joystickmapper.com) program with success on a MacPro.
