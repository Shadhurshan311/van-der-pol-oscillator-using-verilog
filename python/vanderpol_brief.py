#!/usr/bin/env python3
"""
Plot Van der Pol Oscillator Results
Reads vanderpol_data.csv and creates plots
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Read CSV file
data = pd.read_csv("C:\\Users\\94772\\Desktop\\university tools\\SEMESTER 7\\EE587-Digital Design and Synthesis\\Van der Pol Assignment\\E_20_372\\Vivado files\\Vivado files.sim\\sim_1\\behav\\xsim\\vanderpol_data.csv")

print("Van der Pol Oscillator - Data Loaded")
print(f"Total data points: {len(data)}")
print(f"Time range: {data['time'].min():.2f} to {data['time'].max():.2f}")
print(f"Position range: {data['position'].min():.2f} to {data['position'].max():.2f}")
print()

# Create figure with 4 subplots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Van der Pol Oscillator Analysis (μ=1.0)', fontsize=16, fontweight='bold')

# Plot 1: Position vs Time
axes[0, 0].plot(data['time'], data['position'], 'b-', linewidth=1.5)
axes[0, 0].set_xlabel('Time (t)', fontsize=11)
axes[0, 0].set_ylabel('Position x(t)', fontsize=11)
axes[0, 0].set_title('Position vs Time', fontsize=12, fontweight='bold')
axes[0, 0].grid(True, alpha=0.3)
axes[0, 0].axhline(y=0, color='k', linestyle='--', linewidth=0.5)

# Plot 2: Velocity vs Time
axes[0, 1].plot(data['time'], data['velocity'], 'r-', linewidth=1.5)
axes[0, 1].set_xlabel('Time (t)', fontsize=11)
axes[0, 1].set_ylabel('Velocity u(t)', fontsize=11)
axes[0, 1].set_title('Velocity vs Time', fontsize=12, fontweight='bold')
axes[0, 1].grid(True, alpha=0.3)
axes[0, 1].axhline(y=0, color='k', linestyle='--', linewidth=0.5)

# Plot 3: Phase Portrait (x vs u)
axes[1, 0].plot(data['position'], data['velocity'], 'g-', linewidth=2, alpha=0.7)
axes[1, 0].plot(data['position'].iloc[0], data['velocity'].iloc[0], 
                'go', markersize=10, label='Start')
axes[1, 0].plot(data['position'].iloc[-1], data['velocity'].iloc[-1], 
                'rs', markersize=10, label='End')
axes[1, 0].set_xlabel('Position x', fontsize=11)
axes[1, 0].set_ylabel('Velocity u', fontsize=11)
axes[1, 0].set_title('Phase Portrait (Limit Cycle)', fontsize=12, fontweight='bold')
axes[1, 0].grid(True, alpha=0.3)
axes[1, 0].axhline(y=0, color='k', linestyle='--', linewidth=0.5)
axes[1, 0].axvline(x=0, color='k', linestyle='--', linewidth=0.5)
axes[1, 0].legend()
axes[1, 0].axis('equal')

# Plot 4: Both signals together
axes[1, 1].plot(data['time'], data['position'], 'b-', linewidth=2, label='Position x(t)')
axes[1, 1].plot(data['time'], data['velocity'], 'r-', linewidth=2, label='Velocity u(t)')
axes[1, 1].set_xlabel('Time (t)', fontsize=11)
axes[1, 1].set_ylabel('Amplitude', fontsize=11)
axes[1, 1].set_title('Position and Velocity', fontsize=12, fontweight='bold')
axes[1, 1].grid(True, alpha=0.3)
axes[1, 1].axhline(y=0, color='k', linestyle='--', linewidth=0.5)
axes[1, 1].legend()

plt.tight_layout()
plt.savefig('vanderpol_plots.png', dpi=150, bbox_inches='tight')
print("✓ Plots saved as: vanderpol_plots.png")
plt.show()

# Print statistics
print("\n" + "="*50)
print("Statistics:")
print("="*50)
print(f"Position - Max: {data['position'].max():.6f}, Min: {data['position'].min():.6f}")
print(f"Velocity - Max: {data['velocity'].max():.6f}, Min: {data['velocity'].min():.6f}")
print(f"Amplitude: {(data['position'].max() - data['position'].min())/2:.6f}")
print("="*50)