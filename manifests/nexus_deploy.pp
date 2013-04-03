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
define play::nexus_deploy(
    $user,
    $dir,
    $group,
    $artifact,
    $version,
    $url        = undef,
    $snapshots  = true,
) {

    $app = $name
    $repository = $snapshots ? {
        true    => 'snapshots',
        false   => 'releases',
        default => 'snapshots',
    }

    nexus::artifact { $name:
        ensure      => present,
        url         => $url,
        group       => $group,
        artifact    => $artifact,
        version     => $version,
        repository  => $repository,
        packaging   => 'zip',
        cwd         => $dir,
        notify      => Exec["unzip_${name}"],
    }

    $zip_file   = "${artifact}-${version}.zip"

    exec { "unzip_${name}":
        cwd         => $dir,
        command     => "rm -rf ${app} && unzip ${zip_file} -d ${app} && mv ${app}/* ${app}/${artifact} && chown -R ${user} ${app}",
        refreshonly => true, 
    }
}
