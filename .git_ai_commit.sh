# AI commit-message completion.
# Type:  git commit -m "<TAB>
# and an AI-generated  [AMG-<ticket>] <description>  message is inserted after the quote.
# When the branch has no AMG-<ticket>, the [AMG-<ticket>] prefix is dropped entirely.
# Anywhere else, Tab behaves as normal git completion.

_ai_commit_message() {
    # $1 (optional): text the user already typed after the opening quote, used as
    # a hint of intent. The generated message overwrites it (the whole quoted
    # string is a single completion word, so readline replaces all of it).
    local hint=$1
    local branch ticket prefix diff prompt msg
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    # Extract AMG-<id> from the branch name (case-insensitive), normalize to uppercase.
    ticket=$(printf '%s' "$branch" | grep -oiE 'AMG-[0-9]+' | head -n1 | tr '[:lower:]' '[:upper:]')
    [ -n "$ticket" ] && prefix="[$ticket] "

    # If claude isn't installed, fall back to the user's hint when they typed one,
    # otherwise "[AMG-<id>] updated <files>"
    # (prefix omitted entirely when no ticket can be extracted from the branch).
    if ! command -v claude >/dev/null 2>&1; then
        if [ -n "$hint" ]; then
            printf '%s%s' "$prefix" "$hint"
            return
        fi
        local files
        files=$(git diff --cached --name-only 2>/dev/null)
        [ -z "$files" ] && files=$(git diff --name-only 2>/dev/null)
        files=$(printf '%s\n' "$files" | grep -v '^$' | paste -sd ',' - | sed 's/,/, /g')
        printf '%supdated %s' "$prefix" "$files"
        return
    fi

    diff=$(git diff --cached 2>/dev/null)
    [ -z "$diff" ] && diff=$(git diff 2>/dev/null)

    # With a ticket, ask for "[AMG-<id>] <description>"; without one, drop the
    # bracketed prefix entirely and ask for just the description.
    local format
    if [ -n "$ticket" ]; then
        format="[$ticket] <short description>"
    else
        format="<short description>"
    fi
    # If the user already started typing after the quote, pass it along as intent.
    local hint_block=""
    if [ -n "$hint" ]; then
        hint_block="The user started typing this commit message as a hint of intent: \"$hint\"
Use it as guidance for the meaning and scope, but still base the message on the actual diff.

"
    fi
    prompt="Write a git commit message for the diff below.

Output format: $format

${hint_block}Rules:
- Output ONLY the commit message itself, on a single line.
- No preamble, no explanation, no quotes, no code fences, no trailing punctuation.
- Do NOT write phrases like \"Here is the commit message\" or \"Based on the changes\".
- The description must be based on the actual changes in the diff.

Here is the git diff of my changes:
$diff"

    msg=$(claude -p "$prompt" 2>/dev/null)
    local line
    if [ -n "$ticket" ]; then
        # The model may wrap the message in prose / code fences. Pull out just
        # the "[ABC-123] ..." line (up to a backtick or end of line).
        line=$(printf '%s\n' "$msg" | grep -oiE '\[[A-Z]+-[0-9]+\][^`]*' | head -n1)
    fi
    # Fallback (no ticket, or no ticket pattern found): the model may still prepend
    # a prose line like "Here is the commit message:". Drop code fences and blank
    # lines, then take the last remaining line (the message itself).
    if [ -z "$line" ]; then
        line=$(printf '%s\n' "$msg" \
            | grep -v '^[[:space:]]*```' \
            | grep -v '^[[:space:]]*$' \
            | tail -n1)
    fi
    printf '%s' "$line" | sed 's/`//g; s/  */ /g; s/^ *//; s/ *$//'
}

_git_commit_ai_complete() {
    local before=${COMP_LINE:0:COMP_POINT}
    # Right after:  ... commit ... -m "   (an open double quote, no closing quote yet)
    if [[ $before == *commit* && $before =~ -m[[:space:]]+\"([^\"]*)$ ]]; then
        # Whatever was typed after the opening quote is passed as a hint; the
        # generated message overwrites it (the quoted string is one completion word).
        local hint=${BASH_REMATCH[1]}
        local msg
        msg=$(_ai_commit_message "$hint")
        # fzf-tab-completion (if it's driving this Tab) inserts by stripping the
        # last shell token and appending COMPREPLY. With a hint typed, that token
        # is `"<hint>` — the opening quote included — so restore it here or the
        # result loses its quote: `git commit -m message`. With no hint the token
        # is a bare `"`, a word-break char fzf leaves in place, so don't add one.
        if [ -n "$hint" ]; then
            local f
            for f in "${FUNCNAME[@]}"; do
                if [ "$f" = _fzf_bash_completion_complete ]; then msg="\"$msg"; break; fi
            done
        fi
        COMPREPLY=( "$msg" )
        compopt -o nospace 2>/dev/null
        return 0
    fi
    # Otherwise fall back to git's normal completion.
    #
    # bash-completion lazy-loads git's completion on first use, which re-runs
    # `complete -F __git_wrap__git_main git` and REPLACES our binding. If we let
    # that happen (e.g. via `_completion_loader git; return 124`), the AI
    # completion fires exactly once and is dead for the rest of the shell.
    # Instead: load the stock completion once, then re-arm ourselves so
    # `git commit -m "<TAB>` still routes here next time, and delegate inline.
    if ! declare -F __git_wrap__git_main >/dev/null && ! declare -F __git_main >/dev/null; then
        declare -F _completion_loader >/dev/null && _completion_loader git >/dev/null 2>&1
    fi
    complete -F _git_commit_ai_complete git   # re-arm: undo the loader's clobber
    if declare -F __git_wrap__git_main >/dev/null; then __git_wrap__git_main "$@"
    elif declare -F __git_main >/dev/null;         then __git_main "$@"
    elif declare -F _git >/dev/null;               then _git "$@"
    fi
}
complete -F _git_commit_ai_complete git
