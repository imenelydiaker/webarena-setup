# Attach 1To virtual disk parition sda1
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda mkpart primary ext4 0% 100%
sudo parted /dev/sda align-check optimal 1

sudo mkfs.ext4 /dev/sda1

sudo mkdir /datadrive
sudo mount /dev/sda1 /datadrive

sudo chmod u+rw datadrive/
sudo chown -R webarenauser datadrive/