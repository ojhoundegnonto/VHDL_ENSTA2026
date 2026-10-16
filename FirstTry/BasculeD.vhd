library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--- declation entity
entity basculeD is
    port(
        reset_n : in std_logic;
        clk     : in std_logic;
        Q       : in std_logic;
        D       : out std_logic
    );
end entity basculeD;
--- building architecture
architecture inlogic of basculeD is
begin
    process(reset_n,clk)
    begin
        if reset_n = '0' then
            D <= '0';
        elsif rising_edge(clk) then
            D <= Q;
        end if;
    end process ;
end architecture inlogic;