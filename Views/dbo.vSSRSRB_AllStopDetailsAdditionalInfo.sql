SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vSSRSRB_AllStopDetailsAdditionalInfo]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_AllStopDetailsAdditionalInfo]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_AllStopDetailsAdditionalInfo
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_AllStopDetailsAdditionalInfo]

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
 
SELECT evt_hubmiles_trailer1 as [Trailer1 Hub Reading],
       CASE WHEN [Sequence in Movement] = (SELECT MIN(b.[Sequence in Movement]) FROM vSSRSRB_AllStopDetails b  with(NOLOCK) WHERE b.[Move Number] = vSSRSRB_AllStopDetails.[Move Number] AND b.[Trailer1 ID] = vSSRSRB_AllStopDetails.[Trailer1 ID]) Then 0
			ELSE CASE WHEN evt_hubmiles_trailer1 Is NULL Then 0
					  ELSE evt_hubmiles_trailer1 -	(
													SELECT MAX(b.evt_hubmiles_trailer1) 
													FROM EVENT b  with(NOLOCK) 
												    WHERE b.evt_startdate < EVENT.evt_startdate 
												    AND EVENT.evt_mov_number = b.evt_mov_number 
												    AND b.evt_trailer1 = EVENT.evt_trailer1
												    )
					 END
			END AS [Trailer1 Hub Miles],
	 vSSRSRB_AllStopDetails.*
FROM vSSRSRB_AllStopDetails  with(NOLOCK) 
LEFT JOIN EVENT  with(NOLOCK) 
	ON vSSRSRB_AllStopDetails.[Stop Number] = EVENT.stp_number 
	AND EVENT.evt_sequence = 1 


GO
GRANT SELECT ON  [dbo].[vSSRSRB_AllStopDetailsAdditionalInfo] TO [public]
GO
