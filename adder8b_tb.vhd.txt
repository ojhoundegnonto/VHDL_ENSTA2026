-----------------------------------------------------------------
-- This file was generated automatically by vhdl_tb Ruby utility
-- date : (d/m/y) 05/11/2018 15:40
-- Author : Jean-Christophe Le Lann - 2014
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder8b_tb is
end entity;

architecture bhv of adder8b_tb is

  constant HALF_PERIOD : time := 5 ns;

  signal clk     : std_logic := '0';
  signal reset_n : std_logic := '0';
  signal sreset  : std_logic := '0';
  signal running : boolean   := true;

  procedure wait_cycles(n : natural) is
   begin
     for i in 1 to n loop
       wait until rising_edge(clk);
     end loop;
   end procedure;

  signal a    : std_logic_vector(7 downto 0);
  signal b    : std_logic_vector(7 downto 0);
  signal sum  : std_logic_vector(7 downto 0);
  signal cout : std_logic;

begin
  -------------------------------------------------------------------
  -- clock and reset
  -------------------------------------------------------------------
  reset_n <= '0','1' after 666 ns;

  clk <= not(clk) after HALF_PERIOD when running else clk;

  --------------------------------------------------------------------
  -- Design Under Test
  --------------------------------------------------------------------
  dut : entity work.adder8b(structural)

        port map (
          a    => a   ,
          b    => b   ,
          sum  => sum ,
          cout => cout
        );

  --------------------------------------------------------------------
  -- sequential stimuli
  --------------------------------------------------------------------
  stim : process
    variable expected_sum : signed(7 downto 0);
    variable nb_errors : natural := 0;
    function str(v : std_logic_vector(7 downto 0)) return String is
    begin
      return integer'image(to_integer(unsigned(v)));
    end ;

   begin
     a <= (others=>'0');
     b <= (others=>'0');
     report "running testbench for adder8b(structural)";
     report "waiting for asynchronous reset";
     wait until reset_n='1';
     wait_cycles(10);
     report "applying stimuli...";
     for i in 0 to 255 loop
       for j in 0 to 255 loop
         wait until rising_edge(clk);
         a <= std_logic_vector(to_unsigned(i,8));
         b <= std_logic_vector(to_unsigned(j,8));
         expected_sum := signed(a)+signed(b);
         if expected_sum /= signed(sum) then
           report "ERROR for sum : " & str(a) & "+" & str(b);
           report "expecting " & str(std_logic_vector(expected_sum)) & ". Got " & str(sum);
           nb_errors:=nb_errors+1;
         else
           report "OK for sum : " & str(a) & "+" & str(b);
         end if;
       end loop;
     end loop;

     wait_cycles(100);
     a <= std_logic_vector(to_signed(45,8));
     b <= std_logic_vector(to_signed(-48,8));
     wait_cycles(100);
     report "end of simulation";
     report "number of errors detected : " & integer'image(nb_errors);
     running <=false;
     wait;
   end process;

end bhv;
