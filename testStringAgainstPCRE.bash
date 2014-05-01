#!/bin/bash

php -R '$pattern="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"; $string = trim($argn); echo "$string " . (preg_match("|$pattern|", $string) === 1 ? " matches" : "does not match") . " pattern $pattern\n\n";'
