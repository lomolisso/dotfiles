# fish is the interactive shell only. The login shell stays bash, so scripts
# and AI agents that go by $SHELL or /etc/passwd keep getting bash; ghostty,
# zellij and herdr launch fish explicitly. Run `bash` for a bash prompt.

fish_add_path -g ~/.local/bin
set -gx EDITOR helix
set -gx VISUAL helix

# ssh asks rbw-askpass for passwords: logins listed in
# ~/.config/rbw-askpass/hosts come from Bitwarden, the rest are asked as usual.
set -gx SSH_ASKPASS ~/.local/bin/rbw-askpass
set -gx SSH_ASKPASS_REQUIRE force

if status is-interactive
    set -g fish_greeting
    starship init fish | source
    zoxide init fish | source
    atuin init fish | source

    # fzf in the shin palette: greys, white text, wine borders/prompt, bright
    # wine for matches, the cursor and the selected line's marker.
    set -gx FZF_DEFAULT_OPTS "--color=fg:#cfcfcf,bg:-1,hl:#cb4d66,fg+:#e9e9e9,bg+:#2a2a2a,hl+:#cb4d66,info:#989898,prompt:#8c1625,pointer:#cb4d66,marker:#cb4d66,spinner:#cb4d66,header:#989898,border:#8c1625,label:#cb4d66,query:#e9e9e9,gutter:-1 --border=rounded --layout=reverse"

    # Blank line between a command's output and the next prompt (starship's
    # add_newline is off so the first prompt isn't pushed down). Not after
    # `clear`, so a cleared screen starts at the top too.
    function _blank_line_after_command --on-event fish_postexec
        string match -qr '^\s*clear\b' -- $argv[1]; and return
        echo
    end

    # zathura is a GUI app with its own window, so start it in its own session
    # instead of tying up the shell (its GTK warnings stay out of the terminal
    # too, and closing the terminal leaves it open). `command zathura` runs the
    # plain foreground version.
    function zathura --wraps zathura --description 'zathura, detached from the terminal'
        setsid -f zathura $argv </dev/null >/dev/null 2>&1
    end
end
