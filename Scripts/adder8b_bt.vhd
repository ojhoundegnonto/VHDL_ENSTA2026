library ieee;
use ieee.std_logic_1164.all; -- fournit les types logiques standards std_logic et std_logic_vector, ainsi que la fonction rising_edge
use ieee.numeric_std.all; -- fournit les types numériques unsigned/signed et les conversions comme to_unsigned. 
---------------------------- C’est la bibliothèque recommandée pour l’arithmétique, contrairement aux anciens paquets non normalisés
use std.env.all; -- donne accès aux procédures de contrôle de simulation, notamment stop

--- Declaration of the entity: like a closed laboratory, it has no ports, and is used to test the adder8b entity
entity adder8b_bt is
end entity adder8b_bt;
--- Architecture definition
architecture behavior of adder8b_bt is
    constant Nbits : natural :=8; --- Nbits = 8 signifie que les opérandes et la somme ont 8 bits.

    constant HALF_ADDER : time :=5 ns; --- HALF_ADDER = 5 ns est la demi-période de l’horloge. 
    -------------------------------------- L’horloge change d’état toutes les 5 ns, donc sa période 
    -------------------------------------- complète est de 10 ns, soit une fréquence de 100 MHz

    signal clk : std_logic :='0'; -- clk est l’horloge, initialisée à '0'
    signal reset_n : std_logic := '0'; -- reset_n est le signal de reset asynchrone, initialisé à '0' (reset actif)
    ------------------------------------- reset_n est un reset actif à l’état bas : le suffixe _n signifie negative ou not. 
    ------------------------------------- Tant qu’il vaut '0', le circuit est normalement maintenu en reset ; il est libéré 
    ------------------------------------- lorsqu’il passe à '1'

    procedure wait_cycles (n : natural) is
    -- Cette procédure attend plusieurs fronts montants de l’horloge. Elle rend le testbench plus lisible : au lieu d’écrire 
    -- plusieurs fois wait until rising_edge(clk);, on écrit wait_cycles(10);. a boucle va de 1 à n-1, donc elle attend 
    -- seulement n−1 fronts, pas n fronts. Le front de l’horloge qui déclenche l’appel de la procédure est déjà compté.
    begin
        for i in 1 to n-1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    signal a,b : std_logic_vector(Nbits - 1 downto 0) := x"00"; -- a et b sont les opérandes de l’addition, initialisés à 0.
    signal sum : std_logic_vector(Nbits - 1 downto 0) := x"00"; -- sum est le résultat sur 8 bits de l’addition, initialisé à 0.
    signal cout : std_logic; -- cout est le bit de retenue de l’addition, initialisé à 0 par défaut. Il est utile lorsque a+b dépasse 255.

begin
    -----------------------------
    -- Clock and reset generation
    -----------------------------
    -- reset generation
    reset_n <= '0', '1' after 123 ns; 
    ------ Au temps t=0, reset_n vaut '0' : le circuit est en reset.
    ------ Au temps t=123 ns, reset_n vaut '1' : le circuit est libéré du reset.
    ------ Le temps de 123 ns est choisi arbitrairement, il doit être supérieur à la période de l’horloge (10 ns) pour que le circuit ait le temps de se stabiliser.
    ------ La valeur 123 ns est volontairement inhabituelle. Elle évite que le reset change exactement en même temps qu’un front d’horloge, ce qui peut créer des 
    ------ ambiguïtés de simulation. En pratique, on recommande souvent de changer les signaux asynchrones légèrement après un front d’horloge.
    -- clock generation
    --clock <= not (clk) after HALF_ADDER when running else clk;
    clk <= not(clk) after HALF_ADDER; --- L’horloge clk change d’état toutes les 5 ns, donc sa période complète est de 10 ns, soit une fréquence de 100 MHz.
    ------------------------------------- C’est une affectation concurrente : elle est permanente, hors de tout process.
    ------------------------------------ Fonctionnement :
    ---------------------------------------------------- clk commence à '0'.
    ---------------------------------------------------- Après 5 ns, il devient '1'.
    ---------------------------------------------------- Après 5 autres ns, il redevient '0'.
    ---------------------------------------------------- Et ainsi de suite indéfiniment.
-----------------------------
-- Design Under Test (DUT)
-----------------------------
    dut : entity work.adder8b
    port map(
        a => a,
        b => b,
        cin => '0',
        sum => sum,
        cout => cout
    );
-- "dut" signifie Design Under Test : le circuit que l’on veut vérifier.
-- "work" est la bibliothèque de travail, celle qui contient les fichiers compilés du projet.
-- "entity work.adder8b" désigne l’entité adder8b.
-- "port map" relie les signaux du testbench aux ports du DUT.
-- NB: Le testbench ne connaît pas forcément le fonctionnement interne de adder8b : il le considère 
------ comme une boîte noire et vérifie seulement son comportement externe.
---------------------------------
-- Sequential stimulus generation
---------------------------------
stim: process
    variable expected : std_logic_vector(Nbits - 1 downto 0); -- expected est la valeur attendue de la somme, calculée par le testbench.
    variable nb_tests : natural := 0; -- nb_tests est le nombre de tests effectués, initialisé à 0.
    variable nb_errors : natural := 0; -- nb_errors est le nombre d’erreurs détectées, initialisé à 0.
begin
    report "running testbench for adder()";
    report "waiting for asynchronous reset to be deasserted";
    wait until reset_n = '1';
    -- report "reset deasserted, starting tests";
    wait_cycles(10);
---- Notes: Le testbench affiche d’abord des messages dans la console. Puis il attend que reset_n devienne '1', 
----------- c’est-à-dire que le circuit sorte du reset. Ensuite, il attend quelques cycles d’horloge pour 
----------- laisser le circuit se stabiliser avant de commencer les tests.
    for a_int in 0 to 100 loop
        for b_int in 0 to 100 loop
            nb_tests := nb_tests + 1;
            report "testing " & integer'image(a_int) & " + " & integer'image(b_int);
            a <= std_logic_vector(to_unsigned(a_int, Nbits));
            b <= std_logic_vector(to_unsigned(b_int, Nbits));
            -- Notes: Le testbench effectue deux boucles imbriquées pour tester toutes les combinaisons de a et b de 0 à 100.
            -- Il convertit les entiers a_int et b_int en vecteurs de bits std_logic_vector de 8 bits, puis les affecte aux signaux a et b.
            -------- Étape par étape :
            ------------------------- a_int est un entier VHDL, par exemple 25.
            ------------------------- to_unsigned(a_int, Nbits) le convertit en nombre non signé de 8 bits.
            ------------------------- std_logic_vector(...) convertit ce nombre en vecteur de bits.
            ------------------------- Le signal a reçoit finalement la valeur binaire correspondante.
            expected := std_logic_vector(to_unsigned(a_int + b_int, Nbits));
            wait until rising_edge(clk); -- Le testbench attend un front montant de l’horloge pour que le DUT ait le temps de calculer la somme.
            if sum /= expected then -- /= signifie « différent de » (Si sum est différent de expected, le test échoue.)
                nb_errors := nb_errors + 1; -- comptage du nombre d’erreurs
                report "bug : expecting 0x" & to_hstring(expected) & ". Got : 0x" & to_hstring(sum);
                -- Notes: "to_hstring" convertit le vecteur de bits en chaîne hexadécimale lisible (0x)
            end if;
        end loop; -- end of the second loop
    end loop; -- end of the first loop
    
    report "number of tests run : " & integer'image(nb_tests); -- affiche le nombre de tests effectués après les deux boucles imbriquées.
    report "number of errors : " & integer'image(nb_errors); -- affiche le nombre d’erreurs détectées après les deux boucles imbriquées.

    wait_cycles(200); -- il attend 200 cycles, affiche les messages de fin et appelle stop

    report "testbench finished";
    report "end of simulation";
    stop; -- stop est une procédure de la bibliothèque std.env qui arrête la simulation depuis le testbench.
end process stim;

end architecture behavior;