#!/data/data/com.termux/files/usr/bin/bash

# ==================================================
# TERMUX COMMAND LOGGER & VIEWER
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

banner() {
clear
echo -e "${GREEN}"
echo " ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗"
echo " ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝"
echo "    ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ "
echo "    ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ "
echo "    ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗"
echo "    ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝"
echo -e "${CYAN} Command Logger • Viewer • Audit${RESET}"
echo
}

# ---------- INSTALL BACKGROUND LOGGER ----------
if ! grep -q "TERMUX CMD LOGGER (TechVyana)" "$BASHRC"; then
  cat <<EOF >> "$BASHRC"

# ===== TERMUX CMD LOGGER (TechVyana) =====
export HISTTIMEFORMAT="%F %T "
PROMPT_COMMAND='history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" >> \$HOME/.tlogs/cmd.log'
# =========================================

EOF
  echo -e "${GREEN}Background logger installed.${RESET}"
  echo -e "${YELLOW}Restart Termux to start logging.${RESET}"
  sleep 2
fi

# ---------- PASSWORD ----------
if [ ! -f "$PASS_FILE" ]; then
  banner
  echo -e "${YELLOW}Set Admin Password:${RESET}"
  read -s PASS
  echo
  echo -n "$PASS" | sha256sum | awk '{print $1}' > "$PASS_FILE"
  echo -e "${GREEN}Password set successfully!${RESET}"
  sleep 1
fi

banner
echo -e "${CYAN}Enter Password:${RESET}"
read -s INPUT
echo

if [ "$(echo -n "$INPUT" | sha256sum | awk '{print $1}')" != "$(cat "$PASS_FILE")" ]; then
  echo -e "${RED}Access Denied!${RESET}"
  exit 1
fi

# ---------- VIEWER MENU ----------
while true; do
banner
echo -e "${CYAN}1️⃣ View All Logged Commands"
echo "2️⃣ Today's Commands"
echo "3️⃣ Clear Logs"
echo "4️⃣ Exit${RESET}"
echo
read -p "Choose: " C

case $C in
1) less "$LOG_FILE" ;;
2)
  grep "$(date '+%Y-%m-%d')" "$LOG_FILE" || echo "No commands today."
  read -p "Press ENTER..."
  ;;
3)
  echo -e "${RED}Confirm Password:${RESET}"
  read -s P
  echo
  if [ "$(echo -n "$P" | sha256sum | awk '{print $1}')" == "$(cat "$PASS_FILE")" ]; then
    > "$LOG_FILE"
    echo "Logs cleared."
  else
    echo "Wrong password!"
  fi
  sleep 1
  ;;
4) exit ;;
*) echo "Invalid option"; sleep 1 ;;
esac
done
