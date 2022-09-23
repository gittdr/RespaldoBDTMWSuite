SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [dbo].[tmail_update_estloghrs]( 
	@pdrvid varchar(13), 
	@pmsgdate varchar(30), 
	@pestavldate varchar(30), 
	@pestavltime varchar(30), 
	@pavlcmpid varchar(25), -- PTS 61189 enhance cmp_id to 25 length
	@phrs10 varchar(30), 
	@phrs70 varchar(30)) 

as

SET NOCOUNT ON 

	DECLARE @drvid varchar(13), @msgdate datetime, @estavldttm datetime, @avlcmpid varchar(25),-- PTS 61189 enhance cmp_id to 25 length
	 @hrs10 float, @hrs70 float
	DECLARE @ErrText varchar(254), @avlcmpname varchar(254)

	if isnull(@pdrvid, '') = '' RETURN

	select @drvid = mpp_id from manpowerprofile (NOLOCK) where mpp_id = @pdrvid
	if isnull(@drvid, '') = ''
		BEGIN
		RAISERROR ('Unknown Driver ID: %s', 16, 1, @pdrvid)
		RETURN
		END

	if isnull(@pmsgdate, '') = ''
		SELECT @msgdate = getdate()
	else if isdate(@pmsgdate) <> 0 
		select @msgdate = CONVERT(datetime, @pmsgdate)
	else
		BEGIN
		RAISERROR ('Bad Message Date: %s', 16, 1, @pmsgdate)
		RETURN
		END

	if isnull(@pestavldate, '') = '' and isnull(@pestavltime, '') = ''
		select @estavldttm = NULL
	else
		BEGIN
		SELECT @ErrText = ''
		exec dbo.tmail_mergedatetime @pestavldate, @pestavltime, @estavldttm out, @msgDate, @ErrText OUT 
		if isnull(@ErrText, '') <> ''
			BEGIN	
			RAISERROR ('Bad Available Date (%s) or Time (%s): %s', 16, 1, @pestavldate, @pestavltime, @ErrText)
			RETURN
			END
		END

	if isnull(@pavlcmpid, '') = ''
		SELECT @avlcmpid = 'UNKNOWN'
	else
		BEGIN
		select @avlcmpid = cmp_id, @avlcmpname = cmp_name from company (NOLOCK) where cmp_id = @pavlcmpid
		if isnull(@avlcmpid, '') = ''
			BEGIN
			RAISERROR ('Bad Available Company ID: %s', 16, 1, @pavlcmpid)
			RETURN
			END
		END

	if isdate(@phrs10) <> 0
		select @hrs10 = datepart(hh, convert(datetime, @phrs10)) + (datepart(mi, convert(datetime, @phrs10))/60.)
	else if isnumeric(@phrs10) <> 0
		select @hrs10 = convert(float, @phrs10)
	else if isnull(@phrs10, '') = ''
		select @hrs10 = 0
	else
		BEGIN
		RAISERROR ('Bad Hrs 10 value: %s', 16, 1, @phrs10)
		RETURN
		END

	if isdate(@phrs70) <> 0
		select @hrs70 = datepart(hh, convert(datetime, @phrs70)) + (datepart(mi, convert(datetime, @phrs70))/60.)
	else if isnumeric(@phrs70) <> 0
		select @hrs70 = convert(float, @phrs70)
	else if isnull(@phrs70, '') = ''
		select @hrs70 = 0
	else
		BEGIN
		RAISERROR ('Bad Hrs 70 value: %s', 16, 1, @phrs70)
		RETURN
		END


	-- Validation is finally done, do the actual update!
	update manpowerprofile set mpp_dailyhrsest = @hrs10, mpp_weeklyhrsest = @hrs70, mpp_lastlog_cmp_id = @avlcmpid, mpp_lastlog_estdate = @estavldttm, mpp_lastlog_cmp_name = @avlcmpname, mpp_estlog_datetime = @msgdate where mpp_id = @drvid


GO
GRANT EXECUTE ON  [dbo].[tmail_update_estloghrs] TO [public]
GO
