#!/data/data/com.termux/files/usr/bin/bash

# ===============================
# TERMUX AUTOMATION LOGGER TOOL
# Author: TechVyana
# Purpose: Productivity & Learning
# ===============================

LOG_DIR="$HOME/.tlogs"
LOG_FILE="$LOG_DIR/activity.log"
PASS_FILE="$LOG_DIR/.pass"
DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# ---------- COLORS ----------
GREEN="\e[92m"
CYAN="\e[96m"
RED="\e[91m"
YELLOW="\e[93m"
RESET="\e[0m"

# ---------- BANNER ----------
banner() {
clear
echo -e "${GREEN}"
echo " ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗"
echo " ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝"
echo "    ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ "
echo "    ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ "
echo "    ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗"
echo "    ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝"
echo -e "${CYAN}        Automation • Logs • Productivity${RESET}"
echo
}

# ---------- PASSWORD SETUP ----------
if [ ! -f "$PASS_FILE" ]; then
  echo -e "${YELLOW}Set Admin Password:${RESET}"
  read -s PASS
  echo
  echo -n "$PASS" | sha256sum | awk '{print $1}' > "$PASS_FILE"
  echo -e "${GREEN}Password set successfully!${RESET}"
fi

# ---------- AUTH ----------
echo -e "${CYAN}Enter Password:${RESET}"
read -s INPUT
echo
HASH=$(echo -n "$INPUT" | sha256sum | awk '{print $1}')
REAL=$(cat "$PASS_FILE")

if [ "$HASH" != "$REAL" ]; then
  echo -e "${RED}Access Denied!${RESET}"
  exit 1
fi

# ---------- LOGGING ----------
echo "[$DATE_NOW] Tool accessed" >> "$LOG_FILE"

# ---------- MENU ----------
while true; do
banner
echo -e "${CYAN}1️⃣ View Logs"
echo "2️⃣ Daily Summary"
echo "3️⃣ Clear Logs (Protected)"
echo "4️⃣ Exit${RESET}"
echo
read -p "Choose: " CHOICE

case $CHOICE in
1)
  less "$LOG_FILE"
  ;;
2)
  echo -e "${GREEN}Today's Activity:${RESET}"
  grep "$(date '+%Y-%m-%d')" "$LOG_FILE"
  read -p "Press Enter..."
  ;;
3)
  echo -e "${RED}Confirm Password:${RESET}"
  read -s CPASS
  echo
  C_HASH=$(echo -n "$CPASS" | sha256sum | awk '{print $1}')
  if [ "$C_HASH" == "$REAL" ]; then
    > "$LOG_FILE"
    echo -e "${GREEN}Logs cleared securely.${RESET}"
  else
    echo -e "${RED}Wrong password!${RESET}"
  fi
  sleep 1
  ;;
4)
  echo "[$DATE_NOW] Tool exited" >> "$LOG_FILE"
  exit
  ;;
*)
  echo -e "${RED}Invalid option${RESET}"
  sleep 1
  ;;
esac
done
