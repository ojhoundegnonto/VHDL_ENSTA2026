library ieee;
use ieee.std_logic_1164.all; -- fournit les types logiques standards std_logic
-- Declaration of the entity
entity ha is
    port (
        a, b : in std_logic;  -- Input signals
        s, cout : out std_logic  -- Output signals
    );
end entity ha;
-- Architecture definition
architecture internal_logic of ha is
begin
    -- internal structure of the half adder
    s <= a xor b;  -- Sum output
    cout <= a and b;  -- Carry output
end architecture internal_logic;