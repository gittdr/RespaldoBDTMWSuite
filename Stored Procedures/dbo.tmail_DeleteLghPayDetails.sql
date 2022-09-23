SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Flags: None defined.
*/

CREATE PROCEDURE [dbo].[tmail_DeleteLghPayDetails] (@sLgh varchar(10),
												@asgn_type varchar(6),
												@PayTypeLike varchar(6),
												@Flags varchar(10))

AS

DECLARE
	@lgh int,
	@iFlags int

-- If no lgh number was passed in, raise an error
IF ISNULL(@sLgh,'') = ''
  BEGIN
	RAISERROR ('No legheader specified: %s', 16, 1, @sLgh)
	RETURN
  END
ELSE
	SET @lgh = CONVERT(int, @sLgh)

SET @asgn_type = ISNULL(@asgn_type, '') 
SET @PayTypeLike = ISNULL(@PayTypeLike, '')
IF ISNULL(@Flags,'') = ''
	SET @Flags = '0'
SET @iFlags = CONVERT(int, @Flags)

IF @asgn_type = ''
	BEGIN
	IF @PayTypeLike = '' 
		delete paydetail where lgh_number = @lgh
	ELSE
		delete paydetail where lgh_number = @lgh and pyt_itemcode like @PayTypeLike
	END
ELSE
	BEGIN	
	IF @PayTypeLike = '' 
		delete paydetail where lgh_number = @lgh and asgn_type = @asgn_type  
	ELSE
		delete paydetail where lgh_number = @lgh and asgn_type = @asgn_type 
			and pyt_itemcode like @PayTypeLike
	END

GO
GRANT EXECUTE ON  [dbo].[tmail_DeleteLghPayDetails] TO [public]
GO
