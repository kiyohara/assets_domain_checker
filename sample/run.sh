#!/usr/bin/env bash
THIS_FILE_PATH=${BASH_SOURCE[0]-$0}
THIS_FILE_DIR=$(cd $(dirname $THIS_FILE_PATH); pwd)
######################################################################

cd $THIS_FILE_DIR
../exe/assets_domain_checker bulk_list --file uri_list.txt > list.ltsv &&
../exe/assets_domain_checker convert --file list.ltsv > conv.ltsv &&
../exe/assets_domain_checker snip --file conv.ltsv --depth 2 > snip.ltsv &&

echo '** tag base rating **'
../exe/assets_domain_checker gbsnipped --file snip.ltsv

echo '** domain base rating **'
../exe/assets_domain_checker gbsnipped --file snip.ltsv --domain-count true
