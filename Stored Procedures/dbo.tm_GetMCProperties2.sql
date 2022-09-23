SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMCProperties2]	@sPropSN VARCHAR(12)
									,@sPropName VARCHAR(50)
									,@sMCSN VARCHAR(12)
									,@sMCCode VARCHAR(50)
									,@sResourceSN VARCHAR(12)
									,@sResourceName VARCHAR(50)
									,@sResourceType VARCHAR(12)
									,@sInstanceID VARCHAR(3)
									,@sPropType VARCHAR(25)
									,@sFilterValue varchar(50)
									,@sFlags varchar(12)

AS

SET NOCOUNT ON

DECLARE @lPropSN int,
		@lMCSN int,
		@lResourceSN int,
		@lResourceType int,
		@lMCPropSN int,
		@lInstanceID int,
		@lPropType int

IF ISNULL(@sPropSN, '') = '' AND ISNULL(@sPropName, '') = '' 
	BEGIN
	RAISERROR('Property SN or Name must be supplied', 16, 1)
	RETURN
	END

IF ISNULL(@sPropSN, '') > '' 
	IF ISNUMERIC(@sPropSN) = 0
		BEGIN
		RAISERROR('Property SN must be numeric: %s', 16, 1, @sPropSN)
		RETURN
		END

SET @lPropSN = CONVERT(int, @sPropSN)

IF ISNULL(@lPropSN, 0) = 0 AND ISNULL(@sPropName, '') > '' 
	SELECT @lPropSN = ISNULL(SN, 0) 
	FROM tblPropertyList (NOLOCK)
	WHERE Name = @sPropName

IF ISNULL(@lPropSN, 0) = 0 
	BEGIN
	RAISERROR('Property name not found in TotalMail: %s', 16, 1, @sPropName)
	RETURN
	END

IF NOT EXISTS (SELECT * FROM tblPropertyList WHERE SN = @lPropSN)
	BEGIN
	RAISERROR('Property not found in TotalMail: %d', 16, 1, @lPropSN)
	RETURN
	END



--make sure we have a property name
SELECT @sPropName = Name 
FROM tblPropertyList (NOLOCK)
WHERE SN = @lPropSN

IF ISNULL(@sMCSN, '') = '' AND ISNULL(@sMCCode, '') = '' 
	BEGIN
	RAISERROR('Mobile Communication SN or Name must be supplied', 16, 1)
	RETURN
	END

IF ISNULL(@sMCSN, '') > '' 
	IF ISNUMERIC(@sMCSN) = 0
		BEGIN
		RAISERROR('Mobile Communication SN must be numeric: %s', 16, 1, @sMCSN)
		RETURN
		END

SET @lMCSN = CONVERT(int, @sMCSN)

IF ISNULL(@lMCSN, 0) = 0 AND ISNULL(@sMCCode, '') > '' 
	SELECT @lMCSN = ISNULL(SN, 0) 
	FROM tblMobileCommType (NOLOCK)
	WHERE MobileCommType = @sMCCode

IF ISNULL(@lMCSN, 0) > 0 
	IF NOT EXISTS (SELECT * FROM tblMobileCommType WHERE SN = @lMCSN)
		BEGIN
		RAISERROR('Mobile Communication not found in TotalMail: %d', 16, 1, @lMCSN)
		RETURN
		END

--Make sure we have a MC name
SELECT @sMCCode = MobileCommType 
FROM tblMobileCommType (NOLOCK)
WHERE SN = @lMCSN

IF ISNULL(@sResourceSN, '') > '' OR ISNULL(@sResourceName, '') > '' --do Resource Lookup
	BEGIN

		IF ISNULL(@sResourceSN, '') > '' 
			IF ISNUMERIC(@sResourceSN) = 0
				BEGIN
				RAISERROR('Resource SN must be numeric: %s', 16, 1, @sMCSN)
				RETURN
				END

		SET @lResourceSN = CONVERT(int, @sResourceSN)

		IF ISNULL(@lResourceSN, 0) = 0 AND ISNULL(@sResourceName, '') > '' 
			BEGIN
				IF @sResourceType = 'T' 
					SELECT @lResourceSN = ISNULL(SN, 0) 
					FROM tblTrucks (NOLOCK)
					WHERE TruckName = @sResourceName
				ELSE IF @sResourceType = 'D'
					SELECT @lResourceSN = ISNULL(SN, 0) 
					FROM tblDrivers (NOLOCK)
					WHERE Name = @sResourceName
				ELSE
					BEGIN
					RAISERROR('Invalid resource Type %s', 16, 1, @sResourceType)
					RETURN
					END
			END

		IF ISNULL(@lResourceSN, 0) = 0 
			BEGIN
			RAISERROR('Resource not found in TotalMail: %s', 16, 1, @sResourceName)
			RETURN
			END

		SELECT @lResourceType = SN 
		FROM tblAddressTypes (NOLOCK) 
		WHERE AddressType = @sResourceType

		SELECT @lMCPropSN = SN 
		FROM tblResourcePropertiesMobileComm (NOLOCK)
		WHERE MCSN = @lMCSN AND PropSN = @lPropSN
		IF ISNULL(@lMCPropSN, 0) = 0 
			BEGIN
			RAISERROR('Property %s is not attached to TotalMail Mobile Communcation type %s', 16, 1, @sPropName, @sMCCode)
			RETURN
			END
		
		if @lResourceSN = -1 --ALL RESOURCES
			SELECT ISNULL(Value, (SELECT DefaultValue FROM tblPropertyList WHERE SN = @lPropSN)) Value, ResourceSN, ResourceType
				FROM tblResourceProperties (NOLOCK)
				WHERE	Value = case WHEN @sFilterValue = '' THEN Value ELSE @sFilterValue END
						AND ResourceType = @lResourceType
						AND PropMCSN = @lMCPropSN
		else
			SELECT ISNULL(Value, (SELECT DefaultValue FROM tblPropertyList WHERE SN = @lPropSN)) Value, ResourceSN, ResourceType
				FROM tblResourceProperties (NOLOCK)
				WHERE	ResourceSN = @lResourceSN 
						AND ResourceType = @lResourceType
						AND PropMCSN = @lMCPropSN

	END


ELSE  --do Value lookup
	BEGIN
		IF ISNULL(@sInstanceID, '') > ''
			SET @lInstanceID = CONVERT(int, @sInstanceID)
		IF ISNULL(@lInstanceID, 0) = 0 
			SET @lInstanceID = 1

		IF ISNULL(@sPropType,'') > ''
			BEGIN
				SELECT @lPropType = PropType 
				FROM tblPropertyList (NOLOCK)
				WHERE SN = @lPropSN		
			END
			
		IF @lPropType = 1 OR @lPropType IS NULL OR @lPropType = 0
			BEGIN
				SELECT ISNULL(Value, (SELECT DefaultValue FROM tblPropertyList WHERE SN = @lPropSN)) Value, MsgSN, GF_SN, Row, Col --PTS 55441
					FROM tblMCTypeProperties (NOLOCK)
					WHERE MCSN = @lMCSN 
							AND PropSN = @lPropSN 
							AND InstanceID = @lInstanceID
			END
		ELSE IF @lPropType > 1 AND @lPropType < 8
			BEGIN
			--Field props
				SELECT ISNULL(Value, (SELECT DefaultValue 
										FROM tblPropertyList (NOLOCK) 
										WHERE SN = @lPropSN)) Value, MsgSN, GF_SN, Row, Col --PTS 55441
					FROM tblMCTypeProperties (NOLOCK)
					INNER JOIN tblPropertyList (NOLOCK)
					ON tblPropertyList.SN = tblMCTypeProperties.PropSN
					WHERE MCSN = @lMCSN 
							AND PropSN = @lPropSN 
							AND PropType = @lPropType
			END

		ELSE IF NOT EXISTS (SELECT * 
							FROM tblPropertyList (NOLOCK) 
							WHERE PropType = @lPropType)
			BEGIN
			RAISERROR('Invalid PropType: %d', 16, 1, @lPropType)
			RETURN
			END

	END

GO
GRANT EXECUTE ON  [dbo].[tm_GetMCProperties2] TO [public]
GO
