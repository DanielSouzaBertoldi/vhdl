LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Execute IS
	  PORT(	read_data_1	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS

BEGIN
	ALU_result <= read_data_1 + read_data_2;
END behavior;