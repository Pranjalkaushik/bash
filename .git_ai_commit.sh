# AI commit-message completion.
# Type:  git commit -m "<TAB>
# and an AI-generated  [AMG-<ticket>] <description>  message is inserted after the quote.
# When the branch has no AMG-<ticket>, the [AMG-<ticket>] prefix is dropped entirely.
# Anywhere else, Tab behaves as normal git completion.

_ai_commit_message() {
    local branch ticket prefix diff prompt msg
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    # Extract AMG-<id> from the branch name (case-insensitive), normalize to uppercase.
    ticket=$(printf '%s' "$branch" | grep -oiE 'AMG-[0-9]+' | head -n1 | tr '[:lower:]' '[:upper:]')
    [ -n "$ticket" ] && prefix="[$ticket] "

    # If claude isn't installed, fall back to "[AMG-<id>] updated <files>"
    # (prefix omitted entirely when no ticket can be extracted from the branch).
    if ! command -v claude >/dev/null 2>&1; then
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
    prompt="provide a commit msg in following prompt : $format -- the short description should be based on the changes i added -- the response should just be the commit msg

Here is the git diff of my changes:
$diff"

    msg=$(claude -p "$prompt" 2>/dev/null)
    local line
    if [ -n "$ticket" ]; then
        # The model may wrap the message in prose / code fences. Pull out just
        # the "[ABC-123] ..." line (up to a backtick or end of line).
        line=$(printf '%s\n' "$msg" | grep -oiE '\[[A-Z]+-[0-9]+\][^`]*' | head -n1)
    fi
    # Fallback (no ticket, or no ticket pattern found): use the whole output collapsed.
    [ -z "$line" ] && line=$(printf '%s' "$msg" | tr '\n' ' ')
    printf '%s' "$line" | sed 's/`//g; s/  */ /g; s/^ *//; s/ *$//'
}

_git_commit_ai_complete() {
    local before=${COMP_LINE:0:COMP_POINT}
    # Right after:  ... commit ... -m "   (an open double quote, no closing quote yet)
    if [[ $before == *commit* && $before =~ -m[[:space:]]+\"[^\"]*$ ]]; then
        COMPREPLY=( "$(_ai_commit_message)" )
        compopt -o nospace 2>/dev/null
        return 0
    fi
    # Otherwise fall back to git's normal completion.
    if declare -F __git_main >/dev/null;           then __git_main
    elif declare -F _git >/dev/null;               then _git
    elif declare -F _completion_loader >/dev/null; then _completion_loader git; return 124
    fi
}
complete -F _git_commit_ai_complete git
