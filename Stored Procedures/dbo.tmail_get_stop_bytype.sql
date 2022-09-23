SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_stop_bytype] 
	@p_lghnum varchar(11),
	@p_stptype varchar(6),
	@p_flags varchar(11) = 0
		-- +1 = get last - if not set, gets first

AS

declare 
	@lghnum int,
	@flags int,
	@stpnum int,
	@flg_getlast int

if isnull(@p_lghnum, '') = '' 
	BEGIN
	RAISERROR('Legheader Number is missing.', 16, 1)
	RETURN 2
	END

if isnumeric(@p_lghnum) = 0 
	BEGIN
	RAISERROR('Legheader Number %s is not numeric.', 16, 1, @p_lghnum)
	RETURN 2
	END

if isnull(@p_flags, '') = '' set @p_flags = '0'
if isnumeric(@p_flags) = 0 
	BEGIN
	RAISERROR('Flags %s is not numeric.', 16, 1, @p_flags)
	RETURN 2
	END

set @lghnum = convert(int, @p_lghnum)

if @lghnum < 1
	BEGIN
	RAISERROR('Legheader Number %s is not positive.', 16, 1, @p_lghnum)
	RETURN 2
	END

set @flags = convert(int, @p_flags)
set @flg_getlast = @flags & 1

if @flg_getlast > 0 
	select top 1 @stpnum = stp_number 
	from stops (NOLOCK)
	where lgh_number = @lghnum and isnull(stp_type,'NONE') = @p_stptype 
		order by stp_mfh_sequence desc
else
	select top 1 @stpnum = stp_number 
	from stops (NOLOCK)
	where lgh_number = @lghnum and isnull(stp_type,'NONE') = @p_stptype 
		order by stp_mfh_sequence

set @stpnum = isnull(@stpnum, 0)

select @stpnum

RETURN 0

GO
GRANT EXECUTE ON  [dbo].[tmail_get_stop_bytype] TO [public]
GO
