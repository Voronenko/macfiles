macfiles
========

Mod of my usual linux environment over mac M1 favor

So, to recap, the install script will:

* Back up any existing dotfiles in your home directory to ~/dotfiles_old/
* Create symlinks to the dotfiles in ~/dotfiles/ in your home directory
* Clone the oh-my-zsh repository from my GitHub (for use with zsh)
* Check to see if zsh is installed, if it isn't, try to install it.
* If zsh is installed, run a chsh -s to set it as the default shell.


# Terraform versions

As your projects are based on different terraform versions, makes sense to isolate your terraform
version exactly as you isolate python, nodejs, go versions.

Thus if .terraform-version is detected in $HOME, it is assumed that this host has preference of using
terraform versions via tfenv, rather than using binary from ~/dotfiles/bin.

Terraform version is detected using following logic: if no parameter is passed, the version to use is
resolved automatically via .terraform-version files or TFENV_TERRAFORM_VERSION environment variable
(TFENV_TERRAFORM_VERSION takes precedence), defaulting to 'latest' if none are found.

Thus good idea is to set default version of the terraform.
