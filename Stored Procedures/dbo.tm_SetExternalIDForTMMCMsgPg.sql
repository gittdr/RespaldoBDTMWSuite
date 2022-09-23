SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SetExternalIDForTMMCMsgPg] 
				@MCommTypeSN int, 
				@ExternalID varchar(30),
				@OrigMsgSN int,
				@PageNum int, 
				@CabUnitSN int
AS
	IF ISNULL(@CabUnitSN, 0) = 0
		DELETE FROM tblExternalIDs
			WHERE TmailObjType = 'MSG'
			AND MCommTypeSN = @MCommTypeSN
			AND TMailObjSN = @OrigMsgSN
			AND PageNum = @PageNum
	ELSE
		DELETE FROM tblExternalIDs
			WHERE TmailObjType = 'MSG'
			AND TMailObjSN = @OrigMsgSN
			AND PageNum = @PageNum
			AND CabUnitSN = @CabUnitSN

	EXEC dbo.tm_SetExternalID   @MCommTypeSN, 
				@ExternalID,
				'MSG',
				@OrigMsgSN,
				@PageNum, 
				@CabUnitSN,
				NULL
GO
GRANT EXECUTE ON  [dbo].[tm_SetExternalIDForTMMCMsgPg] TO [public]
GO
