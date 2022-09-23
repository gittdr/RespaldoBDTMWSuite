SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*******************************************************************************************************************  
  Object Description:
  Purges TotalMail Admin Folder at specified # of Days.  Calls TM_PurgeFolder.
  Revision History:
  Date         Name             Label/PTS        Description
  -----------  ---------------  ----------       ----------------------------------------
  07/25/2016   Tony Leonardi    Project: xxxxx   Legacy TM
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[TMail_Purge_Admin_Folder]

AS

declare @p_purgedate datetime

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

set @p_purgedate = dateadd(dd,-3,getdate());
exec tm_purgefolder 360,@p_purgedate;

GO
GRANT EXECUTE ON  [dbo].[TMail_Purge_Admin_Folder] TO [public]
GO
