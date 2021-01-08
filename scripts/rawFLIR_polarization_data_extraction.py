import os
import cv2
import numpy as np
import math
import time
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
from scipy import interpolate
from bokeh.plotting import figure, output_file, show
from bokeh.layouts import gridplot
from bokeh.models import ColorBar, LinearColorMapper, BasicTicker
import scipy.io

def theta_phi(filename, file_location, num_images, material, correction_angle=0):
    print('Processing data for material : {}'.format(material.upper()))
    for i in range(num_images):
        image_data = cv2.imread(os.path.join(file_location, filename).format(i))[:,:,0]
        print("image_data shape is : ", image_data.shape)
    #     print(not (image_data[:,:,0]==image_data[:,:,2]).all())
        im90, im45, im135, im0 = quad_algo(image_data)
        print("im90 shape is : ", im90.shape)

        write_quad_image(im90, 90, file_location, filename[:-5])
        write_quad_image(im90, 45, file_location, filename[:-5])
        write_quad_image(im90, 135, file_location, filename[:-5])
        write_quad_image(im90, 0, file_location, filename[:-5])

        # Get Stokes vector first 3 components from 4 quad images
        # S is floating point array -- cannot be written as a tiff or png "image"
        im_stokes0, im_stokes1, im_stokes2 = calculate_Stokes_Params(im90, im45, im135, im0, correction_angle)
        print("im_stokes0 shape is : ", im_stokes0.shape) 
        
        # Get DOLP from Stokes measurements
        im_DOLP = calculate_DOLP(im_stokes0, im_stokes1, im_stokes2)
        print("im_DOLP shape is : ", im_DOLP.shape)
        
        # Get the material refractive index for AOI or DOLP calculations
        if material.lower() == 'borosilicate_glass':
            nt = 1.47
        elif material.lower() == 'ferrofluid_emg905':
            nt = 1.58
        elif material.lower() == 'water':
            nt = 1.33
        else:
            raise Exception('Check the material type entered: borosilicate_glass or ferrofluid_EMG905 or water')
        
        # Get theta (Angle of incidence) from DOLP
        im_theta, DOLP_errors =  DOLP2Theta(1, nt, im_DOLP)
        print(np.array(DOLP_errors).any())

        # Create a heatmap from the greyscale image
        # floating point array -- cannot be written as a tiff or png "image", write a matlab array instead
#         im_DOLP_normalized = normalise_DOLP(im_DOLP)    
#         im_DOLP_heatmap = heatmap_from_greyscale(im_DOLP_normalized)
        write_float_image("DOLP", i, im_DOLP, file_location, filename[:-5])

        # Get AOLP from Stokes measurements
        im_AOLP = calculate_AOLP(im_stokes1, im_stokes2)

        # Get angle of plane of polarization from AOLP
        im_phi = (im_AOLP + np.pi/2)*180/np.pi;

        # Create a heatmap from the greyscale image
        # floating point array -- cannot be written as a tiff or png "image", write a matlab array instead
#         im_AOLP_normalized = normalise_AOLP(im_AOLP)    
#         im_AOLP_heatmap = heatmap_from_greyscale(im_AOLP_normalized)
        write_float_image("AOLP", i, im_AOLP, file_location, filename[:-5])    
        
        return im_theta, im_phi


def quad_algo(image_data):
    '''
    Extract image data from each of the 4 polarized quadrants
    '''
    tic = time.time()

    im90 = image_data[0::2, 0::2]
    im45 = image_data[0::2, 1::2]
    im135 = image_data[1::2, 0::2]
    im0 = image_data[1::2, 1::2]

    toc = time.time()
    print("Quad algorithm time ", toc - tic, "s")
    
    return im90, im45, im135, im0

def write_quad_image(quad_image, quad_angle, location, file_prefix):
    cv2.imwrite(os.path.join(location, file_prefix+"_"+"IM{}.tiff".format(quad_angle)), quad_image)

def write_glare_reduced_image(im90, im45, im135, im0, location):
    '''
    Calculate a glare reduced image by taking the lowest pixel value from each quadrant
    '''
    tic = time.time()

    glare_reduced_image = np.minimum.reduce([im90, im45, im135, im0])

    toc = time.time()
    print("Glare reduction time: ", toc - tic, "s")

    cv2.imwrite(os.path.join(location, file_prefix+"_"+"GlareReduced-{}.tiff".format(i)), glare_reduced_image)
    
    return glare_reduced_image 

def calculate_Stokes_Params(im90, im45, im135, im0, correction_angle = 0):
    '''
    Calculate Stokes parameters
    correction_angle (degrees): non-zero angle to convert from lab frame to meridional frame measurements
    '''
    tic = time.time()

    im_stokes0 = im0.astype(np.float) + im90.astype(np.float) #lab_frame measurement
    im_stokes1 = im0.astype(np.float) - im90.astype(np.float) #lab_frame measurement
    im_stokes2 = im45.astype(np.float) - im135.astype(np.float)#lab_frame measurement
    
    if correction_angle!=0: # convert to meridional frame
        im_stokes2 = -im_stokes1*np.sin(2*np.deg2rad(correction_angle))+im_stokes2*np.cos(2*np.deg2rad(correction_angle))
        im_stokes1 = im_stokes1*np.cos(2*np.deg2rad(correction_angle))+ im_stokes2*np.sin(2*np.deg2rad(correction_angle))
    
    toc = time.time()
    print("Stokes time: ", toc - tic, "s")
    
    return im_stokes0, im_stokes1, im_stokes2

    
def calculate_DOLP(im_stokes0, im_stokes1, im_stokes2):
    '''
    Calculate DoLP
    '''
    tic = time.time()

    im_DOLP = np.divide(
        np.sqrt(np.square(im_stokes1) + np.square(im_stokes2)),
        im_stokes0,
        out=np.zeros_like(im_stokes0),
        where=im_stokes0 != 0.0,
    ).astype(np.float)

    im_DOLP = np.clip(im_DOLP, 0.0, 1.0)
    toc = time.time()
    print("DoLP time: ", toc - tic, "s")
    
    return im_DOLP

def normalise_DOLP(im_DOLP):
    '''
    Normalize from [0.0, 1.0] range to [0, 255] range (8 bit)
    '''
    im_DOLP_normalized = (im_DOLP * 255).astype(np.uint8)
    return im_DOLP_normalized

def DOLP_curve(ni, nt):
    '''
    Get the theoretical DOLP curve for unpolarized light transmission 
    from incident medium with refractive index ni to the transmission medium
    of refractive index nt
    '''
    #nt: 1.47 borosilicate glass; %1.58 ferrofluid emg 905);%1.333 water; 57.68
    
    th_Brewster = np.arctan2(nt,ni)
    
    thI = np.linspace(0, th_Brewster, 200).astype(
        np.float
    )
#     thI = np.linspace(th_Brewster, np.pi/2,200).astype(
#         np.float
#     )
    thT = np.arcsin(ni*np.sin(thI)/nt).astype(
        np.float
    )

    alpha = 0.5*(np.tan(thI-thT)/np.tan(thI+thT))**2
    eta = 0.5*(np.sin(thI-thT)/np.sin(thI+thT))**2

    DOLP = np.abs((alpha - eta)/(alpha + eta))
    
    fig = plt.figure(figsize=(5, 5),  facecolor='w', edgecolor='k')
    plt.plot(thI*180/np.pi, np.abs(DOLP),color='Indigo', linestyle='--', linewidth=3)
    plt.axvline(x=th_Brewster*180/np.pi, linestyle='-', linewidth=3)
    plt.xlabel("Incidence angle ($\\theta_i$) [deg]", fontsize=16)
    plt.ylabel("DOLP($\\theta_i$)", fontsize = 16)
    plt.xlim(0,90)
    plt.grid()
    plt.show()
    
    return DOLP, thI

def DOLP2Theta(ni, nt, im_DOLP):
    '''
    Convert from measured DOLP to theta using theoretical interpolation
    '''
    theoretical_DOLP_curve, theta_in_radians = DOLP_curve(ni, nt)

    f = interpolate.interp1d(theoretical_DOLP_curve, theta_in_radians*180/np.pi)
    im_theta = np.zeros_like(im_DOLP)
    
    DOLP_errors = []
    tic = time.time()
    for i in range(im_theta.shape[0]):
        for j in range(im_theta.shape[1]):
            try:
                im_theta[i,j] = f(im_DOLP[i,j])
            except ValueError:
                DOLP_errors.append(im_DOLP[i,j])
    
    toc = time.time()
    print("Time for DOLP2Theta conversion is : ", toc-tic, "seconds")
    return im_theta, DOLP_errors

def write_float_image(im_prefix, im_number, image, location, file_prefix):
    fname = os.path.join(location, file_prefix+"_"+"{}-{}.mat".format(im_prefix, im_number))
    scipy.io.savemat(fname, {str(im_prefix): image})

def heatmap_from_greyscale(grey_image):
    '''
    @ param: grey_image : [0, 255] range (8 bit) image array
    '''
    # Create a heatmap from the greyscale image
    im_heatmap = cv2.applyColorMap(
        grey_image, cv2.COLORMAP_JET
    )
    return im_heatmap

def calculate_AOLP(im_stokes1, im_stokes2):
    '''
    Calculate AoLP
    '''
    tic = time.time()

    im_AOLP = (0.5 * np.arctan2(im_stokes2, im_stokes1)).astype(
        np.float
    )
    toc = time.time()
    print("AoLP time: ", toc - tic, "s")
    return im_AOLP

def normalise_AOLP(im_AOLP):
    '''
    Normalize from [-pi/2, pi/2] range to [0, 255] range (8 bit)
    '''
    im_AOLP_normalized = (
        (im_AOLP + math.pi / 2) * (255 / math.pi)
    ).astype(np.uint8)
    return im_AOLP_normalized

def saveplot(location, file_prefix, suffix):
    plt.savefig(os.path.join(location, file_prefix+"_"+"{}.png".format(suffix)))

def makeBokehColorbarImage(data, lower, higher, r=1024, c=1224, palette = "Viridis256", title=""):
    # bokeh plot object
    p1 = figure(tooltips = [('x', '$x'), ('y', '$y'), ('value', '@image')], title = title) #'Head-on θ'
    p1.x_range.range_padding = p1.y_range.range_padding = 0
    # p1.y_range.flipped = True
    # ****note that the y axis labels are opposite in order fromn the numpy row labelling 

    # must give a vector of image data for image parameter 
    cmapper = LinearColorMapper(palette = palette, low = lower, high =  higher)
    p1.image(image = [data[::-1,:]], x=0, y=0, dw=c, dh=r, color_mapper = cmapper,  level = "image") # Spectral11
    p1.grid.grid_line_width = 0.5
    color_bar = ColorBar(color_mapper = cmapper, ticker = BasicTicker(), location=(0,0))
    p1.add_layout(color_bar, 'right')
    # show(p1)
    return p1