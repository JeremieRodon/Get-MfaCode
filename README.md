# Get-MfaCode
Those 3 scripts are attended to ease our life when handling multiple MFA devices. <br />
THEY HAVE TO BE PLACED AT THE ROOT OF YOUR HOME DIRECTORY !!! <br />
(Typically C:\Users\\\<login>) <br />

If you want to use this, just start a Powershell (that will conveniently start with your home as working directory)

## Register a new profile
Register-MFACode.ps1 [-ProfileName] \<profile_name\> [-MFAKey] \<key\> <br />
Will register a Base32 key under the name "profile_name". It will be usable by Get-MFAcode.ps1 <br />

You need to provide the MFAKey, you can get it when a website display the QR code that you would normaly scan with GoogleAuthenticator. <br />
There is always a link/button that will display this secret key for manual configuration purpose. For example, in AWS console, it's look like that : FZR5U6AQFCOMBV2T4XVI35WTMIHF4EUUVMJUSBYHCNPDYYWVKAVOC7C2SXUSLDP7

Note : The key is stored encrypted in a SecureString ; which mean it can only be decipher by your Windows user account.
WARNING : If you are using Windows10, there is a console history and it will contain the key in clear text ; be sure to clean it

## Generate the OTP for a profile
Get-MFAcode.ps1 [-ProfileName] \<profile_name\> <br />
Display the 6-digits MFA code corresponding to the key registered for this profile by the script Register-MFACode.ps1

## List available profiles
Get-MFAcode.ps1 -ListProfile

## Details about the third script
TOTP.ps1 [-Key] \<Key\> [-T0 \<Date\>] [-TI \<integer\>] [-TokenLength <integer (<=8)>] <br />
The script used by Get-MFACode to generate the OTP. Can be used standalone if needed.

Defaults are : <br />
T0 = 01/01/1970 <br />
TI = 30 <br />
TokenLength = 6 <br />

With default settings, generate the same 6-digits OTP than Google Authenticator. <br />
You need to provide the secret key : the one you can get when a website display the QR code. <br />
There is always a link/button that will display the secret key (for manual configuration).

See : https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm <br />
for more details