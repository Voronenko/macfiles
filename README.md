macfiles
========

Mod of my usual linux environment over mac M1 favor

So, to recap, the install script will:

* Back up any existing dotfiles in your home directory to ~/dotfiles_old/
* Create symlinks to the dotfiles in ~/dotfiles/ in your home directory
* Clone the oh-my-zsh repository from my GitHub (for use with zsh)
* Check to see if zsh is installed, if it isn't, try to install it.
* If zsh is installed, run a chsh -s to set it as the default shell.

## Some macfiles perks (but not all)

### fzf

`COMMAND [DIRECTORY/][FUZZY_PATTERN]**<TAB>`  - lookup file/folder

`kill -9 <TAB>`  - lookup process

`ssh **<TAB>` - lookup host from ~/.ssh/confog

operate with envvars

```sh
unset **<TAB>
export **<TAB>
unalias **<TAB>
```

as a part of helper for docker <https://github.com/MartinRamm/fzf-docker.git>

| command | description                                        | fzf mode | command arguments (optional)                                             |
|---------|----------------------------------------------------|-----------|--------------------------------------------------------------------|
| dr      | docker restart && open logs (in follow mode)       | multiple  |                                                                    |
| dl      | docker logs (in follow mode)                       | multiple  | time interval - e.g.: `1m` for 1 minute - (defaults to all logs)   |
| dla     | docker logs (in follow mode) all containers        |           | time interval - e.g.: `1m` for 1 minute - (defaults to all logs)   |
| de      | docker exec in interactive mode                    | single    | command to exec (default - see below)                              |
| drm     | docker remove container (with force)               | multiple  |                                                                    |
| drma    | docker remove all containers (with force)          |           |                                                                    |
| ds      | docker stop                                        | multiple  |                                                                    |
| dsa     | docker stop all running containers                 |           |                                                                    |
| dsrm    | docker stop and remove container                   | multiple  |                                                                    |
| dsrma   | docker stop and remove all container               |           |                                                                    |
| dk      | docker kill                                        | multiple  |                                                                    |
| dka     | docker kill all containers                         |           |                                                                    |
| dkrm    | docker kill and remove container                   | multiple  |                                                                    |
| dkrma   | docker kill and remove all container               |           |                                                                    |
| drmi    | docker remove image (with force)                   | multiple  |                                                                    |
| drmia   | docker remove all images (with force)              |           |                                                                    |
| dclean  | `dsrma` and `drmia`                                |           |                                                                    |


### Misc console helpers

`z <tab>`  - quickly change to most often used dir with cd

`ga` Interactive git add selector

`glo` Interactive git log viewer

`gi` Interactive .gitignore generator

`gd` Interactive git diff viewer

`grh` Interactive git reset HEAD <file> selector

`gcf` Interactive git checkout <file> selector

`gss` Interactive git stash viewer

`gclean` Interactive git clean selector

`ec2ssh` - lookup and template ssh connection to machines you want to connect

`ec2ssm` - lookup instances to connect using aws ssm


### Folder specific environment with direnv

If you have direnv tool installed, `.envrc` start to get supported.

```
if [[ -f /usr/bin/direnv ]]; then
# direnv
eval "$(direnv hook zsh)"
fi
```

Quick note on getting "merged" environments: placing `source_env` directive into `.envrc`
allows that effect. In other case, other environment variables will be uploaded.

```
source_env ..
```

Also you might use custom instruction "inherit_env", which will ensure, that all variables from parent .envrc will be loaded.

If you also make use of hashicorp vault for secrets storage,
you can use following workaround with direnv:

```envrc
PROJECT=SOMEPROJECT
export AWS_ACCESS_KEY_ID=$(vault read -field "value" secret/$PROJECT/aws/AWS_ACCESS_KEY_ID)
export AWS_SECRET_ACCESS_KEY=$(vault read -field "value" secret/$PROJECT/aws/AWS_SECRET_ACCESS_KEY)
export AWS_DEFAULT_REGION=us-east-1
```

If you use pass backend, you can also use it like below

```envrc
PROJECT=SOMEPROJECT
export AWS_ACCESS_KEY_ID=$(pass show aws/$PROJECT/AWS_ACCESS_KEY_ID)
export AWS_SECRET_ACCESS_KEY=$(pass show aws/$PROJECT/AWS_SECRET_ACCESS_KEY)
export AWS_DEFAULT_REGION=us-east-1
```

### NodeJS development?

If detected, nvm is loaded and per project `.nvmrc` is supported to switch node version in console.

```sh
if [[ -f ~/.nvm/nvm.sh ]]; then

source ~/.nvm/nvm.sh

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

fi
```

### Python development?

macfiles are optimized specifically for use with conda and pyenv

```zshrc
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


#TODO: consider moving to pyenv plugin
if [[ -d ~/.pyenv ]]; then
export PYTHON_BUILD_HOMEBREW_OPENSSL_FORMULA="openssl@3"
export PYENV_ROOT="$(pyenv root)"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
fi
```


## Anything locally specific?

Add .zshrc.local - it gets parsed.

```sh
if [[ -f ${HOME}/.zshrc.local ]]; then source ${HOME}/.zshrc.local; fi
```

see section on pyenv installation at the bottom of the file



## Automatic tool version switching

### .terraform-version

As your projects are based on different terraform versions, makes sense to isolate your terraform
version exactly as you isolate python, nodejs, go versions.

Thus if .terraform-version is detected in $HOME, it is assumed that this host has preference of using
terraform versions via tfenv, rather than using binary from ~/dotfiles/bin.

Terraform version is detected using following logic: if no parameter is passed, the version to use is
resolved automatically via .terraform-version files or TFENV_TERRAFORM_VERSION environment variable
(TFENV_TERRAFORM_VERSION takes precedence), defaulting to 'latest' if none are found.

Thus good idea is to set default version of the terraform.

### .python-version

Automatically activates pyenv environmet for the version specified in .python-version file.

### .nvmrc

Automatically activates nvm environmet for the version specified in .nvmrc file.

### .java-version

Automatically activates java version specified in .java-version file using jenv, if present





# Troubleshooting

## pyenv installation problems

If your local setup is per `macfiles`, your pyenv installation should work out of the box with:

```
install-pyenv:
 brew reinstall ca-certificates
 brew install openssl readline sqlite3 xz zlib tcl-tk@8 libb2
 brew install pyenv
 echo "Installing virtualenv plugin"
 brew install pyenv-virtualenv
 echo "Usage: pyenv virtualenv 3.9.15 name-of-virtual-env"
```

This goes in line with official pyenv installation instructions.
<https://github.com/pyenv/pyenv/wiki#suggested-build-environment> =>  <https://github.com/pyenv/pyenv?tab=readme-ov-file#b-set-up-your-shell-environment-for-pyenv> =>  <https://github.com/pyenv/pyenv/wiki#suggested-build-environment>



If during installation you face one of the following errors:

### Security certificate problem

Ensure you've instructed pyenv to use openssl v3 instead of v1, as homebrew openssl v1 is badly broken at least on arm64 macs.

`export PYTHON_BUILD_HOMEBREW_OPENSSL_FORMULA="openssl@3"`

In macfiles it is already addressed

```
if [[ -d ~/.pyenv ]]; then
export PYTHON_BUILD_HOMEBREW_OPENSSL_FORMULA="openssl@3"
export PYENV_ROOT="$(pyenv root)"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
fi
```

### Linking errors during python version installation, including DYLD_LIBRARY_PATH errors

If python version installation fails with error messages like:

```txt
DYLD_LIBRARY_PATH=/var/folders/dm/s9twt_h92t15b27mn940zdqw0000gp/T/python-build.20250324114735.79587/Python-3.9.15 ./python.exe -E -m ensurepip \
   $ensurepip --root=/ ; \
 fi
dyld[93892]: missing symbol called
```

or

```txt
Undefined symbols for architecture arm64:
 "_libintl_bindtextdomain", referenced from:
   __locale_bindtextdomain in _localemodule.o
   __locale_bindtextdomain in _localemodule.o
 "_libintl_dcgettext", referenced from:
   __locale_dcgettext in _localemodule.o
 "_libintl_dgettext", referenced from:
   __locale_dgettext in _localemodule.o
 "_libintl_gettext", referenced from:
   __locale_gettext in _localemodule.o
 "_libintl_setlocale", referenced from:
   __locale_setlocale in _localemodule.o
   __locale_setlocale in _localemodule.o
   __locale_localeconv in _localemodule.o
   __locale_localeconv in _localemodule.o
   __locale_localeconv in _localemodule.o
   __locale_localeconv in _localemodule.o
 "_libintl_textdomain", referenced from:
   __locale_textdomain in _localemodule.o
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [Programs/_freeze_module] Error 1
make: *** Waiting for unfinished jobs....
```

Most likely reason on macOS running on M1-M4 chips is that you have ugly mix of homebrew for arm and x86 architectures.
(Don't ask me how you did it, perhaps you haven't used `macfiles` from the start)

And reliable way to fix that might be:

(A)

In zshrc, like `macfiles` does, ensure you have forced arm64 version of the homebrew in terminal sessions
```zshrc
eval $(/opt/homebrew/bin/brew shellenv)
```

(B) You might have mix of the libraries in x86 location (`ls /usr/local/lib/libint*`) and arm64 location (`ls /opt/homebrew/lib/libint*`).
As you are working or arm machine, you should have all necessary libraries in arm64 location.

If, saying, you observe situation like

```shell
ls /usr/local/lib/libint*
/usr/local/lib/libintl.8.dylib /usr/local/lib/libintl.dylib
/usr/local/lib/libintl.a

ls /opt/homebrew/lib/libint*
zsh: no matches found: /opt/homebrew/lib/libint*

```

This is exactly scenario: libraries are installed for the wrong architecture.

Apply (A), open fresh shell.
Reinstall typical python dependencies for arm64 architecture.

```shell
brew install gettext
brew link gettext --force

brew install openssl readline sqlite3 xz zlib tcl-tk@8 libb2

brew install ncurses
```

After that you should be able to install python versions with pyenv for arm64 architecture.
