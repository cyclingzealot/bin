#!/usr/bin/php
<?php

$projects = array(
	'Fair Vote Canada'		=> 'https://www.indiegogo.com/projects/make-2015-the-last-unfair-election',
);



foreach($projects as $projectName => $url) {

$html = file_get_contents($url);

$doc = new DOMDocument();
$previous_value = libxml_use_internal_errors(TRUE);
$doc->loadHTML($html);
libxml_clear_errors();
libxml_use_internal_errors($previous_value);
$xpath = new DOMXPath($doc);

if(is_object($xpath->query('/html/body/div[4]/div[4]/div[2]/div/div/div/span/span')->item(0))) {
	$amount 		= trim($xpath->query('/html/body/div[4]/div[4]/div[2]/div/div/div/span/span')->item(0)->textContent);
	$percentRaised	= trim($xpath->query('/html/body/div[4]/div[4]/div[2]/div/div/div[4]/div')->item(0)->textContent);
	$daysLeft 		= trim($xpath->query('/html/body/div[4]/div[4]/div[2]/div/div/div[4]/div[2]/span[2]')->item(0)->textContent);

	echo "$projectName: $daysLeft days left - $percentRaised ($amount) \n";
}



}

