## GIF Preview
![Simulator Screen Recording - iPhone 17 Pro - 2025-10-05 at 21 44 37 (3)](https://github.com/user-attachments/assets/defcef6a-8ca3-4ecd-9af6-f23e784cfddb)

### Requirements

- [x] App loads to display a grid of cards initially placed face-down:
  - [x] Upon launching the app, a grid of cards should be visible.
  - [x] Cards are facedown to indicate the start of the game.
- [x] Users can tap cards to toggle their display between the back and the face:
  - [x] Tapping on a facedown card should flip it to reveal the front.
  - [x] Tapping a second card that is not identical should flip both back down.
- [x] When two matching cards are found, they both disappear from view:
  - [x] Implement logic to check if two tapped cards match.
  - [x] If they match, both cards should either disappear.
  - [x] If they don't match, they should return to the facedown position.
- [x] User can reset the game and start a new game via a button:
  - [x] Include a button that allows users to reset the game.
  - [x] This button should shuffle the cards and reset any game-related state.

### Stretch Features

- [x] User can select number of pairs to play with (at least 2 unique values like 2 and 4).
  - [x] (Hint: user Picker)
- [x] App allows for user to scroll to see pairs out of view.
  - [x] (Hint: Use a ScrollView)
- [x] Add any flavor you’d like to your UI with colored buttons or backgrounds, unique cards, etc.
  - [x] Enhance the visual appeal of the app with colored buttons, backgrounds, or unique card designs.
  - [x] Consider using animations or transitions to make the user experience more engaging.
