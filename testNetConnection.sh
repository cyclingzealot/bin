#!/bin/sh

echo Attempting to reach router -----------------------------------------
ping -c 3 10.0.0.100
echo
echo
echo

echo Attempting to reach outside OpenDNS -------------------------------
ping -c 3 208.67.222.222
echo
echo
echo

echo Attempting to reach flora via numeric IP ---------------------------
ping -c 3 69.165.168.66
echo
echo
echo

echo Attempting to reach web site via domain name ---------------------------
ping -c 3 www.julienlamarche.ca
echo
echo
echo

echo Atempting to reach julienlamarche.ca via domain name using port 80 ---------------
lynx -dump www.julienlamarche.ca | head -n 10
echo
echo
echo
