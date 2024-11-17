#!/bin/bash
set -e

# Ensure OpenLDAP has sufficient time to initialize
sleep 1

# Establish the Privilege Separation directory for SSH
mkdir -p /var/run/sshd

# Refine the SSHD configuration to integrate PAM and remove existing lines if they exist
sed -i '/ChallengeResponseAuthentication/d' /etc/ssh/sshd_config
sed -i '/UsePAM/d' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i '/PermitRootLogin/d' /etc/ssh/sshd_config
sed -i '/PubkeyAuthentication/d' /etc/ssh/sshd_config
sed -i '/AuthenticationMethods/d' /etc/ssh/sshd_config
sed -i '/KbdInteractiveAuthentication/d' /etc/ssh/sshd_config

cat <<EOL >> /etc/ssh/sshd_config
ChallengeResponseAuthentication yes
UsePAM yes
PasswordAuthentication yes
PermitRootLogin no
EOL

if [ "$ENABLE_MFA" = "true" ]; then
    cat <<EOL >> /etc/ssh/sshd_config
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
KbdInteractiveAuthentication yes
EOL
fi

# Introduce supplementary configuration options to sshd_config
cat <<EOL >> /etc/ssh/sshd_config
AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
AuthorizedKeysCommandUser root
ClientAliveInterval 60
ClientAliveCountMax 2
StreamLocalBindUnlink yes
MaxStartups 50:100:200
EOL

# Modify the PAM common-session file to facilitate home directory creation
echo "session optional pam_mkhomedir.so" >> /etc/pam.d/common-session

# Initialize SSH service
service ssh start

# Initialize SSSD service
rm -f /var/run/sssd.pid
sssd -i &

# Maintain container operation
tail -f /dev/null
