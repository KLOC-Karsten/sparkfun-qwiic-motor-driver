--
--  Demonstration program for the Grove I2C Motor Driver library.
--  Target is a RP Pico.
--

with RP.Device;
with RP.Clock;
with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with HAL; use HAL;
with HAL.I2C;
with Pico;
with Grove_I2C_Motor_Driver;

procedure Test_Motor_Driver is

   Addr_HAL : constant HAL.I2C.I2C_Address := 2 * 16#0F#;

   Port    : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   Success : Boolean;

   package Driver is new Grove_I2C_Motor_Driver
      (Port => Port'Access);

   SDA    : GPIO_Point := Pico.GP8;
   SCL    : GPIO_Point := Pico.GP9;

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

   loop
      Pico.LED.Toggle;
      Driver.Initialize (Addr_HAL, Success);
      RP.Device.Timer.Delay_Milliseconds (300);
      --  Driver.Direction (Addr_HAL, Driver.CCW, Driver.CW, Success);
      --  RP.Device.Timer.Delay_Milliseconds (100);
      --  Driver.Speed (Addr_HAL, 50, 25, Success);
      --  RP.Device.Timer.Delay_Milliseconds (100);

      --  RP.Device.Timer.Delay_Milliseconds (1000);

      --  Driver.Direction (Addr_HAL, Driver.CW, Driver.CCW, Success);
      --  RP.Device.Timer.Delay_Milliseconds (100);
      --  Driver.Speed (Addr_HAL, 25, 50, Success);
      --  RP.Device.Timer.Delay_Milliseconds (100);

      --  RP.Device.Timer.Delay_Milliseconds (1000);
   end loop;
end Test_Motor_Driver;
