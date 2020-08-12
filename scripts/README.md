See files

For the function generator, just use the manual instructions [here](http://web.mit.edu/8.13/8.13d/manuals/bnc-555-digital-delay-generator.pdf)

1. Acquire images using the `matlab_func_generator.m` file. Saving the images from `data1`, `data2`, `data3` streams into different folders. Use this destination folder naming convention: `cam_i` for i in {1,2,3} for checkerboard images, `cam_i_Analyzer_Matrix` for images for the Analyzer Matrix evaluation using the Lazy Susan, `cam_i_expt` for actual experimental system images, `cam_i_flat` for flat field images by shining iPhone light through white paper, `cam_i_dark` for dark field images obtained by covering the camera lens. This file uses the `CalculatePacketDelay.m` func and the `CalculateFrameRate.m` func
2. Use the `flat_field_correction.m` file to evaluate the flat field correction parameters for each camera. These are F, D, m. This file saves these parameters for each of the 3 cameras
3. Next use the `geometricCalibration.m` file for evaluating the geometric transformation to calculate the translation of the cameras as well as corrects for the radiometric distortions (minimal). These parameters are also saved as above in `.mat` files.
4. Next step is to calculate the Analyzer matrix from measurements taken at the Lazy Susan. Correct these images for geometric and radiometric distortions with the parameters calculated in 2 and 3 above. Use the file `Geo_Radio_metric_Calibs_Apply.m` for applying corrections to the 3 set of images. Save the corrected images as `.mat` files in their respective `cam_i_Analyzer_Matrix` folders.
5. Calculate the analyzer matrix using the corrected `.mat` files stored `cam_i_Analyzer_Matrix` folders. Use the `AnalyzerMatrix.ipynb` file to do a linear pregression to get A, where **S_theoretical($$\theta$$) = A x I$$_{measured}$$ **
6. Calculate the image mapping transformation and the cropping parameters using the `image_registration.m` file. Save these paramters.
7. Take measurements for the experimental system, apply radiometric and then geometric corrections, then map the images onto 1, then crop them and finally save these images. Stack the 3 mapped & cropped images in a `final_map.mat` file and save it.
8. Use the analyzer matix from before to calculate the transformation from intensity to Stokes parameters and store the Stokes parameter map in `final_S_map.mat` file.


## To DO: 
List the 
1. Calibration pipeline and file usage & what parameters are stored by which file

2. Listthe file usage for correcting the experimental images

3. How is intensity apped to Stokes params (list file usage)
