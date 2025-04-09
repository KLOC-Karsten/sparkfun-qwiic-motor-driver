--
--  Copyright 2025 (C) Karsten Lueth
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with HAL; use HAL;
with HAL.I2C; use HAL.I2C;

package body Sparkfun_Qwiic_Motor_Driver is

   --  Reference:
   --  https://github.com/sparkfun/
   --   SparkFun_Serial_Controlled_Motor_Driver_Arduino_Library

   --  I2C command definitions
   SCMD_ID            : constant UInt8 := 16#01#;
   SCMD_MA_DRIVE      : constant UInt8 := 16#20#;
   SCMD_DRIVER_ENABLE : constant UInt8 := 16#70#;
   SCMD_STATUS_1      : constant UInt8 := 16#77#;

   --  SCMD_STATUS_1 bits
   SCMD_ENUMERATION_BIT  : constant UInt8 := 16#01#;
   SCMD_BUSY_BIT         : constant UInt8 := 16#02#;
   SCMD_REM_READ_BIT     : constant UInt8 := 16#04#;
   SCMD_REM_WRITE_BIT    : constant UInt8 := 16#08#;
   --  SCMD_HW_EN_BIT        : constant UInt8 := 16#10#;

   --  Write to I2C register.
   procedure Write_Register (Offset  : UInt8;
                             Data    : UInt8;
                             Success : out Boolean)
   is
      Status : HAL.I2C.I2C_Status;
   begin
      Port.Mem_Write (Addr          => I2C_Addr,
                      Mem_Addr      => UInt16 (Offset),
                      Mem_Addr_Size => Memory_Size_8b,
                      Data          => (1 => Data),
                      Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Write_Register;

   --  Read from I2C register.
   procedure Read_Register (Offset  : UInt8;
                            Data    : out UInt8;
                            Success : out Boolean)
   is
      Status : HAL.I2C.I2C_Status;
      Buffer : HAL.I2C.I2C_Data := (1 => 0);
   begin
      Port.Mem_Read (Addr          => I2C_Addr,
                     Mem_Addr      => UInt16 (Offset),
                     Mem_Addr_Size => Memory_Size_8b,
                     Data          => Buffer,
                     Status        => Status);

      Success := Status = HAL.I2C.Ok;
      Data    := Buffer (1);
   end Read_Register;

   procedure Set_Drive (Motor   : Motor_ID;
                        Speed   : Motor_Speed;
                        Success : out Boolean)
   is
      Offset : constant UInt8 := SCMD_MA_DRIVE + UInt8 (Motor);
      Data   : constant UInt8 := UInt8 (127 + Speed);
   begin
      Write_Register (Offset, Data, Success);
   end Set_Drive;

   procedure Set_Enable (Enable  : Boolean;
                         Success : out Boolean) is
   begin
      if Enable then
         Write_Register (SCMD_DRIVER_ENABLE, 1, Success);
      else
         Write_Register (SCMD_DRIVER_ENABLE, 0, Success);
      end if;
   end Set_Enable;

   procedure Is_Busy (Busy    : out Boolean;
                      Success : out Boolean)
   is
      Status : UInt8;
      Flags  : constant UInt8 :=
         SCMD_BUSY_BIT + SCMD_REM_READ_BIT + SCMD_REM_WRITE_BIT;
   begin
      Read_Register (SCMD_STATUS_1, Status, Success);
      if Success then
         if (Status and Flags) > 0 then
            Busy := True;
         else
            Busy := False;
         end if;
      end if;
   end Is_Busy;

   procedure Is_Ready (Ready   : out Boolean;
                       Success : out Boolean)
   is
      Status : UInt8;
   begin
      Read_Register (SCMD_STATUS_1, Status, Success);
      if Success then
         if Status = 16#ff# then
            Ready := False;
         elsif (Status and SCMD_ENUMERATION_BIT) > 0 then
            Ready := True;
         else
            Ready := False;
         end if;
      end if;
   end Is_Ready;

   procedure Initialize (Ident   : out UInt8;
                         Success : out Boolean) is
   begin
      --  Dummy Read
      Read_Register (SCMD_ID, Ident, Success);

      Read_Register (SCMD_ID, Ident, Success);
   end Initialize;

end Sparkfun_Qwiic_Motor_Driver;
