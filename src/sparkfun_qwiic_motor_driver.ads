--
--  Copyright 2025 (C) Karsten Lueth
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with HAL.I2C;

generic
   Port     : not null HAL.I2C.Any_I2C_Port;
   I2C_Addr : HAL.I2C.I2C_Address;
package Sparkfun_Qwiic_Motor_Driver is

   type Motor_Direction is (CCW, CW);
   for Motor_Direction use (CCW => 1, CW => 2);

   subtype Motor_ID is HAL.UInt8 range 0 .. 1;

   subtype Motor_Speed is Integer range -127 .. 127;

   procedure Initialize (Ident   : out HAL.UInt8;
                         Success : out Boolean);

   procedure Is_Ready (Ready   : out Boolean;
                       Success : out Boolean);

   procedure Is_Busy (Busy    : out Boolean;
                      Success : out Boolean);

   procedure Set_Enable (Enable  : Boolean;
                         Success : out Boolean);

   procedure Set_Drive (Motor   : Motor_ID;
                        Speed   : Motor_Speed;
                        Success : out Boolean);

end Sparkfun_Qwiic_Motor_Driver;
