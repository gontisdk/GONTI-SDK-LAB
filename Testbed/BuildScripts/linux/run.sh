#!/bin/bash

# Ustawienie zmiennych środowiskowych (kluczowe na Linuxie)
source /opt/Vulkan/1.4.335.0/setup-env.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.

echo -e "\n\n"
echo "========================================================================================================================"
echo "========================================================================================================================"
echo "========================================================================================================================"
echo -e "\n\n\n"

# Pobieranie inputu od użytkownika
read -p "Enter command (run/quit): " userInput

# Konwersja do małych liter dla łatwiejszego porównania
userInput=$(echo "$userInput" | tr '[:upper:]' '[:lower:]')

if [[ "$userInput" == "run" || "$userInput" == "r" ]]; then
    echo -e "\n\nStarting program...\n"
    echo "================================"
    echo "====    START OF PROGRAM    ===="
    echo "================================"
    echo -e "\n\n"

    # Uruchomienie testbed 
    # Zmienna $assembly jest przekazana
    ./testbed | tee "../Logs/log_$(date +'%Y-%m-%d_%H-%M-%S').log"

    echo -e "\n\n\n"
    echo "================================"
    echo "====     END OF PROGRAM     ===="
    echo "================================"
    echo -e "\n"
else
    echo "Exiting or invalid value..."
    exit 0
fi