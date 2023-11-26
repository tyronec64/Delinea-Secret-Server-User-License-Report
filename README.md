
# Userlicense Reporting Overview

**Author:** Jan.Dijk@mccs.nl  
**Version:** 2.1.2-(30119132)  
**UUID:** 30119132-8b7a-11ee-ba0c-482ae33091e6

## Overview

This report provides insights into Admin and Business Users licenses from your Delinea Secret Server. It is designed for Managers, Product Owners, and Technical Secret Server Admins for a better understanding and determination of the necessary Admin and Business licenses. This tool aids Technical Secret Server Admins in supplying comprehensive reports to management.

### Challenges Addressed

Secret Server does not use a concurrent user license method, and distinguishing between Business and Admin users for licensing purposes can be challenging. This report introduces a method to:

- Define a Primary License Group for a user.
- Differentiate between Admin only, Business User only, or mixed groups.
- Report and purchase the required Business Users licenses effectively.

### Coming Soon

A Compliance Report is in development, which will check the activity of mixed groups over a period to justify license separation.

## Requirements / Installation

To use this reporting feature, you need to tag metadata on Groups to define a user's Primary License Group, AdminLicenseRatio, MaintainedBy, and Description fields.

### Setup Steps in Secret Server:

1. Navigate to `Administration > User Management > Groups`.
2. Select a group to define as a PrimaryLicenseGroup.
3. Go to the "MetaData" tab.

#### Add Metadata for "LicenseReporting":

- **PrimaryLicenseGroup:**
  - Type: Boolean
  - Value: True

- **AdminLicenseRatio:**
  - Type: TEXT (Use TEXT, not number)
  - Value: 
    - `-1` for all Admin Users
    - `0` for all Business Users
    - A positive number (e.g., `3`) to specify the number of Admin users. The rest will be counted as Business Users.

- **Description:**
  - Type: TEXT
  - Value: Description of your primary license group.

- **MaintainedBy:**
  - Type: TEXT
  - Value: Department or system managing the membership and responsible for the AdminUserRatio setting.

#### In Reports:

- Add a new category `"LicenseReporting"`.
- Add two reports with SQL data from the provided SQL files:
  - "License Overview Report - Userlicense Usage"
  - "Userlicense in Cloud Subscription"

### Viewing the Report

1. Unpack the files into a folder and open `DelineaUserLicenseReport.xlsm`.
2. Enable active content if prompted.
3. Replace demo data with your exports, ensuring they are in the same folder.
4. In the settings tab, change the filename if desired.
5. Click "Refresh Data & Sheet" to reload.

## Files Included

- **Excel File:** `DelineaUserLicenseReport-v2.1.2-30119132.xlsm`
- **SQL Files for Secret Server Cloud Reports:**
  - `License Overview Report - Userlicense Usage.sql`
  - `License Overview Report - Userlicense in Cloud Subscription.sql`
- **CSV Demo Data Files:**
  - `License Overview Report - Userlicense in Cloud Subscription.csv`
  - `License Overview Report - Userlicense Usage.csv`

## TODO

- Resolve the metadata entry bug in Delinea Secret Server.
- Implement workarounds for metadata entry issues.
- Create The Compliance report to validate the tagged adminration amounts on the Primary License Groups
