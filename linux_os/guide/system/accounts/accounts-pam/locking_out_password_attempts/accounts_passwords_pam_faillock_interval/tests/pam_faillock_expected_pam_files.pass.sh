#!/bin/bash
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}
# variables = var_accounts_passwords_pam_faillock_fail_interval=900

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="fail_interval=900" --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 fail_interval=900/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
if [ -f /etc/security/faillock.conf ]; then
    > /etc/security/faillock.conf
fi
