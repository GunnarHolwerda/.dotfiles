#!/usr/bin/env bash

fonts_dir="${HOME}/.local/share/fonts"
if [ ! -d "${fonts_dir}" ]; then
    echo "mkdir -p $fonts_dir"
    mkdir -p "${fonts_dir}"
else
    echo "Found fonts dir $fonts_dir"
fi

version=6.2
zip=/tmp/Fira_Code_v${version}.zip
curl --fail --location --show-error https://github.com/tonsky/FiraCode/releases/download/${version}/${zip} --output ${zip}
unzip -o -q -d ${fonts_dir} ${zip}
rm ${zip}

wget -P $fonts_dir https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip
unzip $fonts_dir/0xProto -d $fonts_dir
rm -rf $fonts_dir/0xProto.zip

echo "fc-cache -f"
fc-cache -f
