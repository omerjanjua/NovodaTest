# Novoda TechTest

## Requirements

- When the app is launched, the user should be able to see a list of the top 20
StackOverflow users.
- Each list item should contain the user's profile image, name and reputation.
- Cells should contain an additional option to 'follow' a user. “Follow” functionality should just be locally simulated, i.e. no actual API call should be made.
-- Users that are followed should show an indicator in the list item.
-- Include an 'unfollow' option in the view when a user is followed.
-- “Follow” status should persist between sessions.
- If the server is unavailable (e.g. offline,

## Getting Started

To run app use the following steps.

1. Clone the repo
- `git clone git@github.com:bbc/iplayer-ios.git`
- Open `NovodaTest.xcodeproj` in Xcode
- Run from Xcode

## Architecture
The app uses MVVM, the industry's most common architecture today. Because it separates logic from UI, making the code easier to test and maintain.

## Security
Normally for the Base URL we ideally would like to pull that from a config endpoint which is secure rather than storing it as a string in the code. Especially in scenarios where API keys / tokens are involved and sometimes included as part of the url.   

## Extra 
Added extension to decodedHTMLEntities
NSAttributedString is not very light weight. For performance reasons it's better to cache this when displaying on UI. But for the purpose of this exercise since it only requires to display 20 items it is ok.

