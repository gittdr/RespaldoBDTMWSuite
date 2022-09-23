SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[expiration_protected_check_sp] 
(
    @p_expType varchar(6),
    @p_expCode varchar(6)
)

AS

    DECLARE @v_count int

/* Change Control

TGRIFFIT 42167 06/12/2008 created this stored procedure. Used in w_equipment_status to determine whether or
not the expiration type being selected (dw_det) is protected or not.

declare @ret int
exec @ret = expiration_protected_check_sp 'DrvExp', 'PREDRG'
select @ret

*/

BEGIN
    
    SELECT @v_count = COUNT(1) 
    FROM labelfile
    WHERE labeldefinition = @p_expType + 'Protect'
    AND UPPER(abbr) = UPPER(@p_expCode)
    AND (retired <> 'Y' OR retired IS NULL)
    
    SET @v_count = ISNULL(@v_count,0)
    
    RETURN @v_count
   
       
END
GO
GRANT EXECUTE ON  [dbo].[expiration_protected_check_sp] TO [public]
GO
