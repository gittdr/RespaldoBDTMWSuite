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
@IDList relavent Trailers
@LandmarkName name of landmark querying
@AntiLoadedStatus what am i not looking for (Ex: when i want the empty, I realy want Not loaded so i get "in transition" like stuff)
@System SKYBTZ? startrack? ORBCOM? TrailerTracs?
@Feilds what do I want back

Change Log: 
rwolfe init 2015/07/28
 **/

CREATE PROCEDURE [dbo].[tmail_get_cur_TrailerLoad]
	@IDList as dbo.tmail_StringList READONLY,
	@LandmarkName as varchar(220) = '',
	@AntiLoadedStatus as varchar(12) = '',
	@System as varchar(10) = '',
	@Fields as nvarchar(500) = ' * '
AS 
Begin

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @ssql nvarchar(4000),
		@and nvarchar(7) = N' where '
set @ssql = N'select ' + @Fields + N' from tblCurrentLoadTrailerCommHistory '

if NOT (ISNULL(@LandmarkName,'') = '')
begin	
	set @ssql += @and + N' tch_landmarkname = @LandmarkName '
	set @and = N' AND '
end

if Not (ISNULL(@System,'') = '') 
begin
	set @ssql += @and + N' acm_system = @System '
	set @and = N' AND '
end

if Not (ISNULL(@AntiLoadedStatus,'') = '')
Begin
	set @AntiLoadedStatus = '%'+ @AntiLoadedStatus + '%'
	set @ssql += @and + N' (Not tch_loadedstatus like @AntiLoadedStatus) '
	set @and = N' AND '
end

set @ssql += @and + N' trl_id in (select Val from @IDList) '

exec sp_executeSQL @ssql, N' @IDList as dbo.tmail_StringList READONLY, @LandmarkName as varchar(220),  @System as varchar(10), @AntiLoadedStatus as varchar(12) ',
						  @IDList = @IDList, @LandmarkName = @LandmarkName, @System = @System, @AntiLoadedStatus = @AntiLoadedStatus

End
GO
GRANT EXECUTE ON  [dbo].[tmail_get_cur_TrailerLoad] TO [public]
GO
