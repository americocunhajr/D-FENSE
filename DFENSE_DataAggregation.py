"""
DFENSE Data Aggregation and Visualization in Python
------------------------------------------------------
This script replicates the functionality of the Matlab programs:
- DataCleaning.m :contentReference[oaicite:0]{index=0}
- DFENSE_DataAggregation.m :contentReference[oaicite:1]{index=1}
- PlotCurve1.m :contentReference[oaicite:2]{index=2}
- PlotEnvelope1.m :contentReference[oaicite:3]{index=3}
- PlotEnvelope2.m :contentReference[oaicite:4]{index=4}

It loads dengue, climate, and regic (geocode) CSV files from the "DataRaw" directory,
cleans the data (replacing Inf, NaN, and forbidden values with zeros),
aggregates by epidemiological week for each Brazilian state,
plots the reported dengue cases, temperature, and precipitation data,
and saves the outputs (aggregated CSV and figures) into dedicated folders.

Author: Americo Cunha Jr
"""

import os
import time
import shutil
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter

# Define custom colors (RGB tuples) similar to the Matlab code
MyRed         = (0.6350, 0.0780, 0.1840)
MyGreen       = (0.0000, 0.5000, 0.0000)
MyBlue        = (0.0000, 0.4470, 0.7410)
MyOrange      = (0.8500, 0.3250, 0.0980)
MyPink        = (1.0000, 0.5000, 0.7500)
MyLightBlue   = (0.5000, 0.7235, 0.8705)
MyLightRed    = (0.8175, 0.5390, 0.5920)
MyLightOrange = (0.9250, 0.6625, 0.5490)

def data_cleaning(raw_data, positive_fields=None, forbidden_values=None):
    """
    Preprocess raw_data by replacing Inf, NaN, and any forbidden values with zeros.
    For specified positive_fields, negative values are also set to zero.
    
    Parameters:
        raw_data (pd.DataFrame): The input dataframe.
        positive_fields (list): List of column names that must be positive.
        forbidden_values (list): List of forbidden numeric ranges, each as a [min, max] list.
        
    Returns:
        pd.DataFrame: The cleaned dataframe.
    """
    if positive_fields is None:
        positive_fields = []
    if forbidden_values is None:
        forbidden_values = []

    df = raw_data.copy()

    for col in df.columns:
        # Process only numeric columns
        if pd.api.types.is_numeric_dtype(df[col]):
            # Replace Inf and NaN with 0
            df[col].replace([np.inf, -np.inf], np.nan)
            df[col] = df[col].fillna(0.0)
            # Replace empty entries if any (unlikely in numeric series)
            df[col] = df[col].replace('', 0.0)
            
            # For specified positive fields, ensure no negative values remain
            if col in positive_fields:
                df.loc[df[col] < 0, col] = 0.0
            
            # Replace values within any forbidden range with 0
            for rng in forbidden_values:
                if isinstance(rng, (list, tuple)) and len(rng) == 2:
                    lower, upper = rng
                    df.loc[(df[col] >= lower) & (df[col] <= upper), col] = 0.0
                else:
                    raise ValueError("Forbidden values must be numeric arrays of length 2.")
    return df

def plot_curve1(time_vec, data, graphobj):
    """
    Plot a single time series curve.
    
    Parameters:
        time_vec (list or pd.Series): Datetime objects for the x-axis.
        data (list or np.array): Numeric data for the y-axis.
        graphobj (dict): Configuration parameters (e.g., gname, gtitle, linecolor, ylab, etc.).
        
    Returns:
        fig: The matplotlib figure object.
    """
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(time_vec, data, linewidth=2, color=graphobj.get('linecolor', 'blue'))
    
    ax.set_title(graphobj.get('gtitle', ''), fontsize=24, fontname='Helvetica')
    ax.set_ylabel(graphobj.get('ylab', ''), fontsize=20, fontname='Helvetica')
    # Optionally set x-label if provided
    if graphobj.get('xlab'):
        ax.set_xlabel(graphobj.get('xlab'))
    
    # Set auto or fixed y-limits
    ymin = graphobj.get('ymin', 'auto')
    ymax = graphobj.get('ymax', 'auto')
    if ymin != 'auto' and ymax != 'auto':
        ax.set_ylim([ymin, ymax])
    
    # Format the x-axis dates
    ax.xaxis.set_major_formatter(DateFormatter('%b %Y'))
    plt.xticks(rotation=45)
    ax.grid(True)
    
    # Add logo if available
    logo_path = os.path.join('logo', 'D-FENSE.png')
    if os.path.exists(logo_path):
        try:
            logo = plt.imread(logo_path)
            # inset axes for logo
            inset_ax = fig.add_axes([0.22, 0.75, 0.15, 0.15], anchor='NW', zorder=1)
            inset_ax.imshow(logo)
            inset_ax.axis('off')
        except Exception as e:
            print("Could not load logo:", e)
    
    # Add signature annotation if provided
    if graphobj.get('signature'):
        fig.text(0.98, 0.2, graphobj['signature'], fontsize=12, fontname='Helvetica',
                 color=(0.5, 0.5, 0.5), rotation=90, va='bottom', ha='center')
    
    # Save the figure if requested
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
    """
    Plot a time series with a shaded envelope representing the range between T_min and T_max,
    and a line plot for T_med.
    
    Parameters:
        time_vec (list or pd.Series): Datetime objects.
        T_min, T_med, T_max (array-like): Temperature data.
        graphobj (dict): Graph configuration parameters.
        
    Returns:
        fig: The matplotlib figure object.
    """
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Plot the shaded area
    ax.fill_between(time_vec, T_min, T_max, color=graphobj.get('shadecolor', MyLightOrange),
                    alpha=0.3, label=graphobj.get('labelshade', 'Range'))
    # Plot the median temperature
    ax.plot(time_vec, T_med, linewidth=2, color=graphobj.get('linecolor', MyOrange),
            label=graphobj.get('labelcurve', 'Mean'))
    
    ax.set_title(graphobj.get('gtitle', ''), fontsize=24, fontname='Helvetica')
    ax.set_ylabel(graphobj.get('ylab', ''), fontsize=20, fontname='Helvetica')
    if graphobj.get('xlab'):
        ax.set_xlabel(graphobj.get('xlab'))
    
    # Set y-axis limits if specified
    ymin = graphobj.get('ymin', 'auto')
    ymax = graphobj.get('ymax', 'auto')
    if ymin != 'auto' and ymax != 'auto':
        ax.set_ylim([ymin, ymax])
    
    ax.xaxis.set_major_formatter(DateFormatter('%b %Y'))
    plt.xticks(rotation=45)
    ax.grid(True)
    
    # Add logo image if available
    logo_path = os.path.join('logo', 'D-FENSE.png')
    if os.path.exists(logo_path):
        try:
            logo = plt.imread(logo_path)
            inset_ax = fig.add_axes([0.22, 0.75, 0.15, 0.15], anchor='NW', zorder=1)
            inset_ax.imshow(logo)
            inset_ax.axis('off')
        except Exception as e:
            print("Could not load logo:", e)
    
    if graphobj.get('signature'):
        fig.text(0.98, 0.2, graphobj['signature'], fontsize=12, fontname='Helvetica',
                 color=(0.5, 0.5, 0.5), rotation=90, va='bottom', ha='center')
    
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
    """
    Plot precipitation data with a shaded envelope (P_min to P_max) and two lines:
    one for the median precipitation on the left y-axis and one for total precipitation on the right y-axis.
    
    Parameters:
        time_vec (list or pd.Series): Datetime objects.
        P_min, P_med, P_max, P_tot (array-like): Precipitation data.
        graphobj (dict): Graph configuration parameters.
        
    Returns:
        fig: The matplotlib figure object.
    """
    fig, ax1 = plt.subplots(figsize=(10, 6))
    
    # Left y-axis: shaded envelope and median precipitation
    ax1.fill_between(time_vec, P_min, P_max, color=graphobj.get('shadecolor', MyLightBlue),
                     alpha=0.3, label=graphobj.get('labelshade', 'Min-Max'))
    ax1.plot(time_vec, P_med, linewidth=2, color=graphobj.get('linecolor_l', MyBlue),
             label=graphobj.get('labelcurve_l', 'Mean'))
    ax1.set_ylabel(graphobj.get('ylab_l', 'Precipitation (mm/h)'), fontsize=20, fontname='Helvetica')
    ymin_l = graphobj.get('ymin_l', 'auto')
    ymax_l = graphobj.get('ymax_l', 'auto')
    if ymin_l != 'auto' and ymax_l != 'auto':
        ax1.set_ylim([ymin_l, ymax_l])
    
    # Right y-axis: total precipitation
    ax2 = ax1.twinx()
    ax2.plot(time_vec, P_tot, linestyle='--', linewidth=0.8,
             color=graphobj.get('linecolor_r', MyGreen),
             label=graphobj.get('labelcurve_r', 'Total'))
    ax2.set_ylabel(graphobj.get('ylab_r', 'Total Precipitation (mm)'), fontsize=20, fontname='Helvetica')
    ymin_r = graphobj.get('ymin_r', 'auto')
    ymax_r = graphobj.get('ymax_r', 'auto')
    if ymin_r != 'auto' and ymax_r != 'auto':
        ax2.set_ylim([ymin_r, ymax_r])
    
    ax1.set_title(graphobj.get('gtitle', ''), fontsize=24, fontname='Helvetica')
    if graphobj.get('xlab'):
        ax1.set_xlabel(graphobj.get('xlab'))
    
    ax1.xaxis.set_major_formatter(DateFormatter('%b %Y'))
    plt.xticks(rotation=45)
    ax1.grid(True)
    
    # Add logo image if available
    logo_path = os.path.join('logo', 'D-FENSE.png')
    if os.path.exists(logo_path):
        try:
            logo = plt.imread(logo_path)
            inset_ax = fig.add_axes([0.22, 0.75, 0.15, 0.15], anchor='NW', zorder=1)
            inset_ax.imshow(logo)
            inset_ax.axis('off')
        except Exception as e:
            print("Could not load logo:", e)
    
    if graphobj.get('signature'):
        fig.text(0.98, 0.2, graphobj['signature'], fontsize=12, fontname='Helvetica',
                 color=(0.5, 0.5, 0.5), rotation=90, va='bottom', ha='center')
    
    if graphobj.get('print', 'no') == 'yes':
        eps_filename = f"{graphobj.get('gname')}.eps"
        png_filename = f"{graphobj.get('gname')}.png"
        plt.savefig(eps_filename, format='eps')
        plt.savefig(png_filename, format='png')
        print(f"Plot saved as {eps_filename} and {png_filename}")
    
    if graphobj.get('close', 'no') == 'yes':
        plt.close(fig)
    
    return fig


def fix_csv_columns(df, delimiter=','):
    """
    If the DataFrame was read with all fields in a single column,
    split that column using the provided delimiter and set the header.
    """
    if df.shape[1] == 1:
        # Split the single column into multiple columns using the delimiter
        df = df[df.columns[0]].str.split(delimiter, expand=True)
        # Use the first row as the header
        df.columns = df.iloc[0]
        # Remove the header row from the data and reset the index
        df = df[1:].reset_index(drop=True)
    return df

def main():
    # Start the timer
    start_time = time.time()
    print("------------------------------------------------------")
    print(" DENGUE Sprint Challenge 2024")
    print(" Surveillance and Climate Data Aggregation")
    print(" by Americo Cunha Jr")
    print("------------------------------------------------------\n")
    
    # Load datasets from the DataRaw folder
    data_raw_path = "DataRaw"

    # Load and fix dengue data (assuming comma-separated)
    df_dengue = pd.read_csv(os.path.join(data_raw_path, "dengue.csv"), encoding='latin1')
    df_dengue = fix_csv_columns(df_dengue, delimiter=';')
    df_dengue.columns  = df_dengue.columns.str.lower()
    #print("Dengue columns:", df_dengue.columns)

    # Load and fix climate data (assuming comma-separated)
    df_climate = pd.read_csv(os.path.join(data_raw_path, "climate.csv"), encoding='latin1')
    df_climate = fix_csv_columns(df_climate, delimiter=';')
    df_climate.columns = df_climate.columns.str.lower()
    #print("Climate columns:", df_climate.columns)

    # Load and fix regic data (the header uses semicolons)
    df_regic = pd.read_csv(os.path.join(data_raw_path, "regic2018.csv"), encoding='latin1', sep=';')
    df_regic = fix_csv_columns(df_regic, delimiter=';')
    df_regic.columns   = df_regic.columns.str.lower()
    #print("Regic columns:", df_regic.columns)
    
    print("Loaded dengue, climate, and regic data.\n")
    
    # Define fields that must be positive for cleaning
    positive_fields1 = ['epiweek', 'casos', 'geocode']
    positive_fields2 = ['epiweek', 'geocode', 'precip_min', 'precip_med', 'precip_max', 'precip_tot',
                          'rel_humid_min', 'rel_humid_med', 'rel_humid_max', 'thermal_range']
    positive_fields3 = ['geocode']
    
    # Clean the datasets using data_cleaning()
    df_dengue  = data_cleaning(df_dengue, positive_fields1)
    df_climate = data_cleaning(df_climate, positive_fields2)
    df_regic   = data_cleaning(df_regic, positive_fields3)
    print("Data cleaning complete.\n")
    
    # Define valid epidemiological weeks from 2010 to 2023 (weeks 1 to 52)
    valid_epiweeks = [year * 100 + week for year in range(2010, 2024) for week in range(1, 53)]
    
    # Create directories for output if they don't exist
    os.makedirs("DataAggregated", exist_ok=True)
    os.makedirs("Figures", exist_ok=True)
    
    # Process data for each federative unit (state)
    federative_units = df_dengue['uf'].unique()
    for uf in federative_units:
        print(f"Processing data for {uf} ...")
        # Filter regic data to get geocodes for current state
        geocodes_for_uf = df_regic.loc[df_regic['uf'] == uf, 'geocode']
        
        # Filter dengue and climate datasets
        df_state_dengue  = df_dengue[df_dengue['uf'] == uf]
        df_state_climate = df_climate[df_climate['geocode'].isin(geocodes_for_uf)]
        
        # Filter by valid epiweeks
        df_state_dengue  = df_state_dengue[df_state_dengue['epiweek'].isin(valid_epiweeks)]
        df_state_climate = df_state_climate[df_state_climate['epiweek'].isin(valid_epiweeks)]
        
        # If no data exists for the state, skip processing
        if df_state_dengue.empty or df_state_climate.empty:
            print(f"No valid data for {uf}. Skipping.\n")
            continue
        
        # Aggregate dengue cases by epiweek
        agg_dengue = df_state_dengue.groupby('epiweek')['casos'].sum().reset_index()
        # Aggregate climate data by epiweek: compute mean for temperature and precipitation fields,
        # and sum total precipitation
        agg_climate = df_state_climate.groupby('epiweek').agg({
            'temp_min': 'mean',
            'temp_med': 'mean',
            'temp_max': 'mean',
            'precip_min': 'mean',
            'precip_med': 'mean',
            'precip_max': 'mean',
            'precip_tot': 'sum'
        }).reset_index()
        
        # Merge aggregated dengue and climate data on epiweek
        agg_data = pd.merge(agg_dengue, agg_climate, on='epiweek', how='inner')
        agg_data.sort_values('epiweek', inplace=True)
        
        # Convert epiweek to datetime:
        # For each epiweek, extract year and week number, then compute the date as Jan 1 + (week-1)*7 days.
        def epiweek_to_date(epi):
            year = epi // 100
            week = epi % 100
            # This simple conversion assumes week 1 starts on Jan 1
            return datetime(year, 1, 1) + timedelta(weeks=week-1)
        
        agg_data['date'] = agg_data['epiweek'].apply(epiweek_to_date)
        
        # Prepare plotting data
        dates = agg_data['date']
        # Dengue cases scaled by 1000
        cases = agg_data['casos'] / 1000.0
        # Temperature data
        temp_min = agg_data['temp_min']
        temp_med = agg_data['temp_med']
        temp_max = agg_data['temp_max']
        # Precipitation data
        precip_min = agg_data['precip_min']
        precip_med = agg_data['precip_med']
        precip_max = agg_data['precip_max']
        precip_tot = agg_data['precip_tot']
        
        # Define filenames (prefixes) for current state
        base_csv   = f"DengueSprint2024_AggregatedData_{uf}.csv"
        base_eps1  = f"DengueSprint2024_ReportedCases_{uf}_Raw"
        base_eps2  = f"DengueSprint2024_Temperature_{uf}_Raw"
        base_eps3  = f"DengueSprint2024_Precipitation_{uf}_Raw"
        
        # Plot reported dengue cases
        graphobj1 = {
            'gname': base_eps1,
            'gtitle': f"Dengue Reports in {uf} (Brazil)",
            'ymin': 'auto',
            'ymax': 'auto',
            'xlab': '',
            'ylab': 'Probable Cases × 10^3',
            'linecolor': MyRed,
            'signature': 'Author: Americo Cunha Jr (UERJ)',
            'print': 'yes',
            'close': 'no'
        }
        plot_curve1(dates, cases, graphobj1)
        
        # Plot temperature envelope
        graphobj2 = {
            'gname': base_eps2,
            'gtitle': f"Temperature in {uf} (Brazil)",
            'ymin': 5.0,
            'ymax': 40.0,
            'xlab': '',
            'ylab': 'Temperature (ºC)',
            'labelcurve': 'Mean',
            'labelshade': 'Min-Max',
            'linecolor': MyOrange,
            'shadecolor': MyLightOrange,
            'signature': 'Author: Americo Cunha Jr (UERJ)',
            'print': 'yes',
            'close': 'no'
        }
        plot_envelope1(dates, temp_min, temp_med, temp_max, graphobj2)
        
        # Plot precipitation envelope with dual y-axis
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
            'linecolor_l': MyBlue,
            'linecolor_r': MyGreen,
            'shadecolor': MyLightBlue,
            'signature': 'Author: Americo Cunha Jr (UERJ)',
            'print': 'yes',
            'close': 'no'
        }
        plot_envelope2(dates, precip_min, precip_med, precip_max, precip_tot, graphobj3)
        
        # Save aggregated data to CSV
        agg_data_to_save = agg_data[['epiweek', 'casos', 'temp_min', 'temp_med', 'temp_max',
                                     'precip_min', 'precip_med', 'precip_max', 'precip_tot']]
        agg_data_to_save.to_csv(base_csv, index=False)
        print(f"Data saved to {base_csv}\n")
    
    # Move CSV and figure files to designated folders
    for file in os.listdir('.'):
        if file.endswith('.csv'):
            shutil.move(file, os.path.join("DataAggregated", file))
        if file.endswith('.eps') or file.endswith('.png'):
            shutil.move(file, os.path.join("Figures", file))
    
    elapsed = time.time() - start_time
    print("------------------------------------------------------")
    print("            THE END!")
    print(f"  Total execution time: {elapsed:.2f} seconds")
    print("------------------------------------------------------")

if __name__ == "__main__":
    main()
