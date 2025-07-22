#!/bin/bash
echo "Installing VMan..."
curl -sSL https://raw.githubusercontent.com/YOURUSERNAME/vman/main/vman.sh -o ~/.vman.sh
echo "source ~/.vman.sh" >> ~/.bashrc
echo "Installation complete! Restart your terminal or run: source ~/.bashrc"
