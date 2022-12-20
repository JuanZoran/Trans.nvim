#!/bin/bash
set -e

wget https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip -O /tmp/dict.zip

unzip /tmp/dict.zip -d $HOME/.vim/dict

rm -rf /tmp/dict.zip
