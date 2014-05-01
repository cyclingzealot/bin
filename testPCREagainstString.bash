#!/bin/bash

php -R '$string="001154ac-d0a1-11e3-9935-08002753f3d2"; $pattern = trim($argn); echo "$string " . (preg_match("|$pattern|", $string) === 1 ? " matches" : "does not match") . " pattern $pattern\n\n";'
