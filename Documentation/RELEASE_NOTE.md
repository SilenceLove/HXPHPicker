# Release Notes

## 1.4.3

adaptation`iPhone 14 Pro / Pro Max`

## 1.4.2

### Resolved

- Picker
  - The problem of download failure when previewing `m3u8` format video, if the `m3u8` format video will not be downloaded
  - After adding the file, adding it again will crash

- Camera
  - crash in some cases

## 1.4.1

### Optimizer

- Preview/edit oversized images

### Resolved

- Picker
  - After editing, the list display has not changed

- Editor
  - Editing the problem that the animated picture becomes larger
  - The problem that the edited address is an absolute path
  
### Added

- Picker
  - `config.preview.disableFinishButtonWhenNotSelected`In multi-select mode, whether to disable the finish button when no resource is selected

## 1.4.0

### Resolved

- Editor
  - `EditorController` is missing an `editResult` value passed

### Optimizer

- Picker
  - `PhotoBrowser` display effect

### Added

- Picker
  - The editing configuration can be modified when the callback is added to edit pictures/videos
- Editor
  - You can specify the file path when editing the picture

## 1.3.9

### Resolved

- Fix the bug of failing to archive with Xcode 13.3
- Delete text internationalization

## 1.3.7

### Added

- Picker
  - Support filtering when getting album/photo list
- Camera
  - Add filter effects, customizable filters

### Optimizer

- Picker
  - Loading logic when scrolling fast

## 1.3.6

### Resolved

- Camera
  - Fixed losing audio track when recording video longer than 10 seconds

## 1.3.5

### Resolved

- Picker
  - The photo list cell does not display the icon when there is editing data
- Editor
  - Error in original image when editing image again

## 1.3.4

### Added

- Editor
  - Add crop size function to video (same as picture crop)
  
### Resolved

- Picker
  - `PhotoBrowser` may appear when the video screen is square when browsing web videos
- Editor
  - In special cases, the screen cropping result is wrong after multiple rotations and mirroring

## 1.3.3

### Added

- Editor
  - Added 3 filter effects
- Camera
  - Add configuration`modalPresentationStyle`
  - `sessionPreset`The default is modified to`hd1280x720`
  
### Resolved

- Editor
  - Edit the captured video, the screen is rotated 90°

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
