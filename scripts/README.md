If the sample being imaged does not occupy the entirety of the FOV AND if you have translated or changed the inclination of the camera system, then you need to :

1. Save previous experiment images in folders `cam_i_expt` **before taking new images**
2. You need to **reevaluate the crop parameters** of the image that you are working with. Use the `image_regitsration.m` file last section
3. Need to **crop both the raw (full size) analyzer matrix images (18)** and the newly taken `expt` images using the `final_image_correction_mapping.m` file
4. **Recalculate the analyzer matrix** for the portion of the image for each pixel which you selected to contain the sample using the Python script
5. Use `intensity_to_Stokes.m` file to convert I to S
6. Use `dolp_theta_from_S.m` and `aolp_phi_from_S.m` files to get dolp and aolp