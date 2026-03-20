# macOS

## Setting up a new Mac

```console
$ # install Xcode Command Line Tools
$ xcode-select --install
$ # install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
$ # clone the dotfiles repo
$ git clone https://github.com/joakim-roos/dotfiles.git ~/.dotfiles
$ # install Brewfile
$ cd ~/.dotfiles/macos
$ brew bundle
$ # setup mac defaults
$ ./set-defaults.sh
$ cd ..
$ # setup SSH key for authentication (cloning/pushing)
$ ssh-keygen -t ed25519 -C "your@email.com"
$ chmod 600 ~/.ssh/id_ed25519
$ # add the public key to GitHub as an Authentication key
$ cat ~/.ssh/id_ed25519.pub
$ # setup GPG for signed commits
$ brew install gnupg pinentry-mac

$ # import GPG key from YubiKey
$ gpg --full-generate-key  # select "Existing key from card"
$ # OR import GPG key from file (if no YubiKey)
$ gpg --import /path/to/gpg-key.asc
$ gpg --edit-key <KEY_ID>  # type "trust", select 5 (ultimate), "save"
$ gpg --list-secret-keys --keyid-format=long  # note the key ID after rsa4096/
$ git config --global user.signingkey <KEY_ID>
$ git config --global commit.gpgsign true
$ git config --global gpg.program $(which gpg)
$ # configure git author (use GitHub noreply email to keep your email private)
$ git config --global user.name "jr"
$ git config --global user.email "joakim-roos@users.noreply.github.com"
$ # reboot
$ sudo reboot
```

> **Note:** If you set a passphrase on your SSH key, you can store it in the macOS Keychain to avoid typing it repeatedly:
> ```console
> $ ssh-add --apple-use-keychain ~/.ssh/id_ed25519
> ```
> Then add this to `~/.ssh/config`:
> ```
> Host *
>   AddKeysToAgent yes
>   UseKeychain yes
>   IdentityFile ~/.ssh/id_ed25519
> ```

> **Note:** To export your GPG key for transfer to another machine:
> ```console
> $ gpg --export-secret-keys --armor <KEY_ID> > ~/gpg-key.asc
> ```
> Transfer securely (AirDrop, encrypted USB, or `scp`) and delete the file after importing.

> **Note:** To add or change emails on your GPG key (one key can have multiple emails):
> ```console
> $ gpg --edit-key <KEY_ID>
> # adduid → enter new email → save
> # to remove an old email: uid <N> → revuid → save
> ```
> Then re-export and update the key on GitHub.

> **Note:** Back up your GPG key before moving it to a YubiKey (`keytocard` is a move, not a copy):
> ```console
> $ gpg --export-secret-keys <KEY_ID> > ~/gpg-backup.key
> ```
