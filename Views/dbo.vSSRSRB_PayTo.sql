SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[vSSRSRB_PayTo]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_PayTo
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Payto Data 
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/
 
SELECT           pto_id as PayToID, 
		         pto_id as PayToIDList, 
	             pto_altid as PayToAltID, 
                 pto_fname as [First Name], 
                 pto_mname as [Middle Name], 
                 pto_lname as [Last Name], 
                 pto_ssn as [Social Security Number], 
                 pto_address1 as [Address1], 
                 pto_address2 as [Address2], 
         (select cty_name  from city WITH (NOLOCK) where cty_code = pto_city) as [CityName],
		 (select cty_state from city WITH (NOLOCK) where cty_code = pto_city) as [State],
                 pto_zip as [Zip Code], 
                 pto_phone1 as [Phone Number1], 
                 pto_phone2 as [Phone Number2], 
                 pto_phone3 as [Phone Number3],
                 pto_currency as [Currency], 
                 pto_type1 as [Type1], 
                 pto_type2 as [Type2], 
                 pto_type3 as [Type3], 
                 pto_type4 as [Type4], 
                 pto_company as [Company ID], 
                 pto_division as Division, 
                 pto_terminal as Terminal, 
                 pto_status as PayToStatus, 
                 pto_lastfirst as LastFirstName, 
                 pto_fleet as Fleet, 
                 pto_misc1 as Misc1, 
                 pto_misc2 as Misc2, 
                 pto_misc3 as Misc3, 
                 pto_misc4 as Misc4, 
                 pto_updatedby as UpdatedBy, 
                 pto_updateddate as UpdatedDate, 
                 pto_yrtodategross as YearToDateGross, 
                 pto_socsecfedtax as SocSecFedTax,  
                 pto_dirdeposit as DirectDeposit, 
                 pto_fleettrc as FleetTrc, 
                 pto_startdate as [Start Date], 
                 pto_terminatedate as [Termination Date], 
                 pto_createdate as [Created Date], 
                 pto_companyname as CompanyName,
		         pto_gp_class as [GP Class]

FROM  payto WITH (NOLOCK)

GO
