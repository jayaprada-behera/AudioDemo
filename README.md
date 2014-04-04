AudioDemo
=========

Play music using MPMusicPlayerController and choos songs from device

MPMusicPlayerController
Use MPMusicPlayerController. Easy to use, just give it a media query or media collection and you're done. It's easy to get notified about playback state and track changes, remote control events work and the now playing center is automatically updated. Shuffling and repeat modes work like you would expect, and music in iCloud (iTunes Match) works just fine.

However, notifications don't work while the app is in the background and your app icon won't show up in the multitasking bar. If you don't need this, MPMusicPlayerController will serve you just fine.

AVPlayer
A more powerful way is to go with AVPlayer. You can execute code in the background and your app icon will show up in the multitasking bar.

However, it doesn't work with media queries or media collections. It doesn't know anything about queues, repeat modes and shuffling. By itself, it doesn't send notifications about track changes. And last but not least, it's a lot more complicated to set it all up: handling the now playing center, listening to remote control events, handling audio route changes, etc.

To show the app in Lock screen we have to make some changes in info.plist
