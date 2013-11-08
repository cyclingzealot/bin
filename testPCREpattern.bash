#!/bin/bash

php -R '$pattern="[a-zA-Z0-9 ,]*"; echo "$argn " . (preg_match("|$pattern|", $argn) ? " matches" : "does not match") . " pattern $pattern\n\n";'
