#!/usr/bin/env bash

# Creates a group and add user for real-time processing
sudo groupadd -f realtime
sudo usermod -aG realtime $USER
sudo tee /etc/security/limits.d/99-realtime.conf >/dev/null <<'EOF'
@realtime - rtprio 99
@realtime - memlock unlimited
EOF

echo "Please reboot after this for changes to take effect \nAfter reboot check \n'ulimit -r' -> Expected Output: 99 \n'ulimit -l' -> Expected Output: unlimited"