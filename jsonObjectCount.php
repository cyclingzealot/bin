#!/usr/bin/php

<?php


$f = fopen( 'php://stdin', 'r' );
$content = '';

while( $line = fgets( $f ) ) {
  $content .= $line;
}
fclose( $f );

$contentArray = json_decode($content, TRUE);

printIndexObjCount($contentArray);





function printIndexObjCount($array, $depth=0) {

#str_repeat("  ", $depth);
printf("count: %d\n", count($array));

$depth++;
foreach($array as $index => $element) {
    echo str_repeat("  ", $depth);
    printf("%s: ", $index);

    if(is_scalar($element))  {
        #echo $element;
        printf("%s", $element);
    }

    else if(is_array($element))  {
        printIndexObjCount($element, $depth);
    }

    else {
        printf("%s", gettype($element));
    }

    echo "\n";

}

}


