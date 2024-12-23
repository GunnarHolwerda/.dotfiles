#!/usr/bin/env zsh

echo "DOTFILES is set to: $DOTFILES"
echo "STOW_FOLDERS is set to: $STOW_FOLDERS"

DRY_RUN=0

while [[ "$#" -gt 0 ]]; do
	case $1 in 
		--dry) DRY_RUN=1 ;;
		*) break ;;
	esac
	shift
done

function log() {
	if [[ $DRY_RUN -eq 1 ]]; then
		echo "DRY: $@"
	else
		echo "$@"
		"$@"
	fi
}

# Convert to bash-compatible array handling
pushd "./config" || exit

# Convert comma-separated string to array and iterate
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do

    echo "stow $folder"
    log stow -D "$folder" --target $HOME
    log stow "$folder" --target $HOME
    echo "--------------"
done

popd || exit
