
# Resources
PDF - Terraform up and running by 
Udemy - Complete Terraform course by Nana

# Create AWS account


# Install  
2024-10-
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Mac
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

Linux - 2024-10-29

```sh
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform
```

# neovim on WSL

```sh
# install brew (apt installs outdated Neovim)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# recommended after above command ran
echo >> /home/uwuntu/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/uwuntu/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# sudo apt install neovim
brew install neovim
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

```

# VSCode Fira code

Download from the first link, unzip and click the top .ttf. Next set VSCode settings to "Fira Code".

https://fonts.google.com/specimen/Fira+Code
https://firacode.org/install-and-use-firacode-font-vscode-on-ubuntu/


# Providers

```hcl
provider "aws" {
    region = "us-east-2"
}
```

# Git creation from CLI

Create a new repo on Github, clone it, add all the files on this new repo and do the below cmds. Prior to this I set my SSH key on Github.

```sh
git add .
git commit -m "Initial commit"
git remote set-url origin git@github.com:Ang3lino/terraform-journey.git
git push
```

# Single server

