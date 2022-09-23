SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_update_mppfields3]( 
	@pdrvid varchar(13),
	@pmsgdatetime varchar(30), 
	@pestavldate varchar(30), 
	@pestavltime varchar(30), 
	@pavlcmpid varchar(25), 	-- PTS 61189 enhance cmp_id to 25 length
	@phrs10 varchar(30),		/* hrs available field, conventionally daily hrs. */
	@phrs70 varchar(30),		/* hrs available field, conventionally weekly hrs. */
	@pptadate varchar(30),
	@pptatime varchar(30),
	@phomedate varchar(30),
	@phometime varchar(30),
	@pServiceRule varchar(6)

	)
as

SET NOCOUNT ON 

DECLARE @drvid varchar(13), @msgdate datetime, @estavldttm datetime, @avlcmpid varchar(25), -- PTS 61189 enhance cmp_id to 25 length
@hrs10 float, @hrs70 float
DECLARE @ErrText varchar(254), @avlcmpname varchar(254)
DECLARE @ptadttm datetime
DECLARE @homedttm datetime
DECLARE @ServiceRule varchar(6)

if isnull(@pdrvid, '') = '' RETURN

select @drvid = mpp_id from manpowerprofile (NOLOCK) where mpp_id = @pdrvid
if isnull(@drvid, '') = ''
	BEGIN
	RAISERROR ('Unknown Driver ID: %s', 16, 1, @pdrvid)
	RETURN
	END

if isnull(@pmsgdatetime, '') = ''
	SELECT @msgdate = getdate()
else if isdate(@pmsgdatetime) <> 0 
	select @msgdate = CONVERT(datetime, @pmsgdatetime)
else
	BEGIN
	RAISERROR ('Bad Message Date: %s', 16, 1, @pmsgdatetime)
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
	SELECT @avlcmpid = NULL
else
	BEGIN
	select @avlcmpid = cmp_id, @avlcmpname = cmp_name from company (NOLOCK) where cmp_id = @pavlcmpid
	if isnull(@avlcmpid, '') = ''
		BEGIN
		RAISERROR ('Bad Available Company ID: %s', 16, 1, @pavlcmpid)
		RETURN
		END
	END

if isnull(@pServiceRule, '') = ''
	SELECT @ServiceRule = NULL
else
	BEGIN
	select @ServiceRule = abbr from labelfile (NOLOCK) where abbr = @pServiceRule and labeldefinition = 'ServiceRule'
	if isnull(@ServiceRule, '') = ''
		BEGIN
		RAISERROR ('Bad Service Rule: %s', 16, 1, @pServiceRule)
		RETURN
		END
	END


if isdate(@phrs10) <> 0
	select @hrs10 = datepart(hh, convert(datetime, @phrs10)) + (datepart(mi, convert(datetime, @phrs10))/60.)
else if isnumeric(@phrs10) <> 0
	select @hrs10 = convert(float, @phrs10)
else if isnull(@phrs10, '') = ''
	select @hrs10 = NULL
else
	BEGIN
	RAISERROR ('Bad Hrs 10 value: %s', 16, 1, @phrs10)
	RETURN
	END

if isdate(@phrs70) <> 0
	select @hrs70 = datepart(hh, convert(datetime, @phrs10)) + (datepart(mi, convert(datetime, @phrs70))/60.)
else if isnumeric(@phrs70) <> 0
	select @hrs70 = convert(float, @phrs70)
else if isnull(@phrs70, '') = ''
	select @hrs70 = NULL
else
	BEGIN
	RAISERROR ('Bad Hrs 70 value: %s', 16, 1, @phrs70)
	RETURN
	END


update manpowerprofile set mpp_dailyhrsest = ISNULL(@hrs10,mpp_dailyhrsest), mpp_weeklyhrsest = ISNULL(@hrs70,mpp_weeklyhrsest), 
mpp_lastlog_cmp_id = ISNULL(@avlcmpid,mpp_lastlog_cmp_id), mpp_lastlog_estdate = ISNULL(@estavldttm,mpp_lastlog_estdate), 
mpp_lastlog_cmp_name = ISNULL(@avlcmpname,mpp_lastlog_cmp_name), mpp_estlog_datetime = @msgdate where mpp_id = @drvid

-----------------------
--Service Rule Update--
-----------------------
IF ISNULL(@ServiceRule,'') <> ''
	UPDATE manpowerprofile 
		SET mpp_servicerule = ISNULL(@ServiceRule,mpp_servicerule)
		WHERE  mpp_id = @drvid

--------------
--PTA Update--
--------------
set @ptadttm = NULL

if isnull(@pptadate, '') = '' and isnull(@pptatime, '') = ''
BEGIN
	select @pptadate = NULL
	select @pptatime = NULL
END
else
	BEGIN
	SELECT @ErrText = ''
	exec dbo.tmail_mergedatetime @pptadate, @pptatime, @ptadttm out, @msgDate, @ErrText OUT 
	if isnull(@ErrText, '') <> ''
		BEGIN
		RAISERROR ('Bad PTA Date (%s) or Time (%s): %s', 16, 1, @pptadate, @pptatime, @ErrText)
		RETURN
		END
	END

update manpowerprofile 
set mpp_pta_date = ISNULL(@ptadttm,mpp_pta_date)
where  mpp_id = @drvid

--------------------
--Want Home Update--
--------------------
SET @homedttm = NULL

if isnull(@phomedate, '') = '' and isnull(@phometime, '') = ''
BEGIN
	select @phomedate = NULL
	select @phometime = NULL
END
else
	BEGIN
	SELECT @ErrText = ''
	exec dbo.tmail_mergedatetime @phomedate, @phometime, @homedttm out, @msgDate, @ErrText OUT 
	if isnull(@ErrText, '') <> ''
		BEGIN
		RAISERROR ('Bad Home Date (%s) or Time (%s): %s', 16, 1, @phomedate, @phometime, @ErrText)
		RETURN
		END
	END

update manpowerprofile 
set mpp_want_home = ISNULL(@homedttm,mpp_want_home)
where  mpp_id = @drvid

GO
GRANT EXECUTE ON  [dbo].[tmail_update_mppfields3] TO [public]
GO
