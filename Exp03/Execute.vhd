LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Execute IS
	  PORT(	read_data_1	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALUSrc		: IN 	STD_LOGIC);
END Execute;

ARCHITECTURE behavior OF Execute IS
	--Precisamos ter um sinal interno de controle para saber qual valor será usado como entrada do somador
	SIGNAL Entrada : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	--Multiplexador que decide se será usado o Sign_extend ou o read_data_2
	Entrada 	  <= Sign_extend WHEN ALUSrc = '1' ELSE read_data_2;

	ALU_result <= read_data_1 + Entrada;
END behavior;
