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
printf("\ncount: %d\n", count($array));

$depth++;
foreach($array as $index => $element) {
    str_repeat("  ", $depth);
    printf("\n%s: ", $index);

    if(is_scalar($element))  {
        echo $element;
    }

    else if(is_array($element))  {
        printIndexObjCount($element, $depth);
    }

    else {
        printf("%s", gettype($element));
    }

}

}


