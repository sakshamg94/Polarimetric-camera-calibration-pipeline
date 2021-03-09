import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable


def custom_twinSubPlot(image_data1, image_data2, title1 = "", title2="", save = 0, x_ticks = None, y_ticks = None):
    plt.figure()

    #subplot(r,c) provide the no. of rows and columns
    fig, (ax0, ax1) = plt.subplots(1,2, figsize =(15, 5)) 

    ax0.set_title(title1)
    # Display image, `aspect='auto'` makes it fill the whole `axes` (ax2)
    im0 = ax0.imshow(image_data1, cmap = plt.cm.viridis, aspect='auto')#, vmin = 0, vmax = 255)
    # Create divider for existing axes instance
    divider0 = make_axes_locatable(ax0)
    # Append axes to the right of ax3, with 20% width of ax2
    cax0 = divider0.append_axes("right", size="10%", pad=0.08)
    # Create colorbar in the appended axes
    # Tick locations can be set with the kwarg `ticks`
    # and the format of the ticklabels with kwarg `format`
    cbar0 = plt.colorbar(im0, cax=cax0)
    if x_ticks is not None:
        positions = np.arange(0,image_data1[1])
        labels = x_ticks
        ax0.set_xticks(positions, labels)

    # create the second subplot
    ax1.set_title(title2)
    # Display image, `aspect='auto'` makes it fill the whole `axes` (ax2)
    im1 = ax1.imshow(image_data2, cmap = plt.cm.cividis, aspect='auto') # vmin = -5, vmax = 5, 
    # Create divider for existing axes instance
    divider1 = make_axes_locatable(ax1)
    # Append axes to the right of ax3, with 20% width of ax2
    cax1 = divider1.append_axes("right", size="10%", pad=0.08)
    # Create colorbar in the appended axes
    # Tick locations can be set with the kwarg `ticks`
    # and the format of the ticklabels with kwarg `format`
    cbar1 = plt.colorbar(im1, cax=cax1)
    # Remove yticks from ax1
    ax1.yaxis.set_visible(False)
    if x_ticks is not None:
        positions = np.arange(0,image_data1[1])
        labels = x_ticks
        ax1.set_xticks(positions, labels)

    if y_ticks is not None:
        positions = np.arange(0,image_data1[0])
        labels = y_ticks
        ax1.set_yticks(positions, labels)   


    plt.show()
    if save:
        plt.savefig(title1+title2+'.png')

def slopeFieldFFT(sx, sy, suppress_fig=0):
    '''
    sx: x direction slope field as a function of the spatial coordinates x,y
    sy: y direction slope field as a function of the spatial coordinates x,y
    return height map as a function of space coordiantes x,y upto a constant
    '''
    s_hat_x = np.fft.fft2(sx)
    s_hat_x_shifted = np.fft.fftshift(s_hat_x)
    s_hat_x_mag = 20*np.log(np.abs(s_hat_x_shifted))

    s_hat_y = np.fft.fft2(sy)
    s_hat_y_shifted = np.fft.fftshift(s_hat_y) # DC content at the center
    s_hat_y_mag = 20*np.log(np.abs(s_hat_y_shifted))

    FreqCompRows = np.fft.fftfreq(s_hat_x.shape[0],d=1)
    FreqCompCols = np.fft.fftfreq(s_hat_x.shape[1],d=1)
    FreqCompRows = np.fft.fftshift(FreqCompRows)
    FreqCompCols = np.fft.fftshift(FreqCompCols)

    R,C = np.meshgrid(FreqCompRows, FreqCompCols)

    if not suppress_fig:
        custom_twinSubPlot(s_hat_x_mag, s_hat_y_mag, \
            "$Amplitude ~spectrum:~20~log(|\\hat{s_x}|)$", "$Amplitude ~spectrum: ~20~log(|\\hat{s_y}|)$")

        custom_twinSubPlot(s_hat_x_mag**2, s_hat_y_mag**2, \
            "$Power ~spectrum:~[20~log(|\\hat{s_x}|)]^2$", "$Power ~spectrum: ~[20~log(|\\hat{s_y}|)]^2$")

    return s_hat_x, s_hat_y

def slope2height(s_hat_x, s_hat_y):
    
    assert s_hat_x.shape == s_hat_y.shape
    rows, cols  = s_hat_x.shape

    kx = np.fft.fftfreq(cols, 1/cols)
    ky = np.fft.fftfreq(rows, 1/rows)

    k_grid_x , k_grid_y = np.meshgrid(kx,ky)
    # make the DC wavenumber non zero so that divisoon is not a problem
    k_grid_x[0,0] = 1 
    k_grid_y[0,0] = 1

    h_hat = -1j * (k_grid_x*s_hat_x + k_grid_y*s_hat_y)/(k_grid_x**2 + k_grid_y**2)
    h_hat[0,0] = 0 # making the DC frequency component 0

    height_map = np.fft.ifft2(h_hat)

    return height_map


