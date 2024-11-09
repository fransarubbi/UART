LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_UART IS
END tb_UART;
 
ARCHITECTURE behavior OF tb_UART IS 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT UART
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         trig : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         rdy : OUT  std_logic
        );
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal trig : std_logic := '1';
   signal data_in : std_logic_vector(7 downto 0) := (others => '1');

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);
   signal rdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: UART PORT MAP (
          clk => clk,
          rst => rst,
          trig => trig,
          data_in => data_in,
          data_out => data_out,
          rdy => rdy
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		rst <= '0';
		wait for 100 ns;
		
		rst <= '1';
		trig <= '1';
		--data_in <= "11110000";
		data_in <= "10101010";
		wait for 100 ns;
		
		trig <= '0';
		wait for 100 ns;
		trig <= '1';
      wait;
   end process;

END;
