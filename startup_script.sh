#!/bin/bash
set -e

# Ensure OpenLDAP has sufficient time to initialize
sleep 1

# Establish the Privilege Separation directory for SSH
mkdir -p /var/run/sshd

# Refine the SSHD configuration to integrate PAM
sed -i -e 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' \
       -e 's/UsePAM no/UsePAM yes/' \
       -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' \
       -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' \
       /etc/ssh/sshd_config

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
