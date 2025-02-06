# Strato Pi Max Setup Guide

This document guides you through the first-time setup of Strato Pi Max. It covers the essential steps to get your device up and running, including selecting a boot device, installing an operating system (OS), and accessing the system via the network. Additionally, it offers guidance on avoiding common misconfigurations, troubleshooting issues, and preparing your Strato Pi Max for production deployment.

Before proceeding with each step, ensure you have read the entire guide. If you have any doubts or questions, contact Sfera Labs support at [support@sferalabs.cc](mailto:support@sferalabs.cc).

## Boot Options

Strato Pi Max offers multiple boot options depending on the version of the device and the Compute Module it is equipped with. Below is a description of each boot option, along with the tools and steps required for implementation.

### M.2 NVMe SSD (Recommended)
The M.2 NVMe SSD is the fastest and most flexible boot option for Strato Pi Max, compatible with all versions of the device. It is the recommended choice for users who are setting up Strato Pi Max for the first time.

- **Compatibility Note**: Some NVMe SSD models may have compatibility issues with the Compute Module and Strato Pi Max. A list of tested and compatible SSD models is available [here](./nvme-ssd-compatibility.md).
  
- **Required Tools**: An M.2 NVMe-to-USB adapter is necessary to connect the SSD to your PC for OS installation.

- **Steps**:
  1. Use the adapter to connect the SSD to your PC.
  2. Image the SSD with the desired OS (see below).
  3. Mount the SSD on the PCIe slot as described in the user guide.

### microSD Card (Strato Pi Max XL with CM Lite only)
This boot option is only available on the **Strato Pi Max XL** equipped with a **Compute Module Lite** (i.e., a Compute Module without embedded eMMC Flash memory).

- **Recommendation**: This option is not recommended for initial setup when using a Compute Module 5, as it may require additional configuration depending on the SD card model. Refer to [this document](./cm5-sd-config.md) for more details.

- **Required Tools**: A microSD-to-USB adapter or a PC with a built-in microSD card slot is required for imaging the SD card.

- **Steps**:
  1. Insert the microSD card into the adapter or PC slot.
  2. Image the microSD card with the desired OS (see below).
  3. Insert the microSD card into the SDA slot on the Strato Pi Max (see user guide).

### eMMC Flash Memory
If your Strato Pi Max is equipped with a Compute Module that includes embedded eMMC Flash memory (i.e., not the ‘Lite’ version), you can use this as your boot device.

- **Recommended Procedure**:
  1. Boot the unit using an alternative boot option (e.g., NVMe SSD or USB).
  2. Access the system via the network (see below).
  3. Install the OS on the eMMC Flash memory (see below).

- **Alternative Methods**:
  - **Raspberry Pi Compute Module Provisioning System**: This method requires additional setup and is recommended only if you have prior experience with it and Sfera Labs or Raspberry Pi devices. Note that this utility is currently compatible only with Compute Module 4, not Compute Module 5. Documentation is available [here](https://github.com/raspberrypi/cmprovision).
  - **rpiboot with Compute Module I/O Board**: This method involves disassembling the Compute Module from Strato Pi Max, installing it on a Raspberry Pi Compute Module I/O Board ([4](https://www.raspberrypi.com/products/compute-module-4-io-board/) or [5](https://www.raspberrypi.com/products/compute-module-5-io-board/)), and using [rpiboot](https://github.com/raspberrypi/usbboot) to image the eMMC. This option is discouraged due to the risk of damaging the Compute Module connectors during repeated removal and reinstallation.

### USB Mass Storage (CM4 only)
Strato Pi Max equipped with a **Compute Module 4** can be booted from a USB mass storage device, such as a flash drive or USB disk. This option is not available for Compute Module 5.

- **Use Cases**:
  - Imaging the eMMC Flash memory.
  - Recovery purposes.

- **Steps**:
  1. Connect the USB device to your PC.
  2. Image the USB device with the desired OS (see below).
  3. Plug the USB device into one of the USB ports on Strato Pi Max.

### Network Boot
Network booting requires significant preparation and is recommended only if you already have a network boot system in place for other Sfera Labs or Raspberry Pi devices, or if you plan to use it for multiple units in the future.

- **Use Cases**:
  - Imaging the eMMC Flash memory.
  - Large-scale deployments.

- **Steps**:
  1. Set up a network boot system following the [Raspberry Pi Network Boot Tutorial](https://www.raspberrypi.com/documentation/computers/remote-access.html#network-boot-your-raspberry-pi).
  2. Refer to the [Raspberry Pi Network Booting Documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#network-booting) for additional details.

## OS Preparation and Installation

Strato Pi Max is compatible with any operating system suitable for Raspberry Pi. However, since Strato Pi Max lacks a video output, the OS must be preconfigured for network access.

For headless operation, a lightweight OS such as Raspberry Pi OS Lite is recommended. If remote desktop access is required, use a version with a desktop environment and a remote access utility (e.g., [VNC](https://www.raspberrypi.com/documentation/computers/remote-access.html#vnc), [Raspberry Pi Connect](https://www.raspberrypi.com/documentation/computers/remote-access.html#raspberry-pi-connect)).

### Imaging a Storage Device

For a smooth process, we recommend using [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to download, configure, and write the OS to your chosen storage device (SSD, SD card, or USB drive).

- **Steps**:
  1. Install and launch Raspberry Pi Imager on your PC.
  2. Connect the storage device to your PC.
  3. Select the OS to install.
  4. Use the "OS Customisation" panel to configure:
     - A unique hostname (e.g., `stratopimax001`).
     - Username and password.
     - SSH access.
  5. Write the OS image to the storage device.

- **Alternative**: If you have a preconfigured OS image, Raspberry Pi Imager can also write this image directly to the storage device.

For a step-by-step guide, refer to [this documentation](https://www.raspberrypi.com/documentation/computers/getting-started.html#raspberry-pi-imager).

### Using a Raspberry Pi for OS Preparation

An alternative approach is to prepare the OS image on an SD card using a standard Raspberry Pi with a monitor and keyboard. This SD card can then be used directly on Strato Pi Max XL or imaged for use with other storage options.

- **Tools**:
  - [Raspberry Pi Imager](https://www.raspberrypi.com/software/) or similar imaging utilities.
  - [Network Install utility](https://www.raspberrypi.com/documentation/computers/getting-started.html#install-over-the-network) (for OS installation without a separate computer).

For more details, refer to the [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/computers/getting-started.html).

### Imaging the Compute Module eMMC Flash Memory

The recommended procedure for imaging the eMMC Flash memory is as follows:

1. Boot the unit using an alternative boot option (e.g., NVMe SSD or USB).
2. Access the system via the network.
3. Use the eMMC as a local mass storage device (e.g., `/dev/mmcblk0` on Raspberry Pi OS).
4. Write a preconfigured OS image to the eMMC using tools like `dd`, Raspberry Pi Imager CLI (`rpi-imager --cli`), or Raspberry Pi Imager in a desktop environment.

> [!TIP]
> Before imaging the eMMC, consider modifying the bootloader configuration (see below) to ensure recoverability in case of misconfiguration or data corruption.

### Image Size and Filesystem Expansion

Many OS images for the Raspberry Pi, including Raspberry Pi OS, are configured to automatically expand their filesystem to fill the entire storage device during the first boot. While this is often desirable, you may want to disable this feature if you are preparing an image for later use on multiple devices, so as to keep it small and reduce imaging time.

To disable the automatic filesystem expansion, you can modify specific files after imaging the storage device but before using it to boot the system. The method varies depending on the OS and its version. Below are the options for Raspberry Pi OS Bookworm:

- Modify the `cmdline.txt` file in the FAT32 boot partition by removing the `init=/usr/lib/raspberrypi-sys-mods/firstboot` portion.
- Alternatively, edit the `firstboot` script located in the `/usr/lib/raspberrypi-sys-mods/` directory within the ext4 root partition.

Once your OS setup has been finalized, you can restore the init script to re-enable automatic filesystem expansion on the first boot. 

Alternatively, after copying the image on the final device, run:

```bash
sudo raspi-config nonint do_expand_rootfs
```

For further guidance, updates, or alternative methods, consult the [Raspberry Pi Forum](https://www.raspberrypi.com/forums/).

## SSH Network Access

After imaging the boot device and mounting it on Strato Pi Max, power on the device and access it via SSH.

When configured as described above, SSH will be enabled and DHCP will be set by default.

**Steps**:
1. Connect Strato Pi Max to a network with DHCP service.
2. Use an SSH client to connect to the device using the configured hostname (e.g., `stratopimax001.local`).
3. If the connection fails, retrieve the device's IP address from your router or use a network scanner.

**Direct Connection**: If a DHCP-enabled network is unavailable, connect Strato Pi Max directly to your PC’s Ethernet port and attempt to access it.

## Bootloader Configuration

The Compute Module’s EEPROM bootloader can be configured to prioritize different boot modes using the `BOOT_ORDER` parameter.

By default, the system first attempts to boot from the eMMC (or SD card on Lite models).

When using an **NVMe SSD**, setting it as the primary boot mode is recommended to speed up the boot process. This configuration also allows for a recovery boot from eMMC or SD by programmatically powering off the SSD.

When booting from **eMMC**, particularly during development, it is advisable to adjust the configuration to prioritize other boot modes. This approach ensures that if a corrupted or misconfigured image is loaded, the system can be recovered by connecting a bootable SSD, USB drive, or network boot system.

On the Compute Module 4, modifying the bootloader configuration while booting from eMMC is not possible. Therefore, it is recommended to edit the configuration before imaging the eMMC, while using an alternate boot mode.

Please note that on Strato Pi Max, the USB ports are connected to the Broadcom USB 2.0 controller. Booting from these ports corresponds to the `BCM-USB-MSD` mode (value `0x5`), which is currently unsupported on Compute Module 5.

For more details, refer to the [Raspberry Pi Bootloader Documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-bootloader-configuration).

## Troubleshooting

When removable drives are used as boot devices, system recovery is relatively straightforward. The drive can simply be mounted on a PC to resolve any issues that rendered the system inaccessible.

However, if booting from eMMC with no alternative boot mode prioritized, recovery requires rendering the eMMC unbootable to enable the system to switch to another available boot mode.

One possible approach, if the main console is accessible, is to connect a keyboard, log in "blindly", and relocate the boot partition's contents. For example, after entering your username and password, execute the following commands:

```
sudo mkdir /boot/firmware/bkup
sudo mv /boot/firmware/* /boot/firmware/bkup
sudo reboot
```

To simplify this process and avoid acting completely "blindly", you can use another Raspberry Pi with the same image installed, connect it to a monitor, and observe the console output during boot. This allows you to understand the expected steps, including the login process and command execution, which you can then replicate on the Strato Pi Max with better confidence.

The system will then attempt to boot from other configured modes. Once it successfully boots from an alternative mode, you can access the system and recover the eMMC image.

## Next Steps

Once your Strato Pi Max is accessible and configured as described here, you are ready to install [its drivers](./README.md) and develop your application.

Refer to the user guide for details on each of its features.

## Going to Production

Before deploying your Strato Pi Max-based solution, consider the following:

1. **Fault Tolerance and Redundancy**:
   - Use the watchdog functionality to prevent system unresponsiveness.
   - Separate data from OS files using different storage options.
   - Implement redundant OS copies with automatic failover (e.g., boot from SSD with fallback to eMMC/SD).

2. **OTA Updates**:
   - Plan for full-system OTA updates. For example, setup your system to be able to:
     - Download the new OS image to a secondary boot device.
     - Reboot the system to boot from the secondary storage.
     - Update the primary disk with the new system image and restore it as boot device.
     - If the new system fails to boot, automatic failover will let you attempt a new update or restore the old system.

3. **Security Measures**:
   - Remove default credentials and disable password-based SSH access.
   - Make use of the ATECC secure element and consider the Zymbit SCM opiton for enhanced security.
   - Enable tamper detection using the onboard accelerometer.
   - Consider implementing secure boot.

---

By following this guide, you can ensure a secure, resilient, and easily maintainable deployment of Strato Pi Max. Contact us for tailored provisioning solutions, expert consultation, and personalized setup assistance to meet your specific requirements.
