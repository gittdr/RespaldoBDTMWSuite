SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ResNowFindStep](@GETDATE_Start datetime OUTPUT, @stepIdxCur int OUTPUT, @MaxTimeMilliseconds int OUTPUT, @stepIdxMax int OUTPUT)
AS
	IF DATEDIFF(ms, @GETDATE_Start, GETDATE()) > @MaxTimeMilliseconds 
	BEGIN
		SET @MaxTimeMilliseconds = DATEDIFF(ms, @GETDATE_Start, GETDATE())
		SET @stepIdxMax = @stepIdxCur
	END

	SET @stepIdxCur = @stepIdxCur + 1
	SET @GETDATE_Start = GETDATE()
GO
GRANT EXECUTE ON  [dbo].[ResNowFindStep] TO [public]
GO
