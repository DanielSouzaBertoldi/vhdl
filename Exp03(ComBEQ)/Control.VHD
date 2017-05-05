-- control module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
   PORT( Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			RegDst 		: OUT STD_LOGIC;
			RegWrite 	: OUT STD_LOGIC;
			MemRead		: OUT	STD_LOGIC;
			MemWrite		: OUT	STD_LOGIC;
			MemToReg		: OUT	STD_LOGIC;
			ALUSrc		: OUT STD_LOGIC;
			Branch		: OUT STD_LOGIC);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format 	: STD_LOGIC;
	SIGNAL  I_format	: STD_LOGIC;
	
BEGIN           
	R_format <= '1' WHEN Opcode = "000000" ELSE '0';
	
	I_format <= '1' WHEN Opcode = "100011" ELSE --100011 LW
					'1' WHEN Opcode = "101011" ELSE '0'; --101011 SW
					
	Branch	<= '1' WHEN Opcode = "000100" ELSE '0';
					
	--Se R_format for verdadeiro, RegWrite vira verdadeiro
	RegDst	<= R_format;
	RegWrite <= R_format OR I_format WHEN Opcode = "100011"; --Se for R_format ou quer ser feito um LW, deve-se escrever no registrador destino.

	--Ativa as saidas pro DMEMORY
	MemRead  <= I_format WHEN Opcode = "100011" ELSE '0'; --Deve-se ler do registrador quando for LW
	MemToReg <= I_format WHEN Opcode = "100011" ELSE '0'; --Deve-se escrever da memoria pro registrador quando for LW
	
	MemWrite <= I_format WHEN Opcode = "101011" ELSE '0'; --Deve-se escrever no registrador apenas quando for SW

	--ALUSrc deve ser ativado se o Opcode for LW ou SW
	ALUSrc	<= I_format WHEN Opcode = "101011" ELSE
					I_format WHEN Opcode = "100011" ELSE '0';
	
   END behavior;