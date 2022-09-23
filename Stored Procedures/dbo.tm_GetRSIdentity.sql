SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetRSIdentity] (
	@KeyCode	VARCHAR(10),	--** KeyCode of tblRS value to use as the basis of the identity.
	@ValueCount INT,			--** The number of values to reserve.  Treated as 1 if NULL or less than 1.
	@Flags 		INT,			--** Flag value to customize behavior.  Currently only flag defined is 1: Return resultset.
	@RetVal		INT OUT			--** The returned value, the first value of the reserved block.
	)
AS
	DECLARE @MatchCount int
	DECLARE @ErrWork int

SET NOCOUNT ON

	IF ISNULL(@ValueCount, 0) < 1
		SELECT @ValueCount = 1
	BEGIN TRANSACTION
	UPDATE tblRS with (holdlock) SET text = CONVERT(varchar(20), (CONVERT(int, text) + @ValueCount)) WHERE KeyCode = @KeyCode
	SELECT @ErrWork = @@ERROR, @MatchCount = @@ROWCOUNT
	IF @ErrWork <> 0 GOTO XactErr
	IF @MatchCount = 0
		BEGIN
		INSERT INTO tblRS (keycode, text, description, static)
		VALUES (@KeyCode, CONVERT(varchar(20), @ValueCount + 1), 'Autoinserted identity: ' + @keycode, 0)
		SELECT @ErrWork = @@ERROR
		IF @ErrWork <> 0 GOTO XactErr
		SELECT @RetVal = 1
		END
	ELSE
		BEGIN
		SELECT @RetVal = CONVERT(int, text) - @ValueCount 
		FROM tblRS (NOLOCK)
		WHERE KeyCode = @KeyCode
		SELECT @ErrWork = @@ERROR
		IF @ErrWork <> 0 GOTO XactErr
		END
	COMMIT TRANSACTION
	SELECT @ErrWork = @@ERROR
	IF @ErrWork <> 0 GOTO XactErr
	IF ( @Flags & 1 ) <> 0
		SELECT @RetVal ReturnedIdent
	RETURN

XactErr:
	ROLLBACK TRANSACTION
	SELECT @RetVal = -1
	RETURN
GO
GRANT EXECUTE ON  [dbo].[tm_GetRSIdentity] TO [public]
GO
