-- OK

-- Execute module
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity Execute is
	port (
		-- Ins
		Read_data_1 : in STD_LOGIC_VECTOR(31 downto 0 );
		Read_data_2 : in STD_LOGIC_VECTOR(31 downto 0 );
		ALUSrc : in STD_LOGIC;
		SignExtend : in STD_LOGIC_VECTOR(31 downto 0 );
		PC : in STD_LOGIC_VECTOR(7 downto 0 );
		-- *** ACRESCENTE AS ENTRADAS ABAIXO,
		-- function vem direto da top level e ALUOp vem do control
		-- function sao os 6 bits menos significativos da instrução
		ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
		Function_opcode : in STD_LOGIC_VECTOR(5 downto 0 );
		-- Outs
		ADDResult : out STD_LOGIC_VECTOR(7 downto 0);	
		Zero : out STD_LOGIC;
		ALU_Result : out STD_LOGIC_VECTOR(31 downto 0 )
	);
end Execute;

architecture behavior of Execute is
	-- *** ACRESCENTE A DECLARAÇÃO DE AINPUT
	signal AInput : STD_LOGIC_VECTOR(31 downto 0 );
	signal ALU_ctl : STD_LOGIC_VECTOR(2 downto 0);
	signal BInput : STD_LOGIC_VECTOR(31 downto 0 );
	signal ALU_output_mux : STD_LOGIC_VECTOR(31 downto 0 );
begin
	-- *** ACRESCENTE A ATRIBUIÇÃO A AINPUT
	AInput <= Read_data_1;
	BInput <= Read_data_2 when ALUSrc = '0' else
	          SignExtend;
 
	-- *** SUBSTITUA A DESCRIÇÃO DE SOMA ABAIXO PELA ATRIBUIÇÃO E PELO process A SEGUIR
	-- ALU_Result <= Read_data_1 + BImput;
 
	-- Gera ALU control bits (de acordo com PATERSON)
	ALU_ctl(0 ) <= (Function_opcode(0 ) or Function_opcode(3 ) ) and ALUOp(1 );
	ALU_ctl(1 ) <= (not Function_opcode(2 ) ) or (not ALUOp(1 ) );
	ALU_ctl(2 ) <= (Function_opcode(1 ) and ALUOp(1 )) or ALUOp(0);
 
	Zero <= '1' when (ALU_output_mux(31 downto 0 ) = X"00000000" )
	        else '0'; 
 
	ALU_result <= X"0000000" & B"000" & ALU_output_mux(31 ) when ALU_ctl = "111"
	              else ALU_output_mux(31 downto 0 ); 
	
	ADDResult <= PC + 1 + SignExtend(7 downto 0);
 
	process (ALU_ctl, Ainput, Binput )
	begin
		-- select ALU operation
		case ALU_ctl is
			-- ALU performs ALUresult = A_input and B_input
			when "000" => ALU_output_mux <= Ainput and Binput;
				-- ALU performs ALUresult = A_input or B_input
			when "001" => ALU_output_mux <= Ainput or Binput;
				-- ALU performs ALUresult = A_input + B_input
			when "010" => ALU_output_mux <= Ainput + Binput;
				-- ALU performs ALUresult = A_input -B_input
			when "110" => ALU_output_mux <= Ainput - Binput;
				-- ALU performs SLT
			when "111" => ALU_output_mux <= Ainput - Binput;
			when others => ALU_output_mux <= X"00000000";
		end case;
	end process;
 
end behavior;