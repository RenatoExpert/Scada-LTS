
gpg --pinentry-mode=loopback -o result --passphrase "Shogun Automation" --symmetric crypt_data

gpg --pinentry-mode=loopback --passphrase "Shogun Automation" -o data_tree.json --decrypt result

