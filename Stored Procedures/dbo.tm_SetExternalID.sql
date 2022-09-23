SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SetExternalID] @MCommTypeSN int, 
				@ExternalID varchar(128),
				@TmailObjType varchar(6),
				@TMailObjSN int,
				@PageNum int, 
				@CabUnitSN int,
				@MAPIAddressee varchar(50)
AS

/* 09/26/11 DWG PTS 56125 - Added @TMailObjSN to fix backwards compatible call. */

EXEC tm_SetExternalID2 @MCommTypeSN, @ExternalID, @TmailObjType, @TMailObjSN, @PageNum, @CabUnitSN, @MAPIAddressee, 1

GO
GRANT EXECUTE ON  [dbo].[tm_SetExternalID] TO [public]
GO
