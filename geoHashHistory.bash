#! /usr/bin/perl
#
# GeoHistory - (C) 2012 AeroIllini <aeroillini@gmail.com>
#
# This script generates a kml file containing placemarks for every
# geohash point in a certain graticule since a certain date. The
# default start date is May 21, 2008, which is the date the comic
# first appeared and Geohashing was born.
#
# The output should be piped to a file, and then either loaded in
# Google Earth or hosted on a public server and loaded in Google
# Maps.
#
# The script can be used to explore the random distribution of points,
# or to check for retroactive Couch Potato Awards (or Curse of
# Unawareness Awards).
#
# More information on Geohashing:
# <http://wiki.xkcd.com/geohashing/Main_Page>
#
# ---------------------------------------------------------------------
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ---------------------------------------------------------------------

# Import some useful stuff.
use Date::Calc qw(Add_Delta_Days Delta_Days);
use Time::Local;
use Geo::Hashing;

# This is the start date. Modify as you see fit.
($startyear, $startmonth, $startday) = ("2008", "5", "21");

# This is the graticule we're calculating for.
($lat, $lon) = ("47", "-122");

# Grab the current date.
($a,$a,$a,$todayday,$todaymonth,$todayyear,$a,$a,$a) = localtime(time);

# Translate months for placemark titles.
@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

# Do some interim math.
$todayyear = $todayyear+1900;
$todaymonth = $todaymonth+1;
($year, $month, $day) = ($startyear, $startmonth, $startday);
$delta = Delta_Days(($startyear, $startmonth, $startday),($todayyear,$todaymonth,$todayday));

# Output file header xml stuff
print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.google.com/earth/kml/2\">
<Document>
<name>Historical Geohash Points for ",$lat,",",$lon,"</name>
";

# Main loop
for ($i = 0; $i <= $delta; $i++) {

	# format date for Geo::Hashing
	my $date = sprintf("%04d-%02d-%02d", $year, $month, $day);

	# magic happens!
	my $geo = new Geo::Hashing(lat => $lat, lon => $lon, date => $date);

	# output placemark xml
	print "<Placemark>";
	print "<name>";
	print $months[$month-1]," ",$day,", ",$year;
	print "</name>";
	print "<description>",$geo->lat,", ",$geo->lon,"</description>";
	print "<Point><coordinates>",$geo->lon,",",$geo->lat,"</coordinates></Point>";
	print "</Placemark>","\n";

	# increment day and loop again!
	($year, $month, $day) = Add_Delta_Days($startyear, $startmonth, $startday, $i);
}

# finish up xml file
print "</Document>
</kml>";
