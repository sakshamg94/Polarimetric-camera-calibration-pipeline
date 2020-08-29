# Polarimetric-camera-calibration-pipeline
Files for calibrating the polarimetric camera system and applying correctioons to newly acquired images

| Calibration step                                          | Description                                                  |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| Focus camera (live Pylon 1 at a time)                     | Fix working distance                                         |
| Figure matlab 1, 2, 3                                     | look at s1, s2, s3 for camera device names                   |
| Orient the 3 camera polar filters (live Pylon 1 at a time) | 0, 60, 120 orientations of cam filters                       |
| lock the camera lenses so filters do no move              | Ensure anlayzer matrix configuration does not change         |
| Take flat field images (20*3 together)                    | vignetting correction                                        |
| Take dark field images (20*3 together)                    | improve image quality and remove px level variations         |
| Take calibration checkerboard images (15*3)               | 1. correction of geometric distortion (pin cushion) <br />2. obtain translation between cameras |
| Take Analyzer matrix images (36*3 together)               | Obtain Intensity to Stokes Param mapping                     |
|                                                           |                                                              |
