SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tmail_UpdFreightQtysByCmdCode] (@stopnumber varchar(30), @cmdcode varchar(30), @fgtvolume varchar(30), @fgtcount varchar(30)) 
as
	DECLARE @stpnum int, @newvol float, @newqty float, @UpdCount int
	if isnumeric(isnull(@stopnumber, '')) = 0
		BEGIN
		RAISERROR ('Bad Stop Number for update: %s', 16, 1, @stopnumber)
		RETURN
		END
	select @stpnum = CONVERT(int, @stopnumber), @cmdcode = isnull(@cmdcode, ''), @fgtvolume = isnull(@fgtvolume, ''), @fgtcount = isnull(@fgtcount, '')
	if @cmdcode = '' RETURN
	if isnumeric(@fgtvolume) = 0 or isnumeric(@fgtcount) = 0
		BEGIN
		RAISERROR ('Non numeric freight volume (%s) or quantity (%s) for update.', 16, 1, @fgtvolume, @fgtcount)
		RETURN
		END
	SELECT @newvol = CONVERT(float, @fgtvolume), @newqty = CONVERT(float, @fgtcount)
	SELECT @UpdCount = count(*) from freightdetail where stp_number = @stpnum AND cmd_code = @cmdcode
	IF @UpdCount < 1 
		BEGIN
		RAISERROR ('No freight details with commodity %s were found at stop %s.', 16, 1, @cmdcode, @stopnumber)
		RETURN
		END
	IF @UpdCount > 1 
		BEGIN
		RAISERROR ('More than one freight detail with commodity %s was found at stop %s.', 16, 1, @cmdcode, @stopnumber)
		RETURN
		END
	update freightdetail set fgt_volume = @newvol, fgt_count = @newqty where stp_number = @stpnum AND cmd_code = @cmdcode
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdFreightQtysByCmdCode] TO [public]
GO
