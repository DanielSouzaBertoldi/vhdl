-- control module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
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
        Jump            : OUT   STD_LOGIC;
        Jal             : OUT   STD_LOGIC;
        Jr              : OUT   STD_LOGIC;
        Sl              : OUT   STD_LOGIC;
        Sr              : OUT   STD_LOGIC;
        -- *** Acrescentar a linha abaixo a sua unidade para selecionar as operações
        -- Será mapeado para o execute
        ALUOp           : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 )
      );
END control;

ARCHITECTURE behavior OF control IS

  SIGNAL R_format : STD_LOGIC;
  SIGNAL SW       : STD_LOGIC;
  SIGNAL LW       : STD_LOGIC;
  SIGNAL ADDi     : STD_LOGIC;

  BEGIN
    -- Code to generate control signals using opcode bits
    R_format    <= '1'  WHEN Opcode = "000000" ELSE '0';
    SW          <= '1'  WHEN Opcode = "101011" ELSE '0';
    LW          <= '1'  WHEN Opcode = "100011" ELSE '0';
    Beq         <= '1'  WHEN Opcode = "000100" ELSE '0';
    Bne         <= '1'  WHEN Opcode = "000101" ELSE '0';
    Jump        <= '1'  WHEN Opcode = "000010" ELSE '0';
    Jal         <= '1'  WHEN Opcode = "000011" ELSE '0';
    ADDi        <= '1'  WHEN Opcode = "001000" ELSE '0';
    Jr          <= '1'  WHEN R_format = '1' AND Function_opcode = "001000" ELSE '0';
    Sl          <= '1'  WHEN R_format = '1' AND Function_opcode = "000000" ELSE '0';
    Sr          <= '1'  WHEN R_format = '1' AND Function_opcode = "000010" ELSE '0';
    
    RegDst      <=  R_format;
    RegWrite    <=  R_format OR LW OR ADDi;
    ALUSrc      <=  LW OR SW OR ADDi;
    MemToReg    <=  LW;
    MemRead     <=  LW;
    MemWrite    <=  SW;

    -- *** ACRESCENTE AS ATRIBUIÇÕES ABAIXO
    ALUOp( 1 )  <=  R_format;
    ALUOp( 0 )  <=  Beq OR Bne; -- Beq deve ser 1 quando a instrução for BEQ (BNE também)
END behavior;