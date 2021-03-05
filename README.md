# Compiling and Running The App

## Install flutter SDK:
*  Create a folder in C drive called `src`
*  Using the cmd, navigate to this 'src' folder
*  In this folder, enter the command `git clone https://github.com/flutter/flutter.git -b stable`
*  You should see `C:\src> git clone https://github.com/flutter/flutter.git -b stable` in your cmd
*  Press enter to proceed with the installation flutter SDK
*  Once done, navigate to the newly installed flutter folder and enter the command `flutter doctor`
*  You should see `C:\src\flutter> flutter doctor` in your command
*  Check the output and install any necessary additional files

## Install Android Studio:
* After Android Studio is installed, create virtual device at `Android Studio > Tools > Android > AVD Manager`
* Click on `+ create virtual device...` at the bottom left corner
* Select a device and its corresponding android level for installation
* The device we have used is "nexus 6P" with an android level of 28(android pie)

## Trouble installing flutter or Android Studio:
* If you encounter any trouble following the steps above, please refer to [this link](https://flutter.dev/docs/get-started/install/windows)

## Start up project:
*  In main page of Android Studio, select `Check out project from Version Control > Git`
*  Add installed flutter SDK path at `File > Settings > Languages & Frameworks > Flutter`
*  Enter the command `flutter pub get` at the terminal to install dependencies

You can now run the app by clickling the green play icon to run the main.dart file.
Note: Do ensure that you have an android virtual device up and running before running the file.