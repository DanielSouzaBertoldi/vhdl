LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ProjFinal IS
  PORT(
        reset           : IN    STD_LOGIC;
        clock48MHz      : IN    STD_LOGIC;
        LCD_RS, LCD_E   : OUT   STD_LOGIC;
        LCD_RW, LCD_ON  : OUT   STD_LOGIC;
        DATA            : INOUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        InstrALU        : IN    STD_LOGIC_VECTOR( 2 DOWNTO 0 );
        clockPB         : IN    STD_LOGIC
      );
END ProjFinal;

ARCHITECTURE exec OF ProjFinal IS
COMPONENT LCD_Display
  GENERIC(NumHexDig: Integer:= 11);
  PORT(
        reset, clk_48Mhz    : IN    STD_LOGIC;
        HexDisplayData      : IN    STD_LOGIC_VECTOR((NumHexDig*4)-1 DOWNTO 0);
        LCD_RS, LCD_E       : OUT   STD_LOGIC;
        LCD_RW              : OUT   STD_LOGIC;
        DATA_BUS            : INOUT STD_LOGIC_VECTOR( 7 DOWNTO 0 )
      );
END COMPONENT;

COMPONENT Ifetch
  PORT(
        reset       : IN    STD_LOGIC;
        clock       : IN    STD_LOGIC;
        PC_out      : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        Instruction : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        ADDResult   : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        Reg31       : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        Beq         : IN    STD_LOGIC;
        Bne         : IN    STD_LOGIC;
        Zero        : IN    STD_LOGIC;
        Jump        : IN    STD_LOGIC;
        Jal         : IN    STD_LOGIC;
        Jr          : IN    STD_LOGIC;
        PC_inc      : INOUT STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        J_Address   : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 )
      );
END COMPONENT;

COMPONENT Idecode
  PORT(
        read_data_1     : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        read_data_2     : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Instruction     : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        ALU_result      : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        RegWrite        : IN    STD_LOGIC;
        RegDst          : IN    STD_LOGIC;
        Sign_extend     : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        clock,reset     : IN    STD_LOGIC; 
        MemToReg        : IN    STD_LOGIC;
        read_data       : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Jal             : IN    STD_LOGIC;
        L_Address       : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        Reg31           : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        a1              : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        a2              : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        a3              : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 )
      );
END COMPONENT;

COMPONENT Execute
  PORT(
        read_data_1     : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        read_data_2     : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        ALU_result      : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        ALUSrc          : IN    STD_LOGIC;
        SignExtend      : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        PC              : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        Zero            : OUT   STD_LOGIC;
        ADDResult       : OUT   STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        Sl              : IN    STD_LOGIC;
        Sr              : IN    STD_LOGIC;
        Shamt           : IN    STD_LOGIC_VECTOR(  4 DOWNTO 0);
        ALUOp           : IN    STD_LOGIC_VECTOR(  1 DOWNTO 0);
        Function_opcode : IN    STD_LOGIC_VECTOR(  5 DOWNTO 0 )
      );
END COMPONENT;

COMPONENT Control
  PORT(
        Opcode          : IN    STD_LOGIC_VECTOR( 5 DOWNTO 0 );
        Function_opcode : IN    STD_LOGIC_VECTOR( 5 DOWNTO 0 );
        RegDst          : OUT   STD_LOGIC;
        RegWrite        : OUT   STD_LOGIC;
        ALUSrc          : OUT   STD_LOGIC;
        MemToReg        : OUT   STD_LOGIC;
        MemRead         : OUT   STD_LOGIC;
        MemWrite        : OUT   STD_LOGIC;
        Beq             : INOUT STD_LOGIC;
        Bne             : INOUT STD_LOGIC;
        Jump            : INOUT STD_LOGIC;
        Jal             : INOUT STD_LOGIC;
        Jr              : INOUT STD_LOGIC;
        Sl              : INOUT STD_LOGIC;
        Sr              : INOUT STD_LOGIC;
        ALUOp           : OUT   STD_LOGIC_VECTOR( 1 DOWNTO 0 )
      );
END COMPONENT;

COMPONENT dmemory
  PORT(
        read_data           : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        address             : IN    STD_LOGIC_VECTOR(  7 DOWNTO 0 );
        write_data          : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        MemRead, Memwrite   : IN    STD_LOGIC;
        clock,reset         : IN    STD_LOGIC
      );
END COMPONENT;

SIGNAL DataInstr        : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL DisplayData      : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL PCAddr           : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
SIGNAL RegDst           : STD_LOGIC;
SIGNAL RegWrite         : STD_LOGIC;
SIGNAL ALUResult        : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL SignExtend       : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL readData1        : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL readData2        : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL HexDisplayDT     : STD_LOGIC_VECTOR( 43 DOWNTO 0 );
SIGNAL MemToReg         : STD_LOGIC;
SIGNAL MemRead          : STD_LOGIC;
SIGNAL MemWrite         : STD_LOGIC;
SIGNAL ALUSrc           : STD_LOGIC;
SIGNAL read_data        : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ADDResult        : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
SIGNAL Zero             : STD_LOGIC;
SIGNAL clock            : STD_LOGIC;
SIGNAL Beq              : STD_LOGIC;
SIGNAL Bne              : STD_LOGIC;
SIGNAL Jump             : STD_LOGIC;
SIGNAL Jal              : STD_LOGIC;
SIGNAL Jr               : STD_LOGIC;
SIGNAL Sl               : STD_LOGIC;
SIGNAL Sr               : STD_LOGIC;
SIGNAL PC_inc           : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
SIGNAL ALUOp            : STD_LOGIC_VECTOR(  1 DOWNTO 0 );
SIGNAL Reg31            : STD_LOGIC_VECTOR(  7 DOWNTO 0 );
SIGNAL a1               : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL a2               : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL a3               : STD_LOGIC_VECTOR( 31 DOWNTO 0 );

BEGIN
  LCD_ON <= '1';

  clock <= NOT clockPB;
  
  -- Inserir MUX para DisplayData
  DisplayData <= ALUResult WHEN InstrALU = "001" ELSE
                        a1 WHEN InstrALU = "010" ELSE
                        a2 WHEN InstrALU = "011" ELSE
                        a3 WHEN InstrALU = "100" ELSE
  DataInstr;
  
  HexDisplayDT <= "0000"&PCAddr&DisplayData;

  lcd: LCD_Display
  PORT MAP(
            reset          => reset,
            clk_48Mhz      => clock48MHz,
            HexDisplayData => HexDisplayDT,
            LCD_RS         => LCD_RS,
            LCD_E          => LCD_E,
            LCD_RW         => LCD_RW,
            DATA_BUS       => DATA
          );
  
  IFT: Ifetch
  PORT MAP(
            reset       => reset,
            clock       => clock,
            PC_out      => PCAddr,
            Instruction => DataInstr,
            ADDResult   => ADDResult,
            Reg31       => Reg31,
            Beq         => Beq,
            Bne         => Bne,
            Zero        => Zero,
            Jump        => Jump,
            Jal         => Jal,
            Jr          => Jr,
            PC_inc      => PC_inc,
            J_Address   => DataInstr( 7 DOWNTO 0 )
          );

  CTR: Control
  PORT MAP(
            Opcode          => DataInstr( 31 DOWNTO 26 ),
            Function_opcode => DataInstr(  5 DOWNTO 0 ),
            RegDst          => RegDst,
            RegWrite        => RegWrite,
            MemRead         => MemRead,
            MemWrite        => MemWrite,
            MemToReg        => MemToReg,
            ALUSrc          => ALUSrc,
            Beq             => Beq,
            Bne             => Bne,
            Jump            => Jump,
            Jal             => Jal,
            Jr              => Jr,
            Sl              => Sl,
            Sr              => Sr,
            ALUOp           => ALUOp( 1 DOWNTO 0 )
          );

  IDEC: Idecode
  PORT MAP(
            read_data_1 => readData1,
            read_data_2 => readData2,
            Instruction => dataInstr,
            ALU_result  => ALUResult,
            RegWrite    => RegWrite,
            RegDst      => RegDst,
            Sign_extend => SignExtend,
            clock       => clock,
            reset       => reset,
            MemToReg    => MemToReg,
            read_data   => read_data,
            Jal         => Jal,
            L_Address   => PC_inc,
            Reg31       => Reg31,
            a1          => a1,
            a2          => a2,
            a3          => a3
          );

  EXE: Execute
  PORT MAP(
            read_data_1     => readData1,
            read_data_2     => readData2,
            ALU_result      => ALUResult,
            ALUSrc          => ALUSrc,
            SignExtend      => SignExtend,
            PC              => PCAddr,
            Zero            => Zero,
            ADDResult       => ADDResult,
            Sl              => Sl,
            Sr              => Sr,
            Shamt           => DataInstr( 10 DOWNTO 6 ),
            ALUOp           => ALUOp,
            Function_opcode => DataInstr(  5 DOWNTO 0 )
          );
                  
  DMEM: dmemory
  PORT MAP(
            read_data  => read_data,
            address    => ALUResult( 7 DOWNTO 0 ),
            write_data => readData2,
            MemRead    => MemRead,
            MemWrite   => MemWrite,
            clock      => clock,
            reset      => reset
          );
END exec;