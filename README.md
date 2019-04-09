# GRANNY TURISMO 

An entry for the Flutter Create 5k code competition.

Pilot fearless rider Mrs. Jones and her mobility scooter of death around
a challenging on- and off-road course.

Featuring sort-of 3D graphics and artwork that looks like it has
been drawn by a toddler who just CBB.

## Controls

Press and hold to accelerate, drag left and right to steer.
Lift off to slow down.

## Video

[YouTube video of the gameplay](https://www.youtube.com/watch?v=-y6dZdBFUC4)

# What's in the repo

All program code is in `lib/main.dart`, but you might prefer to look in
`lib/main.with_comments` for some explanation and better readability.

In `extras` you can find graphical assets in GIMP's .xcf format and also the
scene.json file I made in [https://threejs.org/editor](https://threejs.org/editor/)
as a template for the scooter.  This was imported into Blender as a GLTF file
so I could set the viewing angle and rotations easily.  From there, I just
took screenshots of each pose.

There's a texture atlas that holds images of all the static objects in the
scene and another object locations image that matches the bounding box colour
of each atlas image with a pixel of the same colour at the location it is
shown in the scene.

A PHP script, `make_object_data.php`, reads the pixels in the atlas and
location images and makes binary files of the locations of objects suitable
for reading into the app.

There are textures for the ground and sky/mountains that are loaded
directly by Flutter's image importer from the `assets` directory.

There's also a `driveable.png` texture file that defines the bounds of the
track with a greyscale map.  White means fully on the track, black is a no-go
region and in between the scooter is slowed down as though stuck in mud.

The renderer is quite flexible and you could easily change the graphic files
to create completely different tracks and environments.  Just remember to run
the `make_object_data.php` script to regenerate the bin files.
