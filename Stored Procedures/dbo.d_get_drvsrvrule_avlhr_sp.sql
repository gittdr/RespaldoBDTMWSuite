SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_drvsrvrule_avlhr_sp]
@sr_drvrid	varchar(10),
@srvcrule       varchar(10),
@sr_date        datetime, 
@sr_avlhrs	decimal(10,2) output

AS
/**
 * 
 * NAME:
 * dbo.d_get_drvsrvrule_avlhr_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * pts 7862 changed this proc 100%
	When dispatch and OE look at the available hours it is only asking if thee are hours recorded, 
	there is no coding to say whether they have enough to do the load and that would be too much work.
	Also the date being passed in is not relevant since there is no way to look in the future and the 
	past is not important. 
 * change this to look at the hours1-3 field on the driver and return ther value
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names
 *
 *07/23/2008 PTS42127 Output variable @sr_avlhrs was defined as float changed to decimal (10,2)
 **/


declare @lastdt datetime


select @sr_avlhrs = isnull(mpp_hours1 + mpp_hours2 + mpp_hours3,-100),
	@lastdt =convert(datetime, convert(varchar(10), mpp_last_log_date,101)+' 23:59') 
from manpowerprofile 
where mpp_id=@sr_drvrid

if @lastdt < convert(datetime, convert(varchar(10), dateadd(dd,-1,getdate()),101)+' 00:00')
begin
	SELECT @sr_avlhrs = -100
end

GO
GRANT EXECUTE ON  [dbo].[d_get_drvsrvrule_avlhr_sp] TO [public]
GO
