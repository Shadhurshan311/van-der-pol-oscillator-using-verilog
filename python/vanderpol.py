import pandas as pd
import matplotlib.pyplot as plt

# Read data
data = pd.read_csv("C:\\Users\\94772\\Desktop\\university tools\\SEMESTER 7\\EE587-Digital Design and Synthesis\\Van der Pol Assignment\\E_20_372\\Vivado files\\Vivado files.sim\\sim_1\\behav\\xsim\\vanderpol_data.csv")

# Create plots
plt.figure(figsize=(14, 4))

# Position
plt.subplot(1, 3, 1)
plt.plot(data['time'], data['position'], 'b-', linewidth=2)
plt.xlabel('Time')
plt.ylabel('Position x')
plt.title('Position vs Time')
plt.grid(True)

# Velocity
plt.subplot(1, 3, 2)
plt.plot(data['time'], data['velocity'], 'r-', linewidth=2)
plt.xlabel('Time')
plt.ylabel('Velocity u')
plt.title('Velocity vs Time')
plt.grid(True)

# Phase Portrait
plt.subplot(1, 3, 3)
plt.plot(data['position'], data['velocity'], 'g-', linewidth=2)
plt.plot(data['position'].iloc[0], data['velocity'].iloc[0], 'go', markersize=10)
plt.xlabel('Position x')
plt.ylabel('Velocity u')
plt.title('Phase Portrait')
plt.grid(True)

plt.tight_layout()
plt.savefig('vanderpol_quick.png', dpi=150)
print("✓ Plot saved: vanderpol_quick.png")
plt.show()