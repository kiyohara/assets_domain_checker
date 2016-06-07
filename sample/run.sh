#!/usr/bin/env bash
THIS_FILE_PATH=${BASH_SOURCE[0]-$0}
THIS_FILE_DIR=$(cd $(dirname $THIS_FILE_PATH); pwd)
######################################################################

cd $THIS_FILE_DIR

URI_LIST=uri_list.txt
if [ ! -e $URI_LIST ];then
  URI_LIST=uri_list.txt.sample
fi
echo '**' $URI_LIST handling ...

../exe/assets_domain_checker bulk_list --file uri_list.txt > _list.ltsv &&
../exe/assets_domain_checker convert --file _list.ltsv > _conv.ltsv &&
../exe/assets_domain_checker snip --file _conv.ltsv --depth 2 > _snip.ltsv &&

echo '** tag base rating **'
../exe/assets_domain_checker gbsnipped --file _snip.ltsv

echo '** domain base rating **'
../exe/assets_domain_checker gbsnipped --file _snip.ltsv --domain-count true
