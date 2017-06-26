-- OK

-- control module
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity control is
	port (
		-- Ins
		Opcode : in STD_LOGIC_VECTOR(5 downto 0 );
		Function_opcode : in STD_LOGIC_VECTOR(5 downto 0 );
		-- Outs
		RegDst : out STD_LOGIC;
		RegWrite : out STD_LOGIC;
		ALUSrc : out STD_LOGIC;
		MemToReg : out STD_LOGIC;
		MemRead : out STD_LOGIC;
		MemWrite : out STD_LOGIC;
		ALUOp : out STD_LOGIC_VECTOR(1 downto 0 );
		BEQ : out STD_LOGIC;
		BNE : out STD_LOGIC;
		J : out STD_LOGIC;
		JAL : out STD_LOGIC;
		JR : out STD_LOGIC;
		SL : out STD_LOGIC;
		SR : out STD_LOGIC;
	);
end control;

architecture behavior of control is

	signal R_format : STD_LOGIC;
	signal SW : STD_LOGIC;
	signal LW : STD_LOGIC;
	signal BEQ_LOCAL : STD_LOGIC;
	signal BNE_LOCAL : STD_LOGIC;
	
	signal ADDI : STD_LOGIC;

begin
	-- Code to generate control signals using opcode bits
	R_format <= '1' when Opcode = "000000" else '0';
	SW <= '1' when Opcode = "101011" else '0';
	LW <= '1' when Opcode = "100011" else '0';
	BEQ_LOCAL <= '1' when Opcode = "000100" else '0';
	BEQ <= BEQ_LOCAL;
	BNE_LOCAL <= '1' when Opcode = "000101" else '0';
	BNE <= BNE_LOCAL;
	J <= '1' when Opcode = "000010" else '0';
	JAL <= '1' when Opcode = "000011" else '0';
	
	ADDI <= '1' when Opcode = "001000" else '0';
	JR <= '1' when R_format = '1' and Function_opcode = "001000" else '0';
	SL <= '1' when R_format = '1' and Function_opcode = "000000" else '0';
	SR <= '1' when R_format = '1' and Function_opcode = "000010" else '0';
 
	RegDst <= R_format;
	RegWrite <= R_format or LW or ADDI;
	ALUSrc <= LW or SW or ADDI;
	MemToReg <= LW;
	MemRead <= LW;
	MemWrite <= SW;

	-- *** ACRECENTE AS ATRIBUIÇÕES ABAIXO
	ALUOp(1 ) <= R_format;
	ALUOp(0 ) <= BEQ_LOCAL or BNE_LOCAL; -- Beq deve ser 1 quando a instrução for BEQ
 
end behavior;