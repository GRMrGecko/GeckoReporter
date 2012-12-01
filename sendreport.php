<?php
/*
 *  sendreport.php
 *  GeckoReporter
 *
 *  Created by Mr. Gecko on 12/28/09.
 *  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
 *
 */

//Debug
//print_r($_FILES);
//print_r($_POST);

function buildBody($FILES, $BOUNDARY) {
	$BODY = "\n\r\n";
	$KEYS = array_keys($FILES);
	for ($i=0; $i<count($KEYS); $i++) {
		$KEY = $KEYS[$i];
		$FILE = $_FILES[$KEY]['tmp_name'];
		$FILENAME = $_FILES[$KEY]['name'];
		$FILETYPE = $_FILES[$KEY]['type'];
		$FILESIZE = $_FILES[$KEY]['size'];
		$BODY .= "--$BOUNDARY\r\n";
		$BODY .= "Content-Disposition: attachment; filename=\"{$FILENAME}\"\r\n";
		$BODY .= "Content-Type: {$FILETYPE}; name=\"{$FILENAME}\"\r\n";
		$BODY .= "Content-Transfer-Encoding: binary\r\n\r\n";
		$FILEPIPE = fopen($FILE, "r");
		$BODY .= fread($FILEPIPE, $FILESIZE);
		fclose($FILEPIPE);
		$BODY .= "\r\n";
	}
	$BODY .= "--{$BOUNDARY}--";
	return $BODY;
}

//Word of warning, IP is for debugging, do not include the IP of your user without the knowledge that your user may not use your application.
//$_POST['IP'] = $_SERVER['HTTP_PC_REMOTE_ADDR']!="" ? $_SERVER['HTTP_PC_REMOTE_ADDR'] : $_SERVER['REMOTE_ADDR'];

$_POST['User_Agent'] = urldecode($_SERVER['HTTP_USER_AGENT']);
if ($_POST['GRType']=="crash") {
	unset($_POST['GRType']);
	$email = $_POST['GREmail'];
	unset($_POST['GREmail']);
	$subject = $_POST['GRSubject'];
	unset($_POST['GRSubject']);
	$userReport = isset($_POST['GRUserReport']) ? trim($_POST['GRUserReport']) : "";
	unset($_POST['GRUserReport']);
	$boundary = "--Boundary+".rand(0, 100000);
	
	if ($_POST['GRReportAttached']=="NO") {
		if (isset($_FILES['reportFile'])) {
			$filePipe = fopen($_FILES['reportFile']['tmp_name'], "r");
			$reportFileContents = fread($filePipe, $_FILES['reportFile']['size']);
			fclose($filePipe);
			unset($_FILES['reportFile']);
			$_POST['Report'] = "\n\n".$reportFileContents;
		}
	}
	unset($_POST['GRReportAttached']);
	if (preg_match("/([\w\.\-]+)(\@[\w\.\-]+)(\.[a-z]{2,4})+/i", $_POST['User_Email_Address'])) {
		$fromEmail = "{$_POST['User_Email_Address']}";
	} else {
		$fromEmail = "\"Mr. Gecko's Media\" <webmaster@mrgeckosmedia.com>";
	}
	
	$headers = "From: {$fromEmail}\r\n";
	$headers .= "X-Mailer: GeckoReporter/{$_POST['GRVersion']}\r\n";
	unset($_POST['GRVersion']);
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: multipart/mixed; boundary={$boundary}\r\n\r\n";
	
	$headers .= "--$boundary\r\n";
	$headers .= "Content-Type: text/plain; charset=utf-8\r\n";
	$headers .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
	$KEYS = array_keys($_POST);
	sort($KEYS);
	for ($i=0; $i<count($KEYS); $i++) {
		$KEY = $KEYS[$i];
		$NAME = str_replace("_", " ", $KEY);
		$headers .= "{$NAME}: {$_POST[$KEY]}\n";
	}
	if ($userReport!="")
		$headers .= "\nThe user was\n$userReport\n";
	
	$headers .= buildBody($_FILES, $boundary);
	
	$sent = mail($email, $subject, "This is a multipart message, your email client needs to support mime 1.0 in order to read this message.", $headers);
	
	echo ($sent ? "Crash Report Was Sent" : "Crash Report Was Not Sent");
} else if ($_POST['GRType']=="bug") {
	unset($_POST['GRType']);
	$email = $_POST['GREmail'];
	unset($_POST['GREmail']);
	$subject = $_POST['GRSubject'];
	unset($_POST['GRSubject']);
	$bug = isset($_POST['GRBug']) ? trim($_POST['GRBug']) : "";
	unset($_POST['GRBug']);
	$reproduce = isset($_POST['GRReproduce']) ? trim($_POST['GRReproduce']) : "";
	unset($_POST['GRReproduce']);
	$boundary = "--Boundary+".rand(0, 100000);
	if (preg_match("/([\w\.\-]+)(\@[\w\.\-]+)(\.[a-z]{2,4})+/i", $_POST['User_Email_Address'])) {
		$fromEmail = "{$_POST['User_Email_Address']}";
	} else {
		$fromEmail = "\"Mr. Gecko's Media\" <webmaster@mrgeckosmedia.com>";
	}
	
	$headers = "From: {$fromEmail}\r\n";
	$headers .= "X-Mailer: GeckoReporter/{$_POST['GRVersion']}\r\n";
	unset($_POST['GRVersion']);
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: multipart/mixed; boundary={$boundary}\r\n\r\n";
	
	$headers .= "--$boundary\r\n";
	$headers .= "Content-Type: text/plain; charset=utf-8\r\n";
	$headers .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
	$KEYS = array_keys($_POST);
	sort($KEYS);
	for ($i=0; $i<count($KEYS); $i++) {
		$KEY = $KEYS[$i];
		$NAME = str_replace("_", " ", $KEY);
		$headers .= "{$NAME}: {$_POST[$KEY]}\n";
	}
	if ($bug!="")
		$headers .= "\nThe Bug\n$bug\n";
	if ($reproduce!="")
		$headers .= "\nHow you can reproduce it\n$reproduce\n";
	
	$headers .= buildBody($_FILES, $boundary);
	
	$sent = mail($email, $subject, "This is a multipart message, your email client needs to support mime 1.0 in order to read this message.", $headers);
	
	echo ($sent ? "Bug Report Was Sent" : "Bug Report Was Not Sent");
} else if ($_POST['GRType']=="contact") {
	unset($_POST['GRType']);
	$email = $_POST['GREmail'];
	unset($_POST['GREmail']);
	$subject = $_POST['GRSubject'];
	unset($_POST['GRSubject']);
	$message = isset($_POST['GRMessage']) ? trim($_POST['GRMessage']) : "";
	unset($_POST['GRMessage']);
	$boundary = "--Boundary+".rand(0, 100000);
	if (preg_match("/([\w\.\-]+)(\@[\w\.\-]+)(\.[a-z]{2,4})+/i", $_POST['User_Email_Address'])) {
		$fromEmail = "\"{$_POST['User_Name']}\" <{$_POST['User_Email_Address']}>";
	} else {
		$fromEmail = "\"Mr. Gecko's Media\" <webmaster@mrgeckosmedia.com>";
	}
	
	$headers = "From: {$fromEmail}\r\n";
	$headers .= "X-Mailer: GeckoReporter/{$_POST['GRVersion']}\r\n";
	unset($_POST['GRVersion']);
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: multipart/mixed; boundary={$boundary}\r\n\r\n";
	
	$headers .= "--$boundary\r\n";
	$headers .= "Content-Type: text/plain; charset=utf-8\r\n";
	$headers .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
	$KEYS = array_keys($_POST);
	sort($KEYS);
	for ($i=0; $i<count($KEYS); $i++) {
		$KEY = $KEYS[$i];
		$NAME = str_replace("_", " ", $KEY);
		$headers .= "{$NAME}: {$_POST[$KEY]}\n";
	}
	if ($message!="")
		$headers .= "\nThe message\n$message\n";
	
	$headers .= buildBody($_FILES, $boundary);
	
	$sent = mail($email, $subject, "This is a multipart message, your email client needs to support mime 1.0 in order to read this message.", $headers);
	
	echo ($sent ? "Message Was Sent" : "Message Was Not Sent");
}
?>