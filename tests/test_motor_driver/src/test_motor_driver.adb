--
--  Demonstration program for the Sparfun Qwicc Motor Driver library.
--  Target is a RP Pico.
--

with RP.Device;
with RP.Clock;
with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with HAL; use HAL;
with HAL.I2C;
with Pico;
with Sparkfun_Qwiic_Motor_Driver;

procedure Test_Motor_Driver is

   Addr_HAL : constant HAL.I2C.I2C_Address := 2 * 16#5D#;
   Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   Success : Boolean := False;
   Drv_Ready : Boolean := False;
   Drv_Busy : Boolean := True;

   package Driver is new Sparkfun_Qwiic_Motor_Driver
      (Port     => Port'Access,
       I2C_Addr => Addr_HAL);

   SDA    : GPIO_Point := Pico.GP8;
   SCL    : GPIO_Point := Pico.GP9;

   Drv_Id : UInt8 := 0;

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Device.Timer.Enable;
   RP.Clock.Enable (RP.Clock.PERI);

   --  Configure I2C interface.
   Port.Configure
      (Baudrate     => 400_000,
       Address_Size => RP.I2C_Master.Address_Size_7b);

   SDA.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up,
                  RP.GPIO.I2C, Schmitt => True);
   SCL.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up,
                  RP.GPIO.I2C, Schmitt => True);

   --  Configure on-board LED.
   Pico.LED.Configure (RP.GPIO.Output);
   Pico.LED.Set;

   --  Wait for the correct Id of the motor driver.
   while not (Success and then Drv_Id = 16#A9#) loop
      Driver.Initialize (Drv_Id, Success);
   end loop;

   --  Wait until driver is ready for commands.
   while not (Success and then Drv_Ready) loop
      Driver.Is_Ready (Drv_Ready, Success);
   end loop;

   --  Wait until driver is not busy.
   while not Success or else Drv_Busy loop
      Driver.Is_Busy (Drv_Busy, Success);
   end loop;

   --  Enable the driver.
   Driver.Set_Drive (0, 0, Success);
   Driver.Set_Drive (1, 0, Success);
   Driver.Set_Enable (True, Success);
   if not Success then
      loop
         Pico.LED.Set;
         RP.Device.Timer.Delay_Milliseconds (300);
      end loop;
   end if;

   --  Test loop.
   loop
      Pico.LED.Toggle;
      Driver.Set_Drive (0, 60, Success);
      exit when not Success;
      RP.Device.Timer.Delay_Milliseconds (100);
   end loop;

   --  In case of an error, stop blinking the LED.
   loop
      Pico.LED.Set;
      RP.Device.Timer.Delay_Milliseconds (300);
   end loop;

end Test_Motor_Driver;
