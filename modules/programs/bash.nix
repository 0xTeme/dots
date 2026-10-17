{
  flake.modules.homeManager.bash = {
    programs.bash = {
      enable = true;

      initExtra = ''
        # Tracks how long each command takes. __in_prompt_command guards against the
        # DEBUG trap firing on the prompt's own internal commands (git, sed, etc.),
        # which would otherwise overwrite the real start time before it's read.
        __cmd_start=""
        __in_prompt_command=0
        __timer_start() {
          (( __in_prompt_command )) && return
          [[ -z "$__cmd_start" ]] && __cmd_start=$EPOCHREALTIME
        }
        trap '__timer_start' DEBUG

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
          # This must be the very first line. Even the plain assignment below it
          # would reset $? to 0 before we got a chance to read the real value.
          local status=$?
          __in_prompt_command=1

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
