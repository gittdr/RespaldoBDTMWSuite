SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 
NAME:
dbo.tmail_qry_cur_TrailerLoad

TYPE:
Stored Procedure

DESCRIPTION:
gathers curent Trailer information by Landmark


Prams:
@LandmarkName name of landmark querying
@AntiLoadedStatus what am i not looking for (Ex: when i want the empty, I realy want Not loaded so i get "in transition" like stuff)
@System SKYBTZ? startrack? ORBCOM? TrailerTracs?
@Feilds what do I want back

Change Log: 
rwolfe init 2015/07/28
 **/

CREATE PROCEDURE [dbo].[tmail_qry_cur_TrailerLoad]
	@LandmarkName as varchar(220),
	@AntiLoadedStatus as varchar(12) = '',
	@System as varchar(10) = '',
	@Fields as nvarchar(500) = ''
AS 
Begin

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	
Declare @ssql nvarchar(4000)
if ISNULL(@Fields,'') = '' 
	set @Fields = ' * '
set @ssql = N'select ' + @Fields + N' from tblCurrentLoadTrailerCommHistory where rtrim(tch_landmarkname) = @LandmarkName '

if Not (ISNULL(@System,'') = '') 
	set @ssql += N' and acm_system = @System '

if Not (ISNULL(@AntiLoadedStatus,'') = '')
Begin
	set @AntiLoadedStatus = '%'+ @AntiLoadedStatus + '%'
	set @ssql += N' and (Not tch_loadedstatus like @AntiLoadedStatus) '
	--set @ssql = N'select ' + @Fields + N' from tblCurrentLoadTrailerCommHistory where tch_landmarkname = @LandmarkName '
end

exec sp_executeSQL @ssql, N' @LandmarkName as varchar(220),  @System as varchar(10), @AntiLoadedStatus as varchar(12)',
						  @LandmarkName = @LandmarkName, @System = @System, @AntiLoadedStatus = @AntiLoadedStatus




End
GO
GRANT EXECUTE ON  [dbo].[tmail_qry_cur_TrailerLoad] TO [public]
GO
