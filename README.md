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
<<<<<<< HEAD
=======

# Firebase database structure
## User data
```
/users/{uid}
    - firstName: string
    - lastName: string
    - picture: string
    - role: string
    - lastLogin: timestamp

/users/{uid}/personalInfo/{personalInfoId}
    - street: string
    - number: string
    - zipCode: string
    - city: string
    - country: string
    - phoneNumber: string
    - email: string
    - birthday: timestamp
    - gender: string

/users/{uid}/personalInfo/{personalInfoId}/emergencyContacts/{emergencyContactId}
    - firstName: string
    - lastName: string
    - phoneNumber: string
```
## Club data
```
/clubs/{clubId}
    - name: string

/clubs/{clubId}/practiceMoments/{practiceMomentId}
    - location: string
    - day: timestamp
    - start: string
    - end: string
    - ageGroup: string
    - notes: string

/clubs/{clubId}/members/{uid}
    - ELO: number
    - isActive: boolean
    - joinDate: timestamp
    - role: string
    - capNumber: number
```
## Practice data
### General practice data
```
/clubs/{clubId}/practices/{practiceId}
    - date: timestamp
    - coachId: string

/clubs/{clubId}/practices/{practiceId}/attendance/{uid}
    - state: string
    - timestamp: timestamp
    - history: array
```
### Practice match data
```
/clubs/{clubId}/practices/{practiceId}/games/{gameId}
    - scoreBlack: number
    - scoreWhite: number
    - duration: number

/clubs/{clubId}/practices/{practiceId}/games/{gameId}/teamCompositions/{teamCompositionId}

/clubs/{clubId}/practices/{practiceId}/games/{gameId}/teamCompositions/{teamCompositionId}/players/{uid}
    - position: string

/clubs/{clubId}/practices/{practiceId}/games/{gameId}/gameEvents/{gameEventId}
    - playerId: string
    - team: string
    - type: string
    - timestamp: timestamp
```
### Practice swimming data
```
/clubs/{clubId}/practices/{practiceId}/timings/{timingId}
    - timingType: string
    - timingDate: timestamp
    - distance: number
    - time: number
    - notes: string

/clubs/{clubId}/practices/{practiceId}/timings/{timingId}/results/{resultId}
    - playerId: string
    - result: any
```
## Display data
```
/clubs/{clubId}/displays/{displayDeviceId}/settings/content
    - contentType: string
    - drawingId: string
    - gameId: string
    - imageId: string
    - teamId: string
    - text: string
    - timingId: string

/clubs/{clubId}/displays/{displayDeviceId}/settings/global
    - width: number
    - height: number
    - features: array
    - subscriptionEnd: timestamp
    - primaryColor: string
    - secondaryColor: string
    - tertiaryColor: string
    - backgroundColor: string

/clubs/{clubId}/displays/{displayDeviceId}/drawings/{drawingId}
    - category: string
    - tags: array
    - title: string
    - timestamp: timestamp
    - userId: string
    - drawingElements: array

/clubs/{clubId}/displays/{displayDeviceId}/images/{imageId}
    - category: string
    - tags: array
    - title: string
    - timestamp: timestamp
    - userId: string
    - url: string
```
## Tournament data
```
/tournaments/{tournamentId}
```
>>>>>>> 50e4f68 (First commit)
