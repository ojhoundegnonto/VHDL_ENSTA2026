# Explication détaillée d’un testbench VHDL : `adder8b_bt`

Ce code est un **testbench VHDL** : il ne décrit pas un circuit à synthétiser, mais un « laboratoire de simulation » qui applique des entrées à un additionneur 8 bits, observe sa sortie et vérifie automatiquement si elle est correcte.

C’est un excellent exemple pour découvrir VHDL, car il montre les deux faces du langage :

- VHDL permet de **décrire du matériel** : ici, l’additionneur `adder8b`.
- VHDL permet aussi de **vérifier ce matériel** : ici, le testbench `adder8b_bt`.

## Rôle général du code

Le testbench s’appelle `adder8b_bt` et teste une entité nommée `adder8b`, qui réalise vraisemblablement :

\[
\{cout, sum\} = a + b + cin
\]

Ici, `cin` est fixé à `'0'`, donc le test vérifie simplement :

\[
sum = a + b
\]

Le testbench génère l’horloge, libère le reset, fait varier `a` et `b` de 0 à 100, puis compare la sortie `sum` à la valeur attendue.

## Code analysé

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;


-- Declaration of the entity: like a closed laboratory, it has no ports,
-- and is used to test the adder8b entity
entity adder8b_bt is
end entity adder8b_bt;

-- Architecture definition
architecture behavior of adder8b_bt is
    constant Nbits : natural := 8;

    constant HALF_ADDER : time := 5 ns;

    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';

    procedure wait_cycles (n : natural) is
    begin
        for i in 1 to n-1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    signal a, b : std_logic_vector(Nbits - 1 downto 0) := x"00";
    signal sum : std_logic_vector(Nbits - 1 downto 0) := x"00";
    signal cout : std_logic;
begin
    -----------------------------
    -- Clock and reset generation
    -----------------------------
    reset_n <= '0', '1' after 123 ns;
    clk <= not(clk) after HALF_ADDER;

    -----------------------------
    -- Design Under Test (DUT)
    -----------------------------
    dut : entity work.adder8b
    port map(
        a   => a,
        b   => b,
        cin => '0',
        sum => sum,
        cout => cout
    );

    ---------------------------------
    -- Sequential stimulus generation
    ---------------------------------
    stim: process
        variable expected : std_logic_vector(Nbits - 1 downto 0);
        variable nb_tests : natural := 0;
        variable nb_errors : natural := 0;
    begin
        report "running testbench for adder()";
        report "waiting for asynchronous reset to be deasserted";
        wait until reset_n = '1';
        wait_cycles(10);

        for a_int in 0 to 100 loop
            for b_int in 0 to 100 loop
                nb_tests := nb_tests + 1;
                report "testing " & integer'image(a_int)
                     & " + " & integer'image(b_int);

                a <= std_logic_vector(to_unsigned(a_int, Nbits));
                b <= std_logic_vector(to_unsigned(b_int, Nbits));
                expected := std_logic_vector(to_unsigned(a_int + b_int, Nbits));

                wait until rising_edge(clk);

                if sum /= expected then
                    nb_errors := nb_errors + 1;
                    report "bug : expecting 0x" & to_hstring(expected)
                         & ". Got : 0x" & to_hstring(sum);
                end if;
            end loop;
        end loop;

        report "number of tests run : " & integer'image(nb_tests);
        report "number of errors : " & integer'image(nb_errors);

        wait_cycles(200);

        report "testbench finished";
        report "end of simulation";
        stop;
    end process stim;

end architecture behavior;
```

## Les bibliothèques utilisées

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
```

| Bibliothèque | Rôle |
|---|---|
| `ieee.std_logic_1164` | Fournit les types logiques `std_logic` et `std_logic_vector`, ainsi que `rising_edge`. |
| `ieee.numeric_std` | Fournit les types numériques `unsigned` et `signed`, ainsi que les conversions comme `to_unsigned`. |
| `std.env` | Fournit des procédures de contrôle de simulation, notamment `stop`. |

### Point important pour les étudiants

Un `std_logic_vector` n’est **pas un nombre** : c’est un tableau de bits.

Pour faire une addition, on doit :

1. Convertir le vecteur de bits en nombre non signé avec `unsigned`.
2. Effectuer le calcul.
3. Reconvertir le résultat en `std_logic_vector`.

C’est précisément ce que fait la ligne :

```vhdl
expected := std_logic_vector(to_unsigned(a_int + b_int, Nbits));
```

## L’entité de test

```vhdl
entity adder8b_bt is
end entity adder8b_bt;
```

Une entité VHDL normale possède des ports : entrées et sorties physiques.

Ici, il n’y a **aucun port**, car un testbench n’est pas connecté au monde extérieur : il est lui-même le monde extérieur.

Le testbench :

- génère les entrées `a` et `b` ;
- génère l’horloge `clk` ;
- génère le reset `reset_n` ;
- observe les sorties `sum` et `cout`.

### Circuit réel et testbench

| Circuit réel | Testbench |
|---|---|
| Reçoit des entrées | Génère les entrées |
| Produit des sorties | Observe les sorties |
| Doit être synthétisable | Ne doit pas être synthétisé |
| Décrit le matériel | Décrit le scénario de test |
| Décrit ce que fait le circuit | Vérifie que le circuit fait bien ce qui est attendu |

## Les constantes

```vhdl
constant Nbits : natural := 8;
constant HALF_ADDER : time := 5 ns;
```

- `Nbits = 8` signifie que les opérandes et la somme ont 8 bits.
- `HALF_ADDER = 5 ns` est la demi-période de l’horloge.
- L’horloge change d’état toutes les 5 ns, donc sa période complète est de 10 ns.
- La fréquence d’horloge correspondante est donc de 100 MHz.

Utiliser des constantes est une bonne pratique : pour tester un additionneur 16 bits, il suffirait de modifier une seule ligne.

## Les signaux du testbench

```vhdl
signal clk : std_logic := '0';
signal reset_n : std_logic := '0';

signal a, b : std_logic_vector(Nbits - 1 downto 0) := x"00";
signal sum : std_logic_vector(Nbits - 1 downto 0) := x"00";
signal cout : std_logic;
```

| Signal | Rôle |
|---|---|
| `clk` | Horloge du système. |
| `reset_n` | Reset actif à l’état bas. |
| `a` | Premier opérande sur 8 bits. |
| `b` | Second opérande sur 8 bits. |
| `sum` | Somme sur 8 bits produite par le circuit testé. |
| `cout` | Retenue de sortie. |

### Le reset actif bas

Le nom `reset_n` contient le suffixe `_n`, qui signifie *negative* ou *not*.

- Lorsque `reset_n = '0'`, le circuit est en reset.
- Lorsque `reset_n = '1'`, le circuit fonctionne normalement.

C’est une convention très fréquente en électronique numérique.

### Exemple de dépassement

Avec des opérandes sur 8 bits, la valeur maximale est 255.

Si l’on calcule :

\[
200 + 100 = 300
\]

le résultat ne tient pas sur 8 bits.

Le circuit renvoie alors :

- `sum = 44`, qui correspond aux 8 bits de poids faible de 300 ;
- `cout = '1'`, qui indique qu’il y a une retenue.

## La procédure `wait_cycles`

```vhdl
procedure wait_cycles (n : natural) is
begin
    for i in 1 to n-1 loop
        wait until rising_edge(clk);
    end loop;
end procedure wait_cycles;
```

Cette procédure attend plusieurs fronts montants de l’horloge.

Elle rend le testbench plus lisible : au lieu d’écrire plusieurs fois :

```vhdl
wait until rising_edge(clk);
```

on écrit simplement :

```vhdl
wait_cycles(10);
```

### Attention : petite erreur dans le code

La boucle est écrite ainsi :

```vhdl
for i in 1 to n-1 loop
```

Elle attend donc seulement `n - 1` fronts montants, et non `n` fronts montants.

Pour attendre réellement `n` fronts montants, il faudrait écrire :

```vhdl
for i in 1 to n loop
    wait until rising_edge(clk);
end loop;
```

C’est un bon exemple à montrer aux étudiants : un testbench doit être aussi rigoureux que le circuit qu’il teste.

## Génération du reset

```vhdl
reset_n <= '0', '1' after 123 ns;
```

Cette affectation signifie :

1. Au temps \(t = 0\), `reset_n` vaut `'0'` : le circuit est en reset.
2. À \(t = 123\) ns, `reset_n` passe à `'1'` : le reset est relâché.

La valeur 123 ns est volontairement inhabituelle. Elle évite que le reset change exactement au même instant qu’un front d’horloge, ce qui peut créer des ambiguïtés de simulation.

## Génération de l’horloge

```vhdl
clk <= not(clk) after HALF_ADDER;
```

C’est une affectation **concurrente** : elle est permanente et se trouve en dehors de tout `process`.

Fonctionnement :

1. `clk` commence à `'0'`.
2. Après 5 ns, il devient `'1'`.
3. Après 5 autres ns, il redevient `'0'`.
4. Le processus se répète indéfiniment.

La période de l’horloge est donc :

\[
T = 5\ \text{ns} + 5\ \text{ns} = 10\ \text{ns}
\]

La fréquence est :

\[
f = \frac{1}{T} = 100\ \text{MHz}
\]

### Représentation temporelle

```text
clk : 0 ──┐5 ns┌──┐5 ns┌──┐5 ns┌──
          └────┘  └────┘  └────┘
```

Le front montant correspond au passage de `'0'` à `'1'`.

## Connexion du circuit testé

```vhdl
dut : entity work.adder8b
port map(
    a   => a,
    b   => b,
    cin => '0',
    sum => sum,
    cout => cout
);
```

`dut` signifie **Design Under Test** : le circuit que l’on veut vérifier.

- `work` est la bibliothèque de travail, celle qui contient les fichiers compilés du projet.
- `entity work.adder8b` désigne l’entité `adder8b`.
- Le `port map` relie les signaux du testbench aux ports du DUT.

### Schéma de connexion

```text
Testbench                     DUT : adder8b
-----------                   -------------
a    -----------------------> a
b    -----------------------> b
'0'  -----------------------> cin
sum  <----------------------- sum
cout <----------------------- cout
```

Le testbench ne connaît pas forcément le fonctionnement interne de `adder8b`. Il le considère comme une boîte noire et vérifie uniquement son comportement externe.

## Le processus de stimulation

```vhdl
stim: process
```

Un `process` est une partie séquentielle du code VHDL.

Dans un testbench, il sert à décrire une chronologie :

1. Attendre la fin du reset.
2. Appliquer une valeur à `a`.
3. Appliquer une valeur à `b`.
4. Attendre un front d’horloge.
5. Vérifier la sortie `sum`.
6. Répéter l’opération pour d’autres valeurs.

## Les variables locales

```vhdl
variable expected : std_logic_vector(Nbits - 1 downto 0);
variable nb_tests : natural := 0;
variable nb_errors : natural := 0;
```

| Variable | Rôle |
|---|---|
| `expected` | Contient la somme théorique calculée par le testbench. |
| `nb_tests` | Compte le nombre de cas testés. |
| `nb_errors` | Compte le nombre d’échecs détectés. |

### Différence entre signal et variable

| `signal` | `variable` |
|---|---|
| Représente un fil ou un registre | Représente une valeur locale de calcul |
| Mise à jour après un delta cycle | Mise à jour immédiatement |
| Utilisée pour communiquer entre processus | Utilisée dans un processus |
| Adaptée à la description matérielle | Adaptée au testbench et aux calculs intermédiaires |

## Attente du reset

```vhdl
report "running testbench for adder()";
report "waiting for asynchronous reset to be deasserted";
wait until reset_n = '1';
wait_cycles(10);
```

Le testbench affiche d’abord des messages dans la console.

Puis il attend que `reset_n` devienne `'1'`, c’est-à-dire que le circuit sorte du reset.

Ensuite, il attend quelques cycles d’horloge pour laisser le circuit se stabiliser avant de commencer les tests.

## Les boucles de test

```vhdl
for a_int in 0 to 100 loop
    for b_int in 0 to 100 loop
```

Il y a deux boucles imbriquées :

- La boucle externe fait varier `a` de 0 à 100.
- La boucle interne fait varier `b` de 0 à 100.

Le nombre total de tests est donc :

\[
101 \times 101 = 10201
\]

Ce n’est pas une vérification exhaustive de toutes les paires possibles sur 8 bits, qui serait :

\[
256 \times 256 = 65536
\]

Mais c’est déjà une vérification automatique très utile.

## Conversion des valeurs numériques

```vhdl
a <= std_logic_vector(to_unsigned(a_int, Nbits));
b <= std_logic_vector(to_unsigned(b_int, Nbits));
expected := std_logic_vector(to_unsigned(a_int + b_int, Nbits));
```

Étape par étape :

1. `a_int` est un entier VHDL, par exemple 25.
2. `to_unsigned(a_int, Nbits)` le convertit en nombre non signé de 8 bits.
3. `std_logic_vector(...)` convertit ce nombre en vecteur de bits.
4. Le signal `a` reçoit finalement la valeur binaire correspondante.

### Exemple avec `a_int = 25`

\[
25 = 00011001_2
\]

Donc :

```vhdl
a <= "00011001";
```

### Exemple avec `a_int = 25` et `b_int = 10`

\[
25 + 10 = 35
\]

\[
35 = 00100011_2
\]

Donc :

```vhdl
expected := "00100011";
```

## Vérification du résultat

```vhdl
wait until rising_edge(clk);

if sum /= expected then
    nb_errors := nb_errors + 1;
    report "bug : expecting 0x" & to_hstring(expected)
         & ". Got : 0x" & to_hstring(sum);
end if;
```

Le testbench attend le prochain front montant, laisse le DUT produire sa sortie, puis compare `sum` à `expected`.

- `/=` signifie « différent de ».
- Si `sum` est différent de `expected`, le test échoue.
- `to_hstring` convertit le vecteur de bits en chaîne hexadécimale lisible.
- `&` concatène les chaînes de caractères.

### Exemple de message d’erreur

```text
bug : expecting 0x23. Got : 0x22
```

Cela signifie que le test attendait 35, soit `0x23`, mais que le circuit a produit 34, soit `0x22`.

## Bilan et arrêt de la simulation

```vhdl
report "number of tests run : " & integer'image(nb_tests);
report "number of errors : " & integer'image(nb_errors);

wait_cycles(200);

report "testbench finished";
report "end of simulation";
stop;
```

Après les 10 201 tests, le testbench affiche :

- le nombre total de tests ;
- le nombre d’erreurs détectées.

Puis il attend 200 cycles, affiche les messages de fin et appelle `stop`.

La procédure `stop` provient de `std.env` et sert à arrêter la simulation depuis le testbench.

## Résumé pédagogique

Ce code illustre la philosophie de la vérification numérique :

1. **Décrire le circuit** dans `adder8b`.
2. **Créer un environnement de test** dans `adder8b_bt`.
3. **Appliquer des stimulis** : `a`, `b`, horloge, reset.
4. **Calculer un résultat de référence** : `expected`.
5. **Comparer automatiquement** la réponse du circuit à la référence.
6. **Compter et signaler les erreurs**.

C’est exactement la base du métier de conception numérique : on ne se contente pas de dire « cela devrait marcher » ; on construit un testbench qui le prouve, automatiquement et de façon reproductible.

## Améliorations possibles

Pour rendre ce testbench plus robuste, on pourrait :

- corriger `wait_cycles` afin d’attendre exactement `n` fronts montants ;
- tester toutes les valeurs de 0 à 255 pour `a` et `b` ;
- vérifier aussi `cout` lorsque `a + b > 255` ;
- ajouter des cas avec `cin = '1'` ;
- utiliser des assertions `assert` en plus des messages `report` ;
- écrire les résultats dans un fichier de log ;
- séparer les tests simples, les tests de débordement et les tests aléatoires.

### Exemple d’assertion

```vhdl
assert sum = expected
    report "Erreur : somme incorrecte"
    severity error;
```

Cette forme est très utilisée en VHDL : elle exprime directement l’exigence à vérifier.
