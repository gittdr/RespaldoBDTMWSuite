SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TM_Get_Geofence_Info]	@sID varchar(50), 
											@sIDType varchar(6), 
											@sType varchar(6),
											@sEvent varchar(50),
											@sSN varchar(12),
											@sFlags varchar(12),
											@sFormItemID varchar(12),
											@sFormItem varchar(25),
											@sFormType varchar(12)

AS

SET NOCOUNT ON

BEGIN

/*
pass:
	@sID = ID to find
	@sIDType = Type of ID. Describes the ID. 
	@sType = geofence type: 'ARVING'|'ARVED'|'DEPED'
	@sEvent = TMWSuite Event
	@sFormItemID = Form ItemID 'NONE', any text, 'Rev-Type1,2,3,4, etc.'
	@sFormItem = Item text
	@sFormType = 'ALL', 'LATE', any text
return:
	Geofence information

proc uses 'ID', 'event' and 'type' 
and tries to get 'geofence information' as follows:
	ID, event, type
	ID, event, UNKNOWN
	ID, ANY, type
	ID, ANY, UNKNOWN
	UNKNOWN, event, type
	UNKNOWN, event, UNKNOWN
	UNKNOWN, ALL, type
	UNKNOWN, ALL, UNKNOWN
*/

DECLARE
	@SN int,
	@Radius decimal(7,2),
	@RadiusUnits varchar(6),
	@FormIDSN INT	

SET @SN = CONVERT(int, @sSN)

IF ISNULL(@sType, '') = '' AND @SN = 0
	BEGIN
		RAISERROR('Type or SN must be specified', 16, 1)
		RETURN
	END
	
IF ISNULL(@sID, '') = ''
	SET @sID = 'UNKNOWN'

IF ISNULL(@sIDType, '') = ''
	SET @sIDType = 'CMP'

IF ISNULL(@sEvent, '') = ''
	SET @sEvent = 'UNK'

IF ISNULL(@SN, 0) = 0
BEGIN
	--1 ID, event, type
	SELECT @SN = SN 
		FROM tblGeofenceDefaults  (NOLOCK)
		WHERE ID = @sID 
				AND ID_Type = @sIDType
				AND [Event] = @sEvent 
				AND [Type] = @sType 

	IF ISNULL(@SN, 0) = 0
	BEGIN
		--2 ID, event, UNKNOWN
		SELECT @SN = SN 
			FROM tblGeofenceDefaults  (NOLOCK)
			WHERE ID = @sID 
				AND ID_Type = @sIDType
				AND [Event] = @sEvent 
				AND [Type] = 'UNK'

		IF ISNULL(@SN, 0) = 0
		BEGIN
			--3 ID, ANY, type
			SELECT @SN = SN 
				FROM tblGeofenceDefaults (NOLOCK)
				WHERE ID = @sID 
					AND ID_Type = @sIDType
					AND [Event] = 'ALL' 
					AND [Type] = @sType

			IF ISNULL(@SN, 0) = 0
			BEGIN
				--4 ID, ANY, UNKNOWN
				SELECT @SN = SN 
					FROM tblGeofenceDefaults (NOLOCK)
					WHERE ID = @sID 
						AND ID_Type = @sIDType
						AND [Event] = 'ALL' 
						AND [Type] = 'UNK'

				IF ISNULL(@SN, 0) = 0
				BEGIN
					--5 UNKNOWN, event, type
					SELECT @SN = SN 
						FROM tblGeofenceDefaults (NOLOCK)
						WHERE ID = 'UNKNOWN' 
							AND ID_Type = @sIDType
							AND [Event] = @sEvent
							AND [Type] = @sType
					
					IF ISNULL(@SN, 0) = 0
					BEGIN
						--6 UNKNOWN, event, UNKNOWN
						SELECT @SN = SN 
							FROM tblGeofenceDefaults (NOLOCK)
							WHERE ID = 'UNKNOWN' 
								AND ID_Type = @sIDType
								AND [Event] = @sEvent 
								AND [Type] = 'UNK'

						IF ISNULL(@SN, 0) = 0
						BEGIN
							--7 UNKNOWN, ALL, type
							SELECT @SN = SN 
								FROM tblGeofenceDefaults (NOLOCK)
								WHERE ID = 'UNKNOWN' 
									AND ID_Type = @sIDType
									AND [Event] = 'ALL' 
									AND [Type] = @sType

							IF ISNULL(@SN, 0) = 0
							BEGIN
								--8 UNKNOWN, ALL, UNKNOWN
								SELECT @SN = SN 
									FROM tblGeofenceDefaults (NOLOCK)
									WHERE ID = 'UNKNOWN' 
										AND ID_Type = @sIDType
										AND [Event] = 'ALL' 
										AND [Type] = 'UNK'

								IF ISNULL(@SN, 0) = 0
								BEGIN
									SELECT @radius = -1
								END
							END
						END
					END
				END
			END
		END
	END
END


--FormID's START-------------------------------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@FormIDSN, 0) = 0
BEGIN
	--1 ID, event, type
	SELECT @FormIDSN = SN 
		FROM tblGeofenceFormIDs (NOLOCK)
		WHERE GF_SN = @SN 
				AND [Type] = @sFormType
				AND ItemID = @sFormItemID 
				AND Item = @sFormItem 

	IF ISNULL(@FormIDSN, 0) = 0
	BEGIN
		--2 ALL, ItemID, Item
		SELECT @FormIDSN = SN 
			FROM tblGeofenceFormIDs  (NOLOCK)
			WHERE GF_SN = @SN 
				AND [Type] = 'ALL'
				AND ItemID = @sFormItemID 
				AND Item = @sFormItem

		IF ISNULL(@FormIDSN, 0) = 0
		BEGIN
			--3 Type, itemID, BLANK
			SELECT @FormIDSN = SN 
				FROM tblGeofenceFormIDs (NOLOCK)
				WHERE GF_SN = @SN  
					AND [Type] = @sFormType
					AND ItemID = @sFormItemID
					AND Item = ''

			IF ISNULL(@FormIDSN, 0) = 0
			BEGIN
				--4 LATE, ItemID, Item
				SELECT @FormIDSN = SN 
					FROM tblGeofenceFormIDs (NOLOCK)
					WHERE GF_SN = @SN  
						AND [Type] = 'LATE'
						AND ItemID = @sFormItemID 
						AND Item = @sFormItem

				IF ISNULL(@FormIDSN, 0) = 0
				BEGIN
					--5 Type, NONE, Item
					SELECT @FormIDSN = SN 
						FROM tblGeofenceFormIDs (NOLOCK)
						WHERE GF_SN = @SN 
							AND [Type] = @sFormType
							AND ItemID = 'NONE'
							AND Item = @sFormItem
					
				END
			END
		END
	END
END


--FormID's END---------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT	@Radius = Radius, 
		@RadiusUnits = Radius_Units
	FROM tblGeofenceDefaults
	WHERE SN = @SN

SELECT @Radius = 
	case @radiusunits
	when 'FT' then @radius / 5280
	when 'IN' then @radius / 63360
	when 'YD' then @radius / 1760
	when 'CM' then @radius * .000006214 --Note: CM will be removed as a choice. 10/3/03
	when 'MM' then @radius * .0006214 -- meters
	when 'KMS' then @radius * .6214 
	else -- 'MIL', 'UNK'
		@radius
	END

SELECT	SN, 
		ID, 
		ID_Type, 
		[Event], 
		[Type], 
		@Radius AS Radius, 
		@RadiusUnits as RadiusUnits, 
		Latitude_seconds, 
		Longitude_seconds, 
		Latitude_seconds / 3600 Latitude_degrees, 
		Longitude_seconds / 3600 Longitude_degrees, 
		Begin_Early_Tolerance_min, 
		Begin_Late_Tolerance_min, 
		Arrive_Early_Tolerance_min, 
		Arrive_Late_Tolerance_min, 
		Depart_Early_Tolerance_min, 
		Depart_Late_Tolerance_min,
		DepartTimeOut,
		(SELECT FormID 
		FROM tblGeofenceFormIDs (NOLOCK)
		WHERE SN = @FormIDSN) TotalMailFormID ,
		(SELECT MCID 
		FROM tblGeofenceFormIDs (NOLOCK)
		WHERE SN = @FormIDSN) TotalMailFormMCID 
	FROM tblGeofenceDefaults (NOLOCK)
	WHERE SN = @SN

END

GO
GRANT EXECUTE ON  [dbo].[TM_Get_Geofence_Info] TO [public]
GO
