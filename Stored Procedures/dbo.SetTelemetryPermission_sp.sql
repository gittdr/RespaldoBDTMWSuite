SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SetTelemetryPermission_sp] 
	@userId varchar(50),
	@permission bit
AS
BEGIN
	SET NOCOUNT ON;
	declare @id int
	set @id = (Select TOP 1 ID From TelemetryPermission ORDER BY ID DESC)
	update TelemetryPermission set UserId=@userId,Permission=@permission,Prompted=1,TimeStamp=GETDATE() where ID=@id

END
GO
GRANT EXECUTE ON  [dbo].[SetTelemetryPermission_sp] TO [public]
GO
