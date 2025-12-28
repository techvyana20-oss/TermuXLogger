#!/data/data/com.termux/files/usr/bin/bash

# ==================================================
# ULTIMATE TERMUX AUTOMATION LOGGER (STABLE)
# Author : TechVyana
# Purpose: Educational & Productivity
# ==================================================

LOG_DIR="$HOME/.tlogs"
LOG_FILE="$LOG_DIR/cmd.log"
PASS_FILE="$LOG_DIR/.pass"
BASHRC="$HOME/.bashrc"

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
echo -e "${CYAN} Automation • Logs • Productivity${RESET}"
echo
}

# ---------- INSTALL LOGGER (ONCE) ----------
if ! grep -q "TECHVYANA_CMD_LOGGER" "$BASHRC" 2>/dev/null; then
  banner
  echo -e "${YELLOW}Installing background command logger...${RESET}"

cat <<'EOF' >> "$BASHRC"

# ==== TECHVYANA_CMD_LOGGER ====
log_cmd() {
  cmd=$(history 1 | sed 's/^[ ]*[0-9]\+[ ]*//')
  case "$cmd" in
    *termux-automation.sh*) return ;;
    *) echo "[$(date '+%Y-%m-%d %H:%M:%S')] $cmd" >> $HOME/.tlogs/cmd.log ;;
  esac
}
PROMPT_COMMAND=log_cmd
# =============================

EOF

  echo -e "${GREEN}Logger installed successfully!${RESET}"
  echo -e "${CYAN}Restart Termux once.${RESET}"
  sleep 3
fi

# ---------- PASSWORD SETUP ----------
if [ ! -f "$PASS_FILE" ]; then
  banner
  echo -e "${YELLOW}Set Admin Password:${RESET}"
  read -s PASS
  echo
  echo -n "$PASS" | sha256sum | awk '{print $1}' > "$PASS_FILE"
  echo -e "${GREEN}Password saved.${RESET}"
  sleep 2
fi

# ---------- AUTH ----------
banner
echo -e "${CYAN}Enter Password:${RESET}"
read -s INPUT
echo
HASH=$(echo -n "$INPUT" | sha256sum | awk '{print $1}')
REAL=$(cat "$PASS_FILE")

if [ "$HASH" != "$REAL" ]; then
  echo -e "${RED}Access Denied!${RESET}"
  exit 1
fi

# ---------- MENU ----------
while true; do
banner
echo -e "${CYAN}1) View Logs"
echo "2) Daily Summary"
echo "3) Clear Logs (Protected)"
echo "4) Exit${RESET}"
echo
read -p "Choose: " CHOICE

case $CHOICE in
1)
  less "$LOG_FILE"
  ;;
2)
  echo -e "${GREEN}Today's Commands:${RESET}"
  grep "$(date '+%Y-%m-%d')" "$LOG_FILE" || echo "No logs today."
  read -p "Press ENTER..."
  ;;
3)
  echo -e "${RED}Confirm Password:${RESET}"
  read -s CPASS
  echo
  C_HASH=$(echo -n "$CPASS" | sha256sum | awk '{print $1}')
  if [ "$C_HASH" == "$REAL" ]; then
    > "$LOG_FILE"
    echo -e "${GREEN}Logs cleared.${RESET}"
  else
    echo -e "${RED}Wrong password.${RESET}"
  fi
  sleep 2
  ;;
4)
  exit 0
  ;;
*)
  echo -e "${RED}Invalid option!${RESET}"
  sleep 1
  ;;
esac
done
