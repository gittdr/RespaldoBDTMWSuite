SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tm_SaveJBUSFaultEvent] @p_MCVendorSN varchar(2),
									@p_Tractor varchar(15),
									@p_Driver varchar(15),
									@p_EventDateTime varchar(25),
									@p_EventCode01 varchar(30),
									@p_EventValue01 varchar(50),
									@p_EventCode02 varchar(30),
									@p_EventValue02 varchar(50),
									@p_EventCode03 varchar(30),
									@p_EventValue03 varchar(50),
									@p_EventCode04 varchar(30),
									@p_EventValue04 varchar(50),
									@p_EventCode05 varchar(30),
									@p_EventValue05 varchar(50),
									@p_EventCode06 varchar(30),
									@p_EventValue06 varchar(50),
									@p_EventCode07 varchar(30),
									@p_EventValue07 varchar(50),
									@p_EventCode08 varchar(30),
									@p_EventValue08 varchar(50),
									@p_EventCode09 varchar(30),
									@p_EventValue09 varchar(50),
									@p_EventCode10 varchar(30),
									@p_EventValue10 varchar(50)

AS

/**
 * 
 * NAME:
 * dbo.tm_SaveJBUSFaultEvent
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Take fault information from a JBUS interface and save to the appropriate TotalMail tables.
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
 * 005 - @p_EventCode01 varchar(30)	 - The code from tblJBUSDetailIDs of this event
 * 006 - @p_EventValue01 varchar(50)	- The value of this event
 * 007 - @p_EventCode02 varchar(30)	 
 * 008 - @p_EventValue02 varchar(50)
 *  ........
 * 023 - @p_EventCode10 varchar(30)	 
 * 024 - @p_EventValue10 varchar(50)
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 07/30/2010.01 - PTS52030 - MIZ - created
 *
 **/

SET NOCOUNT ON 

DECLARE @IsData int,		-- 0 = no data, 1 = data
		@ErrString varchar(100),
		@DateTime datetime

SET @IsData = 0
SET @p_MCVendorSN = ISNULL(RTRIM(@p_MCVendorSN), '')

IF (@p_MCVendorSN = '')
  BEGIN
	RAISERROR ('The MCVendorSN was not supplied. JBUS data could not be saved.',16,1)
	RETURN 1
  END
ELSE IF NOT EXISTS (SELECT * 
						FROM tblMobileCommType (NOLOCK)
						WHERE SN = @p_MCVendorSN)
  BEGIN
	SET @ErrString = 'The MCVendorSN is invalid (' + @p_MCVendorSN + '). JBUS data could not be saved.'
	RAISERROR (@ErrString,16,1)
	RETURN 1
  END

SET @p_Tractor = ISNULL(RTRIM(@p_Tractor), '')
IF (@p_Tractor = '')
  BEGIN
	RAISERROR ('The tractor number was not supplied. JBUS data could not be saved.',16,1)
	RETURN 1
  END
ELSE IF NOT EXISTS (SELECT * 
					FROM tblTrucks (NOLOCK)
					WHERE DispSysTruckID = @p_Tractor)
  BEGIN
	SET @ErrString = 'The tractor number is invalid (' + @p_Tractor + '). JBUS data could not be saved.'
	RAISERROR (@ErrString,16,1)
	RETURN 1
  END

SET @p_Driver = ISNULL(RTRIM(@p_Driver), '')
IF NOT EXISTS (SELECT * 
				FROM tblDrivers (NOLOCK)
				WHERE DispSysDriverID = @p_Driver)
  BEGIN
	SET @p_Driver = ''
  END

SET @p_EventDateTime = ISNULL(RTRIM(@p_EventDateTime), '')
IF (@p_EventDateTime = '')
  BEGIN
	RAISERROR ('The event date/time was not supplied. JBUS data could not be saved.',16,1)
	RETURN 1
  END
ELSE IF (ISDATE(@p_EventDateTime) < 1)
  BEGIN
	SET @ErrString = 'Invalid event date/time (' + @p_EventDateTime + '). JBUS data could not be saved.'
	RAISERROR (@ErrString,16,1)
	RETURN 1
  END

SET @DateTime = CONVERT(datetime, @p_EventDateTime)
IF EXISTS  (SELECT * 
			FROM tblJBUSHeader header (NOLOCK)
			WHERE hdr_MCSN = @p_MCVendorSN
				AND hdr_Tractor = @p_Tractor
				AND hdr_DateTime = @DateTime
				AND did_Type = 'Fault')
  BEGIN
	SET @ErrString = 'Fault records already exist for MCVendorSN ' + @p_MCVendorSN + ', tractor ' + @p_Tractor + ' at ' + @p_EventDateTime + '. Data not saved.'
	RAISERROR (@ErrString,16,1)
	RETURN 1
  END

SET @p_EventCode01 = ISNULL(RTRIM(@p_EventCode01), '') 
SET @p_EventValue01 = ISNULL(RTRIM(@p_EventValue01), '') 
IF (@p_EventCode01 <> '' AND @p_EventValue01 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode01, @p_EventValue01, 'Fault'
  END									

SET @p_EventCode02 = ISNULL(RTRIM(@p_EventCode02), '') 
SET @p_EventValue02 = ISNULL(RTRIM(@p_EventValue02), '') 
IF (@p_EventCode02 <> '' AND @p_EventValue02 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode02, @p_EventValue02, 'Fault'
  END									

SET @p_EventCode03 = ISNULL(RTRIM(@p_EventCode03), '') 
SET @p_EventValue03 = ISNULL(RTRIM(@p_EventValue03), '') 
IF (@p_EventCode03 <> '' AND @p_EventValue03 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode03, @p_EventValue03, 'Fault'
  END									

SET @p_EventCode04 = ISNULL(RTRIM(@p_EventCode04), '') 
SET @p_EventValue04 = ISNULL(RTRIM(@p_EventValue04), '') 
IF (@p_EventCode04 <> '' AND @p_EventValue04 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode04, @p_EventValue04, 'Fault'
  END									

SET @p_EventCode05 = ISNULL(RTRIM(@p_EventCode05), '') 
SET @p_EventValue05 = ISNULL(RTRIM(@p_EventValue05), '') 
IF (@p_EventCode05 <> '' AND @p_EventValue05 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode05, @p_EventValue05, 'Fault'
  END									

SET @p_EventCode06 = ISNULL(RTRIM(@p_EventCode06), '') 
SET @p_EventValue06 = ISNULL(RTRIM(@p_EventValue06), '') 
IF (@p_EventCode06 <> '' AND @p_EventValue06 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode06, @p_EventValue06, 'Fault'
  END									

SET @p_EventCode07 = ISNULL(RTRIM(@p_EventCode07), '') 
SET @p_EventValue07 = ISNULL(RTRIM(@p_EventValue07), '') 
IF (@p_EventCode07 <> '' AND @p_EventValue07 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode07, @p_EventValue07, 'Fault'
  END									

SET @p_EventCode08 = ISNULL(RTRIM(@p_EventCode08), '') 
SET @p_EventValue08 = ISNULL(RTRIM(@p_EventValue08), '') 
IF (@p_EventCode08 <> '' AND @p_EventValue08 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode08, @p_EventValue08, 'Fault'
  END									

SET @p_EventCode09 = ISNULL(RTRIM(@p_EventCode09), '') 
SET @p_EventValue09 = ISNULL(RTRIM(@p_EventValue09), '') 
IF (@p_EventCode09 <> '' AND @p_EventValue09 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode09, @p_EventValue09, 'Fault'
  END									

SET @p_EventCode10 = ISNULL(RTRIM(@p_EventCode10), '') 
SET @p_EventValue10 = ISNULL(RTRIM(@p_EventValue10), '') 
IF (@p_EventCode10 <> '' AND @p_EventValue10 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode10, @p_EventValue10, 'Fault'
  END									

IF (@IsData < 1)
  BEGIN
	RAISERROR ('No valid event data to save.',16,1)
	RETURN 1
  END
GO
GRANT EXECUTE ON  [dbo].[tm_SaveJBUSFaultEvent] TO [public]
GO
