SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SetExternalIDForTMFrmDef]
				@MCommTypeSN int, 
				@ExternalID varchar(30),
				@SelMCommSN int
AS
	DELETE FROM tblExternalIDs
		WHERE TmailObjType = 'FRMDEF'
		AND TMailObjSN = @SelMCommSN
		AND MCommTypeSN = @MCommTypeSN

	EXEC dbo.tm_SetExternalID   @MCommTypeSN, 
				@ExternalID,
				'FRMDEF',
				@SelMCommSN,
				NULL, 
				NULL,
				NULL
GO
GRANT EXECUTE ON  [dbo].[tm_SetExternalIDForTMFrmDef] TO [public]
GO
