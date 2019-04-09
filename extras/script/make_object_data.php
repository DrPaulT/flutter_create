#!/usr/bin/php -q
<?php
set_time_limit(0);

$object_locations = imagecreatefrompng('object_locations.png');
$id_lookup = array();

unpack_atlas();
find_locations();
echo "All done.\n";

function unpack_atlas() {
  global $id_lookup;
  list($width, $height) = getimagesize('atlas.png');
  $atlas = imagecreatefrompng('atlas.png');
  $lefts = array();
  $tops = array();
  $rights = array();
  $bottoms = array();
  $n = 0;
  $fp = fopen('atlas_info.bin', 'w');
  for ($y = 0; $y < $height; $y += 8) { // 8-pixel alignment.
    for ($x = 0; $x < $width; $x += 8) {
      $c = imagecolorat($atlas, $x, $y) & 0xffffff;
      if ($c != 0) {
        $already_found = false;
        for ($m = 0; $m < $n && !$already_found; $m++) {
          if ($x >= $lefts[$m] && $x < $rights[$m]
           && $y >= $tops[$m]  && $y < $bottoms[$m]) {
            $already_found = true;
          }
        }
        if (!$already_found) {
          $i = $x;
          while (imagecolorat($atlas, $i, $y) == $c) {
            $i++;
          }
          $j = $y;
          while (imagecolorat($atlas, $x, $j) == $c) {
            $j++;
          }
          $lefts[$n]     = $x;
          $tops[$n]      = $y;
          $rights[$n]    = $i - 1;
          $bottoms[$n]   = $j - 1;
          $id_lookup[$c] = $n;
          $n++;
echo "Found $x $y ", ($i - $x), ' ', ($j - $y), "\n";
          fwrite($fp, pack('C', $x / 8));
          fwrite($fp, pack('C', $y / 8));
          fwrite($fp, pack('C', ($i - $x) / 8));
          fwrite($fp, pack('C', ($j - $y) / 8));
        }
      }
    }
  }
  fclose($fp);
}

function find_locations() {
  global $id_lookup;
  // 0.25 scale, one pixel == 16 pixels.
  list($width, $height) = getimagesize('object_locations.png');
  $locations = imagecreatefrompng('object_locations.png');
  $xs     = array();
  $ys     = array();
  $cs     = array();
  $xs_r   = array();
  $ys_r   = array();
  $ns     = array();
  $old_ns = array();
  $n = 0;
  for ($y = 0; $y < $height; $y++) {
    for ($x = 0; $x < $width; $x++) {
      $c = imagecolorat($locations, $x, $y) & 0xffffff;
      if ($c != 0) {
        $ns[] = $n++;
        $cs[] = $id_lookup[$c];
        $xs[] = $xs_r[] = $x * 4 - 2;
        $ys[] = $ys_r[] = $y * 4 - 2;
echo "Found $c at $x, $y\n";
      }
    }
  }
  $fp = fopen('location_info.bin', 'w');
  maybe_output_locations(0, $fp, $cs, $xs, $ys, $xs_r, $ys_r, $ns, $old_ns);
  for ($a = 1; $a < 360; $a++) {
    $rad = $a * 3.141592654 / 180;
    for ($i = 0; $i < count($xs); $i++) {
      $xs_r[$i] = $xs[$i] * cos($rad) - $ys[$i] * sin($rad);
      $ys_r[$i] = $ys[$i] * cos($rad) + $xs[$i] * sin($rad);
    }
    maybe_output_locations($a, $fp, $cs, $xs, $ys, $xs_r, $ys_r, $ns, $old_ns);
  }
  fclose($fp);
}

function maybe_output_locations($a, $fp, $cs, $xs, $ys, $xs_r, $ys_r, &$ns, &$old_ns) {
  $sorted = false;
  while (!$sorted) {
    $sorted = true;
    for ($i = 0; $i < count($ns) - 1; $i++) {
      for ($j = $i + 1; $j < count($ns); $j++) {
        if ($ys_r[$ns[$i]] > $ys_r[$ns[$j]]) {
          $t = $ns[$i];
          $ns[$i] = $ns[$j];
          $ns[$j] = $t;
          $sorted = false;
        }
      }
    }
  }
  for ($i = 0; $i < count($ns) && !$do_output; $i++) {
    if ($ns[$i] != $old_ns[$i]) {
      $do_output = true;
    }
  }
  for ($i = 0; $i < count($ns); $i++) {
    $old_ns[$i] = $ns[$i];
  }
  for ($i = 0; $i < count($ns); $i++) {
    fwrite($fp, pack('C', $cs[$ns[$i]]));
    fwrite($fp, pack('n', $xs[$ns[$i]])); // Flutter is big endian.
    fwrite($fp, pack('n', $ys[$ns[$i]]));
  }
}
