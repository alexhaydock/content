#!/bin/bash
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
fi
# Ensure the parameters only in /etc/security/faillock.conf
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "unlock_time=900" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
