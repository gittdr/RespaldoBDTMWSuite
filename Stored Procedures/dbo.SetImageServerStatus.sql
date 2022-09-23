SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*

   This procedure is used by Imaging Software company to update a table letting TMWS know that the service is active

PTS15913 DPETE created 10/24/02 for Pegasus Imaging

*/

CREATE PROC [dbo].[SetImageServerStatus] (@appName varchar(30),@status Char(1) )
AS

Update ImageAppStatus set ias_Status = @status Where ias_AppName = @appname

GO
GRANT EXECUTE ON  [dbo].[SetImageServerStatus] TO [public]
GO
