SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_create_expiration4] (@EqpType char(3), @EqpID varchar(13), @Drv varchar(13), @Trc varchar(13), @ReasonCode varchar(6), @RETURNDate varchar(30), @RETURNTime varchar(30), @OutDate varchar(30), @OutTime varchar(30), 
@Description varchar(255), @Priority varchar(6), @city varchar(18), @state varchar(6), 
@pRouteTo varchar(25))--PTS 61189 INCREASE LENGTH TO 25

as
	DECLARE @RETURNDateTime datetime, @OutDateTime datetime
	DECLARE @CityCode int
	DECLARE @CityState varchar(25)
	DECLARE @ExpKey int
	DECLARE @RouteTo varchar(12)

	SET @CityCode = 0
	SET @CityState = @City + ', ' + @State

	EXEC dbo.tmail_parseequipinfo @EqpType OUT, @EqpID OUT, @Drv, @Trc
	IF @@Error <> 0 RETURN
	EXEC dbo.tmail_mergedatetime @RETURNDate, @RETURNTime, @RETURNDateTime OUT
	IF @@Error <> 0 RETURN
	EXEC dbo.tmail_mergedatetime @OutDate, @OutTime, @OutDateTime OUT
	IF @@Error <> 0 RETURN
	IF not exists (SELECT * 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = @EqpType + 'Status' and abbr = @ReasonCode)
		BEGIN
		RAISERROR ('(TMWERROR:100)Unknown %s expiration code: %s', 16, 1, @EqpType, @ReasonCode)
		RETURN
		END
	IF ISNULL(@Priority, '') = '' SELECT @Priority = '1'
	SELECT @Description = ISNULL(@Description, '')
	
	IF ISNULL(@City,'')<>'' AND ISNULL(@State,'')<>''
	BEGIN
		IF NOT EXISTS (SELECT top 1 ISNULL(cty_code,-1)
							FROM City (NOLOCK)
							WHERE @City = cty_name
								AND @State = cty_state
						)
		BEGIN
			SET @CityCode = -1
		END
		ELSE
		BEGIN
			SET  @CityCode = (	SELECT top 1 ISNULL(cty_code,-1)
								FROM City (NOLOCK)
								WHERE @City = cty_name
									AND @State = cty_state
							)
		END
		
	END
	ELSE
	BEGIN
		SELECT @CityCode = 0
	END

	IF @CityCode = -1
	BEGIN
		SET @CityCode = 0
		RAISERROR ('WARNING:  Invalid City or State entered.', 16, 1)
	END

	IF ISNULL(@pRouteTo,'')=''
		SET @pRouteTo = 'UNKNOWN'

	IF NOT EXISTS (SELECT NULL 
					FROM company (NOLOCK)
					WHERE cmp_id = @pRouteTo)
		BEGIN
		RAISERROR ('(TMWERROR:101)Unknown company code: %s', 16, 1, @pRouteTo)
		RETURN
		END
	ELSE
		SET @RouteTo = ISNULL(@pRouteTo,'UNKNOWN')

	SELECT @Description = @Description + ' ' + @City + ' ' + @State

	INSERT INTO expiration (exp_idtype, exp_id, exp_code, exp_lastdate, exp_expirationdate, exp_routeto, 
	exp_completed, exp_priority, exp_compldate, exp_UPDATEby, exp_creatdate, exp_UPDATEon, exp_description, exp_city)
	values (@EqpType, @EqpID, @ReasonCode, '20491231 23:59', @OutDateTime, @RouteTo, 'N', @Priority, @RETURNDateTime, 'TMAIL', GETDATE(), GETDATE(), @Description, @CityCode)

	SELECT @ExpKey = @@identity

	IF @EqpType = 'DRV' 
		EXEC dbo.drv_expstatus @EqpID
	else IF @EqpType = 'TRC' 
		EXEC dbo.trc_expstatus @EqpID
	else IF @EqpType = 'TRL' 
		EXEC dbo.trl_expstatus @EqpID

	SELECT @ExpKey ExpKey
	
GO
GRANT EXECUTE ON  [dbo].[tmail_create_expiration4] TO [public]
GO
