<?php
$kegStats = "kegstats.txt";
$kegSizes = "kegsizes.txt";

if($_SERVER["QUERY_STRING"]) {
   // input vars here


   // open file for reading to get current keg levels
   $fh = fopen($kegStats, 'r') or die("can't open file for reading");

   $theData = fread($fh, filesize($kegStats));
   $pieces = explode(",", $theData);
   fclose($fh);

   // get the values from the query string
   $temp1 = floatval($_GET["temp1"]);
   $temp2 = floatval($_GET["temp2"]);
   $keg1 = intval($_GET["keg1"]);
   $keg2 = intval($_GET["keg2"]);
   $avlmem = intval($_GET["avlmem"]);

   // do some math to subtract pulse counts reported by kegbot
   $keg1 = $pieces[2] - $keg1;
   $keg2 = $pieces[3] - $keg2;
   // This gives some feedback to kegbot for reading on the serial port
   echo $temp1;
   echo ",";
   echo $temp2;
   echo ",";
   echo $keg1;
   echo ",";
   echo $keg2;
   echo ",";
   echo $avlmem;

   // build array to be written back to file
   $All_Vars = array( "temp1" => $temp1, "temp2" => $temp2, "keg1" => $keg1, "keg2" => $keg2, "avlmem" => $avlmem);

   // re-open file for writing of new stats
   $fh = fopen($kegStats, 'w') or die("can't open file for writing");
   fwrite($fh, join(",", $All_Vars));
   fclose($fh);

} else {
   // output vars here - this is used for nagios checks
   $fh = fopen($kegStats, 'r') or die("can't open keg vars");
   $kegStatVals = fread($fh, filesize($kegStats));
   $stat_Pieces = explode(",", $kegStatVals);
   fclose($fh);

   // open kegsize.txt for % calcs
   $fh1 = fopen($kegSizes, 'r') or die("can't open file kegsize");
   $kegSizeVals = fread($fh1, filesize($kegSizes));
   $size_Pieces = explode(",", $kegSizeVals);
   fclose($fh1);

//   $kegMath = explode(",", $theData1);

   echo $stat_Pieces[0];
   echo ",";
   echo $stat_Pieces[1];
   echo ",";
   echo round(($stat_Pieces[2] / $size_Pieces[0] * 100), 2);
   echo ",";
   echo round(($stat_Pieces[3] / $size_Pieces[1] * 100), 2);
   echo ",";
   echo $stat_Pieces[4];
}

//fclose($fh);

?>
