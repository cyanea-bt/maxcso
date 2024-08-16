#!/bin/bash
# ref: https://stackoverflow.com/a/52860837



# ref: https://stackoverflow.com/a/34195247, https://stackoverflow.com/a/46022082, https://serverfault.com/a/382740
# find first match for MSBuild tools (any version) and add it to the PATH variable
path_msbuild=$(compgen -G "/c/Program Files/Microsoft Visual Studio/*/*/MSBuild/Current/Bin/amd64" | head -n 1)
path_msbuild_x86=$(compgen -G "/c/Program Files (x86)/Microsoft Visual Studio/*/*/MSBuild/Current/Bin/amd64" | head -n 1)
if [[ -n ${path_msbuild} ]]; then
    echo -e "MSBuild:\n\"${path_msbuild}\"\n"
    PATH="$PATH"':'"${path_msbuild}"
elif [[ -n ${path_msbuild_x86} ]]; then
    echo -e "MSBuild:\n\"${path_msbuild_x86}\"\n"
    PATH="$PATH"':'"${path_msbuild_x86}"
else
    echo "Error: No MSBuild found!"
    exit 1
fi

# find first match for 7-Zip (any version) and add it to the PATH variable
path_sevenzip=$(compgen -G "/c/Program Files/7-Zip" | head -n 1)
path_sevenzip_x86=$(compgen -G "/c/Program Files (x86)/7-Zip" | head -n 1)
if [[ -n ${path_sevenzip} ]]; then
    echo -e "7-Zip:\n\"${path_sevenzip}\"\n"
    PATH="$PATH"':'"${path_sevenzip}"
elif [[ -n ${path_sevenzip_x86} ]]; then
    echo -e "7-Zip:\n\"${path_sevenzip_x86}\"\n"
    PATH="$PATH"':'"${path_sevenzip_x86}"
else
    echo "Error: No 7-Zip found!"
    exit 1
fi

# find commit hashes for master/cyanea branches
hash_master="$(git rev-parse --short master)"
hash_fork="$(git rev-parse --short cyanea)"
echo "master: ${hash_master}"
echo -e "cyanea: ${hash_fork}\n"
read -p "Press enter to continue"
if [[ -z ${hash_master} ]]; then
    echo "master commit not found!"
    exit 1
fi
if [[ -z ${hash_fork} ]]; then
    echo "cyanea commit not found!"
    exit 1
fi

# build, archive and clean
cd cli
msbuild.exe "maxcso.sln" //t:Rebuild //m //p:Configuration='Release;Platform=Win32'
msbuild.exe "maxcso.sln" //t:Rebuild //m //p:Configuration='Release;Platform=x64'
cd ..

archive_name="build_${hash_master} (fork ${hash_fork}).7z"
rm -f "${archive_name}"
7z.exe a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "${archive_name}" \
       "maxcso.exe" "maxcso32.exe" "README.md" "README_CSO.md" "README_ZSO.md" "LICENSE.md" "examples"

echo
read -p "Press enter to continue"

cd cli
msbuild.exe "maxcso.sln" //t:Clean //m //p:Configuration='Release;Platform=Win32'
msbuild.exe "maxcso.sln" //t:Clean //m //p:Configuration='Release;Platform=x64'
