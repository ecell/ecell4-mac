#!/usr/bin/env bash

readonly package=ecell4_base
readonly pattern='\(libicu[a-z0-9]*\.[0-9]*\)\.\([0-9]*\)\.dylib'

readonly cwd=$(pwd)
readonly wheel=${cwd}/$(ls ecell4-base/python/dist/*.whl)
readonly tmpdir=$(mktemp -d)

cd ${tmpdir}
unzip ${wheel}

echo "Fixing ..."
for dylib in $(ls ${package}/.dylibs/libicu*.dylib); do
    change_option=$(basename "$dylib" | grep -e "$pattern" | sed -e "s:^${pattern}$:@loader_path/\1.dylib @loader_path/\1.\2.dylib:g")
    echo "change_option = $change_option"
    for target in $(ls ${package}/.dylibs/lib*.dylib); do
        test -w "${target}" && echo "install_name_tool -change $change_option ${target}" && install_name_tool -change $change_option ${target}
    done
done

echo "Checking ..."
for dylib in $(ls ${package}/.dylibs/lib*.dylib); do
  otool -L ${dylib}
done

zip -r $wheel *
cd ${cwd}
