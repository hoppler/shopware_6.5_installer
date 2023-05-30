Shopware Installer Script Installation:

Why is the installer script valuable:

1. Easy Installation:
   The Shopware installer script automates the installation process and simplifies the installation of Shopware 6.5 and subsequent versions. It is particularly useful for users without in-depth technical knowledge.

2. Error Avoidance:
   The script reduces the likelihood of errors during installation as it includes predefined steps and configurations necessary for a smooth installation.

3. Time-saving:
   By automating the installation process, the script saves time and effort. Users can focus on other tasks while the script performs the installation.

4. User-Friendly:
   The script features a user-friendly interface that allows users to select desired options and track the progress of the installation.

The installer script consists of two parts because the Shopware installation files can no longer be downloaded as a ZIP file. The script interacts with the Shopware installation process by downloading the necessary files and executing the installation steps. An active internet connection is required during the installation.

After the completion of the first part of the installation, a corresponding notification message will appear, containing further instructions. These instructions should be carefully followed to initiate the second part of the installation. The second part of the script executes the necessary steps to complete the installation of Shopware 6.5.

Once the second part of the installation is successfully completed, another message will appear, informing the user that the final installation of Shopware 6.5 can be initiated. At this point, Shopware is ready for use, and further configuration steps can be performed.

Through this two-stage installation, the script enables a seamless and efficient installation of Shopware 6.5. It guides the user throughout the process and provides clear instructions to successfully complete the installation. Please note that an active internet connection is required for the smooth execution of the installation.

Installation Instructions:

1. Prerequisites:
   - Ensure that VirtualBox or VMware Workstation is installed.
   - Download the Ubuntu Server 22.04 LTS ISO image.

2. Installing Ubuntu Server 22.04 LTS in VirtualBox:
   - Open VirtualBox and create a new virtual machine with sufficient RAM and disk space.
   - Select the Ubuntu Server 22.04 LTS ISO image as the installation medium.
   - Start the virtual machine and follow the instructions of the Ubuntu installation wizard to install Ubuntu Server.

3. Installing Ubuntu Server 22.04 LTS in VMware Workstation:
   - Open VMware Workstation and create a new virtual machine using the "Typical" option.
   - Choose the Ubuntu Server 22.04 LTS ISO image and follow the instructions of the wizard to install Ubuntu Server.

4. Obtaining Root Access:
   - Open a terminal or establish an SSH connection to the Ubuntu Server.
   - Log in as a user with administrative privileges.
   - Switch to the root user by entering the command "sudo su -" and providing your password.

5. Preparing the Shopware Installer Script:
   - Download the Shopware Installer Script (sw6_5_installer.sh).
   - Copy the script to the root directory (/) of your Ubuntu Server.
   - Open a terminal or establish an SSH connection to the server and navigate to the root directory using the command "cd /".
   - Make the script executable using the command "chmod +x sw6_5_installer.sh".

6. Running the Shopware Installer Script:
   - Launch the Shopware Installer Script with the desired options.
   - Use the command "./sw6_5_installer.sh -e" to execute the script in English.
   - Use the command "./sw6_5_installer.sh" to execute the script in German.

The Shopware Installer Script will now be initiated and will perform the installation of Shopware 6.5 and higher

 versions on your home network or personal computer. Follow the instructions provided by the script to complete the installation process.

This guide combines the benefits of the installer script with the corresponding instructions to make the installation of Shopware as easy and efficient as possible.
