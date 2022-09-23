SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tm_SaveJBUSData] @p_MCVendorSN varchar(2),
									@p_Tractor varchar(8),
									@p_Driver varchar(8),
									@p_EventDateTime varchar(25),
									@p_EventCode varchar(30),
									@p_EventValue varchar(50),
									@p_RecordType varchar(20)

AS

/**
 * 
 * NAME:
 * dbo.tm_SaveJBUSData
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Save the JBUS interface data to the appropriate TotalMail tables.
 *
 * NOTE: This proc assumes that the data to be saved has been validated in the calling proc.
 *        - MCVendorSN, Tractor, EventDate/Time, EventCode & EventValue are populated
 *		  - MCVendorSN exists in tblMobileCommType
 *		  - Tractor exists in tblTrucks	
 *		  - There isn't already a header record for this MCSN, Tractor and date/time.
 *
 * RETURNS:
 *  none
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @p_MCVendorSN varchar(2) - The SN of this vendor from tblMobileCommType
 * 002 - @p_Tractor varchar(8)	 
 * 003 - @p_Driver varchar(8)	 
 * 004 - @p_EventDateTime varchar(25) - The date/time the JBUS events were recorded
 * 005 - @p_EventCode varchar(30)	 - The code from tblJBUSDetailIDs of this event
 * 006 - @p_EventValue varchar(50)	- The value of this event
 * 007 - @p_RecordType varchar(20) - 'Data' or 'Fault'
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 07/30/2010.01 - PTS52030 - MIZ - created
 *
 **/

SET NOCOUNT ON 

DECLARE @DateTime datetime,
		@ErrString varchar(100),
		@HeaderSN int

SET @DateTime = CONVERT(datetime, @p_EventDateTime)

IF NOT EXISTS (SELECT *		
				FROM tblJBUSDetailIDs (NOLOCK)
				WHERE did_MCSN = @p_MCVendorSN AND did_Type = @p_RecordType AND did_Code = @p_EventCode)
  BEGIN
	SET @ErrString = 'No matching record in tblJBUSDetailIds for MCVendorSN: ' + @p_MCVendorSN + ', Type: ' + @p_RecordType + ', Code: ' + @p_EventCode + '. Data not saved.'
	RAISERROR (@ErrString,16,1)
	RETURN 1
  END

SET @HeaderSN = 0
SELECT @HeaderSN = ISNULL(SN,0) 
FROM tblJBUSHeader  (NOLOCK)
WHERE hdr_MCSN = @p_MCVendorSN 
	AND hdr_Tractor = @p_Tractor 
	AND hdr_DateTime = @DateTime
	AND did_Type = @p_RecordType 

IF (@HeaderSN < 1)
  BEGIN
	-- First entry for this MCSN/Tractor/DateTime, so insert the header record.
	INSERT INTO tblJBUSHeader (hdr_MCSN, hdr_Tractor, hdr_Driver, hdr_DateTime, did_Type)
	VALUES (@p_MCVendorSN, @p_Tractor, @p_Driver, @DateTime, @p_RecordType)

	SELECT @HeaderSN = @@IDENTITY
  END

IF (@HeaderSN > 0)
  BEGIN
	-- Insert detail record
	INSERT INTO tblJBUSDetail (hdr_SN, del_Value, did_SN)
	SELECT @HeaderSN, @p_EventValue, SN 
	FROM tblJBUSDetailIDs (NOLOCK)
	WHERE did_Type = @p_RecordType 
		AND did_Code = @p_EventCode 
		AND did_MCSN = @p_MCVendorSN
  END
GO
GRANT EXECUTE ON  [dbo].[tm_SaveJBUSData] TO [public]
GO
