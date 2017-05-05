LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Exp03 IS
	PORT(	reset				: IN 	STD_LOGIC;
			clock48MHz		: IN 	STD_LOGIC;
			LCD_RS, LCD_E	: OUT	STD_LOGIC;
			LCD_RW, LCD_ON	: OUT 	STD_LOGIC;
			DATA				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			--clock				: IN 	STD_LOGIC;
			InstrALU			: IN 	STD_LOGIC;
			clockPB			: IN  STD_LOGIC);
END Exp03;

ARCHITECTURE exec OF Exp03 IS
COMPONENT LCD_Display
	GENERIC(NumHexDig: Integer:= 11);
	PORT(	reset, clk_48Mhz	: IN	STD_LOGIC;
			HexDisplayData		: IN  	STD_LOGIC_VECTOR((NumHexDig*4)-1 DOWNTO 0);
			LCD_RS, LCD_E		: OUT	STD_LOGIC;
			LCD_RW				: OUT 	STD_LOGIC;
			DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT Ifetch
	PORT(	reset			: IN 	STD_LOGIC;
			clock			: IN 	STD_LOGIC;
			PC_out		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			Instruction	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ADDResult	: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			Branch		: IN	STD_LOGIC;
			ZeroALU		: IN	STD_LOGIC);
END COMPONENT;

COMPONENT Idecode
	PORT(		read_data_1	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC;
				Sign_extend : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC; 
				MemToReg		: IN	STD_LOGIC;
				read_data	: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END COMPONENT;

COMPONENT Execute
	  PORT(	read_data_1	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALUSrc		: IN 	STD_LOGIC;
				ZeroALU		: OUT STD_LOGIC;
				ADDResult	: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				PC				: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END COMPONENT;

COMPONENT Control
  PORT( 	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			RegDst 		: OUT STD_LOGIC;
			RegWrite 	: OUT STD_LOGIC;
			MemRead		: OUT	STD_LOGIC;
			MemWrite		: OUT	STD_LOGIC;
			MemToReg		: OUT	STD_LOGIC;
			ALUSrc		: OUT STD_LOGIC;
			Branch		: OUT STD_LOGIC);
END COMPONENT;

COMPONENT dmemory
	PORT(	read_data 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 				: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   	MemRead, Memwrite	: IN 	STD_LOGIC;
         clock,reset			: IN 	STD_LOGIC);
END COMPONENT;

SIGNAL DataInstr 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DisplayData	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PCAddr			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL RegDst			: STD_LOGIC;
SIGNAL RegWrite		: STD_LOGIC;
SIGNAL ALUResult		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SignExtend		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL readData1		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL readData2		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL HexDisplayDT	: STD_LOGIC_VECTOR(43 DOWNTO 0);
SIGNAL MemToReg		: STD_LOGIC;
SIGNAL MemRead			: STD_LOGIC;
SIGNAL MemWrite		: STD_LOGIC;
SIGNAL ALUSrc			: STD_LOGIC;
SIGNAL read_data		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ADDResult		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Branch			: STD_LOGIC;
SIGNAL ZeroALU			: STD_LOGIC;
SIGNAL clock			: STD_LOGIC;

BEGIN
	LCD_ON <= '1';

	clock <= NOT clockPB;
	
	-- Inserir MUX para DisplayData
						
	HexDisplayDT <= "0000" & PCAddr & DisplayData;

	lcd: LCD_Display
	PORT MAP(	reset				=> reset,
					clk_48Mhz		=> clock48MHz,
					HexDisplayData	=> HexDisplayDT,
					LCD_RS			=> LCD_RS,
					LCD_E				=> LCD_E,
					LCD_RW			=> LCD_RW,
					DATA_BUS			=> DATA);
	
	IFT: Ifetch
	PORT MAP(	reset			=> reset,
					clock 		=> clock,
					PC_out		=> PCAddr,
					Instruction	=> DataInstr,
					Branch		=> Branch,
					ZeroALU		=> ZeroALU,
					ADDResult	=> ADDResult);

	CTR: Control
   PORT MAP( 	Opcode 		=> DataInstr(31 DOWNTO 26),
					RegDst 		=> RegDst,
					RegWrite 	=> RegWrite,
					MemRead		=> MemRead,
					MemWrite		=> MemWrite,
					MemToReg		=> MemToReg,
					ALUSrc		=> ALUSrc,
					Branch		=> Branch);

	IDEC: Idecode
	PORT MAP( 	read_data_1	=> readData1,
					read_data_2	=> readData2,
					Instruction => dataInstr,
					ALU_result	=> ALUResult,
					RegWrite 	=> RegWrite,
					RegDst 		=> RegDst,
					Sign_extend => SignExtend,
					clock			=> clock,
					reset			=> reset,
					MemToReg		=> MemToReg,
					read_data	=> read_data);

	EXE: Execute
	PORT MAP(	read_data_1	=> readData1,
					read_data_2	=> readData2,
					ALU_result	=> ALUResult,
					Sign_extend	=> SignExtend,
					ALUSrc		=> ALUSrc,
					ZeroALU		=> ZeroALU,
					ADDResult	=> ADDResult,
					PC				=> PCAddr);

	DMEM: dmemory
	PORT MAP(	read_data	=> read_data,
					address 		=> ALUResult(7 DOWNTO 0),
					write_data	=> readData2,
					MemRead		=> MemRead,
					MemWrite		=> MemWrite,
					clock			=> clock,
					reset			=> reset);
END exec;
