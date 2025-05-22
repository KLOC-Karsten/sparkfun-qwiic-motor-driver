# sparkfun-qwiic-motor-driver
Ada interface to the SparkFun motor driver.

## Description

This is an simple Ada interface for the SparkFun Qwiic motor driver, which can
be found [here](https://www.sparkfun.com/sparkfun-qwiic-motor-driver.html).
The Ada implementation is based on the C++ implementation by SparkFun,
which can be found [here](https://github.com/sparkfun/SparkFun_Serial_Controlled_Motor_Driver_Arduino_Library).

Communication with the driver is via I2C, so this library should be usable
for every controller for which a BSP is available which implements the
Hardware Abstraction Layer (HAL). More information can be
found [here](https://alire.ada.dev/crates/hal.html).  

The build system used here is [Alire](https://alire.ada.dev/).
The "tests" folder contains two simple application with the driver, both
written for Raspberry Pi Pico controller.

## Using the interface

### Instancing the driver package
To create an instance of the driver package, the I2C address of the
driver is needed (usually 5d) and an I2C port needs to be provided.  

```
with Sparkfun_Qwiic_Motor_Driver;

Addr_HAL : constant HAL.I2C.I2C_Address := 2 * 16#5D#;
Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;

package Driver is new Sparkfun_Qwiic_Motor_Driver
   (Port     => Port'Access,
    I2C_Addr => Addr_HAL);
```

### Initialization
Initialization is a little bit long: first the Initialize procedure
needs to be called, and the returned ID should be checked (it needs to be 0xA9):
```
while not (Success and then Drv_Id = 16#A9#) loop
   Driver.Initialize (Drv_Id, Success);
end loop;
```

after that, make sure that the driver is ready and not busy:
```
--  Wait until driver is ready for commands.
while not (Success and then Drv_Ready) loop
   Driver.Is_Ready (Drv_Ready, Success);
end loop;

--  Wait until driver is not busy.
while not Success or else Drv_Busy loop
   Driver.Is_Busy (Drv_Busy, Success);
end loop;
```

You can set for each of the motors an inversion mode, which
basically means that the direction is inverted,
which can be very handy to compensate the mounting of the motors.
The following code enable the inversion mode for motor 0.
```
Driver.Set_Inversion_Mode (0, True, Success);
```


As a last step, enable the driver so that can power the motors:
```
Driver.Set_Enable (True, Success);
```

### Motor control

Motor control is done with one command. You select the motor and the
speed. Negative values for the speed make the motor to driver  
backwards. Speed range is from -127 to +127. The following code
sets for motor 1 (roughly) half speed backwards.

```
Driver.Set_Drive (1, -60, Success);
```

## Mini robot example

The mini robot example uses the motor driver package and the
ultrasonic ranger package for the Grove ultrasonic ranger.

This example uses a simple state machine to control the robot.
It drives forwards until it detects some objects and then it
stops, drives backwards, makes a turn and then it tries again.

```
--  State Machine
loop
   case State is
      when Forwards =>
         --  Check the distance
         Wait_Some_Time;
         Ranger.Measure (Distance, Success);
         if Success and then Distance < Limit then
            State := Stop;
         end if;
   ....
   end case;
end loop;
```
