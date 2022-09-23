SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[MobileDriversView_TDR]
AS
     SELECT 'TMWWF_MOBILE_DRIVERS' AS 'TMWWF_MOBILE_DRIVERS',
            LTRIM(mpp_id) AS 'ID',
            LTRIM(RTRIM(mpp_otherid)) AS 'AltId',
            LTRIM(mpp_lastfirst) AS 'Name',
            LTRIM(mpp_firstname) AS 'FirstName',
            LTRIM(mpp_lastname) AS 'LastName',
            LTRIM(RTRIM(mpp_currentphone)) AS 'Current Phone Number',
            LTRIM(RTRIM(mpp_alternatephone)) AS 'Alternate Phone Number',
            LTRIM(RTRIM(mpp_homephone)) AS 'Home Phone Number',
            LTRIM(mpp_tractornumber) AS 'TractorNumber',
            LTRIM(mpp_type1) AS 'DrvType1', 'DrvType1 Name' = COALESCE(LTRIM(L1.name), ''),
            LTRIM(mpp_type2) AS 'DrvType2', 'DrvType2 Name' = COALESCE(LTRIM(L2.name), ''),
            LTRIM(mpp_type3) AS 'DrvType3', 'DrvType3 Name' = COALESCE(LTRIM(L3.name), ''),
            LTRIM(mpp_type4) AS 'DrvType4', 'DrvType4 Name' = COALESCE(LTRIM(L4.name), ''),
            LTRIM(mpp_teamleader) AS 'Team Leader',
            (select name from labelfile where labeldefinition = 'fleet' and abbr = LTRIM(mpp_fleet)) AS 'Fleet',
            LTRIM(mpp_division) AS 'Division',
            LTRIM(mpp_domicile) AS 'Domicile',
            LTRIM(mpp_company) AS 'Company ID',
            LTRIM(mpp_terminal) AS 'Terminal',
            LTRIM(mpp_status) AS 'Driver Status',
            LTRIM(RTRIM(mpp_emerphone)) AS 'Emergency Phone Number',
            LTRIM(mpp_emername) AS 'Emergency Contact Name',
            LTRIM(RTRIM(mpp_state)) AS 'State',
            mpp_city AS 'CityId',
            LTRIM(RTRIM(C.cty_name)) AS 'CityName',
            LTRIM(RTRIM(mpp_zip)) AS 'Zip',
            LTRIM(mpp_address1) AS 'Address1',
            LTRIM(mpp_address2) AS 'Address2',
            LTRIM(RTRIM(mpp_currentphone)) AS 'CurrentPhone',
            LTRIM(mpp_company) AS 'CompanyId',
            'CompanyName' = COALESCE(LTRIM(L5.name), '')
     FROM manpowerprofile M WITH (NOLOCK)
          LEFT OUTER JOIN labelfile L1 WITH (NOLOCK) ON M.mpp_type1 = L1.abbr AND L1.labeldefinition = 'DrvType1'
          LEFT OUTER JOIN labelfile L2 WITH (NOLOCK) ON M.mpp_type2 = L2.abbr AND L2.labeldefinition = 'DrvType2'
          LEFT OUTER JOIN labelfile L3 WITH (NOLOCK) ON M.mpp_type3 = L3.abbr AND L3.labeldefinition = 'DrvType3'
          LEFT OUTER JOIN labelfile L4 WITH (NOLOCK) ON M.mpp_type4 = L4.abbr AND L4.labeldefinition = 'DrvType4'
          LEFT OUTER JOIN city C ON M.mpp_city = c.cty_code
          LEFT OUTER JOIN labelfile L5 WITH (NOLOCK) ON M.mpp_company = L5.abbr AND L5.labeldefinition = 'Company'
		  where mpp_status <> 'OUT';

GO
