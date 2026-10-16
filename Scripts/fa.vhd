library ieee;
use ieee.std_logic_1164.all; -- fournit les types logiques standards std_logic
-- Declaration of the entity
entity fa is
    port (
        a, b, cin : in std_logic;  -- Input signals
        s, cout : out std_logic  -- Output signals
    );
end entity fa;
-- Architecture definition
architecture internal_logic of fa is
    -- signal <name> : <type> := <default_value>;
    signal sum_1, cout_1, cout_2 :std_logic;
begin
    -- internal structure of the half adder
    -- Instantiate two half adders and connect them to form a full adder
    --- First half adder to add a and b
    h1 : entity work.ha(internal_logic) 
    port map(
        a => a, 
        b => b, 
        s => sum_1, 
        cout => cout_1
        );
    -- Second half adder to add sum_1 and cin
    h2 : entity work.ha(internal_logic)
    port map(
        a => sum_1,
        b => cin,
        s => s,
        cout => cout_2
        );

    cout <= cout_1 or cout_2;  -- Carry output
end architecture internal_logic;