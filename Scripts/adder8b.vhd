library ieee;
use ieee.std_logic_1164.all; -- fournit les types logiques standards std_logic et std_logic_vector, ainsi que la fonction rising_edge
----------------------------- NB: std_logic_vector n’est pas un nombre. C’est un tableau de bits. 
------------------------------    Pour faire une addition, on le convertit en unsigned, on calcule, puis on reconvertit en std_logic_vector
use ieee.numeric_std.all; -- fournit les types numériques unsigned/signed et les conversions
---------------------------- C’est la bibliothèque recommandée pour l’arithmétique, contrairement aux anciens paquets non normalisés
-- Declaration of the entity
entity adder8b is
    port (
        a, b : in std_logic_vector(7 downto 0);  -- Input signals
        cin : in std_logic;  -- Carry input
        sum : out std_logic_vector(7 downto 0);  -- Sum output
        cout : out std_logic  -- Carry output
    );
end entity adder8b;
-- Architecture definition
architecture internal_logic of adder8b is
    -- signal <name> : <type> := <default_value>;
    signal co : std_logic_vector(7 downto 0);
begin
    -- internal structure of the 8-bit adder
    -- Instantiate eight full adders and connect them to form an 8-bit adder
    fa0 : entity work.fa(internal_logic)
    port map(
        a => a(0),
        b => b(0),
        cin => '0',
        s => sum(0),
        cout => co(0)
        );
    fa1 : entity work.fa(internal_logic)
    port map(
        a => a(1),
        b => b(1),
        cin => co(0),
        s => sum(1),
        cout => co(1)
        );
    fa2 : entity work.fa(internal_logic)
    port map(
        a => a(2),
        b => b(2),
        cin => co(1),
        s => sum(2),
        cout => co(2)
        );
    fa3 : entity work.fa(internal_logic)
    port map(
        a => a(3),
        b => b(3),
        cin => co(2),
        s => sum(3),
        cout => co(3)
        );
    fa4 : entity work.fa(internal_logic)
    port map(
        a => a(4),
        b => b(4),
        cin => co(3),
        s => sum(4),
        cout => co(4)
        );
    fa5 : entity work.fa(internal_logic)
    port map(
        a => a(5),
        b => b(5),
        cin => co(4),
        s => sum(5),
        cout => co(5)
        );
    fa6 : entity work.fa(internal_logic)
    port map(
        a => a(6),
        b => b(6),
        cin => co(5),
        s => sum(6),
        cout => co(6)
        );
    fa7 : entity work.fa(internal_logic)
    port map(
        a => a(7),
        b => b(7),
        cin => co(6),
        s => sum(7),
        cout => co(7)
        );
    cout <= co(7);  -- Carry output
end architecture internal_logic;