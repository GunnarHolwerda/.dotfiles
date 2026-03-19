if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_all_dups hist_ignore_space

# Completion (only rebuild once per day)
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# Plugins
for plugin in zsh-autosuggestions/zsh-autosuggestions zsh-syntax-highlighting/zsh-syntax-highlighting; do
  for prefix in /opt/homebrew/share /usr/local/share /usr/share; do
    [[ -f "$prefix/$plugin.zsh" ]] && source "$prefix/$plugin.zsh" && break
  done
done

source ~/.zsh_profile

eval "$(mise activate zsh)"

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi
