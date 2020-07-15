LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;  -- Tipo de sinal STD_LOGIC e STD_LOGIC_VECTOR
USE IEEE.STD_LOGIC_ARITH.ALL;  -- Operacoes aritmeticas sobre binarios
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

ENTITY Ifetch IS
	PORT(	reset		: IN	STD_LOGIC;
			clock		: IN	STD_LOGIC;
			PC_out		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0);
			Instruction	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			ADDResult	: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0);
			Reg31		: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0);
			Beq			: IN	STD_LOGIC;
			Bne			: IN	STD_LOGIC;
			Zero		: IN	STD_LOGIC;
			Jump		: IN	STD_LOGIC;
			Jal			: IN	STD_LOGIC;
			Jr			: IN	STD_LOGIC;
			PC_inc		: INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			J_Address	: IN	STD_LOGIC_VECTOR(7 DOWNTO 0));
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS

	SIGNAL PC		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Next_PC	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Mem_Addr	: STD_LOGIC_VECTOR(7 DOWNTO 0);

	BEGIN
		-- Descrição da Memória
		data_memory: altsyncram -- Declaração do compomente de memória
		GENERIC MAP(
			operation_mode         => "ROM",
			width_a                => 32, -- tamanho da palavra (Word)
			widthad_a              => 8,   -- tamanho do barramento de endereço
			lpm_type               => "altsyncram",
			outdata_reg_a          => "UNREGISTERED",
			init_file              => "programT.mif",  -- arquivo com estado inicial
			intended_device_family => "Cyclone")
		PORT MAP(
			address_a => Mem_Addr,
			q_a       => Instruction,
			clock0    => clock);  -- sinal de clock da memória

		-- Descrição do somador
		PC_inc <= PC+1;
		
		-- Descrição do registrador
		PROCESS
			BEGIN
			WAIT UNTIL (clock'event AND clock='1');
			IF reset='1' THEN
				PC <= "00000000";
			ELSE
				PC <= Next_PC;
			END IF;
		END PROCESS;

		-- Usar o Next_PC ao invés do PC por quê a memória tem um registrador de entrada interno
		-- Então o PC tem que ser atualizado simultâneamente com o reg interno da memória
		Mem_Addr <= Next_PC;
		Next_PC  <= "00000000"	WHEN reset = '1' ELSE
					--Deve-se somar o endereço do pulo caso seja Beq ou Bne
					ADDResult 	WHEN (Beq = '1' AND Zero = '1') OR (Bne = '1' AND Zero = '0') ELSE
					--Deve-se receber o endereco requisitado caso seja uma instrucao de pulo incondicional
					J_Address	WHEN Jump = '1' OR Jal = '1' ELSE
					--Deve-se receber o endereço armazenado no registrador 31 quando a instrução for Jr
					Reg31		WHEN Jr = '1' ELSE
					--Caso nao seja nenhuma instrucao de pulo, continua normalmente
					PC_inc;
		PC_out <= PC;
END behavior;