LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Execute IS
	  PORT(	read_data_1	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALUSrc		: IN 	STD_LOGIC;
				ZeroALU		: OUT STD_LOGIC;
				ADDResult	: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				PC				: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS
	--Precisamos ter um sinal interno de controle para saber qual valor será usado como entrada do somador
	SIGNAL Entrada : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	--Multiplexador que decide se será usado o Sign_extend ou o read_data_2
	Entrada 	  <= Sign_extend WHEN ALUSrc = '1' ELSE read_data_2;

	--ZeroALU será ativo alto quando Rs (Read_data_1) for igual a Rt (Read_data_2)
	ZeroALU <= '1' WHEN read_data_1 = read_data_2 ELSE '0';

	--ADDResult ira receber PC+1 + Sign_extend
	ADDResult <= PC + 1 + Sign_extend(7 DOWNTO 0);
	
	--Caso seja apenas uma soma normal
	ALU_result <= read_data_1 + Entrada;
END behavior;
