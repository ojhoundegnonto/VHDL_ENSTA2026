#!/bin/bash
# ==============================================================================
# AUTEUR      : Odilon Joël HOUNDEGNONTO (odilon.houndegnonto@gmail.com)
# CRÉATION    : 16 octobre 2026
# VERSION     : 1.0
# DESCRIPTION : script d'analyse et de compilation des fichiers VHDL du projet
# ==============================================================================
echo "=> cleaning previous build artifacts..."
rm -rf adder8b_bt

echo "=> starting VHDL analysis..."
# Analyse des fichiers VHDL
ghdl -a --std=08 ha.vhd # Analyse : vérifie la syntaxe et compile les fichiers VHDL dans la bibliothèque work.
ghdl -a --std=08 fa.vhd
ghdl -a --std=08 adder8b.vhd
ghdl -a --std=08 adder8b_bt.vhd

echo "=> starting VHDL elaboration..."
# Élaboration du testbench
ghdl -e --std=08 adder8b_bt  # Élaboration : construit le modèle exécutable de la hiérarchie complète, ici testbench + DUT.