#!/usr/bin/env php
<?php

$active_builds = [];

$all_versions = json_decode( file_get_contents( 'https://omahaproxy.appspot.com/all.json' ), true );

foreach ( $all_versions as $oses ) {
	if ( $oses['os'] === 'linux' ) {
		foreach ( $oses['versions'] as $version ) {
			$active_builds[] = [
				'version' => explode( '.', $version['current_version'] ),
				'vs'      => $version['current_version'],
				'channel' => $version['channel'],
			];
		}
		break;
	}
}
unset( $all_versions );

$versionsh   = "#!/bin/bash\n";

foreach ( $active_builds as $build ) {
	$versionsh .= <<<SH
echo "${build['channel']}" > versions/${build['vs']}

SH;
}

file_put_contents( 'versions.sh', $versionsh );
chmod( 'versions.sh', 0766 );