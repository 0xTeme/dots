{
  flake.modules.homeManager.bash = {
    programs.bash = {
      enable = true;

      initExtra = ''
        # DEBUG fires before every command. Right before the prompt function runs,
        # $? still holds the status of the command that just finished, so capture it
        # there, before anything else can overwrite it.
        __cmd_start=""
        __in_prompt_command=0
        __last_status=0
        __debug_trap() {
          if [[ "$BASH_COMMAND" == __prompt_command* ]]; then
            __last_status=$?
            return 0
          fi
          (( __in_prompt_command )) && return 0
          [[ -z "$__cmd_start" ]] && __cmd_start=$EPOCHREALTIME
          return 0
        }
        trap '__debug_trap' DEBUG

        # One git call gets branch, dirty state, and ahead/behind together, via
        # git's own machine-readable status format, rather than several separate calls.
        __git_info() {
          local raw branch ab ahead=0 behind=0 dirty=""
          raw=$(git status --porcelain=2 --branch 2>/dev/null) || return
          [[ -z "$raw" ]] && return

          branch=$(sed -n 's/^# branch.head //p' <<<"$raw")
          [[ "$branch" == "(detached)" ]] && branch="detached"

          ab=$(sed -n 's/^# branch.ab //p' <<<"$raw")
          if [[ -n "$ab" ]]; then
            ahead=$(sed -n 's/^+\([0-9]*\).*/\1/p' <<<"$ab")
            behind=$(sed -n 's/.*-\([0-9]*\)$/\1/p' <<<"$ab")
          fi

          grep -qE '^(1|2|u|\?)' <<<"$raw" && dirty="*"

          local marks=""
          (( ahead > 0 )) && marks+="^$ahead"
          (( behind > 0 )) && marks+="v$behind"

          printf " \uf418 %s%s%s" "$branch" "$dirty" "''${marks:+ $marks}"
        }

        __prompt_command() {
          __in_prompt_command=1
          local status=$__last_status

          local elapsed=""
          if [[ -n "$__cmd_start" ]]; then
            local now=$EPOCHREALTIME
            local secs=$(( ''${now%.*} - ''${__cmd_start%.*} ))
            (( secs >= 2 )) && elapsed="  took ''${secs}s"
          fi
          __cmd_start=""

          local git_info
          git_info="$(__git_info)"

          local arrow_color="\[\e[32m\]"
          local status_info=""
          if (( status != 0 )); then
            arrow_color="\[\e[31m\]"
            status_info="  exit:$status"
          fi

          PS1="\n\[\e[36m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]\[\e[35m\]$git_info\[\e[0m\]$status_info$elapsed\n$arrow_color❯\[\e[0m\] "
          __in_prompt_command=0
        }

        PROMPT_COMMAND=__prompt_command
      '';
    };
  };
}
