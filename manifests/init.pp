# This class only creates some directories and
# includes dependent classes.
# The interesting behaviour is in play::app and play::runtime.
# === Parameters
#
# === Variables
#   
# === Examples
#
# === Authors
#
# Dimitri Tischenko <dimitri@proteon.nl>
#
# === Copyright
#
# Copyright 2013 Proteon
#
class play () 
{
    include play::params
    include java

    group { 'play':
        ensure => present,
    }

    file { $play::params::basedir:
        ensure => directory;
    }

    file { "${play::params::basedir}/apps":
        ensure => directory;
    }
}
