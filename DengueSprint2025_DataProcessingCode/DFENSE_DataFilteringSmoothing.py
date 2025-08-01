"""
DFENSE Data Filtering and Smoothing in Python
------------------------------------------------------
This script replicates the functionality of the following Matlab programs:
- DenoiseSVD.m :contentReference[oaicite:2]{index=2}
- DFENSE_DataFilteringSmoothing.m :contentReference[oaicite:3]{index=3}

It:
    • Denoises a given time series using Singular Value Decomposition (SVD) 
      with optimal singular value thresholding (Gavish and Donoho's method).
    • Constructs a Hankel matrix, truncates the singular values, and reconstructs 
      the denoised time series via diagonal averaging.
    • Reads aggregated data by state, applies denoising to each time series (cases, 
      temperature, precipitation, etc.), then applies a Savitzky–Golay filter and cubic 
      spline smoothing.
    • Plots the filtered and smoothed data.
    
Author: Americo Cunha Jr
"""

import os, time, shutil
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter
from scipy.signal import savgol_filter
from scipy.interpolate import CubicSpline
from scipy import integrate

#############################################
#  DenoiseSVD Function and Helpers
#############################################

def denoise_svd(x, w, r=None):
    """
    Remove noise from a time series using SVD.
    
    Parameters:
        x (1D np.array): Noisy time series (will be converted to column vector).
        w (int): Window length for Hankel matrix.
        r (int, optional): Truncation rank. If not provided, determined using 
                           Gavish and Donoho's method.
    
    Returns:
        x_denoised (1D np.array): The denoised time series.
        r (int): Truncation rank used.
    """
    # Ensure x is a column vector
    x = np.asarray(x).flatten()
    N = len(x)
    if w > N:
        raise ValueError("w cannot be greater than the length of the time series.")
    
    # Construct Hankel matrix using a sliding window view
    # H has shape (N-w+1, w)
    H = np.lib.stride_tricks.sliding_window_view(x, window_shape=w).copy()
    
    # Perform SVD (economy size)
    U, S, Vt = np.linalg.svd(H, full_matrices=False)
    
    # Determine rank r if not provided
    if r is None:
        m, n = H.shape
        beta = min(m, n) / max(m, n)
        thresh = optimal_svht_coef(beta, sigma_known=False) * np.median(S)
        r = np.sum(S > thresh)
    else:
        if r <= 0 or r > w:
            raise ValueError("r must be a positive integer and no greater than w.")
    
    # Truncate singular values: set singular values from r onward to zero
    S_r = np.diag(np.concatenate([S[:r], np.zeros(len(S) - r)]))
    
    # Reconstruct the denoised Hankel matrix
    H_denoised = U @ S_r @ Vt
    
    # Diagonal averaging to reconstruct the time series
    x_denoised = np.zeros(N)
    count = np.zeros(N)
    # Loop over each element in H_denoised and average along anti-diagonals
    for i in range(H_denoised.shape[0]):
        for j in range(H_denoised.shape[1]):
            x_denoised[i+j] += H_denoised[i, j]
            count[i+j] += 1
    x_denoised = x_denoised / count
    return x_denoised, r

def optimal_svht_coef(beta, sigma_known):
    """
    Computes the optimal singular value hard threshold coefficient.
    
    Parameters:
        beta (float): Ratio min(m, n)/max(m, n) of the Hankel matrix.
        sigma_known (bool): If True, use the known sigma version.
    
    Returns:
        coef (float): The optimal coefficient.
    """
    if sigma_known:
        return optimal_svht_coef_sigma_known(beta)
    else:
        return optimal_svht_coef_sigma_unknown(beta)

def optimal_svht_coef_sigma_known(beta):
    w_val = (8*beta) / (beta + 1 + np.sqrt(beta**2 + 14*beta + 1))
    lambda_star = np.sqrt(2*(beta + 1) + w_val)
    return lambda_star

def optimal_svht_coef_sigma_unknown(beta):
    coef = optimal_svht_coef_sigma_known(beta)
    MPmedian = median_marcenko_pastur(beta)
    omega = coef / np.sqrt(MPmedian)
    return omega

def median_marcenko_pastur(beta):
    """
    Computes the median of the Marcenko-Pastur distribution for a given beta.
    """
    topSpec = (1 + np.sqrt(beta))**2
    botSpec = (1 - np.sqrt(beta))**2
    # Define the Marcenko-Pastur function as in Matlab: 1 - inc_mar_pas(x, beta, 0)
    def marpas(x):
        return 1 - inc_mar_pas(x, beta, 0)
    lobnd = botSpec
    hibnd = topSpec
    change = True
    while change and (hibnd - lobnd > 0.001):
        change = False
        x_vals = np.linspace(lobnd, hibnd, 5)
        y_vals = np.array([marpas(x) for x in x_vals])
        if np.any(y_vals < 0.5):
            lobnd = np.max(x_vals[y_vals < 0.5])
            change = True
        if np.any(y_vals > 0.5):
            hibnd = np.min(x_vals[y_vals > 0.5])
            change = True
    med = (hibnd + lobnd) / 2.0
    return med

def inc_mar_pas(x0, beta, gamma):
    """
    Computes the incomplete Marcenko-Pastur integral from x0 to topSpec.
    """
    if beta > 1:
        raise ValueError("beta beyond valid range.")
    topSpec = (1 + np.sqrt(beta))**2
    botSpec = (1 - np.sqrt(beta))**2
    def f(x):
        if (topSpec - x) * (x - botSpec) > 0:
            val = np.sqrt((topSpec - x) * (x - botSpec)) / (beta * x) / (2 * np.pi)
        else:
            val = 0
        return (x**gamma * val) if gamma != 0 else val
    I, _ = integrate.quad(f, x0, topSpec)
    return I

#############################################
# Plotting Functions (Reused from DFENSE Aggregation)
#############################################

def plot_curve1(time_vec, data, graphobj):
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(time_vec, data, linewidth=2, color=graphobj.get('linecolor', 'blue'))
    ax.set_title(graphobj.get('gtitle', ''), fontsize=24)
    ax.set_ylabel(graphobj.get('ylab', ''), fontsize=20)
    if graphobj.get('xlab'):
        ax.set_xlabel(graphobj.get('xlab'))
    if graphobj.get('ymin') != 'auto' and graphobj.get('ymax') != 'auto':
        ax.set_ylim([graphobj.get('ymin'), graphobj.get('ymax')])
    ax.xaxis.set_major_formatter(DateFormatter('%b %Y'))
    plt.xticks(rotation=45)
    ax.grid(True)
    # Optionally add logo and signature here...
    if graphobj.get('print', 'no') == 'yes':
        eps_filename = f"{graphobj.get('gname')}.eps"
        png_filename = f"{graphobj.get('gname')}.png"
        plt.savefig(eps_filename, format='eps')
        plt.savefig(png_filename, format='png')
        print(f"Plot saved as {eps_filename} and {png_filename}")
    if graphobj.get('close', 'no') == 'yes':
        plt.close(fig)
    return fig

def plot_envelope1(time_vec, T_min, T_med, T_max, graphobj):
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.fill_between(time_vec, T_min, T_max, color=graphobj.get('shadecolor', (0.925, 0.6625, 0.5490)),
                    alpha=0.3, label=graphobj.get('labelshade', 'Min-Max'))
    ax.plot(time_vec, T_med, linewidth=2, color=graphobj.get('linecolor', (0.850, 0.325, 0.0980)),
            label=graphobj.get('labelcurve', 'Mean'))
    ax.set_title(graphobj.get('gtitle', ''), fontsize=24)
    ax.set_ylabel(graphobj.get('ylab', ''), fontsize=20)
    if graphobj.get('xlab'):
        ax.set_xlabel(graphobj.get('xlab'))
    if graphobj.get('ymin') != 'auto' and graphobj.get('ymax') != 'auto':
        ax.set_ylim([graphobj.get('ymin'), graphobj.get('ymax')])
    ax.xaxis.set_major_formatter(DateFormatter('%b %Y'))
    plt.xticks(rotation=45)
    ax.grid(True)
    if graphobj.get('print', 'no') == 'yes':
        eps_filename = f"{graphobj.get('gname')}.eps"
        png_filename = f"{graphobj.get('gname')}.png"
        plt.savefig(eps_filename, format='eps')
        plt.savefig(png_filename, format='png')
        print(f"Plot saved as {eps_filename} and {png_filename}")
    if graphobj.get('close', 'no') == 'yes':
        plt.close(fig)
    return fig

def plot_envelope2(time_vec, P_min, P_med, P_max, P_tot, graphobj):
    fig, ax1 = plt.subplots(figsize=(10, 6))
    ax1.fill_between(time_vec, P_min, P_max, color=graphobj.get('shadecolor', (0.500, 0.7235, 0.8705)),
                     alpha=0.3, label=graphobj.get('labelshade', 'Min-Max'))
    ax1.plot(time_vec, P_med, linewidth=2, color=graphobj.get('linecolor_l', (0.000, 0.4470, 0.7410)),
             label=graphobj.get('labelcurve_l', 'Mean'))
    ax1.set_ylabel(graphobj.get('ylab_l', 'Precipitation (mm/h)'), fontsize=20)
    if graphobj.get('ymin_l') != 'auto' and graphobj.get('ymax_l') != 'auto':
        ax1.set_ylim([graphobj.get('ymin_l'), graphobj.get('ymax_l')])
    ax2 = ax1.twinx()
    ax2.plot(time_vec, P_tot, linestyle='--', linewidth=0.8,
             color=graphobj.get('linecolor_r', (0.000, 0.500, 0.0000)),
             label=graphobj.get('labelcurve_r', 'Total'))
    ax2.set_ylabel(graphobj.get('ylab_r', 'Total Precipitation (mm)'), fontsize=20)
    if graphobj.get('ymin_r') != 'auto' and graphobj.get('ymax_r') != 'auto':
        ax2.set_ylim([graphobj.get('ymin_r'), graphobj.get('ymax_r')])
    ax1.set_title(graphobj.get('gtitle', ''), fontsize=24)
    if graphobj.get('xlab'):
        ax1.set_xlabel(graphobj.get('xlab'))
    ax1.xaxis.set_major_formatter(DateFormatter('%b %Y'))
    plt.xticks(rotation=45)
    ax1.grid(True)
    if graphobj.get('print', 'no') == 'yes':
        eps_filename = f"{graphobj.get('gname')}.eps"
        png_filename = f"{graphobj.get('gname')}.png"
        plt.savefig(eps_filename, format='eps')
        plt.savefig(png_filename, format='png')
        print(f"Plot saved as {eps_filename} and {png_filename}")
    if graphobj.get('close', 'no') == 'yes':
        plt.close(fig)
    return fig

#############################################
# Main Filtering and Smoothing Script
#############################################

def main():
    start_time = time.time()
    print("------------------------------------------------------")
    print(" DENGUE Sprint Challenge 2024")
    print(" Surveillance and Climate Data Filtering and Smoothing")
    print(" by Americo Cunha Jr")
    print("------------------------------------------------------\n")
    
    # Define parameters
    Window = 52      # window length for SVD (as in Matlab)
    Order = 3        # polynomial order for Savitzky-Golay filter
    FrameLen = 11    # frame length for Savitzky-Golay filter (must be odd)
    
    # List of federative units (states)
    federative_units = ['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA',
                          'MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN',
                          'RS','RO','RR','SC','SP','SE','TO']
    
    # Create output directories if not exist
    os.makedirs("DataProcessed", exist_ok=True)
    os.makedirs("Figures", exist_ok=True)
    
    # Loop over each state
    for uf in federative_units:
        print(f"Processing data for {uf} ...")
        # Construct input filename (aggregated data CSV from previous processing)
        input_filename = f"DengueSprint2024_AggregatedData_{uf}.csv"
        # Assume file is in the "DataAggregated" folder
        df = pd.read_csv(os.path.join("DataAggregated", input_filename), encoding='latin1')
        
        # Extract columns into a numpy array
        # Expected columns: epiweek, cases, temp_min, temp_med, temp_max, precip_min, precip_med, precip_max, precip_tot
        # Ensure columns are in lowercase if needed.
        data = df[['epiweek','casos','temp_min','temp_med','temp_max',
                   'precip_min','precip_med','precip_max','precip_tot']].to_numpy(dtype=float)
        Nepiweeks = data.shape[0]
        
        # Denoise and filter each time series (columns 2 to 9, i.e. indices 1:9)
        for col in range(1, data.shape[1]):
            denoised, _ = denoise_svd(data[:, col], Window)
            # Apply Savitzky-Golay filter (using scipy.signal.savgol_filter)
            filtered = savgol_filter(denoised, window_length=FrameLen, polyorder=Order)
            data[:, col] = filtered
        
        # Spline smoothing: interpolate with a finer grid then sample back to original grid.
        time1 = np.arange(1, Nepiweeks+1)
        time2 = np.arange(1, Nepiweeks+1, 0.5)
        for col in range(1, data.shape[1]):
            cs = CubicSpline(time1, data[:, col])
            interp_vals = cs(time2)
            # Take every second value to return to original length
            data[:, col] = interp_vals[::2]
        
        # Round reported cases (column index 1) to integer values
        data[:, 1] = np.round(data[:, 1])
        # Set any negative values to zero
        data[data < 0] = 0.0
        
        # Convert epiweek (first column) to datetime objects for plotting
        epiweek = data[:, 0]
        years = np.floor(epiweek / 100).astype(int)
        weeks = (epiweek % 100).astype(int)
        #epi_dates = [datetime(year, 1, 1) + timedelta(weeks=week-1) for year, week in zip(years, weeks)]
        epi_dates = [datetime(int(year), 1, 1) + timedelta(weeks=int(week)-1) for year, week in zip(years, weeks)]
        
        # Define filenames for saving plots and processed data
        base_csv   = f"DengueSprint2024_ProcessedData_{uf}.csv"
        base_eps1  = f"DengueSprint2024_ReportedCases_{uf}_Filtered"
        base_eps2  = f"DengueSprint2024_Temperature_{uf}_Filtered"
        base_eps3  = f"DengueSprint2024_Precipitation_{uf}_Filtered"
        
        # Plot reported dengue cases (scale by 1000 as in Matlab)
        graphobj1 = {
            'gname': base_eps1,
            'gtitle': f"Dengue Reports in {uf} (Brazil)",
            'ymin': 'auto',
            'ymax': 'auto',
            'xlab': '',
            'ylab': 'Probable Cases × 10^3',
            'linecolor': (0.635, 0.078, 0.184),
            'print': 'yes',
            'close': 'no'
        }
        plot_curve1(epi_dates, data[:, 1]/1000, graphobj1)
        
        # Plot temperature envelope (using columns: temp_min, temp_med, temp_max -> indices 2,3,4)
        graphobj2 = {
            'gname': base_eps2,
            'gtitle': f"Temperature in {uf} (Brazil)",
            'ymin': 5.0,
            'ymax': 40.0,
            'xlab': '',
            'ylab': 'Temperature (ºC)',
            'labelcurve': 'Mean',
            'labelshade': 'Min-Max',
            'linecolor': (0.850, 0.325, 0.098),
            'shadecolor': (0.925, 0.6625, 0.5490),
            'print': 'yes',
            'close': 'no'
        }
        plot_envelope1(epi_dates, data[:, 2], data[:, 3], data[:, 4], graphobj2)
        
        # Plot precipitation envelope (using columns: precip_min, precip_med, precip_max, precip_tot -> indices 5,6,7,8)
        graphobj3 = {
            'gname': base_eps3,
            'gtitle': f"Precipitation in {uf} (Brazil)",
            'ymin_l': 0.0,
            'ymax_l': 3.0,
            'ymin_r': 0.0,
            'ymax_r': 'auto',
            'xlab': '',
            'ylab_l': 'Precipitation (mm/h)',
            'ylab_r': 'Total Precipitation (mm)',
            'labelcurve_l': 'Mean',
            'labelcurve_r': 'Total',
            'labelshade': 'Min-Max',
            'linecolor_l': (0.000, 0.447, 0.741),
            'linecolor_r': (0.000, 0.500, 0.000),
            'shadecolor': (0.500, 0.7235, 0.8705),
            'print': 'yes',
            'close': 'no'
        }
        plot_envelope2(epi_dates, data[:, 5], data[:, 6], data[:, 7], data[:, 8], graphobj3)
        
        # Save the processed data to CSV
        columns = ['epiweek','cases','temp_min','temp_med','temp_max',
                   'precip_min','precip_med','precip_max','precip_tot']
        df_out = pd.DataFrame(data, columns=columns)
        df_out.to_csv(base_csv, index=False)
        print(f"Data saved to {base_csv}\n")
    
    # Move all CSV and figure files to designated directories
    for file in os.listdir('.'):
        if file.endswith('.csv'):
            shutil.move(file, os.path.join("DataProcessed", file))
        if file.endswith('.eps') or file.endswith('.png'):
            shutil.move(file, os.path.join("Figures", file))
    
    elapsed = time.time() - start_time
    print("------------------------------------------------------")
    print("            THE END!")
    print(f"  Total execution time: {elapsed:.2f} seconds")
    print("------------------------------------------------------")

if __name__ == "__main__":
    main()
