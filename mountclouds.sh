#!/bin/bash
rclone mount --vfs-cache-mode writes GoogleDrive: /home/mx-vu/Clouds/GoogleDrive &
rclone mount --vfs-cache-mode writes GooglePhotos:media/all/ /home/mx-vu/Clouds/GooglePhotos/ &
rclone mount --vfs-cache-mode writes OneDrive: /home/mx-vu/Clouds/OneDrive
