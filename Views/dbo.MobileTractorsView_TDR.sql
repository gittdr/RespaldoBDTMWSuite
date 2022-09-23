SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[MobileTractorsView_TDR]
AS
     SELECT 'TMWWF_MOBILE_TRACTORS' AS 'TMWWF_MOBILE_TRACTORS',
            LTRIM(trc_number) AS 'ID',
            LTRIM(trc_number) AS 'Name',
			Ubicacion =  '<a href='+'http://maps.google.com/maps?z=12&t=k&q=' + CAST((trc_gps_latitude) / 3600.00 AS varchar)+ '+-' + CAST((trc_gps_longitude)/ 3600.00 AS varchar)  +'>'+cast(trc_gps_date as varchar(120)) +'  |  '+ trc_gps_desc +  '</a>',
            LTRIM(trc_type1) AS 'TrcType1', 'TrcType1 Name' = ISNULL((SELECT LTRIM(name) FROM labelfile(NOLOCK) WHERE labelfile.abbr = trc_type1 AND labeldefinition = 'TrcType1'), ''),
            LTRIM(trc_type2) AS 'TrcType2', 'TrcType2 Name' = ISNULL((SELECT LTRIM(name) FROM labelfile(NOLOCK) WHERE labelfile.abbr = trc_type2 AND labeldefinition = 'TrcType2'), ''),
            LTRIM(trc_type3) AS 'TrcType3', 'TrcType3 Name' = ISNULL((SELECT LTRIM(name) FROM labelfile(NOLOCK) WHERE labelfile.abbr = trc_type3 AND labeldefinition = 'TrcType3'), ''),
            LTRIM(trc_type4) AS 'TrcType4', 'TrcType4 Name' = ISNULL((SELECT LTRIM(name) FROM labelfile(NOLOCK) WHERE labelfile.abbr = trc_type4 AND labeldefinition = 'TrcType4'), ''),
            trc_year AS 'Year',
            (select name from labelfile where labeldefinition = 'fleet' and abbr = LTRIM(trc_fleet)) AS 'Fleet',
            LTRIM(trc_division) AS 'Division',
            LTRIM(trc_company) AS 'Company',
            LTRIM(trc_terminal) AS 'Terminal',
            LTRIM(RTRIM(trc_mctid)) AS 'MctId',
            LTRIM(trc_email) AS 'Email',
            LTRIM(trc_serial) AS 'Serial',
            trc_retiredate AS 'RetireDate',
            trc_startdate AS 'StartDate',
            LTRIM(trc_licnum) AS 'LicenseNumber',
            LTRIM(trc_driver) AS 'Driver'
			
				
     FROM dbo.tractorprofile(NOLOCK)
	 where trc_status <> 'OUT'


GO
