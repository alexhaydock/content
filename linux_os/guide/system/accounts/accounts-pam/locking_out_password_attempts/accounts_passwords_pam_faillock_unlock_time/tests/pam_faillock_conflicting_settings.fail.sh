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
# Older versions of authselect, which don't support faillock.conf will complain if any change
# is made in pam files, even for different but valid arguments. In practical, if any change in
# default pam_faillock.so parameters is necessary for hardening, old versions of authselect no
# longer can be used to manage pam. This will impact the ansible remediation for older versions
# of authselect in the specific context of this test scenario, for example, in a RHEL 8.0 and 8.1.
# However, the remediation should work properly in a realistic scenario.
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 unlock_time=600/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "unlock_time=600" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
