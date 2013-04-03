# Deploys a play application from a nexus repository.
# The application is supposed to be created with the "play dist" command.
#
# === Parameters
#
# [*user*] The user owning the application.
# [*nexus_group*] The artifact group.
# [*nexus_artifact*] The artifact name.
# [*nexus_snapshots*] true means the repository contains snapshots, false means releases.
# [*db_host*] The host for the app's database. If localhost, a local mysql server is setup and configured. If not localhost, the configuration should
# be done elsewhere.
# [*db_port*] Port of the database server, defaults to 3306.
# [*db_name*] Database name, defaults to app name.
# [*db_user*] The user owning the database.
# [*db_password*] The password for the database, looked up in hiera if not specified.
# [*ip*] The IP address the app should listen on, defaults to 0.0.0.0.
# [*port*] The port the app should listen on, defaults to 9000.
# [*max_memory*] The max memory of the jvm for the app, defaults to 512 MB.
# [*cmdline_options*] The optional command line options for the play app.
#  
# === Examples
#
#   play:app { 'test-app':
#        user            => 'appuser',
#        nexus_group     => 'my.apps',
#        nexus_artifact  => 'test-app',
#        nexus_version   => '1.0.0-SNAPSHOT',
#        nexus_snapshots => true,
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
define play::app (
    $user,
    $nexus_group, 
    $nexus_artifact, 
    $nexus_version, 
    $nexus_snapshots    = true,
    $db_host            = 'localhost',
    $db_port            = '3306',
    $db_name            = undef,
    $db_user            = undef,
    $db_password,
    $ip                 = '0.0.0.0',
    $port               = '9000',
    $max_memory         = '512', 
    $cmdline_options    = '',
) {
        
    include play
    include mysql
    
    if !defined (Package[zip]) {
        package { 'zip':
            ensure => installed,
        }
    }
    $app = $name
    $user_home = "${play::params::appsdir}/${user}"
    $app_home = "${user_home}/${name}"

    if $db_name {
        $real_db_name = $db_name
    } else {
        $real_db_name = $app
    }

    if $db_user {
        $real_db_user = $db_user
    } else {
        $real_db_user = $user
    }

    if $db_host == 'localhost' {
        include mysql::server
        mysql::db { $real_db_name:
            user        => $real_db_user,
            password    => $db_password,
        }
    }

    file { $user_home:
        ensure  => directory,
        owner   => $user,
        group   => 'play',
    }

    file { "${user_home}/bin":
        ensure  => directory,
        owner   => $user,
        group   => 'play',
    }

    $config_file = "${user_home}/${app}.conf"
    file { $config_file:
        content => template('play/conf.erb'),
    }

    file { "${user_home}/bin/startup.sh":
        owner   => 'root',
        group   => 'play',
        mode    => '755',
        content => template('play/startup.sh.erb'),
    }

    file { "${user_home}/bin/shutdown.sh":
        owner   => 'root',
        group   => 'play',
        mode    => '755',
        content => template('play/shutdown.sh.erb'),
    }

    user { $user:
        home        => $user_home,
        groups      => ['play'],
    }

    play::nexus_deploy { $app:
        dir         => $user_home,
        user        => $user,
        group       => $nexus_group,
        artifact    => $nexus_artifact,
        version     => $nexus_version,
        snapshots   => $nexus_snapshots,
        require     => File[$user_home],
    }
}