#!/usr/bin/env php
<?php

$files = scandir( 'versions' );

foreach ( $files as $version ) {
	if ( in_array( $version, [ '.', '..' ] ) ) {
		continue;
	}

	$size = stat( "versions/$version" )['size'];

	if ( $size === 0 ) {
		unlink( "versions/$version" );
		$builds = scandir( 'built' );
		foreach ( $builds as $owner ) {
			if ( in_array( $owner, [ '.', '..' ] ) ) {
				continue;
			}

			if ( file_exists( "built/$owner/$version" ) ) {
				unlink( "built/$owner/$version" );
			}
		}
	}
}