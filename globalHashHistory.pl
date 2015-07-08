#! /usr/bin/perl

use Date::Calc qw(Add_Delta_Days Delta_Days);
use Time::Local;
use Geo::Hashing;
@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
($startyear, $startmonth, $startday) = ("2008", "5", "21");
($year, $month, $day) = ($startyear, $startmonth, $startday);
($lat, $lon) = ("47", "-122");
($a,$a,$a,$todayday,$todaymonth,$todayyear,$a,$a,$a) = localtime(time);
$todayyear = $todayyear+1900;
$todaymonth = $todaymonth+1;
$delta = Delta_Days(($startyear, $startmonth, $startday),($todayyear,$todaymonth,$todayday));

print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.google.com/earth/kml/2\">
<Document>
<name>Historical Global Geohash Points</name>
";

for ($i = 0; $i <= $delta; $i++) {
	my $date = sprintf("%04d-%02d-%02d", $year, $month, $day);
	my $geo = new Geo::Hashing(date => $date, use_30w_rule => "1");
	$globallat = ($geo->lat * 180) - 90;
	$globallon = ($geo->lon * 360) - 180;
	print "<Placemark>";
	print "<name>";
	print $months[$month-1]," ",$day,", ",$year;
	print "</name>";
	print "<description>Global: ",$globallat,", ",$globallon,"</description>";
	print "<Point><coordinates>",$globallon,",",$globallat,"</coordinates></Point>";
	print "</Placemark>","\n";
	($year, $month, $day) = Add_Delta_Days($startyear, $startmonth, $startday, $i);
}

print "</Document>
</kml>";
