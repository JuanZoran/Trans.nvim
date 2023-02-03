#!/usr/bin/env bash
set -e

if test -e "$HOME/.vim/dict/ultimate.db"; then
    exit
fi


mkdir -p "$HOME/.vim/dict"

wget https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip -O /tmp/dict.zip

unzip /tmp/dict.zip -d "$HOME/.vim/dict" && rm -rf /tmp/dict.zip

uNames=$(uname -s)
osName=${uNames: 0: 4}
if [ "$osName" != "Linux" ];then
    cd ./tts/ && npm install
fi
