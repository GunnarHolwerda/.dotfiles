#!/usr/bin/env zsh

echo "DOTFILES is set to: $DOTFILES"
echo "STOW_FOLDERS is set to: $STOW_FOLDERS"

# Convert to bash-compatible array handling
pushd "$DOTFILES" || exit

# Convert comma-separated string to array and iterate
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do

    echo "stow $folder"
    stow -D "$folder"
    stow "$folder"

    echo "--------------"
done

popd || exit
