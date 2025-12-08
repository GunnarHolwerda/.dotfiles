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
    if ! pushd "$1" &> /dev/null; then
        echo "Failed to pushd to $1"
        return 1
    fi

    echo "Running following commands from: $(pwd)"
    (
        configs=`find . -mindepth 1 -maxdepth 1 -type d -o -type f`
        for c in $configs; do
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

log "env: $REPO_DIR"

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi
copy_dir "$REPO_DIR/scripts" "$HOME/.local/bin"

update_files "$REPO_DIR/config/.config" $XDG_CONFIG_HOME
copy "$REPO_DIR/config/.zshrc" "$HOME/.zshrc"
copy "$REPO_DIR/config/.zsh_profile" "$HOME/.zsh_profile"

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
