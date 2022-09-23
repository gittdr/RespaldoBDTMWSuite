SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_CarrierProfile]
AS

/**
 *
 * NAME:
 * dbo.[vSSRSRB_CarrierProfile]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_CarrierProfile
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_CarrierProfile]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/
 
SELECT     carrier.car_id as 'Carrier ID',
           carrier.car_name as 'Carrier Name', 
           carrier.car_fedid as 'Carrier Federal ID', 
           carrier.car_address1 as 'Address1', 
           carrier.car_address2 as 'Address2', 
		   cty.cty_name AS 'Carrier City',
		   cty.cty_state AS 'Carrier State',
           carrier.cty_code as 'City Code', 
           carrier.car_zip as 'Zip Code', 
           carrier.pto_id as 'Pto Id', 
           carrier.car_scac as 'Carrier Scac Code', 
           carrier.car_contact as 'Contact', 
           carrier.car_type1 as 'CarType1', 
           carrier.car_type2 as 'CarType2', 
           carrier.car_type3 as 'CarType3', 
           carrier.car_type4 as 'CarType4', 
           'CarType1 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = carrier.car_type1 and labelfile.labeldefinition = 'CarType1'),''),
           'CarType2 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = carrier.car_type2 and labelfile.labeldefinition = 'CarType2'),''),
           'CarType3 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = carrier.car_type3 and labelfile.labeldefinition = 'CarType3'),''),
           'CarType4 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = carrier.car_type4 and labelfile.labeldefinition = 'CarType4'),''),
           cast(carrier.car_misc1 as varchar(255)) as 'Misc1', 
           cast(carrier.car_misc2 as varchar(255)) as 'Misc2', 
           cast(carrier.car_misc3 as varchar(255)) as 'Misc3', 
           cast(carrier.car_misc4 as varchar(255)) as 'Misc4', 
           carrier.car_phone1 as 'Phone Number', 
           carrier.car_phone2 as 'Phone Number 2',  
           carrier.car_phone3 as 'Phone Number 3', 
           carrier.car_lastactivity as 'Last Activity', 
		   (select top 1 lgh_number from legheader with (NOLOCK)  where lgh_carrier = car_id and lgh_outstatus = 'CMP' order by lgh_enddate desc) as 'Last Completed Leg',
		   (select top 1 lgh_enddate from legheader with (NOLOCK) where lgh_carrier = car_id and lgh_outstatus = 'CMP' order by lgh_enddate desc) as 'Last Completed Leg Date',
           carrier.car_actg_type as 'Accounting Type', 
           carrier.car_iccnum as 'Icc Number', 
           carrier.car_contract as 'Contract', 
           carrier.car_otherid as 'Other Id', 
           carrier.car_usecashcard as 'Use Cash Card', 
           carrier.car_status as 'Carrier Status', 
           carrier.car_board as 'Board', 
           carrier.car_updatedby as 'Updated By', 
		   (Cast(Floor(Cast(carrier.car_updateddate as float))as smalldatetime)) AS 'Updated Date Only',
           carrier.car_updateddate as 'Updated Date', 
		   car_rating as [Service Rating],
		   la.name AS [Service Rating Description],
       	   carrier.car_createdate as 'Created Date', 
           (Cast(Floor(Cast(carrier.[car_createdate] as float))as smalldatetime)) as [Created Date Only], 
           Cast(DatePart(yyyy,carrier.[car_createdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,carrier.[car_createdate]) as varchar(2)) + '-' + Cast(DatePart(dd,carrier.[car_createdate]) as varchar(2)) as [Created Day],
           Cast(DatePart(mm,carrier.[car_createdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,carrier.[car_createdate]) as varchar(4)) as [Created Month],
           DatePart(mm,carrier.[car_createdate]) as [Created Month Only],
           DatePart(yyyy,carrier.[car_createdate]) as [Created Year],  
		   carrier.car_exp1_date as 'Exp1 Date', 
           carrier.car_exp2_date as 'Exp2 Date', 
       	   car_terminationdt as 'Termination Date',
           (Cast(Floor(Cast(carrier.[car_terminationdt] as float))as smalldatetime)) as [Termination Date Only], 
           Cast(DatePart(yyyy,carrier.[car_terminationdt]) as varchar(4)) +  '-' + Cast(DatePart(mm,carrier.[car_terminationdt]) as varchar(2)) + '-' + Cast(DatePart(dd,carrier.[car_terminationdt]) as varchar(2)) as [Termination Day],
           Cast(DatePart(mm,carrier.[car_terminationdt]) as varchar(2)) + '/' + Cast(DatePart(yyyy,carrier.[car_terminationdt]) as varchar(4)) as [Termination Month],
           DatePart(mm,carrier.[car_terminationdt]) as [Termination Month Only],
           DatePart(yyyy,carrier.[car_terminationdt]) as [Termination Year],  
           carrier.car_email as 'Email', 
           carrier.car_service_location as 'Service Location',
		   carrier.car_branch as Branch,		
		   carrier.car_gp_class as [GP Class],	
		   carrier.car_agent as Agent
from carrier WITH (NOLOCK)
LEFT JOIN city cty	WITH(NOLOCK)
	ON carrier.cty_code = cty.cty_code
LEFT JOIN labelfile la WITH(NOLOCK)
	ON carrier.car_rating = la.abbr and la.labeldefinition = 'CarrierServiceRating'


/**************************************************************************
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 *************************************************************************/

GO
GRANT SELECT ON  [dbo].[vSSRSRB_CarrierProfile] TO [public]
GO
