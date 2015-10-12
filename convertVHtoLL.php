# From http://www.voip-info.org/wiki/view/PHP%3A+V+and+H+Coordinate+functions

function vh2ll($v,$h)
{
	//Constants shamelessly stolen from vh2ll.c
	$transv=6363.235;
	$transh=2250.7;
	$rotc=0.23179040;
	$rots=0.97276575;
	$radius=12481.103;
	$ex=0.40426992;
	$ey=0.68210848;
	$ez=0.60933887;
	$wx=0.65517646;
	$wy=0.37733790;
	$wz=0.65449210;
	$px=-0.555977821730048699;
	$py=-0.345728488161089920;
	$pz=0.755883902605524030;
	$gx=0.216507961908834992;
	$gy=-0.134633014879368199;
	$a=0.151646645621077297;
	$q=-0.294355056616412800;
	$q2=0.0866448993556515751;
	$bi = array( 1.00567724920722457, -0.00344230425560210245, 0.000713971534527667990, -0.0000777240053499279217, 0.00000673180367053244284, -0.000000742595338885741395,  0.0000000905058919926194134 );
	$t1 = ($v - $transv) / $radius;
	$t2 = ($h - $transh) / $radius;
	$vhat = $rotc*$t2 - $rots*$t1;
	$hhat = $rots*$t2 + $rotc*$t1;
	$e = cos(hypot($vhat, $hhat));
	$w = cos(hypot($vhat, $hhat-0.4));
	$fx = $ey*$w - $wy*$e;
	$fy = $ex*$w - $wx*$e;
	$b = $fx*$gx + $fy*$gy;
	$c = $fx*$fx + $fy*$fy - $q2;
	$disc = $b*$b - $a*$c; //discriminant
	if ($disc == 0.0) { //It's right on the E-W axis
		$z = $b/$a;
		$x = ($gx*$z - $fx)/$q;
		$y = ($fy - $gy*$z)/$q;
	} else {
		$delta = sqrt($disc); 
		$z = ($b + $delta)/$a;
		$x = ($gx*$z - $fx)/$q;
		$y = ($fy - $gy*$z)/$q;
		if ( $vhat * ( $px*$x + $py*$y + $pz*$z) < 0 ) { //wrong direction
			$z = ($b - $delta)/$a;
			$x = ($gx*$z - $fx)/$q;
			$y = ($fy - $gy*$z)/$q;
		}
	}

	$lat=asin($z);
	//Use polynomial approximation for inverse mapping
	//(sphere to spheroid)
	$lat2 = $lat*$lat;
	$earthlat = 0;
	for ($i=6; $i>=0 ; $i--) {
		$earthlat = ($earthlat + $bi[$i]) * ($i? $lat2 : $lat);
	}

	$earthlat = rad2deg($earthlat);
	// Adjust Longitude by 52 degrees
	$lon = rad2deg(atan2($x,$y));
	$earthlon = $lon + 52.0000000000000000;
	return array('lat' => $earthlat,'lon' => $earthlon);
}

function vhdistance($v1,$h1, $v2, $h2)
{
	//ceil is used to round up, telco rounds up
	return ceil(hypot($v1-$v2, $h1-$h2) / sqrt(10));
}

#USAGE :

$distance vhdistance("06817","08931","06929","08958");
$latlon = (vh2ll("06929","08958");
