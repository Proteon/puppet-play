# Deploys a play application from a nexus repository.
# The application is supposed to be created with the "play dist" command.
#
# === Parameters
#
# [*user*] The user owning the application.
# [*dir*] The directory to deploy to
# [*group*] The artifact group.
# [*artifact*] The artifact name.
# [*version*] The artifact version.
# [*url*] the url to the artifact repository.
#
# === Examples
#
#   play:nexus_deploy { 'test-app':
#       user        => 'appuser',
#       group       => 'my.apps',
#       artifact    => 'test-app',
#       version     => '1.0.0-SNAPSHOT',
#       snapshots   => true,
#       url         => 'http://my.repo/snapshots',
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
define play::maven_deploy ($user, $dir, $groupid, $artifactid, $version,) {
    $zip_file = "${artifactid}-${version}.zip"

    maven { "${dir}/${zip_file}":
        groupid    => $groupid,
        artifactid => $artifactid,
        version    => $version,
        packaging  => 'zip',
        notify     => Exec["unzip_${name}"],
    }

    exec { "unzip_${name}":
        cwd         => $dir,
        command     => "rm -rf ${name} && unzip ${zip_file} -d ${name} && mv ${name}/* ${name}/${artifact} && chown -R ${user} ${name}",
        refreshonly => true,
    }
}
