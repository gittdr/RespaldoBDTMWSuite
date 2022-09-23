SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SetExternalIDForTMGrpChg]
				@MCommTypeSN int, 
				@ExternalID varchar(30),
				@GrpChgSN int
AS
	DELETE FROM tblExternalIDs
		WHERE TmailObjType = 'GRPCHG'
		AND TMailObjSN = @GrpChgSN
		AND MCommTypeSN = @MCommTypeSN

	EXEC dbo.tm_SetExternalID   @MCommTypeSN, 
				@ExternalID,
				'GRPCHG',
				@GrpChgSN,
				NULL, 
				NULL,
				NULL
GO
GRANT EXECUTE ON  [dbo].[tm_SetExternalIDForTMGrpChg] TO [public]
GO
