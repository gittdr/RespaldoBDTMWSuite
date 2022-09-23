SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.tmail_get_dsp_activity_sp    Script Date: 5/27/99 MZ ******/
CREATE PROCEDURE [dbo].[tmail_get_dsp_activity_sp] 	@type	varchar (6), 
												@id	varchar(13)

AS
/* 05/24/01 DAG: Converting for international date format */

SET NOCOUNT ON 

Declare @mindt datetime
Declare @lgh int  

SELECT @mindt = min(assetassignment.asgn_enddate)
FROM assetassignment (NOLOCK) 
WHERE (assetassignment.asgn_type = @type) AND  
(assetassignment.asgn_id = @id) AND
(
	(assetassignment.asgn_status = 'DSP') 
	OR
	(assetassignment.asgn_status = 'PLN') 
)  
AND
(assetassignment.asgn_enddate <= '20491231 23:59')

SELECT @lgh = legheader.lgh_number 
FROM 	assetassignment(NOLOCK), legheader (NOLOCK) 
WHERE (assetassignment.lgh_number = legheader.lgh_number) and  
	(assetassignment.asgn_type = @type) AND  
   	(assetassignment.asgn_id = @id) AND  
	(
		(assetassignment.asgn_status = 'DSP')
		OR
		(assetassignment.asgn_status = 'PLN')
	)
	AND
	lgh_outstatus ='DSP' AND	
	(assetassignment.asgn_enddate = @mindt)

/*** THIS IS HERE FOR DEBUG PURPOSES ONLY, SHOULD BE REMOVED - ADDED 6/11/99 MZ ****/
/**
INSERT INTO geofueldebug (geotimestamp, 
			tractor, 
			lgh_number, 
			startdate, 
			enddate, 
			outstatus,
			lgh_selected)
	SELECT getdate(), 
		@id, 
		lgh_number, 
		lgh_startdate, 
		lgh_enddate, 
		lgh_outstatus, 
		@lgh
		FROM legheader 
		WHERE lgh_tractor = @id
		AND lgh_active = 'Y'
**/

SELECT @lgh  
GO
GRANT EXECUTE ON  [dbo].[tmail_get_dsp_activity_sp] TO [public]
GO
