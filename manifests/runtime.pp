# installs a play framework runtime
#
# === Variables
#   
# [*version*] The play version
#
# === Authors
#
# Dimitri Tischenko <dimitri@proteon.nl>
#
# === Copyright
#
# Copyright 2013 Proteon
#
class play::runtime(
    $version = $play::params::version,
) {
    
    $download_url="http://downloads.typesafe.com/play/${version}/play-${version}.zip"

    $play_home = "${play::params::basedir}/play-${version}"

    exec { "install-play-${version}":
        command     => "wget ${download_url} && unzip play-${version}.zip",
        creates     => $play_home,
        cwd         => $play::params::basedir,
        before      => File[$play::params::play_executable],
    }

    file { $play::params::play_executable:
        ensure => symlink,
        target => "${play_home}/play",
    }

    file { "${play_home}/repository":
        ensure  => directory,
        group   => 'play',
        mode    => '0775',
        require => Exec["install-play-${version}"],
    }

    file { "${play_home}/framework/sbt/boot":
        ensure  => directory,
        group   => 'play',
        mode    => '0775',
        require => Exec["install-play-${version}"],
    }
}