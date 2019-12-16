# uSonic

uSonic is a native Ubuntu for devices client for streaming your music from a Subsonic (www.subsonic.org) server.

It is a work in development. Feel free to log any issues to the project here.

## How to build
Clone the repository
```
$ https://gitlab.com/arubislander/uSonic.git
```

With [clikckable installed](http://clickable.bhdouglass.com/en/latest/install.html) move to the cloned directory and do
```
$ clickable desktop
```
to run build and run uSonic on the desktop. The app will run in a docker containers. Because the audio hardware is not passed into the containerd no sound is produced.

To test the app on your device, connect it to your computer and do
```
$clickable
```
