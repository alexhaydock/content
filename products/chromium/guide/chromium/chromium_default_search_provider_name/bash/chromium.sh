# platform = Google Chromium Browser

{{{ bash_instantiate_variables("var_default_search_provider_name") }}}

CHROME_POL_FILE="chrome_stig_policy.json"
CHROME_POL_DIR="/etc/chromium/policies/managed/"
POL_SETTING="DefaultSearchProviderName"
POL_SETTING_VAL=$(echo ${var_default_search_provider_name} | sed 's/\//\\\/\\/')

grep -q ${POL_SETTING} ${CHROME_POL_DIR}/${CHROME_POL_FILE}

if ! [ $? -eq 0 ] ; then
   sed -i -e '/{/a \  "'${POL_SETTING}'": "'${var_default_search_provider_name}'",' ${CHROME_POL_DIR}/${CHROME_POL_FILE}
else
   sed -i -e 's/\"'${POL_SETTING}'\".*/\"'${POL_SETTING}'\": \"'${POL_SETTING_VAL}'\",/g' ${CHROME_POL_DIR}/${CHROME_POL_FILE}
fi
