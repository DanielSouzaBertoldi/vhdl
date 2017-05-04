-- control module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
   PORT( Opcode 	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	 RegDst 	: OUT 	STD_LOGIC;
	 RegWrite 	: OUT 	STD_LOGIC;
	 MemRead	: OUT	STD_LOGIC;
	 MemWrite	: OUT	STD_LOGIC;
	 MemToReg	: OUT	STD_LOGIC;
	 ALUSrc		: OUT 	STD_LOGIC);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format 	: STD_LOGIC;
	SIGNAL  I_format	: STD_LOGIC;

BEGIN           
	R_format <= '1' WHEN Opcode = "000000" ELSE '0';
	
	I_format <= '1' WHEN Opcode = "100011" ELSE
		    '1' WHEN Opcode = "101011" ELSE
		    '1' WHEN Opcode = "000100" ELSE
		    '0';
	
	RegDst	 <= R_format;
	RegWrite <= R_format; --Se R_format for verdadeiro, RegWrite vira verdadeiro

	--Ativa as saidas pro DMEMORY
	MemRead  <= I_format;
	MemToReg <= I_format;
	MemWrite <= I_format;
	ALUSrc	 <= I_format;
	
   END behavior;
