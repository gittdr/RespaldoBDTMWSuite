SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[MetricUpdateTimeZones]  
AS
	SET NOCOUNT ON

/*
 Proc was taken from http://wiki.tmwsystems.com/wiki.cgi?TimeZoneInformationByStateSqlScript


 Split state assignments were made by where TMW thought the majority of the larger cities were:
 	EST/EDT: FL, KY, MI, NU, ON
 	EST: IN
 	CST/CDT: TN, ND, SD, NE, KS, TX
 	CST: SK
 	MST/MDT: ID, NT
 	PST/PDT: OR
 	AKST/AKDT: AK
 	UTC-10: HA
 The below includes some attempts to code some of these exceptions, but those attempts are NOT precise.
 */
 -- Split state exceptions
 -- Eastern British Columbia
 update city set cty_GMTDelta = 7, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('BC')) and (isnull(cty_longitude, 999) < 117.) and (cty_GMTDelta is null)
 -- Florida panhandle
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('FL')) and (isnull(cty_longitude, 0) >85.) and (cty_GMTDelta is null)
 -- Idaho Panhandle
 update city set cty_GMTDelta = 8, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('ID')) and (isnull(cty_latitude, 0) >45.5) and (cty_GMTDelta is null)
 -- Northwest Indiana (Chicago Area)
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 0) >40.75) and (isnull(cty_longitude, 0) >86.5) and (cty_GMTDelta is null)
 -- Southwest Indiana (Evansville Area)
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 999) < 38.375) and (isnull(cty_longitude, 0) >86.8) and (cty_GMTDelta is null)
 -- Southeast Indiana (Cincinnati Area)
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 999) < 39.3) and (isnull(cty_longitude, 999) < 85.1) and (cty_GMTDelta is null)
 -- Southern Indiana (Louisville Area)
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 999) < 38.6) and (isnull(cty_longitude, 999) < 86.25) and (cty_GMTDelta is null)
 -- Western Kansas (not coded)
 -- Kentucky panhandle
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('KY')) and (isnull(cty_longitude, 0) >86.) and (cty_GMTDelta is null)
 -- Labrador
 update city set cty_GMTDelta = 4, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('NF')) and (isnull(cty_latitude, 0) > 51.7) and (isnull(cty_longitude, 0) > 57.1)  and (cty_GMTDelta is null)
 -- Michigan Wisconsin Border: Not coded
 -- Southwest North Dakota, Western South Dakota, Western Nebraska
 update city set cty_GMTDelta = 7, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('ND', 'NE', 'SD')) and (isnull(cty_longitude, 0) > 101.) and (isnull(cty_latitude, 999) < 47.5) and (cty_GMTDelta is null)
 -- Nunavut, Northwest Territories
 update city set cty_GMTDelta = 7, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('NT', 'NU')) and (isnull(cty_longitude, 0) > 110.) and (cty_GMTDelta is null)
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('NT', 'NU')) and (isnull(cty_longitude, 0) > 85.) and (cty_GMTDelta is null)
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('NT', 'NU')) and (isnull(cty_longitude, 999) < 85.) and (cty_GMTDelta is null)
 -- Eastern Oregon (not coded)
 -- Western Ontario (Thunder Bay exceptions not coded)
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('ON')) and (isnull(cty_longitude, 0) > 90.) and (cty_GMTDelta is null)
 -- Saskatchewan border towns (not coded)
 -- Eastern Tennessee
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('TN')) and (isnull(cty_longitude, 999) < 85.) and (cty_GMTDelta is null)
 -- El Paso area
 update city set cty_GMTDelta = 7, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('TX')) and (isnull(cty_longitude, 0) > 105.) and (cty_GMTDelta is null)

 --NST/NDT
 update city set cty_GMTDelta = 3, cty_TZMins = 30, cty_DSTApplies = 'Y' where cty_state in ('NF') and (cty_GMTDelta is null)
 --AST/ADT
 update city set cty_GMTDelta = 4, cty_TZMins = 0, cty_DSTApplies = 'Y' where cty_state in ('NB', 'NS', 'PE') and (cty_GMTDelta is null)
 --EST/EDT
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'Y' where cty_state in ('CT', 'DE', 'DC', 'FL', 'GA', 'KY', 'ME', 'MD', 'MA', 'MI', 'NH', 'NJ', 'NY', 'NC', 'NU', 'OH', 'ON', 'PA', 'PQ', 'RI', 'SC', 'VT', 'VA', 'WV') and (cty_GMTDelta is null)
 --EST Only
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'N' where cty_state in ('IN') and (cty_GMTDelta is null)
 --CST/CDT
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where cty_state in ('AL', 'AR', 'IL', 'IA', 'KS', 'LA', 'MB', 'MX', 'MN', 'MS', 'MO', 'NE', 'ND', 'OK', 'SD', 'TN', 'TX', 'WI') and (cty_GMTDelta is null)
 --CST Only
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'N' where cty_state in ('SK') and (cty_GMTDelta is null)
 --MST/MDT
 update city set cty_GMTDelta = 7, cty_TZMins = 0, cty_DSTApplies = 'Y' where cty_state in ('AB', 'CO', 'ID', 'MT', 'NM', 'NT', 'UT', 'WY') and (cty_GMTDelta is null)
 --MST Only
 update city set cty_GMTDelta = 7, cty_TZMins = 0, cty_DSTApplies = 'N' where cty_state in ('AZ') and (cty_GMTDelta is null)
 --PST/PDT
 update city set cty_GMTDelta = 8, cty_TZMins = 0, cty_DSTApplies = 'Y' where cty_state in ('BC', 'CA', 'NV', 'OR', 'WA', 'YT') and (cty_GMTDelta is null)
 --AKST/AKDT
 update city set cty_GMTDelta = 9, cty_TZMins = 0, cty_DSTApplies = 'Y' where cty_state in ('AK') and (cty_GMTDelta is null)
 --Hawaii
 update city set cty_GMTDelta = 10, cty_TZMins = 0, cty_DSTApplies = 'N' where cty_state in ('HA') and (cty_GMTDelta is null)

 -- Indiana time has ceased to exist.  Anything still not on
 --   DST should be reavaluated, so do so...
 -- New Chicago area border

 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 0) >40.909874) and (isnull(cty_longitude, 0) >86.468472) and (cty_DSTApplies = 'N')
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 0) >40.837973) and (isnull(cty_longitude, 0) >86.986372) and (cty_DSTApplies = 'N')
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 0) >40.736586) and (isnull(cty_longitude, 0) >87.098402) and (cty_DSTApplies = 'N')
 -- New Evansville area border
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 999) < 38.904718) and (isnull(cty_longitude, 0) >86.683097 ) and (cty_DSTApplies = 'N')
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 999) < 38.266189) and (isnull(cty_longitude, 0) >86.570112) and (cty_DSTApplies = 'N')
 update city set cty_GMTDelta = 6, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (isnull(cty_latitude, 999) < 38.206752) and (isnull(cty_longitude, 0) >86.460401) and (cty_DSTApplies = 'N')

 -- Rest of state is now EST/EDT
 update city set cty_GMTDelta = 5, cty_TZMins = 0, cty_DSTApplies = 'Y' where (cty_state in ('IN')) and (cty_DSTApplies = 'N')

GO
