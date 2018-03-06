# Get-MfaCode
Those 3 scripts are attended to ease our life when handling multiple MFA devices.
THEY HAVE TO BE PLACED AT THE ROOT OF YOUR HOME DIRECTORY !!!
(Typically C:\Users\<login>)

Register-MFACode.ps1 [-ProfileName] <profile_name> [-MFAKey] <key>
Will register a Base32 key under the name "profile_name". It will be usable by Get-MFAcode.ps1


Get-MFAcode.ps1 [-ProfileName] <profile_name>
Display the 6-digits MFA code corresponding to the key registered for this profile by the script Register-MFACode.ps1

Get-MFAcode.ps1 -ListProfile
List available profiles...



TOTP.ps1 [-Key] <Key> [-T0 <Date>] [-TI <integer>] [-TokenLength <integer (<=8)>]
The script used by Get-MFACode to generate the OTP. Can be used standalone if needed.

Defaults are :
T0 = 01/01/1970
TI = 30
TokenLength = 6

With default settings, generate the same 6-digits OTP than Google Authenticator.
You need to provide the secret key : the one you can get when a website display the QR code.
There is always a link/button that will display the secret key (for manual configuration).

See : https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm
for more details