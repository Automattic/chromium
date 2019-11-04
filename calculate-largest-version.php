#!/usr/bin/env php
<?php

$active_builds = [];

$all_versions = json_decode( file_get_contents( 'https://omahaproxy.appspot.com/all.json' ), true );

foreach ( $all_versions as $oses ) {
	if ( $oses['os'] === 'linux' ) {
		$all_versions = $oses['versions'];
		break;
	}
}

foreach ( $all_versions as $version ) {
	$active_builds[] = [
		'version' => explode( '.', $version['current_version'] ),
		'vs'      => $version['current_version'],
		'channel' => $version['channel'],
	];
}

$max_version = $active_builds[0]['version'];
$versionsh   = "#!/bin/bash\n";

foreach ( $active_builds as $build ) {

	if ( $max_version[0] < $build['version'][0] ) {
		$max_version = $build['version'];
	} else if ( $max_version[0] === $build['version'][0] && $max_version[1] < $build['version'][1] ) {
		$max_version = $build['version'];
	}

	$versionsh .= <<<SH
echo "${build['channel']}" > versions/${build['vs']}

SH;
}

file_put_contents( 'versions.sh', $versionsh );
chmod( 'versions.sh', 0766 );