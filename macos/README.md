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
$ # configure pinentry-mac for GPG passphrase prompts
$ echo "pinentry-program /opt/homebrew/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
$ gpgconf --kill gpg-agent
$ export GPG_TTY=$(tty)
$ # configure git author (use GitHub noreply email to keep your email private)
$ git config --global user.name "jr"
$ git config --global user.email "joakim-roos@users.noreply.github.com"
$ # test gpg signing
$ mkdir -p /tmp/test
$ cd $_
$ git init
$ git commit --allow-empty -m 'signsss'
$ git log --show-signature
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

## Hammerspoon

The Brewfile installs Hammerspoon. Run `stow .` from the dotfiles root to link its configuration.
Open Hammerspoon and enable it in **System Settings → Privacy & Security → Accessibility**.
Restart Hammerspoon after you enable access. Hold Right Command to speak; release it to mute.


### Raycast microphone commands

In Raycast Settings, select **Extensions → Script Commands → Add Directories**.
Add `~/.dotfiles/.config/raycast/scripts`.

- **Enable Push to Talk** starts Hammerspoon and enables Right Command hold-to-talk.
- **Disable Push to Talk** stops the listener and timer, then unmutes the default microphone at its saved volume.
  This command also works when Hammerspoon is closed.

The disable command builds its audio helper on first use. Xcode Command Line Tools must be installed, as shown above.
The helper uses macOS Core Audio and requires no additional packages. Git ignores the compiled helper.

Quitting Hammerspoon leaves the microphone muted. Use **Disable Push to Talk** to restore normal microphone use.
The configuration controls the default microphone. Microphones without a mute control use input volume, which may not block all sound.

To check the configuration without changing the live microphone, run `lua macos/tests/push-to-talk.lua` from the dotfiles root.
