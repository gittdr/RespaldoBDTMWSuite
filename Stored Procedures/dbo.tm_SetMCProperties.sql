SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SetMCProperties]	--@sPropSN VARCHAR(12)
									/*,*/
									 @sPropName VARCHAR(50)
									,@sMCSN VARCHAR(12)
									,@sMCCode VARCHAR(50)
									,@sResourceSN VARCHAR(12)
									,@sResourceName VARCHAR(50)
									,@sResourceType VARCHAR(2)
									,@sInstanceID VARCHAR(3)
									,@sValue VARCHAR(255)
									,@sPropType VARCHAR(12)
									,@sFieldSN VARCHAR(10)
									,@sFormSN VARCHAR(10)
									,@sMsgSN VARCHAR(10)
									,@sGeofenceSN VARCHAR(10)
									
AS

SET NOCOUNT ON 

DECLARE @lPropSN int,
		@lMCSN int,
		@lResourceSN int,
		@lResourceType int,
		@lPropMCSN int,
		@lInstanceID int,
		@lPropType int,
		@sDataType VARCHAR(12),
		@sRange1 VARCHAR(12),
		@sRange2 VARCHAR(12),
		@lFieldSN INT,
		@lFormSN INT,
		@lMsgSN INT,
		@lGeofenceSN INT
		

IF ISNULL(@sPropName, '') = '' 
	BEGIN
		RAISERROR('Property Name must be supplied', 16, 1)
		RETURN
	END

IF ISNULL(@sPropType, '') = '' 
	BEGIN
		RAISERROR('Property Type must be supplied ', 16, 1)
		RETURN
	END

IF ISNULL(@sPropType,'') > ''
SET @lPropType = CONVERT(INT,@sPropType)

IF ISNULL(@sValue, '') = '' 
	BEGIN
		RAISERROR('A value must be supplied', 16, 1)
		RETURN
	END

IF ISNULL(@sFieldSN, '') > ''
SET @lFieldSN = CONVERT(INT, @sFieldSN)

IF ISNULL(@sFormSN, '') > ''
SET @lFormSN = CONVERT(INT, @sFormSN)

IF ISNULL(@lMsgSN, '') > ''
SET @lMsgSN = CONVERT(INT, @sMsgSN)

IF ISNULL(@lGeofenceSN, '') > ''
SET @lGeofenceSN = CONVERT(INT, @sGeofenceSN)

IF ISNULL(@sPropName, '') > '' 
	SELECT @lPropSN = ISNULL(SN, 0) 
	FROM tblPropertyList (NOLOCK) 
	WHERE Name = @sPropName


IF NOT EXISTS (SELECT * 
				FROM tblPropertyList (NOLOCK) 
				WHERE SN = @lPropSN)
	BEGIN
		RAISERROR('Property not found in TotalMail: %d', 16, 1, @lPropSN)
		RETURN
	END


--****************************VALUE VALIDATION**********************************************
SELECT @sDatatype = ISNULL(Datatype,'') 
FROM tblPropertyList (NOLOCK) 
WHERE SN = @lPropSN

SELECT @sRange1 = ISNULL(Range1,'') 
FROM tblPropertyList (NOLOCK)
WHERE SN = @lPropSN

SELECT @sRange2 = ISNULL(Range2,'') 
FROM tblPropertyList (NOLOCK) 
WHERE SN = @lPropSN

IF @sDatatype = 'STRING'
BEGIN				
	IF @sRange1 > ''
	BEGIN
		IF @sValue < @sRange1
		BEGIN
			RAISERROR('Value is less than lower range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END

	IF @sRange2 > ''
	BEGIN
		IF @sValue > @sRange2
		BEGIN
			RAISERROR('Value exceeds upper range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END
	IF @sRange1 > '' AND @sRange2 > ''
	BEGIN
		IF @sRange1 > @sRange2
		BEGIN
			RAISERROR('Range1 exceeds value of Range2: %s', 16, 1, @sRange2)
			RETURN
		END			
	END					
END
IF @sDatatype = 'INT'
BEGIN				
	IF ISNUMERIC(@sValue) = 0
	BEGIN
		RAISERROR('Values for this property must be numeric: %s', 16, 1, @sValue)
		RETURN
	END

	IF @sRange1 > ''
	BEGIN
		IF ISNUMERIC(@sRange1) = 0
		BEGIN
			RAISERROR('Range1 must be an integer: %s', 16, 1, @sRange1)
			RETURN
		END

		IF CONVERT(INT,@sValue) < CONVERT(INT,@sRange1)
		BEGIN
			RAISERROR('Value is less than lower range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END

	IF @sRange2 > ''
	BEGIN
		IF ISNUMERIC(@sRange2) = 0
		BEGIN
			RAISERROR('Range2 must be an integer: %s', 16, 1, @sRange2)
			RETURN
		END

		IF CONVERT(INT,@sValue) > CONVERT(INT,@sRange2)
		BEGIN
			RAISERROR('Value exceeds upper range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END
	IF @sRange1 > '' AND @sRange2 > ''
	BEGIN
		IF CONVERT(INT,@sRange1) > CONVERT(INT,@sRange2)
		BEGIN
			RAISERROR('Range1 exceeds value of Range2: %s', 16, 1, @sRange1)
			RETURN
		END			
	END
END
IF @sDatatype = 'REAL'
BEGIN				
	IF ISNUMERIC(@sValue) = 0
	BEGIN
		RAISERROR('Values for this property must be numeric: %s', 16, 1, @sValue)
		RETURN
	END

	IF @sRange1 > ''
	BEGIN
		IF CONVERT(REAL,@sValue) < CONVERT(REAL,@sRange1)
		BEGIN
			RAISERROR('Value is less than lower range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END

	IF @sRange2 > ''
	BEGIN
		IF CONVERT(REAL,@sValue) > CONVERT(REAL,@sRange2)
		BEGIN
			RAISERROR('Value exceeds upper range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END
	IF @sRange1 > '' AND @sRange2 > ''
	BEGIN
		IF CONVERT(REAL,@sRange1) > CONVERT(REAL,@sRange2)
		BEGIN
			RAISERROR('Range1 exceeds value of Range2: %s', 16, 1, @sRange1)
			RETURN
		END			
	END
END
IF @sDatatype = 'DATE' OR @sDatatype = 'NEAR DATE' OR @sDatatype = 'DATETIME' OR @sDataType = 'TIME'
BEGIN
	IF ISDATE(@sValue) = 0
		BEGIN
			RAISERROR('Values for this property must be dates: %s', 16, 1, @sValue)
			RETURN
		END

	IF @sRange1 > ''
	BEGIN
		IF ISDATE(@sRange1) = 0
		BEGIN
			RAISERROR('Range1 must be a date: %s', 16, 1, @sRange1)
			RETURN
		END
		
		IF CONVERT(DATETIME,@sValue) < CONVERT(DATETIME,@sRange1)
		BEGIN
			RAISERROR('Value is less than lower range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END

	IF @sRange2 > ''
	BEGIN
		IF ISDATE(@sRange2) = 0
		BEGIN
			RAISERROR('Range2 must be a date: %s', 16, 1, @sRange2)
			RETURN
		END

		IF CONVERT(DATETIME,@sValue) > CONVERT(DATETIME,@sRange2)
		BEGIN
			RAISERROR('Value exceeds upper range limit: %s', 16, 1, @sValue)
			RETURN
		END
	END
	IF @sRange1 > '' AND @sRange2 > ''
	BEGIN
		IF CONVERT(DATETIME,@sRange1) > CONVERT(DATETIME,@sRange2)
		BEGIN
			RAISERROR('Range1 exceeds value of Range2: %s', 16, 1, @sRange1)
			RETURN
		END			
	END
	IF @sDatatype = 'NEAR DATE' AND @sRange1 = '' AND @sRange2 = ''
		BEGIN
			RAISERROR('Near Date must have at least one range value: ', 16, 1, @sValue)
			RETURN
		END			
END
IF @sDatatype = 'BOOLEAN'
BEGIN
	IF UPPER(@sValue) != 'T' AND UPPER(@sValue) != 'F' AND UPPER(@sValue) != 'TRUE' AND UPPER(@sValue) != 'FALSE'
	BEGIN
		RAISERROR('Values for properties of Boolean data type must be T,F,True, or False: ', 16, 1)
		RETURN		
	END
END
--****************************END VALUE VALIDATION*******************************************


--make sure we have a property name
--SELECT @sPropName = Name FROM tblPropertyList WHERE SN = @lPropSN

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
	IF NOT EXISTS (SELECT * 
					FROM tblMobileCommType (NOLOCK) 
					WHERE SN = @lMCSN)
	BEGIN
		RAISERROR('Mobile Communication not found in TotalMail: %d', 16, 1, @lMCSN)
		RETURN
	END

--Make sure we have a MC name
SELECT @sMCCode = MobileCommType 
FROM tblMobileCommType (NOLOCK) 
WHERE SN = @lMCSN

--Handle General MCSN and MC Code
IF ISNULL(@sMCCode,'') = 'General'
SET @lMCSN = 0

IF @lMCSN = 0
SET @sMCCode = 'General'


IF ISNULL(@sResourceSN, '') > '' OR ISNULL(@sResourceName, '') > '' --ADD RESOURCE PROPS
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

		IF ISNULL(@sResourceType,'') > ''	
		BEGIN
			IF ISNUMERIC(@sResourcetype) = 0
				BEGIN
					SELECT @lResourceType = SN 
					FROM tblAddressTypes (NOLOCK)
					WHERE AddressType = @sResourceType			
				END
			ELSE
				BEGIN
					SELECT @lResourceType = CONVERT(INT, @sResourceType)
				END
		END

		--Add the value for the resource property
		IF NOT EXISTS(SELECT * 
						FROM tblResourcePropertiesMobileComm (NOLOCK) 
						WHERE PropSN = @lPropSN AND MCSN = @lMCSN)
			BEGIN
				INSERT INTO tblResourcePropertiesMobileComm(MCSN,PropSN) VALUES(@lMCSN,@lPropSN)
			END		

		IF EXISTS(SELECT * 
					FROM tblResourceProperties (NOLOCK) 
					WHERE (ResourceSN = @lResourceSN AND ResourceType = @lResourceType) AND PropMCSN 
					IN (SELECT SN 
						FROM tblResourcePropertiesMobileComm (NOLOCK)
						WHERE MCSN = @lMCSN AND PropSN = @lPropSN)) AND ISNULL(@sValue, '') > ''
			BEGIN
				SELECT @lPropMCSN = (SELECT DISTINCT SN 
					FROM tblResourcePropertiesMobileComm (NOLOCK)
					WHERE PropSN = @lPropSN AND MCSN = @lMCSN)
				UPDATE tblResourceProperties
				SET Value = @sValue
				WHERE PropMCSN = @lPropMCSN AND ResourceSN = @lResourceSN AND ResourceType = @lResourceType 
						AND (SELECT PropType 
								FROM tblPropertyList (NOLOCK)
								WHERE SN = @lPropSN) = ISNULL(@lPropType,2)
			END		
		ELSE
			BEGIN
				SELECT @lPropMCSN = (SELECT DISTINCT SN 
										FROM tblResourcePropertiesMobileComm (NOLOCK)
										WHERE PropSN = @lPropSN AND MCSN = @lMCSN)
				IF NOT (@lResourceType IS NULL) AND NOT (@lResourceSN IS NULL) AND NOT (@lPropMCSN IS NULL)
					INSERT INTO tblResourceProperties(ResourceSN,ResourceType,Value,PropMCSN) VALUES (@lResourceSN, @lResourceType,ISNULL(@sValue,''), @lPropMCSN)
				ELSE			
					RAISERROR('Property can not be added to TotalMail ', 16, 1)
					RETURN
			END				

	END

ELSE IF ISNULL(@sFieldSN,'') > '' --Field properties
	BEGIN
		
		IF EXISTS(SELECT * 
					FROM tblMCTypeProperties (NOLOCK)
					WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND FieldSN = @lFieldSN) AND ISNULL(@sValue, '') > ''
			BEGIN
				UPDATE tblMCTypeProperties
				SET Value = @sValue
				WHERE MCSN = @lMCSN 
					AND PropSN = @lPropSN 
					AND FieldSN = @lFieldSN
					AND (SELECT PropType FROM tblPropertyList WHERE SN = @lPropSN) = ISNULL(@lPropType,3)
			END
		ELSE
			BEGIN
				RAISERROR('Property not found in TotalMail ', 16, 1)
				RETURN
			END				
	END
ELSE IF ISNULL(@sFormSN,'') > '' --Form properties
	BEGIN
		IF EXISTS(SELECT * 
					FROM tblMCTypeProperties (NOLOCK) 
					WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND FormSN = @lFormSN) AND ISNULL(@sValue, '') > ''
			BEGIN
				UPDATE tblMCTypeProperties
				SET Value = @sValue
				WHERE MCSN = @lMCSN 
					AND PropSN = @lPropSN 
					AND FormSN = @lFormSN
					AND (SELECT PropType FROM tblPropertyList WHERE SN = @lPropSN) = ISNULL(@lPropType,4)
			END
		ELSE
			BEGIN
				RAISERROR('Property not found in TotalMail ', 16, 1)
				RETURN
			END				
	END

ELSE IF ISNULL(@sMsgSN,'') > '' --Message properties
	BEGIN

		--Message Form Props
		IF EXISTS(SELECT * 
					FROM tblMCTypeProperties (NOLOCK) 
					WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND MsgSN = @lMsgSN 
					AND (SELECT PropType 
							FROM tblPropertyList (NOLOCK) 
							WHERE SN = @lPropSN) = ISNULL(@lPropType,5)) AND ISNULL(@sValue, '') > ''
			BEGIN
				UPDATE tblMCTypeProperties
				SET Value = @sValue
				WHERE MCSN = @lMCSN 
					AND PropSN = @lPropSN 
					AND MsgSN = @lMsgSN
					AND (SELECT PropType 
							FROM tblPropertyList (NOLOCK) 
							WHERE SN = @lPropSN) = ISNULL(@lPropType,5)
			END
			
		--Message Field Props
		ELSE IF EXISTS(SELECT * 
		FROM tblMCTypeProperties (NOLOCK) 
		WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND MsgSN = @lMsgSN 
		AND (SELECT PropType 
				FROM tblPropertyList (NOLOCK)
				WHERE SN = @lPropSN) = ISNULL(@lPropType,6)) AND ISNULL(@sValue, '') > ''
			BEGIN
				UPDATE tblMCTypeProperties
				SET Value = @sValue
				WHERE MCSN = @lMCSN 
					AND PropSN = @lPropSN 
					AND MsgSN = @lMsgSN
					AND (SELECT PropType 
							FROM tblPropertyList (NOLOCK)
							WHERE SN = @lPropSN) = ISNULL(@lPropType,6)

			END
		ELSE
			BEGIN
				RAISERROR('Property not found in TotalMail ', 16, 1)
				RETURN
			END
	END
ELSE IF ISNULL(@sGeofenceSN,'') > '' --Geofence properties
	BEGIN
		IF EXISTS(SELECT * 
					FROM tblMCTypeProperties (NOLOCK)
					WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND GF_SN = @lGeofenceSN) AND ISNULL(@sValue, '') > ''
			BEGIN
				UPDATE tblMCTypeProperties
				SET Value = @sValue
				WHERE MCSN = @lMCSN 
					AND PropSN = @lPropSN 
					AND FormSN = @lGeofenceSN
					AND (SELECT PropType 
							FROM tblPropertyList (NOLOCK) 
							WHERE SN = @lPropSN) = ISNULL(@lPropType,7)
			END
		ELSE
			BEGIN
				RAISERROR('Property not found in TotalMail ', 16, 1)
				RETURN
			END				
	END
				

ELSE  --Else Add Value Properties
	BEGIN
		IF ISNULL(@sInstanceID, '') > ''
			SET @lInstanceID = CONVERT(int, @sInstanceID)
		IF ISNULL(@lInstanceID, 0) = 0 
			SET @lInstanceID = 1

		IF EXISTS(SELECT * 
					FROM tblMCTypeProperties (NOLOCK)
					WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND InstanceID = @lInstanceID) AND ISNULL(@sValue, '') > ''
			BEGIN
				UPDATE tblMCTypeProperties
				SET Value = @sValue
				WHERE MCSN = @lMCSN AND PropSN = @lPropSN AND InstanceID = @lInstanceID 
					AND (SELECT PropType 
					FROM tblPropertyList (NOLOCK) 
					WHERE SN = @lPropSN) = ISNULL(@lPropType,1)
			END
		ELSE
			BEGIN
				RAISERROR('Property not found in TotalMail ', 16, 1)
				RETURN
			END				
	END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[tm_SetMCProperties] TO [public]
GO
