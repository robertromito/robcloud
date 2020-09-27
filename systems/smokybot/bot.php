<?php 
$my_person = $_POST["username"];
$data = ["text" => "Meow 🐈 I love {$my_person} 🥰\nI want treats 😽\nPurr 😻"];
header('Content-Type: application/json');
echo json_encode($data);

?>