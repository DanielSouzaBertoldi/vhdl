-- Dmemory module (implements the data
-- memory for the MIPS computer)
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity dmemory is
	port (
		-- Ins
		address : in STD_LOGIC_VECTOR(7 downto 0 );
		write_data : in STD_LOGIC_VECTOR(31 downto 0 );
		MemRead, Memwrite : in STD_LOGIC;
		clock, reset : in STD_LOGIC;
		-- Outs
		read_data : out STD_LOGIC_VECTOR(31 downto 0 )
	);
end dmemory;

architecture behavior of dmemory is
	signal write_clock : STD_LOGIC;
begin
	data_memory : altsyncram
	generic map(
		operation_mode => "SINGLE_PORT", 
		width_a => 32, 
		widthad_a => 8, 
		lpm_type => "altsyncram", 
		outdata_reg_a => "UNREGISTERED", 
		init_file => "dmemory.mif", 
		intended_device_family => "Cyclone"
	)
	port map(
		wren_a => memwrite, 
		clock0 => write_clock, 
		address_a => address, 
		data_a => write_data, 
		q_a => read_data 
	);
	-- Load memory address register with write clock
	write_clock <= not clock;
end behavior;