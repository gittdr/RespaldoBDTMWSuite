SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_FindExternalIdRecord] @MCommTypeSN int, 
				@ExternalID varchar(128),
				@CabUnitSN int,
				@InstanceID int
AS
DECLARE @OldestDate DateTime
SELECT @OldestDate = DATEADD(dd, -30, GETDATE())

IF ISNULL(@InstanceID, 0) < 1  
	SET @InstanceID = 1

IF ISNULL(@CabUnitSN, 0) < 1  
	SET @CabUnitSN = 0

-- Find matching record.
IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID and CabUnitSN = @CabUnitSN AND DateAndTime > @OldestDate)
	-- All match
	SELECT TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID and CabUnitSN = @CabUnitSN AND DateAndTime > @OldestDate
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID AND CabUnitSN = 0 AND DateAndTime > @OldestDate)
	-- No CabUnit, but Instance Matches
	SELECT TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID AND CabUnitSN = 0 AND DateAndTime > @OldestDate
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = 0 AND DateAndTime > @OldestDate)
	-- No CabUnit, but any Instance
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = 0 AND DateAndTime > @OldestDate ORDER BY DateAndTime DESC
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = @CabUnitSN AND DateAndTime > @OldestDate)
	-- CabUnit matches, instance ignored.
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = @CabUnitSN AND DateAndTime > @OldestDate ORDER BY DateAndTime DESC
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID AND DateAndTime > @OldestDate)
	-- Instance Matches, CabUnit ignored
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID AND DateAndTime > @OldestDate ORDER BY DateAndTime DESC
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND DateAndTime > @OldestDate)
	-- Any Instance, any cabunit
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND DateAndTime > @OldestDate ORDER BY DateAndTime DESC
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID and CabUnitSN = @CabUnitSN)
	-- All match
	SELECT TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID and CabUnitSN = @CabUnitSN
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID AND CabUnitSN = 0)
	-- No CabUnit, but Instance Matches
	SELECT TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID AND CabUnitSN = 0
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = 0)
	-- No CabUnit, but any Instance
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = 0 ORDER BY DateAndTime DESC
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = @CabUnitSN)
	-- CabUnit matches, instance ignored.
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND CabUnitSN = @CabUnitSN ORDER BY DateAndTime DESC
ELSE IF EXISTS (SELECT 1 FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID)
	-- Instance Matches, CabUnit ignored
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID AND InstanceID = @InstanceID ORDER BY DateAndTime DESC
ELSE 
	-- Any Instance, any cabunit
	SELECT TOP 1 TmailObjType, TMailObjSN, PageNum, CabUnitSN, DateAndTime FROM tblExternalIds WHERE MCommTypeSN = @MCommTypeSN AND ExternalID = @ExternalID ORDER BY DateAndTime DESC

GO
GRANT EXECUTE ON  [dbo].[tm_FindExternalIdRecord] TO [public]
GO
