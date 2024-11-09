library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART is
	Port(
		clk : in std_logic;
		rst : in std_logic;
		trig : in std_logic;
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0);
		rdy : out std_logic
	);
end UART;

architecture Behavioral of UART is

	signal line : std_logic;
	--signal dep : std_logic_vector(9 downto 0);

	component Transmitter
		Port(
			rst   : in  std_logic;
			clk   : in  std_logic;
			trign : in  std_logic;
			dato  : in  std_logic_vector(0 to 7);
			so    : out std_logic);
	end component;
	
	component receptor
		Port(
			clk : in std_logic;
			rst : in std_logic;
			input : in std_logic;
			ready : out std_logic;
			--aux : out std_logic_vector(9 downto 0);
			dato : out std_logic_vector(7 downto 0));
	end component;

begin
	u1: Transmitter
		port map (
            clk   => clk,
            rst   => rst,
            trign => trig,
				dato => data_in,
				so => line
        );
	
	u2: receptor
		port map (
            clk   => clk,
            rst   => rst,
            input => line,
				ready => rdy,
				--aux => dep,
				dato => data_out
        );
end Behavioral;