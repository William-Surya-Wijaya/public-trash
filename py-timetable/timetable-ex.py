import matplotlib.pyplot as plt
import numpy as np
import math
from datetime import datetime
from matplotlib.animation import FuncAnimation

# Activities and corresponding hours (start and end times)
activities = {
    (0, 6): "Dreamland",
    (6, 9): "Morning",
    (9, 12): "Gaming",
    (12, 14): "Exercise",
    (14, 18): "Comics",
    (18, 19): "Free Time",
    (19, 21): "Meditation",
    (21, 24): "Sleep"
}

# Function to draw the clock with activities, schedule separation lines, and real-time hands
def draw_clock():
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.set_aspect('equal')
    
    # Set background color to #d8d7d2 (RGB: 216, 215, 210)
    fig.patch.set_facecolor('#d8d7d2')
    ax.set_facecolor('#d8d7d2')
    
    # Turn off grid lines and axis ticks
    ax.grid(False)
    ax.set_xticks([])
    ax.set_yticks([])
    
    # Remove the square border (spines)
    for spine in ax.spines.values():
        spine.set_visible(False)
    
    outer_circle = plt.Circle((0, 0), 1.15, color='black', fill=False, lw=1)
    inner_circle = plt.Circle((0, 0), 1.1, color='black', fill=False, lw=2)  # Larger inner circle
    ax.add_artist(inner_circle)
    ax.add_artist(outer_circle)
    
    # Draw separation lines at the boundaries between schedules (increased gap)
    for start, end in activities.keys():
        for boundary in [start, end]:
            angle = math.radians(90 - boundary * 15)
            
            # Separation line from the inner circle to about 70% towards the center (increased gap)
            line_x_start = 1.08 * np.cos(angle)
            line_y_start = 1.08 * np.sin(angle)
            line_x_end = 0.25 * np.cos(angle)  # Increased gap from center
            line_y_end = 0.25 * np.sin(angle)
            
            ax.plot([line_x_start, line_x_end], [line_y_start, line_y_end], color='black', lw=1)

    # Add tick marks for the hours (1 to 24)
    for hour in range(1, 25):
        angle = math.radians(90 - hour * 15)
        x_start = 1.12 * np.cos(angle)
        y_start = 1.12 * np.sin(angle)
        x_end = 1.17 * np.cos(angle)  # Extend a bit outside the inner circle
        y_end = 1.17 * np.sin(angle)
        ax.plot([x_start, x_end], [y_start, y_end], color='black', lw=1)
        ax.text(1.22 * np.cos(angle), 1.22 * np.sin(angle), str(hour), ha='center', va='center', fontsize=10)

    # Add activity labels (moved closer to the center)
    for (start, end), activity in activities.items():
        mid_time = (start + end) / 2
        angle = 90 - mid_time * 15  # Convert time to angle
        rad_angle = math.radians(angle)
        
        # Calculate label position (moved closer to center)
        x = 0.7 * np.cos(rad_angle)
        y = 0.7 * np.sin(rad_angle)
        
        # Adjust rotation for labels on the bottom half
        if 90 < angle < 270:
            rotation = angle + 180
        else:
            rotation = angle
        
        # Add text with proper rotation
        ax.text(x, y, activity, ha='center', va='center', fontsize=12, rotation=rotation)
    
    # Create handles for clock hands (hour, minute, second) using Line2D with rounded edges
    hour_hand = ax.plot([], [], color='black', lw=4, solid_capstyle='round')[0]
    minute_hand = ax.plot([], [], color='black', lw=3, solid_capstyle='round')[0]
    second_hand = ax.plot([], [], color='#c3a802', lw=1.5, solid_capstyle='round')[0]  # Color change to #c3a802

    # Function to update the clock hands in real-time
    def update_clock_hand(frame):
        now = datetime.now()
        
        # Hour, minute, and second calculations
        hour_angle = math.radians(90 - (now.hour % 12 + now.minute / 60) * 30)  # 30 degrees per hour
        minute_angle = math.radians(90 - (now.minute + now.second / 60) * 6)    # 6 degrees per minute
        second_angle = math.radians(90 - now.second * 6)                        # 6 degrees per second
        
        # Calculate hand positions
        hour_x = 0.5 * np.cos(hour_angle)
        hour_y = 0.5 * np.sin(hour_angle)
        minute_x = 0.7 * np.cos(minute_angle)
        minute_y = 0.7 * np.sin(minute_angle)
        second_x = 1.12 * np.cos(second_angle)  # Extended second hand slightly beyond inner circle
        second_y = 1.12 * np.sin(second_angle)
        
        # Update hand positions
        hour_hand.set_data([0, hour_x], [0, hour_y])
        minute_hand.set_data([0, minute_x], [0, minute_y])
        second_hand.set_data([0, second_x], [0, second_y])
        return hour_hand, minute_hand, second_hand,

    # Set up real-time animation of the clock hands
    ani = FuncAnimation(fig, update_clock_hand, interval=1000, cache_frame_data=False)  # Update every second

    # Draw the "PLAY" button at the center, after the hands so it's in front
    ax.add_artist(plt.Circle((0, 0), 0.2, color='#c3a802'))  # Color change to #c3a802
    ax.text(0, 0, 'PLAY', ha='center', va='center', fontsize=16, fontweight='bold')

    plt.show()

# Run the function to display the clock
draw_clock()
