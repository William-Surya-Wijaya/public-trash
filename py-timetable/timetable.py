import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import numpy as np
import math
from datetime import datetime
from matplotlib.animation import FuncAnimation
from matplotlib.offsetbox import OffsetImage, AnnotationBbox

korean_font_path = './fonts/NotoSansKR.ttf'
korean_font_prop = fm.FontProperties(fname=korean_font_path)

activities = {
    (0, 6): ("꿈나라", "icons/dreamland.png"),
    (6, 9): ("아침", "icons/morning.png"),
    (9, 12): ("노름", "icons/gaming.png"),
    (12, 14): ("운동", "icons/exercise.png"),
    (14, 18): ("만화", "icons/comics.png"),
    (18, 19): ("지세도", "icons/freetime.png"),
    (19, 21): ("심사 숙고", "icons/meditation.png"),
    (21, 24): ("잠", "icons/sleep.png")
}

def get_icon_image(path, zoom):
    img = plt.imread(path)
    return OffsetImage(img, zoom=zoom)

# MAIN FUNCTION
def draw_clock():
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.set_aspect('equal')

    fig.patch.set_facecolor('#d8d7d2')
    ax.set_facecolor('#d8d7d2')

    # Menghilangkan GRID matplotlib
    # ax.grid(False)
    # ax.set_xticks([])
    # ax.set_yticks([])

    # Menghilangkan Kotak matplotlib diluar
    # for spine in ax.spines.values():
    #     spine.set_visible(False)

    # Lingkaran luar dan dalam (beda tebal outline)
    outer_circle = plt.Circle((0, 0), 1.15, color='black', fill=False, lw=1)
    inner_circle = plt.Circle((0, 0), 1.1, color='black', fill=False, lw=2)

    ax.add_artist(inner_circle)
    ax.add_artist(outer_circle)

    # Buat garis garis separasi antar jadwal
    for start, end in activities.keys():
        for boundary in [start, end]:
            angle = math.radians(90 - boundary * 15)

            # Atur gap antara lingkaran dalam (PLAY) dan lingkaran luar
            line_x_start = 1.08 * np.cos(angle)
            line_y_start = 1.08 * np.sin(angle)
            line_x_end = 0.25 * np.cos(angle)
            line_y_end = 0.25 * np.sin(angle)

            ax.plot([line_x_start, line_x_end], [line_y_start, line_y_end], color='black', lw=1)

    # Tambahkan icon
    for (start, end), (_, icon_path) in activities.items():
        mid_time = (start + end) / 2
        angle = 90 - mid_time * 15 # Convert satuan waktu ke sudut / derajat

        rad_angle = math.radians(angle)

        icon_x = 0.85 * np.cos(rad_angle)
        icon_y = 0.85 * np.sin(rad_angle)
        icon = get_icon_image(icon_path, zoom=0.1)

        ab = AnnotationBbox(icon, (icon_x, icon_y), frameon=False)
        ax.add_artist(ab)

    # Tanda garis di tiap satuan jam
    for hour in range(1, 25):
        angle = math.radians(90 - hour * 15)
        x_start = 1.12 * np.cos(angle)
        y_start = 1.12 * np.sin(angle)
        x_end = 1.17 * np.cos(angle)
        y_end = 1.17 * np.sin(angle)
        ax.plot([x_start, x_end], [y_start, y_end], color='black', lw=1)
        ax.text(1.22 * np.cos(angle), 1.22 * np.sin(angle), str(hour), ha='center', va='center', fontsize=10)
    
    # Schedule (label) yang sudah kita input
    for (start, end), (activity, _) in activities.items():
        # Angle label
        mid_time = (start + end) / 2
        angle = 90 - mid_time * 15
        rad_angle = math.radians(angle)

        x = 0.7 * np.cos(rad_angle)
        y = 0.7 * np.sin(rad_angle)

        if 90 < angle < 270:
            rotation = angle + 180
        else:
            rotation = angle

        ax.text(x, y, activity, ha='center', va='center', fontsize=12, rotation=rotation, fontproperties=korean_font_prop)
    
    # Jarum jam
    hour_hand = ax.plot([], [], color='black', lw=4, solid_capstyle='round')[0]
    minute_hand = ax.plot([], [], color='black', lw=3, solid_capstyle='round')[0]
    second_hand = ax.plot([], [], color='#c3a802', lw=1.5, solid_capstyle='round')[0]
    
    # Fungsi pergerakan jarum jam
    def update_clock_hand(frame):
        now = datetime.now()

        # Perhitungannya berbeda dari jam biasa karena 24 jam
        hour_angle = math.radians(90 - (now.hour % 12 + now.minute / 60) * 30)  
        minute_angle = math.radians(90 - (now.minute + now.second / 60) * 6)
        second_angle = math.radians(90 - now.second * 6)                    

        hour_x = 0.5 * np.cos(hour_angle)
        hour_y = 0.5 * np.sin(hour_angle)
        minute_x = 0.7 * np.cos(minute_angle)
        minute_y = 0.7 * np.sin(minute_angle)
        second_x = 1.12 * np.cos(second_angle)
        second_y = 1.12 * np.sin(second_angle)

        hour_hand.set_data([0, hour_x], [0, hour_y])
        minute_hand.set_data([0, minute_x], [0, minute_y])
        second_hand.set_data([0, second_x], [0, second_y])
        return hour_hand, minute_hand, second_hand,

    # Animasi untuk pergerakan jarum jam
    ani = FuncAnimation(fig, update_clock_hand, interval=1000, cache_frame_data=False)

    # Buat play button di tengah
    ax.add_artist(plt.Circle((0, 0), 0.2, color='#c3a802'))
    ax.text(0, 0, 'PLAY', ha='center', va='center', fontsize=18, fontweight='bold')
    
    # Title timeschedulenya
    plt.text(0, 1.4, '오늘의 시간표', ha='center', va='center', fontsize=20, fontweight='bold', fontproperties=korean_font_prop)
    
    # Gambar plotnya
    plt.show()

# Jalankan main function
draw_clock()
