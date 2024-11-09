library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity receptor is
	Port(
		clk : in std_logic;
		rst : in std_logic;
		input : in std_logic;
		ready : out std_logic;
		dato : out std_logic_vector(7 downto 0)
	);
end receptor;

architecture Behavioral of receptor is
	type state is (init, runing, stop);
	signal s_present, s_future : state;

	-- Contador prescaler
	signal CONT_pre_reg : std_logic_vector(4 downto 0);  -- 27
	signal CONT_pre_input : std_logic_vector(4 downto 0);
	
	-- Contador 16
	signal CONT_16_reg : std_logic_vector(3 downto 0);  -- 15
	signal CONT_16_input : std_logic_vector(3 downto 0);
	signal CONT_16_write : std_logic;
	
	-- Contador 9
	signal CONT_10_reg : std_logic_vector(3 downto 0);  -- 9
	signal CONT_10_input : std_logic_vector(3 downto 0);
	signal CONT_10_write : std_logic;
	signal CONT_10_last : std_logic;
	
	-- Registro Dato
	signal data_reg : std_logic_vector(9 downto 0);
	signal data_input : std_logic_vector(9 downto 0);
	signal data_write : std_logic;
	
	-- Controles
	signal c_zero10 : std_logic;
	signal c_zero16 : std_logic;
	signal c_zero_pre : std_logic;
	signal c_enable_pre : std_logic;
	signal run : std_logic;
	signal she : std_logic;
	signal she_prev : std_logic;
	
begin
	-- Prescaler
	c_zero_pre <= '1' when CONT_pre_reg = "00000" else '0';
	CONT_pre_input <= "11011" when c_zero_pre = '1' else
							CONT_pre_reg - '1' when c_enable_pre = '1' else CONT_pre_reg;
	
	-- she
	she <= '1' when CONT_16_reg = "1000" else '0';
	
	-- Contador 16
	c_zero16 <= '1' when CONT_16_reg = "1111" else '0';
	CONT_16_input <= "0000" when c_zero16 = '1' else 
							CONT_16_reg + '1' when c_zero_pre = '1' else CONT_16_reg;
	CONT_16_write <= run;
	
	-- Contador 10
	c_zero10 <= '1' when CONT_10_reg = "0000" else '0';
	CONT_10_input <= "0000" when CONT_10_reg = "1010" else CONT_10_reg + '1'; 
	CONT_10_write <= '1' when CONT_16_reg = "1111" else '0';
	CONT_10_last <= '1' when CONT_10_reg = "1000" else '0';

	-- Registro Datos
	data_input <= data_reg(8 downto 0)&input when she = '1' else data_reg;
	data_write <= '1' when she = '1' and she_prev = '0' else '0';
	
	process(s_present, input, run, CONT_10_last, CONT_10_reg)
	begin
		run <= '0';
		dato <= (others => 'Z');
		ready <= '0';
		c_enable_pre <= '0';
		s_future <= s_present;
		case s_present is
			when init =>
				if input = '0' then
					run <= '1';
					s_future <= runing;
				end if;
			
			when runing =>
				run <= '1';
				c_enable_pre <= '1';
				if run = '1' and CONT_10_last = '1' then
					s_future <= stop;
				end if;
			
			when stop =>
				run <= '1';
				c_enable_pre <= '1';
				if CONT_10_reg = "1001" then
					ready <= '1';
				end if;
				if CONT_10_reg = "1010" then
					run <= '0';
					c_enable_pre <= '0';
					dato <= data_reg(8 downto 1);
				end if;
		end case;
	end process;

	process(clk, rst, CONT_16_write, CONT_10_write, data_write)
	begin
		if rst = '0' then
			CONT_16_reg <= (others => '0');
			CONT_10_reg <= (others => '0');
			data_reg <= (others => '0');
		elsif clk'event and clk = '1' then
			if CONT_16_write = '1' then
				CONT_16_reg <= CONT_16_input;
			end if;
			if CONT_10_write = '1' then
				CONT_10_reg <= CONT_10_input;
			end if;
			if data_write = '1' then
				data_reg <= data_input;
			end if;
		end if;
	end process;
	 
	process(clk, rst)
	begin
		if rst = '0' then
			she_prev <= '0';
			CONT_pre_reg <= "11011";
			s_present <= init;
		elsif clk'event and clk = '1' then
			she_prev <= she;
			CONT_pre_reg <= CONT_pre_input;
			s_present <= s_future;
		end if;
	end process;

end Behavioral;