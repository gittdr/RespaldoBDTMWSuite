SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Purges tblWebTechMessage posted messages keeping the given minimum number of days or 
-- minimum number of rows of data (whichever is more).  
-- Returns number of rows deleted.
CREATE Procedure [dbo].[tm_PurgeWebtechmessage] (
	@minDays int,
	@minRows int
	)
AS
SET NOCOUNT ON

declare @minDaysDate datetime
declare @rowsToKeep int
declare @lastRowToKeepDate datetime
declare @tempTable TABLE(
	SN				int			NULL,
	receive_time	datetime	NULL,
	post_time		datetime	NULL
	)

-- Get number of rows to keep, where post_time is null.
set @minDaysDate = DATEADD(day, @mindays * -1, GETDATE())

select @rowsToKeep = count(SN) 
from tblWebTechMessage (NOLOCK)
where not post_time is null and receive_time >= @minDaysDate

if @rowsToKeep < @minRows set @rowsToKeep = @minRows

-- Get date of last row to keep
INSERT INTO @tempTable(
	SN,
	receive_time,
	post_time
	)
	SELECT top (@rowsToKeep)			
		SN,
		receive_time,
		post_time
		FROM tblWebTechMessage (NOLOCK)
		WHERE not post_time is null order by receive_time desc, sn desc
select top 1 @lastRowToKeepDate = receive_time from @tempTable
	order by receive_time, sn

-- Delete rows
delete tblWebTechMessage where receive_time < @lastRowToKeepDate

select @@ROWCOUNT

GO
GRANT EXECUTE ON  [dbo].[tm_PurgeWebtechmessage] TO [public]
GO
