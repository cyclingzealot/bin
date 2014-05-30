#!/bin/bash

php -R '$string="\"/tags/58fe2cec-cf2b-11e3-aa5c-08002753f3d2\": ["; $pattern = trim($argn); echo "$string " . (preg_match("|$pattern|", $string) === 1 ? " matches" : "does not match") . " pattern $pattern\n\n";'
