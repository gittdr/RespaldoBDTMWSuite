SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_StatusIsActive] (@p_status varchar(6)) 
RETURNS char(1)
AS
/* Returns Y if the order status is AVL or greater or is ICO (IE it is a real order)
SAMPLE CALL

if (dbo.fn_statusisactive ('AVL')) = 'Y'
  select 'A'
else
  select 'B'

6/4/10 DPETE PTS51844
*/
BEGIN   DECLARE @Return 	char(1)
   DECLARE	@Avlcode int, @OrdStatusCode int
        
   Select @OrdStatusCode  = code 
   From labelfile with (nolock)
   Where  labeldefinition = 'DispStatus'
   and labelfile.abbr  = @p_status

   Select @avlcode  = code 
   From labelfile with (nolock)
   Where labeldefinition = 'DispStatus' and abbr = 'AVL'
   

   If  @OrdStatusCode >= @avlcode or @p_status = 'ICO'

        select @Return  = 'Y'
   Else
        select @Return  =  'N'

  Return @return
END
GO
GRANT EXECUTE ON  [dbo].[fn_StatusIsActive] TO [public]
GO
