--  Execute module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUSrc			: IN  STD_LOGIC;
			SignExtend		: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC					: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			Zero				: OUT STD_LOGIC;
			ADDResult		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			-- *** ACRESCENTE AS ENTRADAS ABAIXO, 
			-- Function vem direto da top level e ALUOp vem do control
			-- Function sao os 6 bits menos significativos da instrução
			ALUOp				: IN STD_LOGIC_VECTOR( 1 DOWNTO 0);
			Function_opcode: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS
-- *** ACRESCENTE A DECLARAÇÃO DE AINPUT
SIGNAL AInput				: STD_LOGIC_VECTOR(31 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
SIGNAL BInput				: STD_LOGIC_VECTOR(31 DOWNTO 0 );
SIGNAL ALU_output_mux	: STD_LOGIC_VECTOR(31 DOWNTO 0 );

BEGIN
	-- *** ACRESCENTE A ATRIBUIÇÃO A AINPUT
	AInput <= read_data_1;
	BInput <= read_data_2 WHEN ALUSrc = '0' ELSE SignExtend;
	
	-- *** SUBSTITUA A DESCRIÇÃO DE SOMA ABAIXO PELA ATRIBUIÇÃO E PELO PROCESS A SEGUIR
	-- ALU_Result <= Read_data_1 + BImput;
	
	-- Gera ALU control bits (de acordo com PATERSON)
	ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
	
	Zero <= '1' WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000" ) ELSE '0';
	
	--Calcula próximo endereco de acordo com o SignExtend (endereco de pulo)
	ADDResult <= PC + 1 + SignExtend(7 DOWNTO 0);
	
	ALU_result <= X"0000000"&B"000"&ALU_output_mux( 31 ) WHEN  ALU_ctl = "111" 
					  ELSE  	ALU_output_mux( 31 DOWNTO 0 );

	PROCESS ( ALU_ctl, Ainput, Binput )
	BEGIN
	-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
	
END behavior;

