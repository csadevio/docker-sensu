#!/bin/bash
urls_src=${CHECK_URL_SRC}
if [ "$urls_src" = "" ]; then
	echo "CHECK_URL_SRC is empty"
	exit
fi

if [ ! -e "$urls_src" ]; then
	echo "$urls_src does not exists"
	exit
fi

urls=`cat $urls_src`

tmpl=${CHECK_URL_TMPL}
if [ "$tmpl" = "" ]; then
	tmpl=/etc/sensu/templates/checks/check_http.json.tmpl
fi

config_dir=${CHECK_CONFIG_DIR}
if [ "$config_dir" = "" ]; then
	config_dir=/etc/sensu/conf.d
fi

for line in $urls
do
	url=`echo $line | cut -d";" -f1`
	name=`echo $line | cut -d";" -f2 -s`
	option=`echo $line | cut -d";" -f3 -s`
	if [ "$name" = "" ]; then
		name=`echo "$url" | sed "s/://gi" | sed "s/\./_/gi" | sed "s/\///gi" | sed "s/http//gi" | sed "s/https//gi"` 
	fi

	export CHECK_NAME=$name
	export CHECK_URL=$url
	export CHECK_OPTION=$option

	file=$config_dir/$name.json

	dockerize -template $tmpl:$file echo $file
done
