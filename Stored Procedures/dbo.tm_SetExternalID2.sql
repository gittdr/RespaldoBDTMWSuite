SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SetExternalID2] @MCommTypeSN int, 
				@ExternalID varchar(128),
				@TmailObjType varchar(6),
				@TMailObjSN int,
				@PageNum int, 
				@CabUnitSN int,
				@MAPIAddressee varchar(50),
				@InstanceID int
AS

IF ISNULL(@InstanceID, 0) < 1  
	SET @InstanceID = 1

IF ISNULL(@CabUnitSN, 0) < 1
	SET @CabUnitSN = 0

-- Clean up any preexisting (assumed outdated) entry with the same ExternalID for this MCommType.
DELETE FROM tblExternalIDs 
	WHERE MCommTypeSN = @MCommTypeSN
	AND ExternalID = @ExternalID
	AND InstanceID = @InstanceID
	AND CabUnitSN = @CabUnitSN

INSERT INTO tblExternalIDs 
	(MCommTypeSN, ExternalID, TmailObjType, TMailObjSN,
	PageNum, CabUnitSN, MAPIAddressee, DateAndTime, InstanceID)
	VALUES
	(@MCommTypeSN, @ExternalID, @TmailObjType, @TMailObjSN,
	@PageNum, @CabUnitSN, @MAPIAddressee, GetDate(), @InstanceID)

GO
GRANT EXECUTE ON  [dbo].[tm_SetExternalID2] TO [public]
GO
