SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
Object Description:
DESCRIPTION: Updates LGH OutStatus .
Revision History:
Date				Name						Label/PTS		Description
----------	------------   	---------  	----------------------------------------------------------------
08/03/2018	Tony Leonardi		xxxxx 			Legacy TM
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[Tmail_Update_LGH_Outstatus] 
		 @p_lgh_number varchar(12)
		,@p_lgh_outstatus varchar(12)

AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF COALESCE(@p_lgh_number, 0) = 0 
	BEGIN
		RAISERROR('Tmail_Update_LGH_Outstatus: Leg Number not specified.', 16, 1)
		RETURN
	END;

IF COALESCE(@p_lgh_outstatus, 'DSP') NOT IN ('DSP','STD','PLN')
	BEGIN
		RAISERROR('Tmail_Update_LGH_Outstatus: Invalid Leg Status Provided.', 16, 1)
		RETURN
	END;

UPDATE dbo.legheader
		SET lgh_OutStatus = @p_lgh_OutStatus
		WHERE lgh_number = @p_lgh_number;

GO
GRANT EXECUTE ON  [dbo].[Tmail_Update_LGH_Outstatus] TO [public]
GO
