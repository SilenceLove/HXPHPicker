# Release Notes

## 1.3.2

### Added

- Editor
  - Soundtrack and soundtrack volume can be adjusted when video editor adds soundtrack
  - Video editing supports adding filter effects
- Camera
  - Support click method when shooting video `takePhotoMode`
  - Click the shooting method to support unlimited maximum time
  
### Resolved

- Editor
  - Crash when setting a single type in the bottom toolbar
- Camera
  - The camera screen is displayed incorrectly after rotating the screen
  
## 1.3.1

### Added
 
- Picker
  - Add LivePhoto logo
  - Support adding local LivePhoto
- Editor
  - Add custom colors to the brush

### Resolved

- English internationalization issues
- The downloaded video may not have a callback

## 1.3.0

- Picker
  - When synchronizing videos on iCloud, get the quality modified to high quality
  - `PhotoAsset`When getting the URL, add compression parameters

## 1.2.9

### Resolved

- Picker
  - It will cause a crash when the album permission is "selected photos" for the first time loading
  - The preview interface will always be loading when acquiring the original image under certain circumstances
- Editor
  - Exporting may fail when editing special videos
- Camera
  - Return to the camera after the photo is taken and the zoom function does not work

## 1.2.8

### Resolved

- Picker
  - In special cases, clear pictures are not loaded after sliding stops
  - In the case of pre-selection, enter the selection interface, the screen may be messed up at the beginning
  - Allow gesture swipe selection `allowSwipeToSelect` defaults to `false`
