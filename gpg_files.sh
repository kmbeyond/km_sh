
#------
Steps:
-We create a key & distribute publc key.
-Sender encrypts with Public key
-We decrypt file with Private key


#-----import public key
gpg --import km_public_key.asc
gpg --edit km@km.com
command>trust
####>Your decision? 5
####>y
####>quit

#Check keys using:
gpg -k


#encrypt
cat my_file.txt | gpg --batch --trust-model always --encrypt -a -r km@km.com -r encrypted_file.pgp


#decrypt
passphrase="5w00r814d6p942y5"
echo "$passphrase" | gpg --batch --yes --passphrase-fd 0 encrypted_file.pgp
=> my_file.txt

