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

   subtype Motor_Speed is HAL.UInt8 range 0 .. 100;

   procedure Initialize (Addr    : HAL.I2C.I2C_Address;
                         Success : out Boolean);

   procedure Direction (Addr        : HAL.I2C.I2C_Address;
                        Direction_1 : Motor_Direction;
                        Direction_2 : Motor_Direction;
                        Success     : out Boolean);

   procedure Speed (Addr    : HAL.I2C.I2C_Address;
                    Speed_1 : Motor_Speed;
                    Speed_2 : Motor_Speed;
                    Success : out Boolean);

end Sparkfun_Qwiic_Motor_Driver;
