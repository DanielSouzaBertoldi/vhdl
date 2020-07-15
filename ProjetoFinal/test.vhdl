-- control module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
  PORT( Opcode          : IN  STD_LOGIC_VECTOR( 5 DOWNTO 0 );
        Function_opcode : IN  STD_LOGIC_VECTOR( 5 DOWNTO 0 );
        RegDst          : OUT STD_LOGIC;
        RegWrite        : OUT STD_LOGIC;
        ALUSrc          : OUT STD_LOGIC;
        MemToReg        : OUT STD_LOGIC;
        MemRead         : OUT STD_LOGIC;
        MemWrite        : OUT STD_LOGIC;
        Beq             : INOUT STD_LOGIC;
        Bne             : INOUT STD_LOGIC;
        Jump            : OUT STD_LOGIC;
        Jal             : OUT STD_LOGIC;
        Jr              : OUT STD_LOGIC;
        Sl              : OUT STD_LOGIC;
        Sr              : OUT STD_LOGIC;
        -- *** Acrescentar a linha abaixo a sua unidade para selecionar as operações
        -- Será mapeado para o execute
        ALUOp       : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 ));
END control;