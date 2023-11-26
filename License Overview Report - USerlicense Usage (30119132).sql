SELECT DISTINCT
-- License Overview Report - Userlicense Usage (2395b854)
-- version 2.1.2
-- By: jan.dijk@mccs.nl
-- uuid: 30119132-8b7a-11ee-ba0c-482ae33091e6
-- part of DelineaUserLicenseReport-v2.1.2-30119132.xlsm
--
    ISNULL(u.UserName, N'No username assigned') AS [UserName],
    gdn.DisplayName AS [Groupname],
    u.Enabled,
    udn.DisplayName AS [UserDisplayName],
    udn.UserName as [UPN],
    CASE 
        WHEN u.LastLogin IS NULL THEN 'Never'
        ELSE CONVERT(VARCHAR(500), u.LastLogin, 22)
    END AS [Last Login],
    CASE
        WHEN u.LastLogin > (GetDate() - 90) THEN 'Recent login'
        WHEN u.LastLogin <= (GetDate() - 90) THEN 'Too long ago'
        ELSE 'Never'
    END AS [90 days],
    u.DomainID,
    CASE 
        WHEN ISNULL(primaryGroup.GroupName, '') = '' THEN 'PRIMARY-LICENSE-GROUP-NOT-DEFINED-TAG-METADATA-ON-GROUP-OR-MAKE-MEMBER-OF-A-PLG'
        ELSE primaryGroup.GroupName
    END AS [PrimaryLicenseGroup],
    CASE 
        WHEN ISNULL(primaryGroup.GroupName, '') = '' THEN '-1'
        ELSE primaryGroup.AdminLicenseRatio
    END AS [AdminLicenseRatio],    
    primaryGroup.MaintainedBy,
    primaryGroup.Description,
    STUFF((SELECT DISTINCT ', ' + gdn_inner.DisplayName
           FROM tbUserGroup ug_inner
           JOIN tbGroup g_inner ON ug_inner.GroupId = g_inner.GroupId
           JOIN vGroupDisplayName gdn_inner ON g_inner.GroupId = gdn_inner.GroupId
           INNER JOIN 
               (
                   SELECT
                       mi.ItemId,
                       mi.VALUEBIT
                   FROM
                       tbMetadataItemdata mi
                   JOIN
                       tbmetadatafield mf ON mi.MetadataFieldId = mf.Metadatafieldid
                   WHERE
                       mf.MetadatafieldName = 'PrimaryLicenseGroup' AND
                       mi.METADATATYPEID = 4
               ) md_PrimaryLicenseGroup ON g_inner.GroupId = md_PrimaryLicenseGroup.ItemId
           WHERE ug_inner.UserId = u.UserId AND md_PrimaryLicenseGroup.VALUEBIT = 1
           FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [PrimaryLicenseGroups],
    STUFF((SELECT DISTINCT ', ' + gdn_inner.DisplayName
           FROM tbUserGroup ug_inner
           JOIN tbGroup g_inner ON ug_inner.GroupId = g_inner.GroupId
           JOIN vGroupDisplayName gdn_inner ON g_inner.GroupId = gdn_inner.GroupId
           WHERE ug_inner.UserId = u.UserId
           FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [ALLGroupmembership]

FROM 
    tbGroup g WITH (NOLOCK)
INNER JOIN 
    vGroupDisplayName gdn WITH (NOLOCK) ON g.GroupId = gdn.GroupId
LEFT JOIN 
    tbUserGroup ug WITH (NOLOCK) ON g.GroupId = ug.GroupId
LEFT JOIN 
    tbUser u WITH (NOLOCK) ON ug.UserId = u.UserId 
LEFT JOIN 
    vUserDisplayName udn WITH (NOLOCK) ON u.UserId = udn.UserId
OUTER APPLY 
    (
        SELECT TOP 1
            gdn_inner.DisplayName AS GroupName,
            md_AdminLicenseRatio.ValueString AS AdminLicenseRatio,
            md_maintainedBy.ValueString AS MaintainedBy,
            md_Group_description.ValueString AS Description
        FROM tbUserGroup ug_inner
        INNER JOIN tbGroup g_inner ON ug_inner.GroupId = g_inner.GroupId
        INNER JOIN vGroupDisplayName gdn_inner ON g_inner.GroupId = gdn_inner.GroupId
        INNER JOIN 
            (
                SELECT
                    mi.ItemId,
                    mi.VALUEBIT
                FROM
                    tbMetadataItemdata mi
                JOIN
                    tbmetadatafield mf ON mi.MetadataFieldId = mf.Metadatafieldid
                JOIN
                    tbMetadataFieldSection mfs ON mf.MetadataFieldSectionId = mfs.MetadataFieldSectionId
                WHERE
                    mf.MetadatafieldName = 'PrimaryLicenseGroup' AND
                    mfs.MetadataFieldSectionName = 'LicenseReporting'
            ) md_PrimaryLicenseGroup ON g_inner.GroupId = md_PrimaryLicenseGroup.ItemId
        LEFT JOIN 
            (
                SELECT
                    mi.ItemId,
                    mi.ValueString
                FROM
                    tbMetadataItemdata mi
                JOIN
                    tbmetadatafield mf ON mi.MetadataFieldId = mf.Metadatafieldid
                JOIN
                    tbMetadataFieldSection mfs ON mf.MetadataFieldSectionId = mfs.MetadataFieldSectionId
                WHERE
                    mf.MetadatafieldName = 'AdminLicenseRatio' AND
                    mfs.MetadataFieldSectionName = 'LicenseReporting'
            ) md_AdminLicenseRatio ON g_inner.GroupId = md_AdminLicenseRatio.ItemId
        LEFT JOIN 
            (
                SELECT
                    mi.ItemId,
                    mi.ValueString
                FROM
                    tbMetadataItemdata mi
                JOIN
                    tbmetadatafield mf ON mi.MetadataFieldId = mf.Metadatafieldid
                JOIN
                    tbMetadataFieldSection mfs ON mf.MetadataFieldSectionId = mfs.MetadataFieldSectionId
                WHERE
                    mf.MetadatafieldName = 'MaintainedBy' AND
                    mfs.MetadataFieldSectionName = 'LicenseReporting'
            ) md_maintainedBy ON g_inner.GroupId = md_maintainedBy.ItemId
        LEFT JOIN 
            (
                SELECT
                    mi.ItemId,
                    mi.ValueString
                FROM
                    tbMetadataItemdata mi
                JOIN
                    tbmetadatafield mf ON mi.MetadataFieldId = mf.Metadatafieldid
                JOIN
                    tbMetadataFieldSection mfs ON mf.MetadataFieldSectionId = mfs.MetadataFieldSectionId
                WHERE
                    mf.MetadatafieldName = 'Description' AND
                    mfs.MetadataFieldSectionName = 'LicenseReporting'
            ) md_Group_description ON g_inner.GroupId = md_Group_description.ItemId
        WHERE 
            ug_inner.UserId = u.UserId AND
            md_PrimaryLicenseGroup.VALUEBIT = 1
    ) primaryGroup
WHERE
    g.Active = 1 AND
    u.Enabled = 1 AND
    gdn.DisplayName = 'All Vault Users'
