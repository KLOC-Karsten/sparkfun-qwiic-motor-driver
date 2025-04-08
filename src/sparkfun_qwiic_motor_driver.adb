--
--  Copyright 2025 (C) Karsten Lueth
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with HAL; use HAL;
with HAL.I2C; use HAL.I2C;

package body Grove_I2C_Motor_Driver is

   --  Reference: https://github.com/Seeed-Studio/Grove_I2C_Motor_Driver_v1_3/

   --  I2C command definitions
   Direction_Set     : constant UInt16 := 16#aa#;
   Motor_Speed_Set   : constant UInt16 := 16#82#;
   PWM_Frequence_Set : constant UInt16 := 16#42#;
   Nothing           : constant UInt8 := 16#01#;

   --  Prescaler Frequence
   --  F_31372Hz  : constant UInt8 := 16#1#;
   --  F_3921Hz   : constant UInt8 := 16#2#;
   --  F_490Hz    : constant UInt8 := 16#3#;
   --  F_122Hz    : constant UInt8 := 16#4#;
   --  F_30Hz     : constant UInt8 := 16#5#;

   --  Sets the PWM frequency. Must by one of above values.
   procedure Frequence (Addr    : HAL.I2C.I2C_Address;
                        Freq    : UInt16;
                        Success : out Boolean)
   is
      LSB : constant UInt8 := UInt8 (Freq and 16#ff#);
      MSB : constant UInt8 := UInt8 (Shift_Right (Freq, 8) and 16#ff#);
      Status : HAL.I2C.I2C_Status;
   begin
      Port.Mem_Write (Addr          => Addr,
                      Mem_Addr      => PWM_Frequence_Set,
                      Mem_Addr_Size => Memory_Size_8b,
                      Data          => (1 => LSB, 2 => MSB),
                      Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Frequence;

   procedure Initialize (Addr    : HAL.I2C.I2C_Address;
                         Success : out Boolean) is
   begin
      Frequence (Addr, 16#0202#, Success);
   end Initialize;

   --  Sets the direction for both channels.
   procedure Speed (Addr    : HAL.I2C.I2C_Address;
                    Speed_1 : Motor_Speed;
                    Speed_2 : Motor_Speed;
                    Success : out Boolean)
   is
      Status : HAL.I2C.I2C_Status;
   begin
      Port.Mem_Write (Addr          => Addr,
                      Mem_Addr      => Motor_Speed_Set,
                      Mem_Addr_Size => Memory_Size_8b,
                      Data          => (1 => UInt8 (Speed_1),
                                        2 => UInt8 (Speed_2)),
                      Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Speed;

   --  Sets the direction for both channels.
   procedure Direction (Addr        : HAL.I2C.I2C_Address;
                        Direction_1 : Motor_Direction;
                        Direction_2 : Motor_Direction;
                        Success     : out Boolean)
   is
      Dir : constant UInt8 := Motor_Direction'Pos (Direction_2) * 4
                              + Motor_Direction'Pos (Direction_1);
      Status : HAL.I2C.I2C_Status;
   begin
      Port.Mem_Write (Addr          => Addr,
                      Mem_Addr      => Direction_Set,
                      Mem_Addr_Size => Memory_Size_8b,
                      Data          => (1 => Dir, 2 => Nothing),
                      Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Direction;

end Grove_I2C_Motor_Driver;
