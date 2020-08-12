See files

For the function generator, just use the manual instructions [here](http://web.mit.edu/8.13/8.13d/manuals/bnc-555-digital-delay-generator.pdf)

1. Acquire images using the `matlab_func_generator.m` file. Saving the images from `data1`, `data2`, `data3` streams into different folders. Use this destination folder naming convention: `cam_i` for i in {1,2,3} for checkerboard images, `cam_i_Analyzer_Matrix` for images for the Analyzer Matrix evaluation using the Lazy Susan, `cam_i_expt` for actual experimental system images, `cam_i_flat` for flat field images by shining iPhone light through white paper, `cam_i_dark` for dark field images obtained by covering the camera lens. This file uses the `CalculatePacketDelay.m` func and the `CalculateFrameRate.m` func
2. Use the `flat_field_correction.m` file to evaluate the flat field correction parameters for each camera. These are F, D, m. This file saves these parameters for each of the 3 cameras
3. Next use the `geometricCalibration.m` file for evaluating the geometric transformation to calculate the translation of the cameras as well as corrects for the radiometric distortions (minimal). These parameters are also saved as above in `.mat` files.

## To DO: 
List the 
1. Calibration pipeline and file usage & what parameters are stored by which file

2. Listthe file usage for correcting the experimental images

3. How is intensity apped to Stokes params (list file usage)
