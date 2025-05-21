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
with Pico_Ultrasonic_Ranger;

procedure Mini_Robot is

   --  Configuration of I2C and the motor driver.
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

   --  Ultrasonic Ranger.
   package Ranger is new Pico_Ultrasonic_Ranger (GPIO => Pico.GP16'Access);
   Distance : Natural := 0;
   Limit : constant Natural := 300;

   --  State Machine
   type Robot_State_Type is (Stop, Forwards, Turn, Backwards, Halt);
   State : Robot_State_Type := Forwards;

   procedure Stop_Motors is
   begin
      Driver.Set_Drive (0, 0, Success);
      Driver.Set_Drive (1, 0, Success);
   end Stop_Motors;

   procedure Drive_Forwards is
   begin
      Driver.Set_Drive (0, 60, Success);
      Driver.Set_Drive (1, 60, Success);
   end Drive_Forwards;

   procedure Drive_Backwards is
   begin
      Driver.Set_Drive (0, -60, Success);
      Driver.Set_Drive (1, -60, Success);
   end Drive_Backwards;

   procedure Turn_Robot is
   begin
      Driver.Set_Drive (0, -45, Success);
      Driver.Set_Drive (1, 0, Success);
   end Turn_Robot;

   procedure Wait_Some_Time is
   begin
      RP.Device.Timer.Delay_Milliseconds (1000);
   end Wait_Some_Time;

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
   Driver.Set_Inversion_Mode (0, True, Success);
   Drive_Forwards;
   Driver.Set_Enable (True, Success);

   --  State Machine
   loop
      case State is
         when Forwards =>
            --  Check the distance
            Pico.LED.Set;
            Wait_Some_Time;
            Ranger.Measure (Distance, Success);
            if Success and then Distance < Limit then
               --  Goto State Stop
               State := Stop;
            end if;
         when Stop =>
            Pico.LED.Clear;
            Stop_Motors;
            Wait_Some_Time;
            State := Turn;
         when Turn =>
            Pico.LED.Set;
            Turn_Robot;
            Wait_Some_Time;
            State := Backwards;
         when Backwards =>
            Drive_Backwards;
            Wait_Some_Time;
            State := Halt;
         when Halt =>
            Pico.LED.Clear;
            Stop_Motors;
            Wait_Some_Time;
            State := Forwards;
            Pico.LED.Set;
            Drive_Forwards;
      end case;
   end loop;
end Mini_Robot;
