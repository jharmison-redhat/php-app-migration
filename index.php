<?php
$my = new mysqli("database", "visitor", "R3dh4t1!", "visitors");
$results = $my->query("SELECT * from visitors");
echo "You are the visitor number: " . $results->fetch_array()['number'];
echo "<br />";
$my->query("UPDATE visitors SET number=number+1");
echo "I'm the server " . getenv('COMPUTERNAME');
?>
