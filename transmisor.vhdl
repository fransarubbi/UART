library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Transmitter is port(
       rst   : in  std_logic;
       clk   : in  std_logic;
       trign : in  std_logic;
       dato  : in  std_logic_vector(7 downto 0);
       so    : out std_logic
       );
end entity Transmitter;

architecture rtlTx of Transmitter is

-- Senales del Registro D                             
signal DReg   : std_logic_vector(7 downto 0);
signal DInput : std_logic_vector(7 downto 0);
signal DWrite : std_logic;

-- Senales del Prescaler                               
signal PrescalerReg      : std_logic_vector(4 downto 0);  --27
signal PrescalerRegInput : std_logic_vector(4 downto 0);
signal PrescalerZero     : std_logic;
signal enable_pre : std_logic;

-- Senales del Shifter                                 
signal ShShifterReg   : std_logic_vector(9 downto 0);
signal ShShifterInput : std_logic_vector(9 downto 0);
signal shShifterWrite : std_logic;

-- Senales Cont10                                      
constant cZero             : std_logic_vector(3 downto 0):= "0000";
constant cNueve            : std_logic_vector(3 downto 0):= "1001";
signal Cont10Load          : std_logic;
signal Cont10Last          : std_logic;
signal Cont10CuentaInput   : std_logic_vector(0 to 3);
signal Cont10CuentaReg     : std_logic_vector(0 to 3);
signal Cont10CuentaWrite   : std_logic;

-- Senales Cont16                                      
constant cQuince           : std_logic_vector(0 to 3):="1111";
signal Cont16CuentaInput   : std_logic_vector(0 to 3);
signal Cont16CuentaReg     : std_logic_vector(0 to 3);
signal Cont16CuentaWrite   : std_logic;
signal Cont16Pulso15       : std_logic;
signal Cont16Zero : std_logic;

-- Senales 
type state is (init, runing, stop);
signal s_present, s_future : state;
signal run : std_logic;
signal load : std_logic;
signal last : std_logic;
signal she : std_logic;

begin
	load   <= Cont10Load;
	last   <= Cont10Last;
	she    <= Cont16Pulso15;
	DInput <= dato;
	DWrite <= trign;
	
	-- Prescaler 
	PrescalerZero <= '1' when PrescalerReg = "00000" else '0';
	PrescalerRegInput <= "11011" when PrescalerZero = '1' else
								PrescalerReg - '1' when enable_pre = '1' else PrescalerReg;
	
	-- Shifter                              
	ShShifterInput <= '0'&DReg&'1' when Cont10CuentaReg = "0000" else
							ShShifterReg(8 downto 0)&'0' when she = '1' and Cont10Load = '0' else ShShifterReg;
	
	ShShifterWrite <= Cont16Pulso15;
	so <= ShShifterReg(9);

	-- Cont 10                               
	Cont10CuentaInput  <= cZero when Cont10CuentaReg = "1010" else
                      Cont10CuentaReg + '1';
							 
	Cont10CuentaWrite  <= Cont16Pulso15;  -- Habilita la escritura del cont10 cuando cont16 = 15
	Cont10Load <= '1' when Cont10CuentaReg = cZero  else '0'; -- Load vale 1 cuado cont10 es 0
	Cont10Last <= '1' when Cont10CuentaReg = "1001" else '0'; -- Load vale 1 cuado cont10 es 9

	-- Cont 16                               
	Cont16Zero <= '1' when Cont16CuentaReg = cQuince else '0';
	Cont16CuentaInput <= cZero when Cont16Zero = '1' else
								Cont16CuentaReg + '1' when PrescalerZero = '1' else Cont16CuentaReg;
	
	Cont16CuentaWrite <= run;
	Cont16Pulso15 <= '1' when Cont16CuentaReg = cQuince else '0'; -- Avisa cuando el cont16 vale 15

	-- Maquina Estados                          
	fsm1:process(s_present,Cont10Last,Cont10CuentaReg,trign)
	begin
		enable_pre <= '0';
		run <= '0';
		s_future <= s_present;
		case s_present is
			when init =>
				if Cont10Last = '0' and trign = '0' then
					s_future <= runing;
				end if;
				
			when runing =>
				run <= '1';
				enable_pre <= '1';
				if Cont10Last = '1' and trign = '1' then
					s_future <= stop;
				end if;
			
			when stop =>
				enable_pre <= '1';
				run <= '1';
				if Cont10CuentaReg = "1010" then
					run <= '0';
					enable_pre <= '0';
				end if;
		end case;
	end process fsm1;


	-- Cambio de Estado                                     
	write: process(rst,clk)
	begin
		if rst = '0' then
			PrescalerReg <= (others => '0');
			s_present <= init;
		elsif clk = '1' and clk'event then
			PrescalerReg <= PrescalerRegInput;
			s_present <= s_future;
		end if;
	end process;

	write1: process(clk,rst,ShShifterWrite,Cont10CuentaWrite,Cont16CuentaWrite)
	begin
		if rst = '0' then
			ShShifterReg <= (others => '1');
			Cont10CuentaReg <= cZero; 
			Cont16CuentaReg <= cZero;
		elsif clk = '1' and clk'event then
			if ShShifterWrite = '1' then 
				ShShifterReg <= ShShifterInput;
			end if;
			if Cont10CuentaWrite = '1' then
				Cont10CuentaReg <= Cont10CuentaInput;
			end if;
			if Cont16CuentaWrite = '1' then 
				Cont16CuentaReg <= Cont16CuentaInput;
			end if;
		end if;
	end process;

	write2: process(rst,clk,DWrite)
	begin
		if rst = '0' then
			DReg <= (others => '0');
		elsif clk = '1' and clk'event then
			if DWrite = '0' then        
				DReg <= DInput;
			end if;
		end if;
	end process;

end architecture rtlTx;