Taste
=====

Taste for Rdio was created as my senior capstone project at Washburn University. Taste generates a 25 song playlist based on a song that the user selects. The Last.fm API is leveraged to find the similar tracks, and the Rdio API is used to play the music. Development continued on Taste until Rdio implemented the exact same functionality in their own applications. I would like to state that my engine consistently generated more relevant tracks, however, and that if I ever have free time in the future, I would like to finish this.

# To do...
1. Refactor code to more consistently leverage MVC patterns
2. Get rid of ViewController class and only use NowPlayingViewController (the distinction was made in haste for some reason. ViewController is used in the iPhone application, and NowPlayingViewController is used in the iPad application)
3. Get lockscreen information to update correctly. Right now it suffers from a one-off error.
4. Play controls should be accessible from any screen.
5. Update for iOS 7/8
