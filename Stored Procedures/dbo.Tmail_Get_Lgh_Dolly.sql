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

CREATE PROCEDURE [dbo].[Tmail_Get_Lgh_Dolly] 
	  @p_lgh_number varchar(20)
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT lgh_dolly from legheader WHERE lgh_number = @p_lgh_number;

GO
GRANT EXECUTE ON  [dbo].[Tmail_Get_Lgh_Dolly] TO [public]
GO
