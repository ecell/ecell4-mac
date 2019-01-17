#!/usr/bin/env bash

cd ecell4/python/dist

readonly pattern='\(libicu[a-z0-9]*\.[0-9]*\)\.\([0-9]*\)\.dylib'
readonly no_minor_pattern='libicu[a-z0-9]*\.[0-9]*\.dylib\)'

readonly wheel=$(ls *.whl)
unzip $wheel

for dylib in $(ls ecell4/.dylibs/libicu*.dylib); do
    change_option=$(basename "$dylib" | grep -e "$pattern" | sed -e "s:^${pattern}$:@loader_path/\1.dylib @loader_path/\1.\2.dylib:g")
    for target in $(ls ecell4/.dylibs/lib*.dylib); do
        test -w "$target" && install_name_tool -change $change_option $target
    done
done

readonly files=$(ls -d ecell*)
readonly tmp=$(mktemp).zip
zip -r $tmp $files && rm -rf $wheel $files && mv $tmp $wheel
