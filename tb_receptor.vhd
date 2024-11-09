LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_receptor IS
END tb_receptor;
 
ARCHITECTURE behavior OF tb_receptor IS 
 
    COMPONENT receptor
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         input : IN  std_logic;
         ready : OUT  std_logic;
         dato : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal input : std_logic := '1';

 	--Outputs
   signal ready : std_logic;
   signal dato : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: receptor PORT MAP (
          clk => clk,
          rst => rst,
          input => input,
          ready => ready,
          dato => dato
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
		input <= '1';
		wait for 4415 ns;
		
		rst <= '1';
		wait for 100 ns;
		
		input <= '0';   -- start
		wait for 4200 ns;
		
		input <= '1';   -- 4345 ns
		wait for 16800 ns;
		
		input <= '0';
		wait for 16800 ns;
		
		input <= '1';
		wait for 21020 ns;
		
		
		
		
		
--		input <= '0';
--		wait for 4345 ns;
--		
--		input <= '1';
--		wait for 4345 ns;
--		
--		input <= '0';
--		wait for 4345 ns;
--		
--		input <= '1';
--		wait for 4345 ns;
--		
--		input <= '0';
--		wait for 4400 ns;
--		
--		input <= '1';    --stop
      wait;
   end process;

END;
