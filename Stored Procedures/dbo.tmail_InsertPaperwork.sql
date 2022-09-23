SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Flags: None defined.
*/

CREATE PROCEDURE [dbo].[tmail_InsertPaperwork] (@slgh_number varchar(10),
											@abbr varchar(6),
											@spw_dt varchar(25),
											@pw_received varchar(1), -- Y/N, default N
											@Flags varchar(10))
												
AS

SET NOCOUNT ON 

DECLARE
	@ord_hdrnumber int,
	@lgh_number int,
	@pw_dt datetime,
	@iFlags int

IF ISNULL(@slgh_number,'') = ''
  BEGIN
	RAISERROR ('No legheader specified: %s', 16, 1, @slgh_number)
	RETURN
  END
SET @lgh_number = CONVERT(int, ISNULL(@slgh_number,''))	

IF ISNULL(@abbr,'') = ''
  BEGIN
	RAISERROR ('No abbr specified: %s', 16, 1, @abbr)
	RETURN
  END
 
IF ISNULL(@spw_dt,'') = '' 
	SET @pw_dt = GETDATE()
ELSE IF ISDATE(@spw_dt) <> 1 
	BEGIN
		RAISERROR ('Invalid paperwork date specified: %s', 16, 1, @spw_dt)
		RETURN
  	END
ELSE 
	SET @pw_dt = CONVERT(datetime, @spw_dt)

IF @pw_dt < '20000101'
	SET @pw_dt = '20000101'

SET @pw_received = UPPER(ISNULL(@pw_received, 'N'))
IF @pw_received <> 'Y' AND @pw_received <> 'N'
	BEGIN
		RAISERROR ('Invalid received Y/N specified: %s', 16, 1, @pw_received)
		RETURN
  	END

IF ISNULL(@Flags,'') = ''
	SET @Flags = '0'
SET @iFlags = CONVERT(int, @Flags)

IF NOT EXISTS (select lgh_number 
					from legheader (NOLOCK)
					where lgh_number = @lgh_number) 
	BEGIN
		RAISERROR ('Leg header not found: %s', 16, 1, @slgh_number)
		RETURN
  	END
  	
select @ord_hdrnumber = ord_hdrnumber 
from legheader (NOLOCK)
where lgh_number = @lgh_number

delete from paperwork where abbr = @abbr and lgh_number = @lgh_number

INSERT INTO paperwork (
	abbr, 
	pw_received, 
	ord_hdrnumber, 
	pw_dt, 
	last_updatedby, -- 5
	last_updateddatetime, 
	lgh_number,
	pw_imaged
	 ) 
	VALUES ( 
		@abbr, 
		@pw_received, 
		@ord_hdrnumber, 
		@pw_dt, 
		'TotalMail', -- 5
		GETDATE(), 
		@lgh_number,
		'N'
		)
	
GO
GRANT EXECUTE ON  [dbo].[tmail_InsertPaperwork] TO [public]
GO
