SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[sp_advmisc_log]
( @Action         VARCHAR(15)
, @pyd_number     INT
)
AS

/*
*
*
* NAME:
* dbo.sp_advmisc_log
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to Save Advance Miscellaneous Labor Window Actions on each paydetail
*
* RETURNS:
*
* NOTHING:
*
* 12/13/2012 PTS65642 SPN - Created Initial Version
*
*/

BEGIN

   INSERT INTO advmisc_log(Action, pyd_number)
   VALUES (@Action, @pyd_number)

   RETURN 0

END
GO
GRANT EXECUTE ON  [dbo].[sp_advmisc_log] TO [public]
GO
