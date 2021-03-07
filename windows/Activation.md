# Activation

TheBeast is running py-kms as an activation server for Microsoft.

(https://py-kms.readthedocs.io/en/latest/Getting%20Started.html#docker)

## Windows 10

Open CMD as agmin:

```batch
cd C:\Windows\system32
cscript //nologo slmgr.vbs /upk
cscript //nologo slmgr.vbs /ipk <KMS_KEY>
cscript //nologo slmgr.vbs /skms TheBeast:1688
cscript //nologo slmgr.vbs /ato
```

```plain
Operating system edition            KMS Client Setup Key

Windows 10 Pro                      W269N-WFGWX-YVC9B-4J6C9-T83GX
Windows 10 Pro N                    MH37W-N47XK-V7XM9-C7227-GCQG9
Windows 10 Pro for Workstations     NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J
Windows 10 Pro for Workstations N   9FNHH-K3HBT-3W4TD-6383H-6XYWF
Windows 10 Pro Education            6TP4R-GNPTD-KYYHQ-7B7DP-J447Y
Windows 10 Pro Education N          YVWGF-BXNMC-HTQYQ-CPQ99-66QFC
Windows 10 Education                NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
Windows 10 Education N              2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
Windows 10 Enterprise               NPPR9-FWDCX-D2C8J-H872K-2YT43
Windows 10 Enterprise N             DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4
Windows 10 Enterprise G             YYVX9-NTFWV-6MDM3-9PT4T-4M68B
Windows 10 Enterprise G N           44RPN-FTY23-9VTTB-MP9BX-T84FV
```

References:

- [Activation Procdedures (py-kms)](https://py-kms.readthedocs.io/en/latest/Usage.html#activation-procedure)
- [KMS Keys](https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys)

## Server 2019

Install with Desktop Exp.

### Standard

Open Powershell as admin:

```ps
cd C:\Windows\system32
cscript //nologo slmgr.vbs /skms TheBeast:1688
DISM /online /Set-Edition:ServerStandard /ProductKey:<KMS_KEY> /AcceptEula
cscript //nologo slmgr.vbs /ato
```

### Enterprise

Open Powershell as admin:

```ps
cd C:\Windows\system32
cscript //nologo slmgr.vbs /skms TheBeast:1688
DISM /online /Set-Edition:ServerStandard /ProductKey:<KMS_KEY> /AcceptEula
cscript //nologo slmgr.vbs /ato
```

```plain
Operating system edition        KMS Client Setup Key

Windows Server 2019 Datacenter  WMDGN-G9PQG-XVVXX-R3X43-63DFG
Windows Server 2019 Standard    N69G4-B89J2-4G8F4-WWYCC-J464C
Windows Server 2019 Essentials  WVDHN-86M7X-466P6-VHXV7-YY726
```

References:

- [Converting from Eval to Std or Datacenter](https://www.reddit.com/r/sysadmin/comments/giaqt5/heres_the_trick_for_converting_2019_eval_to/)
- [Activation Procdedures (py-kms)](https://py-kms.readthedocs.io/en/latest/Usage.html#activation-procedure)
- [KMS Keys](https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys)

## Office 2019

Configuration:

Download the Office [Deployment Tool](https://www.microsoft.com/en-us/download/details.aspx?id=49117):

Create the `configuration.xml` file in the same directory as `setupodt.exe` (The deployment tool):

```xml
<Configuration ID="a89617d4-ed28-4fad-94be-a224a96f6c17">
  <Add OfficeClientEdition="64" Channel="PerpetualVL2019">
    <Product ID="ProPlus2019Volume" PIDKEY="NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
    </Product>
    <Product ID="VisioPro2019Volume" PIDKEY="9BGNQ-K37YR-RQHF2-38RQ3-7VCBB">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
    </Product>
    <Product ID="ProjectPro2019Volume" PIDKEY="B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="PinIconsToTaskbar" Value="FALSE" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="Full" AcceptEULA="TRUE" />
  <Logging Level="Off" />
</Configuration>
```

Open a command prompt as admin and run:

```command
cd <dir where configuration.xml file is>
setupodt.exe /configure
```

```plain
Product                         GVLK

Office Professional Plus 2019   NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP
Office Standard 2019            6NWWJ-YQWMR-QKGCB-6TMB3-9D9HK
Project Professional 2019       B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B
Project Standard 2019           C4F7P-NCP8C-6CQPT-MQHV9-JXD2M
Visio Professional 2019         9BGNQ-K37YR-RQHF2-38RQ3-7VCBB
Visio Standard 2019             7TQNQ-K3YQQ-3PFH7-CCPPM-X4VQ2

Access 2019                     9N9PT-27V4Y-VJ2PD-YXFMF-YTFQT
Excel 2019                      TMJWT-YYNMB-3BKTF-644FC-RVXBD
Outlook 2019                    7HD7K-N4PVK-BHBCQ-YWQRW-XW4VK
PowerPoint 2019                 RRNCX-C64HY-W2MM7-MCH9G-TJHMQ
Publisher 2019                  G2KWX-3NW6P-PY93R-JXK2T-C9Y9V
Skype for Business 2019         NCJ33-JHBBY-HTK98-MYCV8-HMKHJ
Word 2019                       PBX3G-NWMT6-Q7XBW-PYJGG-WXD33
```

References:

- [Deploy Office 2019 (for IT Pros)](https://docs.microsoft.com/en-us/deployoffice/office2019/deploy)
- [Supported Product ID's](https://docs.microsoft.com/en-us/office365/troubleshoot/installation/product-ids-supported-office-deployment-click-to-run)
- [GVLK Keys](https://docs.microsoft.com/en-us/deployoffice/vlactivation/gvlks)