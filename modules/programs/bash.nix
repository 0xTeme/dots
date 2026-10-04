{
  flake.modules.homeManager.bash = {
    programs.bash = {
      enable = true;

      initExtra = ''
        __git_prompt() {
          local branch
          local status

          branch=$(git symbolic-ref --short HEAD 2>/dev/null) ||
            branch=$(git rev-parse --short HEAD 2>/dev/null) ||
            return

          status=$(git status --porcelain 2>/dev/null)

          if [[ -n "$status" ]]; then
            printf " [git:%s*]" "$branch"
          else
            printf " [git:%s]" "$branch"
          fi
        }

        __prompt_command() {
          local status=$?

          local git_info
          git_info="$(__git_prompt)"

          local status_info=""
          if (( status != 0 )); then
            status_info=" [exit:$status]"
          fi

          PS1="\[\e[36m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]$git_info$status_info \[\e[33m\]\$\[\e[0m\] "
        }

        PROMPT_COMMAND=__prompt_command
      '';
    };
  };
}
