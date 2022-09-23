SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SendTotalMailMessage]
		@Recipients			VARCHAR(MAX),
		@FromName			VARCHAR(50), 
		@FromType			INT, 
		@Subject			VARCHAR(255), 
		@MsgText			VARCHAR(4000), 
		@Priority			INT = NULL,
		@Error				BIT = NULL
AS

DECLARE @LoginID			VARCHAR(25),
		@Pos				INT,
		@ASCII				INT,
		@Part				NVARCHAR(MAX),
		@EIND				INT,
		@MessageSN			INT
		
SET @Pos = CHARINDEX(',',@Recipients)

WHILE(@Pos != LEN(@Recipients) AND LEN(@Recipients) > 0)
BEGIN

	IF @Pos = 0
    BEGIN
		SET @Pos = LEN(@Recipients) + 1
    END

	-- GET THE NEXT NAME
	SET @LoginID = ISNULL(SUBSTRING(@Recipients, 0, @Pos), '')
	
	-- NO MORE NAMES
	IF @LoginID = ''
	BEGIN
		BREAK
	END
	
	-- REMOVE THE LOGIN NAME FROM THE LIST
	SET @Recipients = ISNULL(SUBSTRING(@Recipients, @Pos+1, LEN(@Recipients)-1), '')
	
	-- MOVE THE POSITION TO THE NEXT COMMA	
	SET @Pos = CHARINDEX(',',@Recipients)
	
	INSERT INTO 
	tblMessages
	(
		Type, 
		Status, 
		Priority, 
		FromType, 
		DTSent, 
		DTReceived, 
		Folder,
		Contents, 
		FromName, 
		Subject, 
		DeliverTo
	)
	SELECT 
		1, 
		1,
		4, 
		1, 
		GETDATE(), 
		GETDATE(), 
		(tblFolders.SN + 1), 
		@MsgText, 
		@FromName, 
		@Subject, 
		@LoginID
	FROM 
		tblMsgStatus (NOLOCK), 
		tblFolders (NOLOCK)
	WHERE 
		Code = 'ACK' 
		AND 
		Name = @LoginID


	SELECT @MessageSN = SCOPE_IDENTITY()

	IF ISNULL(@MessageSN, -1) < 0 OR ISNULL(@Error, 0) = 0
	BEGIN
		RETURN
	END
	ELSE
	BEGIN
		EXEC dbo.tm_AddErrorToMessage @MessageSN, 0, @MsgText, @Subject, 1
	END
END
GO
GRANT EXECUTE ON  [dbo].[tm_SendTotalMailMessage] TO [public]
GO
