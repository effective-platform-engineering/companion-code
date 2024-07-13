## Configuring GitHub for signed commits

This explanation assumes MacOs and is based on using a personal KeyBase account.  

Use of Keybase is not a requirement for signed commits and there are many posts you can find that describe alternative means. Many people already use other popular keyservers (e.g., pgp.mit.edu, keyserver.ubuntu.com)

Requirements:
* Github account
* Keybase account
* GPG service locally

```bash
$ brew cask install keybase  # typically already installed as part of keybase app install
$ brew install gpg
```

Create new personal key. (Note: you can skip if you already maintain your key via alternative means)
```bash
$ keybase pgp gen --multi

# If your gpg is running local then you should see the following

Enter your real name, which will be publicly visible in your new key: Jane Doe
Enter a public email address for your key: jdoe@thoughtworks.com
Enter another email address (or <enter> when done): jane.doe@gmail.com
Enter another email address (or <enter> when done):
Push an encrypted copy of your new secret key to the Keybase.io server? [Y/n] Y
When exporting to the GnuPG keychain, encrypt private keys with a passphrase? [Y/n] Y
▶ INFO PGP User ID: Jane Doe <jdoe@thoughtworks.com> [primary]
▶ INFO PGP User ID: Jane Doe <jane.doe@gmail.com>
▶ INFO Generating primary key (4096 bits)
▶ INFO Generating encryption subkey (4096 bits)
▶ INFO Generated new PGP key:
▶ INFO   user: Jane Doe <jdoe@thoughtworks.com>
▶ INFO   4096-bit RSA key, ID 5BE03B7DE63C0271, created 2020-05-25
▶ INFO Exported new key to the local GPG keychain
```

List info needed to setup git locally

```bash
$ gpg --list-secret-keys --keyid-format LONG
/Users/ncheneweth/.gnupg/pubring.kbx
------------------------------------
sec   rsa4096/A8E47CAE38308EC9 2020-05-25 [SC] [expires: 2036-05-21]
      7703E0D1ECF17C64C6B09DDFA8E47CAE38308EC9
uid                 [ unknown] Jane Doe <jdoe@thoughtworks.com>
uid                 [ unknown] Jane Doe <njane.doe@gmail.com>
```

#### add to git config

```bash
$ git config --global user.signingkey A8E47CAE38308EC9
$ git config --global commit.gpgsign true
```

#### copy to clipboard for pasting into github
```bash
keybase pgp export -q 5BE03B7DE63C0271 | pbcopy
```

#### test
```bash
export GPG_TTY=$(tty)
echo "test" | gpg --clearsign
```

#### Set as default gpg key
```bash
$ $EDITOR ~/.gnupg/gpg.conf
```

#### Add line:

```bash
default-key 5BE03B7DE63C0271
```
There are couple different common ways of getting your local config to know to use the key for signing every time. 

```bash
$ brew uninstall pinentry-mac
```

Some people find that pinentry installed with brew does not allow the password to be saved to macOS's keychain.
If you do not see "Save in Keychain" after following Method 1, try the GPG Suite versions, available from gpgtools.org, or from brew by running:

```bash
$ brew install gpg-suite --cask
```

Once installed, open Spotlight and search for "GPGPreferences", or open system preferences and select "GPGPreferences." Select the Default Key if it is not already selected, and ensure "Store in OS X Keychain" is checked.

### working with multiple SSH keys

If you need to maintain multiple SSH and GPG signing keys, below is one strategy:  

Edit your ~/.ssh/config file:  

```bash
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes

Host github.com-company-1
  HostName github.com
  User git
  IdentityFile ~/.ssh/company_1_id_rsa
  IdentitiesOnly yes
  
Host bitbucket.org-company-2
  HostName bitbucket.org
  User git
  IdentityFile ~/.ssh/company_2_id_rsa
  IdentitiesOnly yes

Host *
  AddKeysToAgent yes
  IdentitiesOnly yes
  PreferredAuthentications publickey
  UseKeychain yes
  Compression yes
```

Edit your ~/.gitconfig file
```bash
[init]
  defaultBranch = main

[commit]
  gpgsign = true

# ...

[user]
  name = Jane Doe
  useConfigOnly = true

# optional (if you organize your repositories by ssh context)  

[include]
  path = ~/.gitconfig-default

[includeIf "gitdir:~/github/company-1/"]
  path = ~/.gitconfig-company-1

[includeIf "gitdir:~/github/company-2/"]
  path = ~/.gitconfig-company-2
 ```
 
 For each of the config specific files:  
 
 ~/.gitconfig-default  
 ```bash
 [user]
	   email = jdoe@thoughtworks.com
	   signingkey = 5BE03B7DE63C0271
 ```
 
  ~/.gitconfig-company-1  
 ```bash
 [user]
	  email = jdoe@company-1.com
	  signingkey = 6F3B53E64B964B824

[url "git@github.com-company-1"]
	  insteadOf = git@github.com
 ```
 
   ~/.gitconfig-company-2  
 ```bash
  [user]
	  email = jdoe@company-2.com
	  signingkey = 3456753E64B964B824

[url "git@bitbucket.org-company-2"]
	  insteadOf = git@github.com
 ```
 