###########################
# Oh My Zsh configuration #
###########################

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# zsh-syntax-highlighting must remain at the end
plugins=(
	asdf
	git
	rails
	ruby
	bundler
	zsh-completions
	zsh-autosuggestions
  zsh-syntax-highlighting
)
autoload -U compinit && compinit
source $ZSH/oh-my-zsh.sh




######################
# User configuration #
######################

# removes warning on vim startup
export LC_ALL=en_US.UTF-8




# starship prompt (this should be located at the end of the file)
eval "$(starship init zsh)"


