#!/bin/bash

ROOT_UID=0
THEME_DIR="/usr/share/grub/themes"
THEME_NAME=Fs0cicty

MAX_DELAY=20                                        

#COLORS
CDEF=" \033[0m"                                     
CCIN=" \033[0;36m"                                  
CGSC=" \033[0;32m"                                  
CRER=" \033[0;31m"                                  
CWAR=" \033[0;33m"                                  
b_CDEF=" \033[1;37m"                               
b_CCIN=" \033[1;36m"                                
b_CGSC=" \033[1;32m"                                
b_CRER=" \033[1;31m"                                
b_CWAR=" \033[1;33m"                                

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;          
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;       
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;          
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    
    *)
    echo -e "$@"
    ;;
  esac
}

# Welcome message
prompt -s "\n\t************************\n\t*  ${THEME_NAME} - Grub2 Theme  *\n\t************************"

# Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

prompt -w "\nChecking for root access...\n"

# Checking for root access and proceed if it is present
if [ "$UID" -eq "$ROOT_UID" ]; then

  # Create themes directory if not exists
  prompt -i "\nChecking for the existence of themes directory...\n"
  [[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
  mkdir -p "${THEME_DIR}/${THEME_NAME}"

  # Copy theme
  prompt -i "\nInstalling ${THEME_NAME} theme...\n"

  cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}

  # Set theme
  prompt -i "\nSetting ${THEME_NAME} as default...\n"

  # Backup grub config
  cp -an /etc/default/grub /etc/default/grub.bak

  grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub

  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

  # Update grub config
  echo -e "Updating grub config..."
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command grub2-mkconfig; then
    if has_command zypper; then
      grub2-mkconfig -o /boot/grub2/grub.cfg
    elif has_command dnf; then
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi
  fi

  # Success message
  prompt -s "\n\t          ***************\n\t          *  All done!  *\n\t          ***************\n"

else

  # Error message
  prompt -e "\n [ Error! ] -> Run me as root "

  # persisted execution of the script as root
  read -p "[ trusted ] specify the root password : " -t${MAX_DELAY} -s
  [[ -n "$REPLY" ]] && {
    sudo -S <<< $REPLY $0
  } || {
    prompt  "\n Operation canceled  Bye"
    exit 1
  }
fi
