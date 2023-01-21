#!/usr/bin/env bash
set -e

if [[ -d "$HOME/.vim" ]]; then
    if [[ -d "$HOME/.vim/dict" && -f "$HOME/.vim/dict/ultimate.db" ]]; then
        echo 'db has been installed'
        exit 0
    fi
else
    echo '$HOME/.vim not exist'
    exit 1
fi
wget https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip -O /tmp/dict.zip

unzip /tmp/dict.zip -d $HOME/.vim/dict


rm -rf /tmp/dict.zip


uNames=`uname -s`
osName=${uNames: 0: 4}
if [ "$osName" != "Linux" ];then
    cd ./tts/ && npm install
fi
