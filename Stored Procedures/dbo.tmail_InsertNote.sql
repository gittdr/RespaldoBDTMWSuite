SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_InsertNote]   @Table varchar(18),
										@Regarding varchar(6),
										@Key varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
										@Expires varchar(25),
										@AlertNote char(1),
										@Text varchar(254),
										@Flags varchar(5)
AS

SET NOCOUNT ON 

DECLARE @not_number int,
		@not_sequence int,
		@not_expires datetime,
		@iFlags int,
		@IsInvalid int,
		@tmpKey varchar(25), --PTS 67926 RS: Changed size to 25 to accomodate PTS 61189(increase cmp_id length to 25)
		@tmpTable varchar(18)

IF (RTRIM(LTRIM(@Table)) = '')
  BEGIN
	RAISERROR ('No table supplied.  Note could not be inserted.',16,1)
	RETURN 1	
  END
	
IF (RTRIM(LTRIM(@Regarding)) = '')
  BEGIN
	RAISERROR ('No Regarding value supplied.  Note could not be inserted.',16,1)
	RETURN 1	
  END
ELSE
	IF (NOT EXISTS (SELECT abbr 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'NoteRe' and abbr = @Regarding AND ISNULL(retired,'N') = 'N'))
	  BEGIN
		RAISERROR ('Invalid Regarding value supplied (%s).  Note could not be inserted.',16,1, @Regarding)
		RETURN 1	
	  END

IF (RTRIM(LTRIM(@Text)) = '')
  BEGIN
	RAISERROR ('No text supplied.  Note was not inserted.',16,1)
	RETURN 1	
  END

IF (RTRIM(LTRIM(@Key)) = '')
  BEGIN
	RAISERROR ('No Key value supplied.  Note could not be inserted.',16,1)
	RETURN 1	
  END
ELSE  -- validate the key value
  BEGIN
	SET @tmpTable = @Table
	SET @tmpKey = @Key

	IF (UPPER(@Table) = 'ORDERNUMBER')	-- If ordernumber, convert to orderheader for the rest of the proc
	  BEGIN
		SET @Table = 'orderheader'	-- THIS MUST BE LOWERCASE (VDisp doesn't handle upper case at this point.
		SELECT @Key = ord_hdrnumber
		FROM orderheader (NOLOCK)
		WHERE ord_number = @Key
	  END

	SET @IsInvalid = 0
	IF (UPPER(@Table) = 'CARRIER') 
	  BEGIN
		IF (NOT EXISTS (SELECT car_id 
							FROM carrier (NOLOCK)
							WHERE car_id = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'COMMODITY')
	  BEGIN
		IF (NOT EXISTS (SELECT cmd_code 
							FROM commodity (NOLOCK)
							WHERE cmd_code = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'COMPANY')
	  BEGIN
		IF (NOT EXISTS (SELECT cmp_id 
						FROM company (NOLOCK)
						WHERE cmp_id = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'MANPOWERPROFILE')
	  BEGIN
		IF (NOT EXISTS (SELECT mpp_id 
						FROM manpowerprofile 
						WHERE mpp_id = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'MOVEMENT')
	  BEGIN
		IF (NOT EXISTS (SELECT mov_number 
							FROM orderheader 
							WHERE mov_number = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'ORDERHEADER')
	  BEGIN
		IF (NOT EXISTS (SELECT ord_hdrnumber 
							FROM orderheader 
							WHERE ord_hdrnumber = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'PAYTO')
	  BEGIN
		IF (NOT EXISTS (SELECT pto_id 
						FROM payto (NOLOCK)
						WHERE pto_id = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'TRACTORPROFILE')
	  BEGIN
		IF (NOT EXISTS (SELECT trc_number 
						FROM tractorprofile (NOLOCK)
						WHERE trc_number = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'TRAILERPROFILE')
	  BEGIN
		IF (NOT EXISTS (SELECT trl_number 
							FROM trailerprofile (NOLOCK)
							WHERE trl_number = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'PAYHEADER')
	  BEGIN
		IF (NOT EXISTS (SELECT pyh_pyhnumber 
							FROM payheader (NOLOCK)
							WHERE pyh_pyhnumber = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'INVOICEHEADER')
	  BEGIN
		IF (NOT EXISTS (SELECT ivh_invoicenumber 
							FROM invoiceheader (NOLOCK)
							WHERE ivh_invoicenumber = @Key))
			SET @IsInvalid = 1
	  END
	ELSE IF (UPPER(@Table) = 'THIRDPARTYPROFILE')
	  BEGIN
		IF (NOT EXISTS (SELECT tpr_id 
							FROM thirdpartyprofile (NOLOCK)
							WHERE tpr_id = @Key))
			SET @IsInvalid = 1
	  END

	IF (@IsInvalid = 1)
	  BEGIN
		RAISERROR ('Invalid Key value supplied. Table:(%s) Key:(%s).  Note could not be inserted.',16,1,@tmpTable,@tmpKey)
		RETURN 1	
	  END
  END

IF (ISDATE(@Expires) = 0)
	SET @not_expires = '20491231 23:59'	-- If not valid date or not supplied, default 12-31-2049 23:59
ELSE
	SET @not_expires = CONVERT(datetime, @Expires)

IF (RTRIM(LTRIM(@AlertNote)) = '')
	SET @AlertNote = 'N'	-- default to note if not supplied

-- Get the not_sequence number
SELECT @not_sequence = MAX(ISNULL(not_sequence,0)) + 1
FROM notes (NOLOCK)
WHERE ntb_table = @Table
	AND nre_tablekey = @Key

IF ISNULL(@not_sequence,0) = 0
	SET @not_sequence = 1

-- Get the next Note system number
SET @not_number = 0
EXECUTE @not_number = dbo.getsystemnumber 'NOTES', ''
IF @not_number = 0
  BEGIN
	RAISERROR ('Unable to generate not_number.  Note was not inserted.',16,1)
	RETURN 1	
  END

INSERT INTO Notes  (not_number, not_text, not_type, not_urgent, not_expires, 						--5
					ntb_table, nre_tablekey, not_sequence, last_updatedby, last_updatedatetime)		--10
VALUES (@not_number, @Text, @Regarding, @AlertNote, @not_expires,									--5
		@Table, @Key, @not_sequence, 'TMAIL', GETDATE())											--10
GO
GRANT EXECUTE ON  [dbo].[tmail_InsertNote] TO [public]
GO
