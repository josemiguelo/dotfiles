###########################
# Oh My Zsh configuration #
###########################

export ZSH="/Users/josemiguel/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git rails ruby bundler)
source $ZSH/oh-my-zsh.sh




######################
# User configuration #
######################

# removes warning on vim startup
export LC_ALL=en_US.UTF-8




# starship prompt (this should be located at the end of the file)
eval "$(starship init zsh)"


