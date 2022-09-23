SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_subcmd_prior_csv](@cmd_code VARCHAR(8), @cpr_id AS integer)
RETURNS VARCHAR(2048)

AS
BEGIN
    DECLARE @subs VARCHAR(2048)
	SELECT @subs= ''
    
    IF @cmd_code = 'UNKNOWN' RETURN @subs
    
    SELECT @subs = @subs + scm_subcode + ','
    FROM subcommodity JOIN commodity_prior_subcodes ON subcommodity.scm_identity = commodity_prior_subcodes.scm_identity
    WHERE cmd_code = @cmd_code
    AND cpr_id = @cpr_id

    IF datalength(@subs) > 1
      SELECT @subs = substring(@subs,1, datalength(@subs) - 1)
  
	RETURN @subs
END

GO
GRANT EXECUTE ON  [dbo].[fn_subcmd_prior_csv] TO [public]
GO
