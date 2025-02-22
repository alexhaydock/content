#!/bin/bash
{{%- if product in ["rhel7"] %}}
# packages = authconfig
{{%- else %}}
# packages = authselect
{{%- endif %}}

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="even_deny_root" --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 even_deny_root/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
if [ -f /etc/security/faillock.conf ]; then
    > /etc/security/faillock.conf
fi
