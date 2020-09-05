<?php 

$data = ["text" => "Meow 🐈 I want treats from {$_POST["username"]} 😽 Purr 😻"];
header('Content-Type: application/json');
echo json_encode($data);

?>