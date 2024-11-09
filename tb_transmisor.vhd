
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_transmisor IS
END tb_transmisor;
 
ARCHITECTURE behavior OF tb_transmisor IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Transmitter
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         trign : IN  std_logic;
         dato : IN  std_logic_vector(0 to 7);
         so : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal trign : std_logic := '0';
   signal dato : std_logic_vector(0 to 7) := (others => '0');

 	--Outputs
   signal so : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Transmitter PORT MAP (
          rst => rst,
          clk => clk,
          trign => trign,
          dato => dato,
          so => so
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
      -- hold reset state for 100 ns.
      wait for 100 ns;
		rst <= '0';
		wait for 100 ns;
		
		rst <= '1';
		trign <= '1';
		dato <= "11110000";
		--dato <= "10101010";
		wait for 100 ns;
		
		trign <= '0';
		wait for 100 ns;
		trign <= '1';

      wait;
   end process;

END;
