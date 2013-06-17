# makes sure the play app $name is running
#
# === Parameters
#
# [*user*] The user owning the application.
# [*ensure*] running or stopped.
#
# === Variables
#
# === Examples
#
#   play:service { 'test-app':
#       user            => 'appuser',
#       ensure          => running,
#    }
#
# === Authors
#
# Dimitri Tischenko <dimitri@proteon.nl>
#
# === Copyright
#
# Copyright 2013 Proteon
#
define play::service (
    $user   = $name,
    $ensure = running,) {
    $app       = $name
    $user_home = "${play::params::appsdir}/${user}"
    $app_home  = "${user_home}/${app}"

    service { "play_${app}":
        ensure     => $ensure,
        pattern    => "java.*${app}",
        start      => "su -c ${user_home}/bin/startup.sh ${user}",
        stop       => "su -c ${user_home}/bin/shutdown.sh ${user}",
        hasstatus  => false,
        hasrestart => false,
        provider   => base,
    }

    package { 'lsof':
        ensure => installed,
        before => Service["play_${app}"],
    }
}
