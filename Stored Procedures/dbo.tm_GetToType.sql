SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetToType]	@ToText varchar(50) out,
					@ToType int out,
					@ReturnAmbiguousList int
AS

SET NOCOUNT ON

DECLARE @PatternIndex int, @MatchCount int, @LikeToText varchar(100)

SELECT @PatternIndex = PATINDEX('%@TotalMail', @ToText)
IF @PatternIndex <> 0 SELECT @ToText = LEFT(@ToText, @PatternIndex -1)
IF PATINDEX('%@%', @ToText) <> 0
	BEGIN
	SELECT @ToType = 2
	RETURN
	END

IF EXISTS (SELECT * 
			FROM tblAddressBook (NOLOCK)
			WHERE Name = @ToText)	-- First check the alias table
	BEGIN
	SELECT @ToType = 8
	RETURN
	END

SELECT @MatchCount= COUNT(*) 
FROM tblAddresses (NOLOCK)
WHERE AddressName = @ToText AND UseInResolve = 1

IF @MatchCount = 1
	BEGIN
		SELECT @ToText = AddressName, @ToType = AddressType 
		FROM tblAddresses (NOLOCK)
		WHERE AddressName = @ToText AND UseInResolve = 1
	RETURN
	END
IF @MatchCount > 1
	BEGIN
	IF @ReturnAmbiguousList <> 0
		BEGIN
			SELECT ad.AddressType, AddressName, AddresseeType = CASE WHEN ad.AddressType = 4 THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 THEN 'Truck' WHEN ISNULL(GroupFlag, -1) > 0 THEN 'Group' ELSE '<UNK>' END ELSE ty.Description END
			FROM tblAddresses ad (NOLOCK) 
			INNER JOIN tblAddressTypes ty (NOLOCK)ON ad.AddressType = ty.SN
			LEFT JOIN tblTrucks tr (NOLOCK) ON tr.TruckName = ad.AddressName
			WHERE AddressName = @ToText AND UseInResolve = 1
		END
	RETURN
	END

SELECT @MatchCount= COUNT(*) 
FROM tblAddresses (NOLOCK)
WHERE AddressName = @ToText

IF @MatchCount = 1
	BEGIN
		SELECT @ToText = AddressName, @ToType = AddressType 
		FROM tblAddresses (NOLOCK)
		WHERE AddressName = @ToText
	RETURN
	END
IF @MatchCount > 1
	BEGIN
	IF @ReturnAmbiguousList <> 0
		BEGIN
			SELECT ad.AddressType, AddressName, AddresseeType = CASE WHEN ad.AddressType = 4 THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 THEN 'Truck' WHEN ISNULL(GroupFlag, -1) > 0 THEN 'Group' ELSE '<UNK>' END ELSE ty.Description END
			FROM tblAddresses ad (NOLOCK)
			INNER JOIN tblAddressTypes ty (NOLOCK) ON ad.AddressType = ty.SN
			LEFT JOIN tblTrucks tr (NOLOCK) ON tr.TruckName = ad.AddressName
			WHERE AddressName = @ToText
		END
	RETURN
	END

SELECT @LikeToText = RTRIM(@ToText)
WHILE PATINDEX('  ', @LikeToText) <> 0
	SELECT @LikeToText = REPLACE(@LikeToText, '  ', ' ')
SELECT @LikeToText = REPLACE(@ToText, ' ', '% ') + '%'

SELECT @MatchCount= COUNT(*) 
FROM tblAddresses (NOLOCK)
WHERE AddressName Like @LikeToText AND UseInResolve = 1

IF @MatchCount = 1
	BEGIN
		SELECT @ToText = AddressName, @ToType = AddressType 
		FROM tblAddresses (NOLOCK)
		WHERE AddressName like @LikeToText AND UseInResolve = 1
	RETURN
	END
IF @MatchCount > 1
	BEGIN
	IF @ReturnAmbiguousList <> 0
		BEGIN
		SELECT ad.AddressType, AddressName, AddresseeType = CASE WHEN ad.AddressType = 4 THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 THEN 'Truck' WHEN ISNULL(GroupFlag, -1) > 0 THEN 'Group' ELSE '<UNK>' END ELSE ty.Description END
			FROM tblAddresses ad (NOLOCK)
			INNER JOIN tblAddressTypes ty (NOLOCK) ON ad.AddressType = ty.SN
			LEFT JOIN tblTrucks tr (NOLOCK) ON tr.TruckName = ad.AddressName
			WHERE AddressName like @LikeToText AND UseInResolve = 1
		END
	RETURN
	END


SELECT @MatchCount= COUNT(*) 
FROM tblAddresses (NOLOCK)
WHERE AddressName Like @LikeToText
IF @MatchCount = 1
	BEGIN
		SELECT @ToText = AddressName, @ToType = AddressType 
		FROM tblAddresses (NOLOCK)
		WHERE AddressName like @LikeToText
	RETURN
	END
IF @MatchCount > 1
	BEGIN
	IF @ReturnAmbiguousList <> 0
		BEGIN
			SELECT ad.AddressType, AddressName, AddresseeType = CASE WHEN ad.AddressType = 4 THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 THEN 'Truck' WHEN ISNULL(GroupFlag, -1) > 0 THEN 'Group' ELSE '<UNK>' END ELSE ty.Description END
			FROM tblAddresses ad (NOLOCK)
			INNER JOIN tblAddressTypes ty (NOLOCK) ON ad.AddressType = ty.SN
			LEFT JOIN tblTrucks tr (NOLOCK) ON tr.TruckName = ad.AddressName
			WHERE AddressName like @LikeToText
		END
	RETURN
	END
GO
GRANT EXECUTE ON  [dbo].[tm_GetToType] TO [public]
GO
