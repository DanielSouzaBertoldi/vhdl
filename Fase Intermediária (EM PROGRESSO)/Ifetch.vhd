library IEEE;
use IEEE.STD_LOGIC_1164.all; -- Tipo de sinal STD_LOGIC e STD_LOGIC_VECTOR
use IEEE.STD_LOGIC_ARITH.all; -- Operacoes aritmeticas sobre binarios
use IEEE.STD_LOGIC_UNSIGNED.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity Ifetch is
	port (
		-- Ins
		reset : in STD_LOGIC;
		clock : in STD_LOGIC;
		ADDResult : in STD_LOGIC_VECTOR(7 downto 0);
		Zero : in STD_LOGIC;
		JumpAddr : in STD_LOGIC_VECTOR(7 downto 0);
		BEQ : in STD_LOGIC;
		BNE : in STD_LOGIC;
		J : in STD_LOGIC;
		JAL : in STD_LOGIC;
		-- Outs
		PC_out : out STD_LOGIC_VECTOR(7 downto 0);
		Instruction : out STD_LOGIC_VECTOR(31 downto 0);
		-- Inouts
		PC_inc : inout STD_LOGIC_VECTOR(7 downto 0)
	);
end Ifetch;

architecture behavior of Ifetch is
	signal PC : STD_LOGIC_VECTOR(7 downto 0);
	signal Next_PC : STD_LOGIC_VECTOR(7 downto 0);
	signal Mem_Addr : STD_LOGIC_VECTOR(7 downto 0);
	signal Temp : STD_LOGIC_VECTOR(7 downto 0);
begin
	-- Descricao da Memoria
	data_memory : altsyncram -- Declaracao do compomente de memoria
	generic map(
		operation_mode => "ROM", 
		width_a => 32, -- tamanho da palavra (Word)
		widthad_a => 8, -- tamanho do barramento de endereco
		lpm_type => "altsyncram", 
		outdata_reg_a => "UNREGISTERED", 
		init_file => "program.mif", -- arquivo com estado inicial
		intended_device_family => "Cyclone")
	port map(
		address_a => Mem_Addr, 
		q_a => Instruction, 
		clock0 => clock); -- sinal de clock da memoria
 
	-- Descricao do somador
	PC_inc <= PC + 1;
 
	-- Descricao do registrador
	process
	begin
		wait until (clock'EVENT and clock = '1');
		if reset = '1' then
			PC <= "00000000";
		else
			PC <= Next_PC;
		end if;
	end process;

	-- Usar o Next_PC ao inves do PC porque a memoria tem um registrador de entrada interno
	-- Entao o PC tem que ser atualizado simultaneamente com o reg interno da memoria
	Mem_Addr <= Next_PC;
	PC_out <= PC;
	Temp <= 
		ADDResult when (BEQ = '1' and Zero = '1') or (BNE = '1' and Zero = '0') else
		JumpAddr when (J = '1') or (JAL = '1') else
		PC_inc;
	Next_PC <= "00000000" when reset = '1' else Temp;

end behavior;