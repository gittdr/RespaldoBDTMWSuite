SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_getsystemnumber](@p_controlid varchar(10),
					 @p_reservenbr int)
AS

SET NOCOUNT ON

DECLARE	@return_number int

SELECT @p_reservenbr = ISNULL(@p_reservenbr,1)  -- If the nbr of reserved numbers wasn't set, default to 1

BEGIN TRAN TMSYSCONTROL 

-- Reserve a @p_reservenbr size block of numbers
UPDATE tblrs
SET tblrs.Text = tblrs.Text + @p_reservenbr
FROM tblrs
WHERE (tblrs.KeyCode = @p_controlid) 

IF @@error != 0 GOTO ERROR_EXIT

SELECT @return_number = 0

-- Return the first number in the block to use
SELECT @return_number =  tblrs.Text - (@p_reservenbr - 1)
FROM tblrs (NOLOCK)
WHERE (tblrs.KeyCode = @p_controlid) 

IF @return_number = 0 
	BEGIN 
	INSERT INTO tblrs (KeyCode, Text, Static) VALUES (@p_controlid, @p_reservenbr + 1, 0)
	COMMIT TRAN TMSYSCONTROL 
	SELECT @return_number = 1 
	END

ERROR_EXIT:
IF @@error != 0 
  BEGIN
	ROLLBACK TRAN TMSYSCONTROL 
	SELECT @return_number = -1
  END
ELSE
	COMMIT TRAN TMSYSCONTROL 
	
RETURN @return_number
GO
GRANT EXECUTE ON  [dbo].[tm_getsystemnumber] TO [public]
GO
