SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Checks the pay details for a legheader to determine if they are different from 
	the specified input.  Checks: 
	1) sInTotalQuantity = sum(paydetail.pyd_quantity) 
	2) sInLastUpdateTime =  paperwork.pw_dt
	Returns: sMatch: '0' = One or both checks failed; '1' = both checks passed.
	
	Flags: 1 = Do not return result set.
*/

CREATE PROCEDURE [dbo].[tmail_CheckLghPayDetails] (@sLgh varchar(10),
												@asgn_type varchar(6),
												@PayTypeLike varchar(6),
												@pw_abbr varchar(6),
												@sInTotalQuantity varchar(20),
												@sInLastUpdateTime varchar(25),
												@Flags varchar(10),
												@sMatch varchar(10) out)

AS

SET NOCOUNT ON 

DECLARE
	@lgh int,
	@InTotalQuantity float,
	@InLastUpdateTime datetime,
	@iFlags int,
	@TotalQuantity float,
	@LastUpdateTime datetime,
	@SuppressResultSet int

/* Massage input */

IF ISNULL(@sLgh,'') = ''
  BEGIN
	RAISERROR ('No legheader specified: %s', 16, 1, @sLgh)
	RETURN
  END
ELSE
	SET @lgh = CONVERT(int, @sLgh)

SET @asgn_type = ISNULL(@asgn_type, '') 
SET @PayTypeLike = ISNULL(@PayTypeLike, '')
SET @pw_abbr = ISNULL(@pw_abbr, '')
SET @InTotalQuantity = CONVERT(float, ISNULL(@sInTotalQuantity,'0'))

IF ISDATE(@sInLastUpdateTime) = 1
	SET @InLastUpdateTime = CONVERT(datetime, @sInLastUpdateTime)
ELSE
	SET @InLastUpdateTime = CONVERT(datetime, '00:00')
	
SET @Flags = ISNULL(@Flags,'0')
IF ISNUMERIC(@Flags) <> 1
	SET @Flags = '0'
SET @iFlags = CONVERT(int, @Flags)

SET @SuppressResultSet = 0
IF @iFlags & 1 <> 0 
	SET @SuppressResultSet = 1

/* Initialize */
SELECT @sMatch = '1' -- Initialize to true

/* Check last update time */

IF @pw_abbr <> ''
	select @LastUpdateTime = pw_dt 
		from paperwork (NOLOCK)
		where ord_hdrnumber = 
			(select ord_hdrnumber 
			from legheader (NOLOCK)
			where lgh_number = @lgh) 
			and abbr = @pw_abbr
SET @LastUpdateTime = ISNULL(@LastUpdateTime, '00:00')

IF @InLastUpdateTime < '20000101' SET @InLastUpdateTime = '20000101'
IF @LastUpdateTime < '20000101' SET @LastUpdateTime = '20000101'

IF CONVERT(varchar, @LastUpdateTime, 120) <> CONVERT(varchar, @InLastUpdateTime, 120)
	BEGIN
	SELECT @sMatch = '0'
	IF @SuppressResultSet <> 1 
		SELECT @sMatch as 'Match'
	RETURN
	END

/* Check sum of quantities */

IF @asgn_type = ''
	BEGIN
	IF @PayTypeLike = '' 
		select @TotalQuantity = sum(pyd_quantity) 
		from paydetail (NOLOCK)
		where lgh_number = @lgh
	ELSE
		select @TotalQuantity = sum(pyd_quantity) 
		from paydetail (NOLOCK)
		where lgh_number = @lgh and pyt_itemcode like @PayTypeLike
	END
ELSE
	BEGIN	
	IF @PayTypeLike = '' 
		select @TotalQuantity = sum(pyd_quantity) 
		from paydetail (NOLOCK)
		where lgh_number = @lgh and asgn_type = @asgn_type  
	ELSE
		select @TotalQuantity = sum(pyd_quantity) 
		from paydetail (NOLOCK) 
		where lgh_number = @lgh and asgn_type = @asgn_type 
			and pyt_itemcode like @PayTypeLike
	END

IF ABS(@TotalQuantity - @InTotalQuantity) > 0.0001
	BEGIN
	SELECT @sMatch = '0'
	IF @SuppressResultSet <> 1 
		SELECT @sMatch as 'Match'
	RETURN
	END

IF @SuppressResultSet <> 1 
	SELECT @sMatch as 'Match'

GO
GRANT EXECUTE ON  [dbo].[tmail_CheckLghPayDetails] TO [public]
GO
