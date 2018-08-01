# arch beowulf cluster script
A Shell Script for creating a headnode and slaves in a beowulf cluster

## How to use it
(Optional) Run autoDownload for save the download to the equivalent every time to install a new node

Create a folder named programs, and download the mpich, hydra and primeCount (do not unpack)

Download Urls:
mpich and hydra: https://www.mpich.org/downloads/
primeCount: https://github.com/kimwalisch/primecount/releases

Finaly, run the archScript.sh with the desired options

### Most used Options
--headnode  # For instaling the headnode

--headnodeAddress  # For instaling the slaves

--language=[loadkey]  # For loadkeys language Ex: us-acentos or the default br-abnt2

--password=[pass]  # Define the password for the root

--device=[/dev/sd[a-z]]  # Define the device for format and install

-h or --help  # For the help messages

#### In test:
--deviceSection=  # For install the cluster after a device section

--tags=  # Yet for rapid-mode (not add an user) and no-reboot

--partitionType=  # Not completely implemented

--inputFiles=  # With errors

## Help
Feel free to help the repository.

## LICENSE
Text Analytic is copyright (c) Vinicius Molina 2018, and released under the GNU GENERAL PUBLIC LICENSE Version 3. See the LICENCE file in this repository for detailed information.
