library ieee;
use ieee.std_logic_1164.all;
----------------------------------------------------
--- entity: defining the entity part of the programm
entity half_adder is
    port(
        a    : in std_logic;
        b    : in std_logic;
        sum  : out std_logic;
        cout : out std_logic
        );
end entity half_adder;
----------------------------------------------------------------
--- architecture: defining the architecture part of the programm
architecture logic of half_adder is

begin
    sum <= a xor b;
    cout <= a and b;
end logic;