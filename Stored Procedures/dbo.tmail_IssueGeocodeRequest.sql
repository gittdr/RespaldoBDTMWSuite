SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_IssueGeocodeRequest] 
	@TMFormId int, 
	@TMTruckName varchar(15), -- dummy truck for addressing geocode messages
	@cmp_id varchar(25)--PTS 61189 CMP_ID INCREASE LENGTH TO 25

AS


 EXEC dbo.tmail_IssueGeocodeRequest2 @TMFormId,
									 @TMTruckName,
									 @cmp_id, 
									 ''				-- StopNumber
		
GO
GRANT EXECUTE ON  [dbo].[tmail_IssueGeocodeRequest] TO [public]
GO
