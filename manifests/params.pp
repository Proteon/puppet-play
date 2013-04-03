# Various play parameters
#
# === Variables
#   
# [*version*] The play version
# [*basedir*] The directory play will be installed to
# [*appsdir*] The directory play apps will be installed in
# [*play_executable*] The path the play executable will be symlinked to
#
# === Authors
#
# Dimitri Tischenko <dimitri@proteon.nl>
#
# === Copyright
#
# Copyright 2013 Proteon
#
class play::params {

    $version            = '2.1.0'
    $basedir            = '/opt/play'
    $appsdir            = "${basedir}/apps"
    $play_executable    = '/usr/local/bin/play'
}