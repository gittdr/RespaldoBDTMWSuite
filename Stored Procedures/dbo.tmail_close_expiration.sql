SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tmail_close_expiration] (@EqpType char(3), @EqpID varchar(13), @Drv varchar(13), @Trc varchar(13), @ReasonCode varchar(6), @ReturnDate varchar(30), @ReturnTime varchar(30))
as

SET NOCOUNT ON 

	DECLARE @ReturnDateTime datetime, @OutDateTime datetime
	DECLARE @ExpSysNum int, @TextDate varchar(30)
	
	EXEC dbo.tmail_parseequipinfo @EqpType OUT, @EqpID OUT, @Drv, @Trc
	IF @@Error <> 0 return
	
	EXEC dbo.tmail_mergedatetime @ReturnDate, @ReturnTime, @ReturnDateTime OUT
	
	IF @@Error <> 0 return
	IF ISNULL(@ReasonCode, '') = ''
		BEGIN
		SELECT @ReasonCode = MAX(exp_code) 
		FROM expiration (NOLOCK) 
		WHERE exp_idtype = @EqpType AND exp_id = @EqpID AND exp_expirationdate <= @ReturnDate AND ISNULL(exp_completed, 'N') = 'N'
		IF EXISTS (SELECT * 
					FROM expiration (NOLOCK) 
					WHERE exp_idtype = @EqpType AND exp_id = @EqpID AND exp_expirationdate <= @ReturnDate AND ISNULL(exp_completed, 'N') = 'N' AND exp_code <> @ReasonCode)
			RAISERROR ('(TMWERROR:110)Multiple open expirations present for %s:%s', 16, 1, @EqpType, @EqpID)
			RETURN
		END
	IF not exists (select * 
					from labelfile (NOLOCK)
					where labeldefinition = @EqpType + 'Status' and abbr = @ReasonCode)
		BEGIN
		RAISERROR ('(TMWERROR:100)Unknown %s expiration code: %s', 16, 1, @EqpType, @ReasonCode)
		RETURN
		END
	SELECT @OutDateTime = MAX(exp_expirationdate) 
	FROM expiration (NOLOCK)
	WHERE exp_idtype = @EqpType AND exp_id = @EqpID AND exp_expirationdate <= @ReturnDate AND ISNULL(exp_completed, 'N') = 'N' AND exp_code = @ReasonCode
	
	IF @OutDateTime IS NULL
		BEGIN
		SELECT @TextDate = ISNULL(CONVERT(varchar(30), @ReturnDateTime), '--')
		RAISERROR ('(TMWERROR:120)No open %s expirations found for %s:%s before %s', 16, 1, @ReasonCode, @EqpType, @EqpID, @TextDate)
		RETURN
		END
	UPDATE expiration 
	SET exp_lastdate = @ReturnDateTime, exp_completed = 'Y', exp_compldate = @ReturnDateTime, exp_updateby = 'TMAIL', exp_updateon = GETDATE()
	WHERE exp_idtype = @EqpType AND exp_id = @EqpID AND exp_expirationdate <= @ReturnDate AND ISNULL(exp_completed, 'N') = 'N' AND exp_code = @ReasonCode AND exp_expirationdate = @OutDateTime

	IF @EqpType = 'DRV' 
		EXEC dbo.drv_expstatus @EqpID
	else IF @EqpType = 'TRC' 
		EXEC dbo.trc_expstatus @EqpID
	else IF @EqpType = 'TRL' 
		EXEC dbo.trl_expstatus @EqpID
GO
GRANT EXECUTE ON  [dbo].[tmail_close_expiration] TO [public]
GO
