autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo "on %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "on %{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

# This assumes that you always have an origin named `origin`, and that you only
# care about one specific origin. If this is not the case, you might want to use
# `$git cherry -v @{upstream}` instead.
need_push () {
  if [ $($git rev-parse --is-inside-work-tree 2>/dev/null) ]
  then
    number=$($git cherry -v origin/$(git symbolic-ref --short HEAD) 2>/dev/null | wc -l | bc)

    if [[ $number == 0 ]]
    then
      echo " "
    else
      echo " with %{$fg_bold[magenta]%}$number unpushed%{$reset_color%}"
    fi
  fi
}

directory_name() {
  echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

battery_status() {
  if test ! "$(uname)" = "Darwin"
  then
    exit 0
  fi

  if [[ $(sysctl -n hw.model) == *"Book"* ]]
  then
    if test ! "$(uname)" = "Darwin"
      then
      printf ""
      exit 0
    fi

    battstat=$(pmset -g batt)
    time_left=$(echo $battstat |
      tail -1 |
      cut -f2 |
      awk -F"; " '{print $3}' |
      cut -d' ' -f1
    )

    if [[ $(pmset -g ac) == *"No adapter attached."* ]]
    then
      emoji='🔋'
    else
      emoji='🔌'
    fi

    if [[ $time_left == *"(no"* || $time_left == *"not"* ]]
    then
      time_left='⌛️ '
    fi

    if [[ $time_left == *"0:00"* ]]
    then
      time_left='⚡️ '
    fi

    printf "\033[1;92m$emoji  $time_left \033[0m"
  fi
}

rancher_context () {
  if [ -n "$RANCHER_CONTEXT" ]; then
    echo "%{$fg_bold[green]%}rancher-ctx[$(rancher context current)]%{$reset_color%}"
  fi
}

export PROMPT=$'\n$(battery_status)in $(directory_name) $(git_dirty)$(need_push) $(rancher_context)\n› '
set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
