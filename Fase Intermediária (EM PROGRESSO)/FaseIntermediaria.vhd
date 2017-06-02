library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FaseIntermediaria is
	port (
		-- Ins
		reset : in STD_LOGIC;
		clock48MHz : in STD_LOGIC;
		clockPB : in STD_LOGIC;
		InstrALU : in STD_LOGIC;
		-- Outs
		LCD_RS, LCD_E : out STD_LOGIC;
		LCD_RW, LCD_ON : out STD_LOGIC;
		-- Inouts
		DATA : inout STD_LOGIC_VECTOR(7 downto 0)
	);
end FaseIntermediaria;

architecture exec of FaseIntermediaria is
	
	component LCD_Display is
		generic (NumHexDig : integer := 11);
		port (
			-- Ins
			reset, clk_48Mhz : in STD_LOGIC;
			HexDisplayData : in STD_LOGIC_VECTOR((NumHexDig * 4) - 1 downto 0);
			-- Outs
			LCD_RS, LCD_E : out STD_LOGIC;
			LCD_RW : out STD_LOGIC;
			-- Inouts
			DATA_BUS : inout STD_LOGIC_VECTOR(7 downto 0)
		);
	end component LCD_Display;
	
	component Ifetch is
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
	end component;

	component Idecode is
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
			Sign_extend : out STD_LOGIC_VECTOR(31 downto 0 )
		);
	end component;
	
	component Execute is
		port (
			-- Ins
			Read_data_1 : in STD_LOGIC_VECTOR(31 downto 0 );
			Read_data_2 : in STD_LOGIC_VECTOR(31 downto 0 );
			ALUSrc : in STD_LOGIC;
			SignExtend : in STD_LOGIC_VECTOR(31 downto 0 );
			PC : in STD_LOGIC_VECTOR(7 downto 0 );
			ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
			Function_opcode : in STD_LOGIC_VECTOR(5 downto 0 );
			-- Outs
			ADDResult : out STD_LOGIC_VECTOR(7 downto 0);	
			Zero : out STD_LOGIC;
			ALU_Result : out STD_LOGIC_VECTOR(31 downto 0 )
		);
	end component;
	
	component dmemory is
		port (
			-- Ins
			address : in STD_LOGIC_VECTOR(7 downto 0 );
			write_data : in STD_LOGIC_VECTOR(31 downto 0 );
			MemRead, Memwrite : in STD_LOGIC;
			clock, reset : in STD_LOGIC;
			-- Outs
			read_data : out STD_LOGIC_VECTOR(31 downto 0 )
		);
	end component;

	component control is
		port (
			-- Ins
			Opcode : in STD_LOGIC_VECTOR(5 downto 0 );
			-- Outs
			RegDst : out STD_LOGIC;
			RegWrite : out STD_LOGIC;
			ALUSrc : out STD_LOGIC;
			MemToReg : out STD_LOGIC;
			MemRead : out STD_LOGIC;
			MemWrite : out STD_LOGIC;
			J : out STD_LOGIC;
			JAL : out STD_LOGIC;
			-- *** Acrescentar a linha abaixo a sua unidade para selecionar as operações
			-- Será mapeado para o execute
			ALUOp : out STD_LOGIC_VECTOR(1 downto 0 );
			-- Inouts
			BEQ : inout STD_LOGIC;
			BNE : inout STD_LOGIC
		);
	end component;

	signal DataInstr : STD_LOGIC_VECTOR(31 downto 0);
	signal DisplayData : STD_LOGIC_VECTOR(31 downto 0);
	signal PCAddr : STD_LOGIC_VECTOR(7 downto 0);
	signal RegDst : STD_LOGIC;
	signal RegWrite : STD_LOGIC;
	signal ALUResult : STD_LOGIC_VECTOR(31 downto 0);
	signal SignExtend : STD_LOGIC_VECTOR(31 downto 0);
	signal readData1 : STD_LOGIC_VECTOR(31 downto 0);
	signal readData2 : STD_LOGIC_VECTOR(31 downto 0);
	signal HexDisplayDT : STD_LOGIC_VECTOR(43 downto 0);
	signal clock: STD_LOGIC;
	signal MemRead : STD_LOGIC;
	signal MemWrite : STD_LOGIC;
	signal MemToReg : STD_LOGIC;
	signal ALUSrc : STD_LOGIC;
	signal read_data : STD_LOGIC_VECTOR(31 downto 0);
	signal Zero : STD_LOGIC;
	signal ADDResult : STD_LOGIC_VECTOR(7 downto 0);
	signal BEQ : STD_LOGIC;
	signal BNE : STD_LOGIC;
	signal J : STD_LOGIC;
	signal JAL : STD_LOGIC;
	signal ALUOp : STD_LOGIC_VECTOR(1 downto 0 );
	signal PC_inc : STD_LOGIC_VECTOR(7 downto 0);

begin
	clock <= not clockPB;

	LCD_ON <= '1';
 
	-- Inserir MUX para DisplayData
	DisplayData <= DataInstr when InstrALU = '0' else ALUResult;
 
	HexDisplayDT <= "0000" & PCAddr & DisplayData;

	lcd : LCD_Display
	port map(
		-- Ins
		reset => reset, 
		clk_48Mhz => clock48MHz, 
		HexDisplayData => HexDisplayDT, 
		-- Outs
		LCD_RS => LCD_RS, 
		LCD_E => LCD_E, 
		LCD_RW => LCD_RW, 
		-- Inouts
		DATA_BUS => DATA
	);
 
	IFT : Ifetch
	port map(
		-- Ins
		reset => reset, 
		clock => clock, 
		ADDResult => ADDResult,
		Zero => Zero,
		JumpAddr => DataInstr(7 downto 0),
		BEQ => BEQ,
		BNE => BNE,
		J => J,
		JAL => JAL,
		-- Outs
		PC_out => PCAddr, 
		Instruction => DataInstr,
		-- Inouts
		PC_inc => PC_inc
	);

	CTR : Control
	port map(
		-- Ins
		Opcode => DataInstr(31 downto 26), 
		-- Outs
		RegDst => RegDst, 
		RegWrite => RegWrite,
		MemRead => MemRead,
		MemWrite => MemWrite,
		MemToReg => MemToReg,
		ALUSrc => ALUSrc,
		J => J,
		JAL => JAL,
		ALUOp => ALUOp,
		-- Inouts
		BEQ => BEQ,
		BNE => BNE
	);
	IDEC : Idecode
	port map(
		-- Ins
		Instruction => DataInstr, 
		ALU_result => ALUResult, 
		RegWrite => RegWrite, 
		RegDst => RegDst, 
		clock => clock, 
		reset => reset,
		MemToReg => MemToReg,
		read_data => read_data,
		JAL => JAL,
		LinkAddr => PC_inc,
		-- Outs
		read_data_1 => readData1, 
		read_data_2 => readData2, 
		Sign_extend => SignExtend
	);
	
	EXE : Execute
	port map(
		-- Ins
		read_data_1 => readData1, 
		read_data_2 => readData2, 
		ALUSrc => ALUSrc,
		SignExtend => SignExtend,
		PC => PCAddr,
		ALUOp => ALUOp,
		Function_opcode => DataInstr(5 downto 0),
		-- Outs
		ADDResult => ADDResult,
		Zero => Zero,
		ALU_result => ALUResult
	);
	
	DMEM : dmemory
	port map (
		-- Ins
		address => ALUResult(9 downto 2),
		write_data => readData2,
		MemRead => MemRead,
		MemWrite => MemWrite,
		clock => clock,
		reset => reset,
		-- Outs
		read_data => read_data
	);
end exec;