SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tmail_parseequipinfo] (@EqpType char(3) OUT, @EqpID varchar(13) OUT, @Drv varchar(13), @Trc varchar(13), @ErrText varchar(254) = NULL OUT )
as

SET NOCOUNT ON 

	DECLARE @RetText varchar(254)
	SELECT @RetText = NULL
	IF ISNULL(@EqpType, '') = ''
		BEGIN
		IF ISNULL(@Drv, '') <> ''
			SELECT @EqpType = 'DRV'
		ELSE
			SELECT @EqpType = 'TRC'
		END
	IF @EqpType = 'TRC'
		BEGIN
		IF ISNULL(@EqpID, '') = '' SELECT @EqpID = @Trc
		IF NOT EXISTS (SELECT * 
						FROM tractorprofile (NOLOCK)
						WHERE trc_number = @EqpID)
			SELECT @RetText = '(TMWERROR:101)Unknown Tractor: ' + ISNULL(@EqpID, '(null)')
		END
	ELSE IF @EqpType = 'DRV'
		BEGIN
		IF ISNULL(@EqpID, '') = '' SELECT @EqpID = @Drv
		IF NOT EXISTS (SELECT * 
						FROM manpowerprofile (NOLOCK)
						WHERE mpp_id = @EqpID)
			SELECT @RetText = '(TMWERROR:102)Unknown Driver: ' + ISNULL(@EqpID, '(null)')
		END
	ELSE IF @EqpType = 'TRL'
		BEGIN
		IF NOT EXISTS (SELECT * 
						FROM trailerprofile (NOLOCK)
						WHERE trl_id = @EqpID)
			SELECT @RetText = '(TMWERROR:103)Unknown Trailer: ' + ISNULL(@EqpID, '(null)')
		END
	ELSE IF @EqpType = 'CAR'
		BEGIN
		IF NOT EXISTS (SELECT * 
						FROM carrier (NOLOCK)
						WHERE car_id = @EqpID)
			SELECT @RetText = '(TMWERROR:104)Unknown Carrier: ' + ISNULL(@EqpID, '(null)')
		END
	ELSE
		BEGIN
		SELECT @RetText = '(TMWERROR:105)Unknown Equipment Type: ' + ISNULL(@EqpType, '(null)')
		END
	IF (@ErrText IS NULL) AND NOT (@RetText IS NULL)
		RAISERROR ( '%s', 16, 1, @RetText )
	ELSE IF NOT (@RetText IS NULL)
		SELECT @ErrText = @RetText
		
GO
GRANT EXECUTE ON  [dbo].[tmail_parseequipinfo] TO [public]
GO
