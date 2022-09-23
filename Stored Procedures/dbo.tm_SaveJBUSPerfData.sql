SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tm_SaveJBUSPerfData] @p_MCVendorSN varchar(2),
									@p_Tractor varchar(8),
									@p_Driver varchar(8),
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
									@p_EventValue10 varchar(50),
									@p_EventCode11 varchar(30),
									@p_EventValue11 varchar(50),
									@p_EventCode12 varchar(30),
									@p_EventValue12 varchar(50),
									@p_EventCode13 varchar(30),
									@p_EventValue13 varchar(50),
									@p_EventCode14 varchar(30),
									@p_EventValue14 varchar(50),
									@p_EventCode15 varchar(30),
									@p_EventValue15 varchar(50),
									@p_EventCode16 varchar(30),
									@p_EventValue16 varchar(50),
									@p_EventCode17 varchar(30),
									@p_EventValue17 varchar(50),
									@p_EventCode18 varchar(30),
									@p_EventValue18 varchar(50),
									@p_EventCode19 varchar(30),
									@p_EventValue19 varchar(50),
									@p_EventCode20 varchar(30),
									@p_EventValue20 varchar(50),
									@p_EventCode21 varchar(30),
									@p_EventValue21 varchar(50),
									@p_EventCode22 varchar(30),
									@p_EventValue22 varchar(50),
									@p_EventCode23 varchar(30),
									@p_EventValue23 varchar(50),
									@p_EventCode24 varchar(30),
									@p_EventValue24 varchar(50),
									@p_EventCode25 varchar(30),
									@p_EventValue25 varchar(50),
									@p_EventCode26 varchar(30),
									@p_EventValue26 varchar(50),
									@p_EventCode27 varchar(30),
									@p_EventValue27 varchar(50),
									@p_EventCode28 varchar(30),
									@p_EventValue28 varchar(50),
									@p_EventCode29 varchar(30),
									@p_EventValue29 varchar(50),
									@p_EventCode30 varchar(30),
									@p_EventValue30 varchar(50),
									@p_EventCode31 varchar(30),
									@p_EventValue31 varchar(50),
									@p_EventCode32 varchar(30),
									@p_EventValue32 varchar(50),
									@p_EventCode33 varchar(30),
									@p_EventValue33 varchar(50),
									@p_EventCode34 varchar(30),
									@p_EventValue34 varchar(50),
									@p_EventCode35 varchar(30),
									@p_EventValue35 varchar(50),
									@p_EventCode36 varchar(30),
									@p_EventValue36 varchar(50),
									@p_EventCode37 varchar(30),
									@p_EventValue37 varchar(50),
									@p_EventCode38 varchar(30),
									@p_EventValue38 varchar(50),
									@p_EventCode39 varchar(30),
									@p_EventValue39 varchar(50),
									@p_EventCode40 varchar(30),
									@p_EventValue40 varchar(50)

AS

/**
 * 
 * NAME:
 * dbo.tm_SaveJBUSPerfData
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Take information from a JBUS interface and save to the appropriate TotalMail tables.
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
 * 083 - @p_EventCode40 varchar(30)	 
 * 084 - @p_EventValue40 varchar(50)
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
			FROM tblJBUSHeader (NOLOCK)
			WHERE hdr_MCSN = @p_MCVendorSN
				AND hdr_Tractor = @p_Tractor
				AND hdr_DateTime = @DateTime
				AND did_Type = 'Data')
  BEGIN
	SET @ErrString = 'Data records already exist for MCVendorSN ' + @p_MCVendorSN + ', tractor ' + @p_Tractor + ' at ' + @p_EventDateTime + '. Data not saved.'
	RAISERROR (@ErrString,16,1)
	RETURN 1
  END

SET @p_EventCode01 = ISNULL(RTRIM(@p_EventCode01), '') 
SET @p_EventValue01 = ISNULL(RTRIM(@p_EventValue01), '') 
IF (@p_EventCode01 <> '' AND @p_EventValue01 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode01, @p_EventValue01, 'Data'
  END									

SET @p_EventCode02 = ISNULL(RTRIM(@p_EventCode02), '') 
SET @p_EventValue02 = ISNULL(RTRIM(@p_EventValue02), '') 
IF (@p_EventCode02 <> '' AND @p_EventValue02 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode02, @p_EventValue02, 'Data'
  END									

SET @p_EventCode03 = ISNULL(RTRIM(@p_EventCode03), '') 
SET @p_EventValue03 = ISNULL(RTRIM(@p_EventValue03), '') 
IF (@p_EventCode03 <> '' AND @p_EventValue03 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode03, @p_EventValue03, 'Data'
  END									

SET @p_EventCode04 = ISNULL(RTRIM(@p_EventCode04), '') 
SET @p_EventValue04 = ISNULL(RTRIM(@p_EventValue04), '') 
IF (@p_EventCode04 <> '' AND @p_EventValue04 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode04, @p_EventValue04, 'Data'
  END									

SET @p_EventCode05 = ISNULL(RTRIM(@p_EventCode05), '') 
SET @p_EventValue05 = ISNULL(RTRIM(@p_EventValue05), '') 
IF (@p_EventCode05 <> '' AND @p_EventValue05 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode05, @p_EventValue05, 'Data'
  END									

SET @p_EventCode06 = ISNULL(RTRIM(@p_EventCode06), '') 
SET @p_EventValue06 = ISNULL(RTRIM(@p_EventValue06), '') 
IF (@p_EventCode06 <> '' AND @p_EventValue06 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode06, @p_EventValue06, 'Data'
  END									

SET @p_EventCode07 = ISNULL(RTRIM(@p_EventCode07), '') 
SET @p_EventValue07 = ISNULL(RTRIM(@p_EventValue07), '') 
IF (@p_EventCode07 <> '' AND @p_EventValue07 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode07, @p_EventValue07, 'Data'
  END									

SET @p_EventCode08 = ISNULL(RTRIM(@p_EventCode08), '') 
SET @p_EventValue08 = ISNULL(RTRIM(@p_EventValue08), '') 
IF (@p_EventCode08 <> '' AND @p_EventValue08 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode08, @p_EventValue08, 'Data'
  END									

SET @p_EventCode09 = ISNULL(RTRIM(@p_EventCode09), '') 
SET @p_EventValue09 = ISNULL(RTRIM(@p_EventValue09), '') 
IF (@p_EventCode09 <> '' AND @p_EventValue09 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode09, @p_EventValue09, 'Data'
  END									

SET @p_EventCode10 = ISNULL(RTRIM(@p_EventCode10), '') 
SET @p_EventValue10 = ISNULL(RTRIM(@p_EventValue10), '') 
IF (@p_EventCode10 <> '' AND @p_EventValue10 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode10, @p_EventValue10, 'Data'
  END									

SET @p_EventCode11 = ISNULL(RTRIM(@p_EventCode11), '') 
SET @p_EventValue11 = ISNULL(RTRIM(@p_EventValue11), '') 
IF (@p_EventCode11 <> '' AND @p_EventValue11 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode11, @p_EventValue11, 'Data'
  END									

SET @p_EventCode12 = ISNULL(RTRIM(@p_EventCode12), '') 
SET @p_EventValue12 = ISNULL(RTRIM(@p_EventValue12), '') 
IF (@p_EventCode12 <> '' AND @p_EventValue12 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode12, @p_EventValue12, 'Data'
  END									

SET @p_EventCode13 = ISNULL(RTRIM(@p_EventCode13), '') 
SET @p_EventValue13 = ISNULL(RTRIM(@p_EventValue13), '') 
IF (@p_EventCode13 <> '' AND @p_EventValue13 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode13, @p_EventValue13, 'Data'
  END									

SET @p_EventCode14 = ISNULL(RTRIM(@p_EventCode14), '') 
SET @p_EventValue14 = ISNULL(RTRIM(@p_EventValue14), '') 
IF (@p_EventCode14 <> '' AND @p_EventValue14 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode14, @p_EventValue14, 'Data'
  END									

SET @p_EventCode15 = ISNULL(RTRIM(@p_EventCode15), '') 
SET @p_EventValue15 = ISNULL(RTRIM(@p_EventValue15), '') 
IF (@p_EventCode15 <> '' AND @p_EventValue15 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode15, @p_EventValue15, 'Data'
  END									

SET @p_EventCode16 = ISNULL(RTRIM(@p_EventCode16), '') 
SET @p_EventValue16 = ISNULL(RTRIM(@p_EventValue16), '') 
IF (@p_EventCode16 <> '' AND @p_EventValue16 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode16, @p_EventValue16, 'Data'
  END									

SET @p_EventCode17 = ISNULL(RTRIM(@p_EventCode17), '') 
SET @p_EventValue17 = ISNULL(RTRIM(@p_EventValue17), '') 
IF (@p_EventCode17 <> '' AND @p_EventValue17 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode17, @p_EventValue17, 'Data'
  END									

SET @p_EventCode18 = ISNULL(RTRIM(@p_EventCode18), '') 
SET @p_EventValue18 = ISNULL(RTRIM(@p_EventValue18), '') 
IF (@p_EventCode18 <> '' AND @p_EventValue18 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode18, @p_EventValue18, 'Data'
  END									

SET @p_EventCode19 = ISNULL(RTRIM(@p_EventCode19), '') 
SET @p_EventValue19 = ISNULL(RTRIM(@p_EventValue19), '') 
IF (@p_EventCode19 <> '' AND @p_EventValue19 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode19, @p_EventValue19, 'Data'
  END									

SET @p_EventCode20 = ISNULL(RTRIM(@p_EventCode20), '') 
SET @p_EventValue20 = ISNULL(RTRIM(@p_EventValue20), '') 
IF (@p_EventCode20 <> '' AND @p_EventValue20 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode20, @p_EventValue20, 'Data'
  END									

SET @p_EventCode21 = ISNULL(RTRIM(@p_EventCode21), '') 
SET @p_EventValue21 = ISNULL(RTRIM(@p_EventValue21), '') 
IF (@p_EventCode21 <> '' AND @p_EventValue21 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode21, @p_EventValue21, 'Data'
  END									

SET @p_EventCode22 = ISNULL(RTRIM(@p_EventCode22), '') 
SET @p_EventValue22 = ISNULL(RTRIM(@p_EventValue22), '') 
IF (@p_EventCode22 <> '' AND @p_EventValue22 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode22, @p_EventValue22, 'Data'
  END									

SET @p_EventCode23 = ISNULL(RTRIM(@p_EventCode23), '') 
SET @p_EventValue23 = ISNULL(RTRIM(@p_EventValue23), '') 
IF (@p_EventCode23 <> '' AND @p_EventValue23 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode23, @p_EventValue23, 'Data'
  END									

SET @p_EventCode24 = ISNULL(RTRIM(@p_EventCode24), '') 
SET @p_EventValue24 = ISNULL(RTRIM(@p_EventValue24), '') 
IF (@p_EventCode24 <> '' AND @p_EventValue24 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode24, @p_EventValue24, 'Data'
  END									

SET @p_EventCode25 = ISNULL(RTRIM(@p_EventCode25), '') 
SET @p_EventValue25 = ISNULL(RTRIM(@p_EventValue25), '') 
IF (@p_EventCode25 <> '' AND @p_EventValue25 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode25, @p_EventValue25, 'Data'
  END									

SET @p_EventCode26 = ISNULL(RTRIM(@p_EventCode26), '') 
SET @p_EventValue26 = ISNULL(RTRIM(@p_EventValue26), '') 
IF (@p_EventCode26 <> '' AND @p_EventValue26 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode26, @p_EventValue26, 'Data'
  END									

SET @p_EventCode27 = ISNULL(RTRIM(@p_EventCode27), '') 
SET @p_EventValue27 = ISNULL(RTRIM(@p_EventValue27), '') 
IF (@p_EventCode27 <> '' AND @p_EventValue27 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode27, @p_EventValue27, 'Data'
  END									

SET @p_EventCode28 = ISNULL(RTRIM(@p_EventCode28), '') 
SET @p_EventValue28 = ISNULL(RTRIM(@p_EventValue28), '') 
IF (@p_EventCode28 <> '' AND @p_EventValue28 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode28, @p_EventValue28, 'Data'
  END									

SET @p_EventCode29 = ISNULL(RTRIM(@p_EventCode29), '') 
SET @p_EventValue29 = ISNULL(RTRIM(@p_EventValue29), '') 
IF (@p_EventCode29 <> '' AND @p_EventValue29 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode29, @p_EventValue29, 'Data'
  END									

SET @p_EventCode30 = ISNULL(RTRIM(@p_EventCode30), '') 
SET @p_EventValue30 = ISNULL(RTRIM(@p_EventValue30), '') 
IF (@p_EventCode30 <> '' AND @p_EventValue30 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode30, @p_EventValue30, 'Data'
  END									

SET @p_EventCode31 = ISNULL(RTRIM(@p_EventCode31), '') 
SET @p_EventValue31 = ISNULL(RTRIM(@p_EventValue31), '') 
IF (@p_EventCode31 <> '' AND @p_EventValue31 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode31, @p_EventValue31, 'Data'
  END									

SET @p_EventCode32 = ISNULL(RTRIM(@p_EventCode32), '') 
SET @p_EventValue32 = ISNULL(RTRIM(@p_EventValue32), '') 
IF (@p_EventCode32 <> '' AND @p_EventValue32 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode32, @p_EventValue32, 'Data'
  END									

SET @p_EventCode33 = ISNULL(RTRIM(@p_EventCode33), '') 
SET @p_EventValue33 = ISNULL(RTRIM(@p_EventValue33), '') 
IF (@p_EventCode33 <> '' AND @p_EventValue33 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode33, @p_EventValue33, 'Data'
  END									

SET @p_EventCode34 = ISNULL(RTRIM(@p_EventCode34), '') 
SET @p_EventValue34 = ISNULL(RTRIM(@p_EventValue34), '') 
IF (@p_EventCode34 <> '' AND @p_EventValue34 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode34, @p_EventValue34, 'Data'
  END									

SET @p_EventCode35 = ISNULL(RTRIM(@p_EventCode35), '') 
SET @p_EventValue35 = ISNULL(RTRIM(@p_EventValue35), '') 
IF (@p_EventCode35 <> '' AND @p_EventValue35 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode35, @p_EventValue35, 'Data'
  END									

SET @p_EventCode36 = ISNULL(RTRIM(@p_EventCode36), '') 
SET @p_EventValue36 = ISNULL(RTRIM(@p_EventValue36), '') 
IF (@p_EventCode36 <> '' AND @p_EventValue36 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode36, @p_EventValue36, 'Data'
  END									

SET @p_EventCode37 = ISNULL(RTRIM(@p_EventCode37), '') 
SET @p_EventValue37 = ISNULL(RTRIM(@p_EventValue37), '') 
IF (@p_EventCode37 <> '' AND @p_EventValue37 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode37, @p_EventValue37, 'Data'
  END									

SET @p_EventCode38 = ISNULL(RTRIM(@p_EventCode38), '') 
SET @p_EventValue38 = ISNULL(RTRIM(@p_EventValue38), '') 
IF (@p_EventCode38 <> '' AND @p_EventValue38 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode38, @p_EventValue38, 'Data'
  END									

SET @p_EventCode39 = ISNULL(RTRIM(@p_EventCode39), '') 
SET @p_EventValue39 = ISNULL(RTRIM(@p_EventValue39), '') 
IF (@p_EventCode39 <> '' AND @p_EventValue39 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode39, @p_EventValue39, 'Data'
  END									

SET @p_EventCode40 = ISNULL(RTRIM(@p_EventCode40), '') 
SET @p_EventValue40 = ISNULL(RTRIM(@p_EventValue40), '') 
IF (@p_EventCode40 <> '' AND @p_EventValue40 <> '')
  BEGIN
	SET @IsData = 1

	EXEC dbo.tm_SaveJBUSData @p_MCVendorSN, @p_Tractor, @p_Driver, @p_EventDateTime, @p_EventCode40, @p_EventValue40, 'Data'
  END									

IF (@IsData < 1)
  BEGIN
	RAISERROR ('No valid event data to save.',16,1)
	RETURN 1
  END
GO
GRANT EXECUTE ON  [dbo].[tm_SaveJBUSPerfData] TO [public]
GO
