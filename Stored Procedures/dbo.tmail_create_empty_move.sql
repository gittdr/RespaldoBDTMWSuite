SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_create_empty_move] 
	@begcmpid char(25), --PTS 61189 change cmp_id fields to 25 length
	@a_begdate varchar(30),
	@endcmpid char(25), --PTS 61189 change cmp_id fields to 25 length
	@a_enddate varchar(30)

AS

declare @begdate datetime,
	@enddate datetime,
	@lghnum int,
	@movnum int,
	@begstpnum int,
	@endstpnum int,
	@str1 varchar(50), 
	@str2 varchar(50)

if isnull(@begcmpid, '') = '' OR isnull(@begcmpid, 'UNKNOWN') = 'UNKNOWN'
	BEGIN
	RAISERROR('Beginning company ID is missing.', 16, 1)
	RETURN 1
	END

if isnull(@endcmpid, '') = '' OR isnull(@endcmpid, 'UNKNOWN') = 'UNKNOWN'
	BEGIN
	RAISERROR('Ending company ID is missing.', 16, 1)
	RETURN 1
	END

if isnull(@a_begdate, '') = ''
	set @begdate = getdate()
else if isdate(@a_begdate) = 1
	set @begdate = convert(datetime, @a_begdate)
else
	BEGIN
	RAISERROR('Beginning date %s is bad.', 16, 1, @a_begdate)
	RETURN 1
	END

if isnull(@a_enddate, '') = '' 
	set @enddate = dateadd(n, 1, @begdate)
else if isdate(@a_enddate) = 1
	set @enddate = convert(datetime, @a_enddate)
else
	BEGIN
	RAISERROR('Ending date %s is bad.', 16, 1, @a_enddate)
	RETURN 1
	END

if @enddate = @begdate
	set @enddate = dateadd(n, 1, @begdate)	

if @begdate >= @enddate
	BEGIN
	set @str1 = convert(varchar(30), @begdate, 20)
	set @str2 = convert(varchar(30), @enddate, 20)
	RAISERROR('Beginning date %s is the same or later than ending date %s', 16, 1, @str1, @str2)
	RETURN 1
	END

if not exists(select cmp_id from company where cmp_id = @begcmpid)
	BEGIN
	RAISERROR('Beginning company ID %s is not on file.', 16, 1, @begcmpid)
	RETURN 2
	END

if not exists(select cmp_id from company where cmp_id = @endcmpid)
	BEGIN
	RAISERROR('Ending company ID %s is not on file.', 16, 1, @endcmpid)
	RETURN 2
	END

EXEC @movnum = dbo.getsystemnumber 'MOVNUM', ''	
EXEC @lghnum = dbo.getsystemnumber  'LEGHDR', '' 

exec dbo.tmail_create_empty_move_stop @lghnum, @movnum, @begcmpid, 1, 'BBT', @begdate, @begstpnum out

exec dbo.tmail_create_empty_move_stop @lghnum, @movnum, @endcmpid, 2, 'EBT', @enddate, @endstpnum out

EXEC dbo.update_move @movnum  --Adds legheader.

select @lghnum as 'LghNum', 
	@movnum as 'MoveNum', 
	@begstpnum as 'BeginStopNum', 
	@endstpnum as 'EndStopNum'

RETURN 0

GO
GRANT EXECUTE ON  [dbo].[tmail_create_empty_move] TO [public]
GO
