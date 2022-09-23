SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
Object Description:
Updates Lgh_Dolly.
Revision History:
Date		Name		Label/PTS	Description
----------	------------   	---------  	----------------------------------------------------------------
02/24/2017	Tony Leonardi	xxxxx 		Legacy TM
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[Tmail_Update_Lgh_Dolly] 
	  @p_lgh_number varchar(20)
	, @p_lgh_dolly varchar(13)

AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

update legheader 
	set lgh_dolly = @p_lgh_dolly 
	where lgh_number = @p_lgh_number


/*********************************
There is also needed an updated on the event table so dolly get updated correctly
By: Emolvera 19/04/18
***********************************/

update event set evt_dolly = @p_lgh_dolly 
where event.stp_number in (select stp_number from stops where stops.lgh_number = @p_lgh_number)
and event.evt_trailer2 <> 'UNKNOWN'
GO
GRANT EXECUTE ON  [dbo].[Tmail_Update_Lgh_Dolly] TO [public]
GO
