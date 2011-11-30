<?php
  
  $kegSizes = "kegsizes.txt";
  $kegStats = "kegstats.txt";

  $now = date("Y-m-d-H:i:s");
  $newfile = "backups/keg_size_backup-".$now.".txt";

  $keg1 = substr($_REQUEST['keg1'], 0, 1) ;
  $keg2 = substr($_REQUEST['keg2'], 0, 1) ;

  // create a backup of the original SIZE file for safe keeping!
  if (!copy($kegSizes, $newfile)) {
   echo "failed to copy $kegSizes to $newfile...\n";
  } 

  // create a backup of the original STAT file for safe keeping!
    $newfile = "backups/keg_stat_backup-".$now.".txt";
  if (!copy($kegStats, $newfile)) {
   echo "failed to copy $kegStats to $newfile...\n";
  } 

  //////////////////////////
  $fh1 = fopen($kegStats, 'r') or die("can't open file kegsize");
  $kegStatVals = fread($fh1, filesize($kegStats));
  $stat_Pieces = explode(",", $kegStatVals);
  fclose($fh1); 
  
  $fh1 = fopen($kegSizes, 'r') or die("can't open file kegsize");
  $kegSizeVals = fread($fh1, filesize($kegSizes));
  $size_Pieces = explode(",", $kegSizeVals);
  fclose($fh1); 
  //////////////////////////

  switch ($keg1) {
    case "N":
	echo "no change to keg1 better drink up!";
	$keg1 = $size_Pieces[0];
	$kegstat1 = $stat_Pieces[2];
        break;
    case "3":
 	echo "keg1 is now using a wimpy 3 gallon keg";
	$kegstat1 = 69120;
        break;
    case "5":
    	echo "keg1 is now using a standard 5 Gallon keg";
	$kegstat1 = 115200;
        break;
    case "7":
   	echo "keg1 is now using a healthy 7.8 gallon keg";
	$kegstat1 = 172800;
        break;
    case "1":
	echo "keg1 is now using a 15.5 Gallong Bohemoth, party on!";
	$kegstat1 = 357120;
        break;
  }
echo "<p>";
  switch ($keg2) {
    case "N":
        echo "no change to keg2 better drink up!";
	$keg2 = $size_Pieces[1];
	// need to find out old value and get it!
	$kegstat2 = $stat_Pieces[3];
	
        break;
    case "3":
        echo "keg2 is now using a wimpy 3 gallon keg";
        $kegstat2 = 69120;
        break;
    case "5":
        echo "keg2 is now using a standard 5 Gallon keg";
        $kegstat2 = 115200;
        break;
    case "7":
        echo "keg2 is now using a healthy 7.8 gallon keg";
        $kegstat2 = 172800;
        break;
    case "1":
        echo "keg2 is now using a 15.5 Gallong Bohemoth, party on!";
        $kegstat2 = 357120;
        break;
  } 
echo "<P>";

// open up kegsizes.txt for writing and replace the vals like $kegstat1,$kegstat2
$str = $kegstat1.",".$kegstat2;
   $fh = fopen($kegSizes, 'w') or die("can't open kegsize file for writing");
   fwrite($fh, $str);
   fclose($fh);

// Need to reset keg values stored in kegstats.txt file
	$str = $stat_Pieces[0].",".$stat_Pieces[1].",".$kegstat1.",".$kegstat2;
	$fh = fopen($kegStats, 'w') or die("can't open kegstats file for writing");
	fwrite($fh, $str);
	fclose($fh);
?>

