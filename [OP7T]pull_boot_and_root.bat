@echo off
REM counter for retrying loops
SET /a counter=0                                                    
REM this is the startscreen
:start 
echo.                                                            
echo ------Boot imager puller and rooting script-------
timeout 1 /nobreak >nul
echo.
echo ------------- created by KyoshiDev ---------------
timeout 1 /nobreak >nul
echo ------------------ 2020-04-15 --------------------
timeout 1 /nobreak >nul
echo.
echo                       :ss:`                      
echo             .``   `:ohhhdddo:`  ``.-             
echo            `------++----::::oo:///:-`            
echo              `ohyo/-----::::/shddo`              
echo             `/+/:-------::::///+oso`             
echo            `-:::::::----////////////`            
echo            o/::::-------:::::://///oo            
echo            /h++hdyo:`   ```./sydhood+            
echo           :dm+-sdyddds  ``sdddhds/smm:           
echo         `ommm+- . :h+o/ `+s+ys.-`:smmmo`         
echo        -hmmmm++       ` `.```````osmmmmd-        
echo       .dmmmmm+s.      . `-``````-ysmmmmmm.       
echo       .dmmmmm+sy      .---``````hysmmmmmm-       
echo        .hmmmm+smy.   /yhhy/```-hmysmmmmd.        
echo         `+yyh/ommms-    ````-smmmsohyy+`         
echo             `--+/:/++.  ``-+o/:++/:`             
echo             `..`                `--.          
timeout 1 /nobreak >nul
echo.
echo.
echo ## [Pull boot image from your rom and root it] --------------------------[1]
echo ## [Just flash boot image] [image must be named "magisk_patched.img"]----[2]
set /p choice= >nul
if %choice% EQU 1 goto start1
if %choice% EQU 2 goto magisk_flash
if /I "%choice%"=="exit" exit

:start1
echo.
echo ## make sure your device have an unlocked bootloader, is booted up and has adb activated
echo ## is your device ready? [y/n]                             type exit to exit
set /P c=>nul
if /I "%c%"=="y" goto getBoot
if /I "%c%"=="n" goto end
if /I "%c%"=="exit" exit
echo ## wrong input: [%c%]
timeout 1 /nobreak>nul
goto start

REM rebooting device from android ui into fastboot
:getBoot                                                                    
echo.
echo ## checking for adb
REM checks if any devices are active on ADB
adb.exe devices -l | find "device product:" >nul 
REM errorhandler                           
if errorlevel 1 (                                                           
    set /a counter=counter+1
    if %counter% EQU 3 (        
        goto error )
    echo ## No connected devices, please make sure you have adb access! retrying...
    timeout 5 /nobreak>nul    
    goto getBoot    
) else (
    echo ## adb connected....
    timeout 1 /nobreak>nul
    echo ## rebooting your device into fastboot
    timeout 2 /nobreak>nul
    adb.exe reboot bootloader
    timeout 1 /nobreak>nul
    set /a counter = 0
    goto fastboot_boot_twrp )
goto end

REM  booting custom recovery TWRP
:fastboot_boot_twrp                                                         
echo.
echo ## rename your TWRP recovery image to TWRP.img and place it into same folder as this script.
echo ## Press any key to continue....
pause >nul
echo ## checking for fastboot device
REM checks if device is in fastboot mode 
fastboot.exe devices -l | find /n "fastboot" >nul   
REM errorhandler                       
if errorlevel 1 (                                                           
    echo ## cant reach fastboot, retrying...
    set /a counter=counter+1
    if %counter% EQU 3 (        
        goto error )
    timeout 5 /nobreak >nul
    goto fastboot_boot_twrp
) else (
echo ## booting custom recovery
timeout 1 /nobreak>nul
fastboot.exe boot TWRP.img
if errorlevel 1 goto error
timeout 15 /nobreak>nul
set /a counter = 0
goto twrp_adb )
goto end

REM pulling boot.img via ADB in recovery
:twrp_adb                                                                   
echo.
echo ## checking for adb devices..
REM checks if any devices are active on ADB
adb.exe devices -l | find "recovery product:" >nul  
REM errorhandler                       
if errorlevel 1 (                                                           
    echo ## device still not in custom recovery, retrying...
    set /a counter=counter+1
    if %counter% EQU 3 (        
        goto error )
    timeout 5 /nobreak >nul
    goto twrp_adb
    ) else (
    echo ## getting boot.img...
    timeout 1 /nobreak>nul
    adb.exe shell dd if=/dev/block/bootdevice/by-name/boot of=/tmp/boot.img
    timeout 1 /nobreak>nul
    adb.exe shell exit
    echo ## pulling the boot.img to the pc...
    timeout 1 /nobreak>nul
    echo ## this takes a while [about 15-90 seconds]
    adb.exe pull /tmp/boot.img stock_boot.img    
    if errorlevel 1 goto error
    echo ## Finish! rebooting...
    timeout 1 /nobreak>nul
    adb.exe reboot
    echo ## now the stock boot image [stock_boot.img] is locally stored on your computer [directory where the script is lcoated].
    timeout 1 /nobreak>nul
    echo ## want to patch the boot image with MAGISK for root? [y/n]
    set /P c= >null
    if /I "%c%"=="y" (
        set /a counter = 0
        goto patch_instruction )
    if /I "%c%"=="n" (
        echo ## FINISH!
        goto end ) )
goto end

REM instruction to patch the stock boot image
:patch_instruction                                                          
echo.
echo ###### INSTRUCTIONS #######
echo ## Please download and install MagiskManager. In the app press install, then select "Select and Patch File" and search for your boot.img to patch. 
echo ## [stock_boot.img that was previously pulled from your phone to pc, need to be copied to the phone to patch it via Magisk Manager]
timeout 1 /nobreak >nul
echo ## After magisk patched your stock_boot.img as magisk_patched.img succesfully, you need to copy it to your pc.
echo ## Please copy the patched magisk_patched.img into the folder where this script is.
timeout 1 /nobreak >nul
echo ## if you are ready and want to start press any key
pause >nul
echo ## checking for adb device
REM checks if any devices are active on ADB
adb.exe devices -l | find "device product:" >nul                                
REM errorhandler
if errorlevel 1 (                                                           
    set /a counter=counter+1
    if %counter% EQU 3 (        
        goto error )
    echo ## No connected devices, please make sure you have access to adb on the device! retrying...
    timeout 3 /nobreak>nul    
    goto patch_instruction
) else (
echo ## rebooting into fastboot...
adb.exe reboot bootloader
timeout 10 /nobreak >nul
set /a counter = 0
goto flash_patched_boot )
goto end

REM flashing magisk patched boot over fastboot
:flash_patched_boot                                                         
echo.
echo ## checking for fastboot device...
REM checks if device is in fastboot mode
fastboot.exe devices -l | find /n "fastboot" >nul    
REM errorhandler                           
if errorlevel 1 (                                                           
    echo ## cant reach fastboot,retrying...
    set /a counter=counter+1
    if %counter% EQU 3 (        
        goto error )
    timeout 5 /nobreak >nul
    goto flash_patched_boot
) else (
    echo ## make sure the patched boot image is named magisk_patched.img
    if exist magisk_patched.img (        
        set /a counter = 0
        goto magisk_boot
    ) else (
        echo ## magisk_patched.img does not exist!
        echo ## Copy the patched file from your phone into the directory where the script is! 
        echo ## type any key to retry...
        pause >n
        goto flash_patched_boot ) )
goto end


:magisk_boot
echo ## to be safe, we just boot the boot image [name must be "magisk_boot.img"]
echo ## booting...
fastboot.exe boot magisk_patched.img     
if errorlevel 1 goto error          
timeout 5 /nobreak >nul
echo ## Booting may take a while...
echo ## Did your phone boot without problems? [WIFI,LTE,GPS, everything working?] [y/n]
set /p c= >nul
if "%c%"=="y" goto magisk_flash
if "%c%"=="n" (
    echo ## try another boot.img
    goto end )
goto end

:magisk_flash
echo ## is your device in fastboot mode[1] or Android UI[2] ?
set /p i= >nul
if %i% EQU 1 (
        timeout 1 /nobreak>nul
        echo ## checking for fastboot device...
        fastboot.exe devices -l | find /n "fastboot" >nul    
        REM errorhandler                           
    if errorlevel 1 (                                                           
        echo ## cant reach fastboot, retrying...        
        timeout 5 /nobreak >nul
        goto magisk_flashed
    ) else (
        echo ## flashing boot image...
        fastboot.exe flash boot magisk_patched.img
        if errorlevel 1 goto error
        echo ## succesfully flashed! 
        timeout 1 /nobreak >nul
        echo ## ENJOY!
        goto end ) )
if %i% EQU 2 (
    REM checks if any devices are active on ADB
    echo ## checking for adb device
    adb.exe devices -l | find "device product:" >nul                                
    REM errorhandler
    if errorlevel 1 (                                                        
    echo ## No connected devices, please make sure you have adb turned on! retry...
    timeout 4 /nobreak>nul    
    goto magisk_flash 
    ) else (
            echo ## booting into fastboot...
            adb.exe reboot bootloader            
            timeout 10 /nobreak >nul
            fastboot.exe devices -l | find /n "fastboot" >nul    
            REM errorhandler                           
            if errorlevel 1 (                                                           
            echo ## cant reach fastboot,retry...           
            timeout 5 /nobreak >nul
            goto magisk_flashed 
            ) else (
                echo ## flashing boot image...
                timeout 1 /nobreak >nul
                fastboot.exe flash boot magisk_patched.img
                if errorlevel 1 goto error
                timeout 1 /nobreak >nul
                echo ## Flashed succesfully!
                timeout 1 /nobreak >nul
                echo ## FINISH! 
                timeout 1 /nobreak >nul
                fastboot reboot
                goto end ) ) )
if /I "%i%"=="exit" exit
else (    
    echo ## wrong input: [%i%]
    timeout 1 /nobreak>nul
    goto magisk_flash )
goto end

:error
echo ## something went wrong!
SET /a counter= 0
goto end

:end
echo.
SET /a counter= 0
echo ##  END
pause