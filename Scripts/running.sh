#!/bin/bash
# ===================================================================================
# AUTEUR      : Odilon Joël HOUNDEGNONTO (odilon.houndegnonto@gmail.com)
# CRÉATION    : 16 octobre 2026
# VERSION     : 1.0
# DESCRIPTION : script de compilation des fichiers VHDL pour le projet VHDL ENSTA2026
# ===================================================================================
echo "=> cleaning previous build artifacts..."
rm -rf adder8b_bt

echo "=> starting running simulation of the testbench code..."
ghdl -r --std=08 adder8b_bt --wave=waves.ghw # Exécution : lance réellement la simulation.

echo "wave form simulation saved in waves.ghw"
gtkwave waves.ghw display.sav # Visualisation : affiche les chronogrammes contenus dans le fichier VCD