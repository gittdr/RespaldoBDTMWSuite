SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDICreateUpdate204]  
 @p_OrderHeaderNumber int  
as  
DECLARE @lgh_number INT, @lgh_204status varchar(6), @lgh_carrier varchar(8) 
 
IF (SELECT UPPER(SUBSTRING(gi_string1, 1,1))   
      FROM generalinfo WITH (NOLOCK)   
     WHERE gi_name = 'ProcessOutbound204') = 'Y'  
BEGIN  

	DECLARE LEGS CURSOR FAST_FORWARD FOR
	SELECT lgh_number, lgh_204status, lgh_carrier FROM legheader with (nolock)
	   WHERE ord_hdrnumber = @p_OrderHeaderNumber  
		 AND lgh_number > 0 order by lgh_number

	OPEN LEGS
	FETCH NEXT FROM LEGS INTO @lgh_number, @lgh_204status, @lgh_carrier

	WHILE @@FETCH_STATUS = 0
		BEGIN    
		        
		  IF @lgh_204status IN ('TND','TDA') AND isnull(@lgh_carrier,'UNKNOWN') <> 'UNKNOWN'  
				EXEC create_outbound204 @lgh_number, @lgh_carrier, 'CHANGE' 
		   
		FETCH NEXT FROM LEGS INTO @lgh_number, @lgh_204status, @lgh_carrier
		END
	CLOSE LEGS
	DEALLOCATE LEGS

END  
  

GO
GRANT EXECUTE ON  [dbo].[dx_EDICreateUpdate204] TO [public]
GO
