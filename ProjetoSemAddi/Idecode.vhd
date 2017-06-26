library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Idecode is
	port (
		-- Ins
		Instruction : in STD_LOGIC_VECTOR(31 downto 0 );
		ALU_result : in STD_LOGIC_VECTOR(31 downto 0 );
		RegWrite : in STD_LOGIC;
		RegDst : in STD_LOGIC;
		clock, reset : in STD_LOGIC ;
		MemToReg : in STD_LOGIC;
		read_data : in STD_LOGIC_VECTOR(31 downto 0 );
		JAL : in STD_LOGIC;
		LinkAddr : in STD_LOGIC_VECTOR(7 downto 0);
		-- Outs
		read_data_1 : out STD_LOGIC_VECTOR(31 downto 0 );
		read_data_2 : out STD_LOGIC_VECTOR(31 downto 0 );
		Sign_extend : out STD_LOGIC_VECTOR(31 downto 0 );
		ReturnAddr : out STD_LOGIC_VECTOR(7 downto 0)
	);
end Idecode;

architecture behavior of Idecode is

	-- Vetor de regitradores
	type registers is array (0 to 31) of std_logic_vector (31 downto 0);
	signal register_array : registers;

	-- Sinais internos
	signal read_Rs_ID : std_logic_vector (4 downto 0);
	signal read_Rt_ID : std_logic_vector (4 downto 0);
	signal write_Rd_ID : std_logic_vector (4 downto 0);
	signal write_Rt_ID : std_logic_vector (4 downto 0);
	signal Immediate_value : std_logic_vector (15 downto 0);
	signal write_reg_ID : std_logic_vector (4 downto 0);
	signal write_data : std_logic_vector (31 downto 0);
	
	
	signal read_data_1_LOCAL : STD_LOGIC_VECTOR(31 downto 0 );

begin
	-- Os sinais abaixo devem receber as identificacoes dos registradores
	-- que estao definidos na instrucao, ou seja, o indice dos registradores
	-- a serem utilizados na execucao da instrucao
	read_Rs_ID <= Instruction(25 downto 21);
	read_Rt_ID <= Instruction(20 downto 16);
	write_Rd_ID <= Instruction(15 downto 11);
	write_Rt_ID <= Instruction(20 downto 16);
	Immediate_value <= Instruction(15 downto 0);
 
	-- Os sinais abaixo devem receber o conteudo dos registradores, reg(i)
	-- use "CONV_INTEGER(read_Rs_ID)" para converser os bits de indice do registrador
	-- para um inteiro a ser usado como indice do vetor de registradores.
	-- Exemplo: dado um sinal X do tipo array de registradores,
	-- X(CONV_INTEGER("00011")) recuperaria o conteudo do registrador 3.
	read_data_1_LOCAL <= register_array(CONV_INTEGER(read_Rs_ID)); 
	read_data_1 <= read_data_1_LOCAL;
	read_data_2 <= register_array(CONV_INTEGER(read_Rt_ID)); 
 
	-- Crie um multiplexador que seleciona o registrador de escrita de acordo com o sinal RegDst
	write_reg_ID <= write_Rd_ID when RegDst = '1' else write_Rt_ID;
 
	-- Ligue no sinal abaixo os bits relativos ao valor a ser escrito no registrador destino.
	write_data <= read_data when MemToReg = '1' else ALU_result;
 
	-- Estenda o sinal de instrucoes do tipo I de 16-bits to 32-bits
	-- Faca isto independente do tipo de instrucao, mas use apenas quando
	-- for instrucao do tipo I.
	Sign_extend <= x"0000" & Immediate_value when Immediate_value(15) = '0' else x"FFFF" & Immediate_value;
	
	ReturnAddr <= read_data_1_LOCAL(7 downto 0); 
	
	process
	begin
		wait until clock'EVENT and clock = '1';
		if reset = '1' then
			-- Inicializa os registradores com seu numero
			for i in 0 to 31 loop
				register_array(i) <= CONV_STD_LOGIC_VECTOR(i, 32 );
			end loop;
		elsif JAL = '1' then
			register_array(31) <= X"000000" & LinkAddr;
		elsif RegWrite = '1' then
			-- Escreve no registrador indicado pela instrucao
			register_array(CONV_INTEGER(write_reg_ID)) <= write_data;
		end if;
	end process;
end behavior;