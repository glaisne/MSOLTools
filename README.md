# MSOLTools
Tools for MSOnLine

##Available Functions:
- **Add-MsolService** - Used to add services to a given license. If the license is not assigned, this function will assign the specified license. Helpful in that it hides the difficult logic of adding a service by disabling all the others, and makes sure anything that existed previously does not get removed.
- **Get-LicenseUsage** - Used to display a simple table of where licenses currently stand. (Best to format with format-table. I haven't set it up to display as a table by default yet)
- **Get-MSOLSubscriptionTimeline** - An attempt to improve appon the Get-MsolSubscription. At this time, Get-MsolSubscription is a better way to get the needed information.
- **Get-MsolUserLicenseAssignment** - Built as a quick way to get a user's service status within a license.
- **Get-O365LicenseFriendlyName** - Translates cryptic license names into the equivalent name in the O365 portal. This function simply pulls from a hash table written in to the psm1 files. This hash table will need to be updated manually. There is no way (That I know of) to get the names of licenses dynamically.
- **Get-O365ServiceFriendlyName** - Same as Get-O365LicenseFriendlyName but for services within a license.
- **Move-MsolLicense** - BETA - This function is still in the works. The idea here is to move a license from one to another and ensure that nothing new is added or that nothing is lost in the process.
- **Remove-MSOLAllLicenses** - the 'Format c:' of O365 licenses. This function removes all license from a user. Use with extreme caution! 

