#!/bin/sh

SOURCE_PATH=""
IS_DEBUG=false

while getopts "r:d" opt #选项后面的冒号表示该选项需要参数
do
    case $opt in
        r)
           echo "r's arg:$OPTARG" #参数存在$OPTARG中
           SOURCE_PATH=${OPTARG}
           ;;
        d)
           echo "debug" #参数存在$OPTARG中
           IS_DEBUG=true
           if [ IS_DEBUG ]; then
            set -ex
           fi
           ;;
        ?)  #当有不认识的选项的时候arg为?
            echo "Usage: "
            echo "  -r ROOT_PATH"
            echo "  -d IS_DEBUG"
    exit 1
    ;;
    esac
done

# update steps
## 1. root

## 2. .obsidian
mkdir -p ./.obsidian/
cp -r ${SOURCE_PATH}/.obsidian/* ./.obsidian/
rm -rf .obsidian/git_cfg

## 3. 0.unsorted
mkdir -p ./0.unsorted/

## 4. 1.index
mkdir -p ./1.index/
mkdir -p ./1.index/index-diary
mkdir -p ./1.index/index-life
mkdir -p ./1.index/index-note
mkdir -p ./1.index/index-phrase
mkdir -p ./1.index/index-technology
cp ${SOURCE_PATH}/1.index/*.md ./1.index/

## 5. 2.fleeting
mkdir -p ./2.fleeting/

## 6. 3.literature
mkdir -p ./3.literature/

## 7. 4.permanent
mkdir -p ./4.permanent/

## 8. 5.tags
mkdir -p ./5.tags/

## 9. 6.readwise
mkdir -p ./6.readwise/

## 10. 7.archive
mkdir -p ./7.archive/

## 11. 8.templates
mkdir -p ./8.templates
cp -r ${SOURCE_PATH}/8.templates/* ./

## 12. 9.src
mkdir -p ./9.src

## 13. a.logseq
mkdir -p ./a.logseq
