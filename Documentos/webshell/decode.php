<?php
function decodeSecret($secret){
  //return base64_decode(strrev(hex2bin($secret)));
  return hex2bin($secret);
  }

print "The secret is: ";
print decodeSecret("3d3d516343746d4d6d6c315669563362");
print "\n";
?>
