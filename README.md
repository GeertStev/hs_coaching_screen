# Holy Squid Coaching app
## Coaching app for underwater hockey.
A screen in the swimming pool shows an HTML Flutter app.
A tablet on the side of the pool controls the screen with a Android Flutter app.
Two apps to keep HTML app lean and fast. The Android app moreover has extended functionality.
## Functions of the both apps
### Displaying an image on screen
The Android app sends an image to Firebase, the HTML app shows this image
* Upload an image to firebase storage
* Tag the image
* List of images (Filter on tag, user; sort on date)
* Send image to screen (set firestore field to url)
### Live drawing on screen
A drawing drawn on the android app is shown live in the HTML app
### Time keeping
The Android app starts and stops a stopwatch or a timer, the time is shown in the HTML app
* General stopwatch
* Consecutive timers
* Assign players to lane and stopwatch & record the times to a player
### Team composition
The Android app signals the HTML app to retrieve data from a Google sheet to display
* Show team based on Google sheet data (ELO rating)
* ToDo: Migrate sheet to firestore
### Score keeping
The Android app edits the score in Firebase, the score is shonw in HTML app
* Show score
* Keep track of score per player
* Time-out for teams, show countdown

## Functions of the android app
### Authentication
Restricting functionality (acces to screenfunctionality only for moderators)
### User profile
* Name
* Avatar
* Birthdate
* Administrative properties (adress, billing status, health check status)
### Player statistics
* Speed (25m sprint, 50m sprint, ...)
* Maximum length underwater
* Times present on training
* Goals scored on training
* Tournaments played
### Registration
* Register for trainings
* Register for tournaments
* Comment on training or tournament events (forum)
* Calendar

See `CLAUDE.md` for this repo's current architecture and Firestore schema.
