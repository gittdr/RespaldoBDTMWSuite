SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[HistoryDetail_Insert] 
(	
	@HistoryConfigurationId int,
	@HistoryDetailRecordTypeId int,
	@Artifact nvarchar(max),
	@ArtifactKey bigint,
	@UserName varchar(256)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @UserInformationId int
	DECLARE @ID table (ID int)
	SELECT @UserInformationId = HistoryUserInformationId FROM HistoryUserInformation WHERE UserName = @UserName
	IF @UserInformationId IS NULL
	BEGIN
			INSERT INTO HistoryUserInformation (UserName) OUTPUT INSERTED.HistoryUserInformationId INTO @ID VALUES (@UserName)
			SET @UserInformationId = (SELECT TOP 1 ID FROM @ID)
	END

	DECLARE @ReturnId table (ID int)
	INSERT INTO HistoryDetail (HistoryConfigurationId, HistoryDetailRecordTypeId, Artifact, ArtifactKey, CreatedByUserId, CreatedDate) 
	OUTPUT INSERTED.HistoryDetailId INTO @ReturnId VALUES (@HistoryConfigurationId, @HistoryDetailRecordTypeId, @Artifact, @ArtifactKey, @UserInformationId, GETDATE())

	-- Insert statements for procedure here
	SELECT TOP 1 ID FROM @ReturnId
END
GO
GRANT EXECUTE ON  [dbo].[HistoryDetail_Insert] TO [public]
GO
