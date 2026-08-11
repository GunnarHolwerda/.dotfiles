#!/usr/bin/env bash

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "no xdg config home"
    echo "using ~/.config"
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$REPO_DIR" ]; then
    echo "env var REPO_DIR needs to be present"
    exit 1
fi

DRY_RUN=0
IS_MAC=0
CONFIG_ONLY=0

while [[ "$#" -gt 0 ]]; do
	case $1 in
	    --dry) DRY_RUN=1 ;;
	    --mac) IS_MAC=1 ;;
	    --config-only) CONFIG_ONLY=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
	esac
	shift
done

function log() {
	if [[ $DRY_RUN -eq 1 ]]; then
		echo "DRY: $@"
	else
		echo "$@"
	fi
}

function update_files() {
    log "symlinking files from: $1 to $2"
    local exclude="$3"
    if ! pushd "$1" &> /dev/null; then
        echo "Failed to pushd to $1"
        return 1
    fi

    echo "Running following commands from: $(pwd)"
    (
        configs=`find . -mindepth 1 -maxdepth 1 -type d -o -type f`
        for c in $configs; do
            # Skip excluded directory
            if [[ -n "$exclude" && "${c#./}" == "$exclude" ]]; then
                log "    skipping: $c (excluded)"
                continue
            fi
            target=${2%/}/${c#./}
            source="$(pwd)/${c#./}"
            log "    removing: rm -rf $target"

            if [[ $DRY_RUN == "0" ]]; then
                rm -rf $target
            fi

            log "    symlinking: ln -s $source $target"
            if [[ $DRY_RUN == "0" ]]; then
                ln -s "$source" "$target"
            fi

        done
    )
    popd &> /dev/null
}

function copy_dir() {
    log echo "copying dir from $1 to $2"
    pushd $1 &> /dev/null
    (
        files=`find . -mindepth 1 -maxdepth 1 -type f`
        for f in $files; do
            copy "$f" "$2/$(basename $f)"
        done

    )
    popd &> /dev/null
}

function copy() {
    log "removing: $2"
    if [[ $DRY_RUN == "0" ]]; then
        rm $2
    fi
    log "copying: $1 to $2"
    if [[ $DRY_RUN == "0" ]]; then
        cp $1 $2
    fi
}

function symlink_personal_skills() {
    # Treat repo-managed skill directories as aliases so any personal skill can be
    # used by Claude Code, Amp/agents, and Codex regardless of which convention
    # the skill was originally stored under.
    local skill_sources=(
        "$REPO_DIR/config/.claude/skills"
        "$REPO_DIR/config/.agents/skills"
        "$REPO_DIR/config/.codex/skills"
    )
    local skill_targets=(
        "$HOME/.claude/skills"
        "$HOME/.agents/skills"
        "${CODEX_HOME:-$HOME/.codex}/skills"
    )
    # An agent should not carry a skill describing how to invoke itself; it
    # invites recursive self-delegation. Entries are "<skill name>:<target dir>".
    #
    # Codex scans ~/.agents/skills as well as its own skills dir, so excluding a
    # self-skill from one root alone does not hide it. Both self-skills are kept
    # out of the shared root, which leaves each one reachable only from the other
    # agent's private directory.
    local skill_target_excludes=(
        "codex:${CODEX_HOME:-$HOME/.codex}/skills"
        "codex:$HOME/.agents/skills"
        "claude-code:$HOME/.claude/skills"
        "claude-code:$HOME/.agents/skills"
    )
    local has_skills=0

    for skills_src in "${skill_sources[@]}"; do
        if [[ -d "$skills_src" ]]; then
            has_skills=1
            break
        fi
    done

    if [[ $has_skills == "0" ]]; then
        return
    fi

    for skills_dir in "${skill_targets[@]}"; do
        log "    ensuring: mkdir -p $skills_dir"
        if [[ $DRY_RUN == "0" ]]; then
            mkdir -p "$skills_dir"
        fi
    done

    for skills_src in "${skill_sources[@]}"; do
        if [[ ! -d "$skills_src" ]]; then
            continue
        fi

        for skill in "$skills_src"/*; do
            if [[ ! -e "$skill" ]]; then
                continue
            fi

            if [[ ! -d "$skill" ]]; then
                log "    skipping: $skill (not a directory)"
                continue
            fi

            skill_name="${skill##*/}"
            for skills_dir in "${skill_targets[@]}"; do
                local excluded=0
                for exclude in "${skill_target_excludes[@]}"; do
                    if [[ "$skill_name:$skills_dir" == "$exclude" ]]; then
                        excluded=1
                        break
                    fi
                done
                log "    removing: rm -rf $skills_dir/$skill_name"
                if [[ $DRY_RUN == "0" ]]; then
                    rm -rf "$skills_dir/$skill_name"
                fi

                # Removed above but not relinked, so a machine installed before
                # the exclusion existed converges on the next run.
                if [[ $excluded == "1" ]]; then
                    log "    skipping: $skill_name in $skills_dir (self-skill)"
                    continue
                fi

                log "    symlinking: ln -s $skill $skills_dir/$skill_name"
                if [[ $DRY_RUN == "0" ]]; then
                    ln -s "$skill" "$skills_dir/$skill_name"
                fi
            done
        done
    done
}

function symlink_claude_config() {
    log "symlinking claude config"
    CLAUDE_DIR="$HOME/.claude"
    CLAUDE_SRC="$REPO_DIR/config/.claude"

    # Ensure ~/.claude exists
    if [[ $DRY_RUN == "0" ]]; then
        mkdir -p "$CLAUDE_DIR"
    fi

    # Symlink CLAUDE.md (global instructions; the AGENTS.md links below point here)
    log "    removing: rm -f $CLAUDE_DIR/CLAUDE.md"
    if [[ $DRY_RUN == "0" ]]; then
        rm -f "$CLAUDE_DIR/CLAUDE.md"
    fi
    log "    symlinking: ln -s $CLAUDE_SRC/CLAUDE.md $CLAUDE_DIR/CLAUDE.md"
    if [[ $DRY_RUN == "0" ]]; then
        ln -s "$CLAUDE_SRC/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    fi

    # Codex reads AGENTS.md, so point both of its global locations at the same file
    for agents_link in "$HOME/AGENTS.md" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"; do
        log "    removing: rm -f $agents_link"
        if [[ $DRY_RUN == "0" ]]; then
            mkdir -p "$(dirname "$agents_link")"
            rm -f "$agents_link"
        fi
        log "    symlinking: ln -s $CLAUDE_SRC/CLAUDE.md $agents_link"
        if [[ $DRY_RUN == "0" ]]; then
            ln -s "$CLAUDE_SRC/CLAUDE.md" "$agents_link"
        fi
    done

    # Symlink settings.json
    log "    removing: rm -f $CLAUDE_DIR/settings.json"
    if [[ $DRY_RUN == "0" ]]; then
        rm -f "$CLAUDE_DIR/settings.json"
    fi
    log "    symlinking: ln -s $CLAUDE_SRC/settings.json $CLAUDE_DIR/settings.json"
    if [[ $DRY_RUN == "0" ]]; then
        ln -s "$CLAUDE_SRC/settings.json" "$CLAUDE_DIR/settings.json"
    fi

    # Symlink commands directory
    log "    removing: rm -rf $CLAUDE_DIR/commands"
    if [[ $DRY_RUN == "0" ]]; then
        rm -rf "$CLAUDE_DIR/commands"
    fi
    log "    symlinking: ln -s $CLAUDE_SRC/commands $CLAUDE_DIR/commands"
    if [[ $DRY_RUN == "0" ]]; then
        ln -s "$CLAUDE_SRC/commands" "$CLAUDE_DIR/commands"
    fi

    # Symlink agents directory (custom subagents)
    log "    removing: rm -rf $CLAUDE_DIR/agents"
    if [[ $DRY_RUN == "0" ]]; then
        rm -rf "$CLAUDE_DIR/agents"
    fi
    log "    symlinking: ln -s $CLAUDE_SRC/agents $CLAUDE_DIR/agents"
    if [[ $DRY_RUN == "0" ]]; then
        ln -s "$CLAUDE_SRC/agents" "$CLAUDE_DIR/agents"
    fi

    symlink_personal_skills

}

function symlink_codex_config() {
    local codex_dir="${CODEX_HOME:-$HOME/.codex}"
    local codex_src="$REPO_DIR/config/.codex"

    log "symlinking codex config"

    if [[ $DRY_RUN == "0" ]]; then
        mkdir -p "$codex_dir/rules"
    fi

    for relative_path in config.toml rules/default.rules hooks.json; do
        # config.toml is gitignored (Codex rewrites it constantly), so a fresh
        # clone has no source to link. Linking anyway leaves a broken symlink.
        if [[ ! -e "$codex_src/$relative_path" ]]; then
            log "    skipping: $codex_src/$relative_path does not exist"

            # A machine installed before the file was ignored still points here.
            # Drop that link so Codex writes a real file, but never touch a
            # regular file: -L with a failing -e matches only a dangling link.
            if [[ -L "$codex_dir/$relative_path" && ! -e "$codex_dir/$relative_path" ]]; then
                log "    removing dangling link: rm -f $codex_dir/$relative_path"
                if [[ $DRY_RUN == "0" ]]; then
                    rm -f "$codex_dir/$relative_path"
                fi
            fi
            continue
        fi

        log "    removing: rm -f $codex_dir/$relative_path"
        if [[ $DRY_RUN == "0" ]]; then
            rm -f "$codex_dir/$relative_path"
        fi
        log "    symlinking: ln -s $codex_src/$relative_path $codex_dir/$relative_path"
        if [[ $DRY_RUN == "0" ]]; then
            ln -s "$codex_src/$relative_path" "$codex_dir/$relative_path"
        fi
    done
}

function symlink_zed_config() {
    log "symlinking zed config"
    ZED_DIR="$XDG_CONFIG_HOME/zed"
    ZED_SRC="$REPO_DIR/config/.config/zed"

    # Ensure ~/.config/zed and snippets dir exist
    if [[ $DRY_RUN == "0" ]]; then
        mkdir -p "$ZED_DIR"
    fi

    # Symlink individual config files
    for f in settings.json keymap.json tasks.json; do
        log "    removing: rm -f $ZED_DIR/$f"
        if [[ $DRY_RUN == "0" ]]; then
            rm -f "$ZED_DIR/$f"
        fi
        log "    symlinking: ln -s $ZED_SRC/$f $ZED_DIR/$f"
        if [[ $DRY_RUN == "0" ]]; then
            ln -s "$ZED_SRC/$f" "$ZED_DIR/$f"
        fi
    done

    # Symlink snippets directory
    log "    removing: rm -rf $ZED_DIR/snippets"
    if [[ $DRY_RUN == "0" ]]; then
        rm -rf "$ZED_DIR/snippets"
    fi
    log "    symlinking: ln -s $ZED_SRC/snippets $ZED_DIR/snippets"
    if [[ $DRY_RUN == "0" ]]; then
        ln -s "$ZED_SRC/snippets" "$ZED_DIR/snippets"
    fi
}

log "env: $REPO_DIR"

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi
copy_dir "$REPO_DIR/scripts" "$HOME/.local/bin"

update_files "$REPO_DIR/config/.config" $XDG_CONFIG_HOME "zed"
copy "$REPO_DIR/config/.zshrc" "$HOME/.zshrc"
copy "$REPO_DIR/config/.zsh_profile" "$HOME/.zsh_profile"
symlink_claude_config
symlink_codex_config
symlink_zed_config

if [ $IS_MAC -eq 0 ]; then
    copy "$REPO_DIR/config/.Xresources" "$HOME/.Xresources"
    update_files "$REPO_DIR/config/ubuntu" "$XDG_CONFIG_HOME"
fi

function install_programs() {
    log echo "installing programs from: $1"
    pushd $1 &> /dev/null
    (
        programs=`find . -mindepth 1 -maxdepth 1 -type f`
        for p in $programs; do
            log echo "    installing: $p"
            if [[ $DRY_RUN == "0" ]]; then
                $p
            fi
        done

    )
    popd &> /dev/null
}

if [ $CONFIG_ONLY -eq 0 ]; then
	if [ $IS_MAC -eq 0 ]; then
		install_programs "$REPO_DIR/programs/ubuntu"
	else
		install_programs "$REPO_DIR/programs/mac"
	fi
else
	log "Skipping install as --config-only was specified"
fi

log "Run 'source ~/.zshrc' to setup shell"
