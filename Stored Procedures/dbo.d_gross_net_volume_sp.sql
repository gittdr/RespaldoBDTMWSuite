SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_gross_net_volume_sp](	@billto	varchar(8),
														@cmd_code varchar(8)) 
AS

DECLARE @defaultbillingqty char(1),
		@gi_string2 char(1),
		@grossnet char(1)

SELECT @defaultbillingqty = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1)),
		 @gi_string2 = ISNULL(gi_string2, '1')
FROM generalinfo
WHERE gi_name = 'DefaultBillingQty'

IF @defaultbillingqty = 'Y'
	SELECT @grossnet  = btr.gross_net_flag 
	FROM billto_cmd_billingqty_relations btr
	JOIN commodity cmd on CASE WHEN @gi_string2 = '1' THEN cmd.cmd_class ELSE cmd.cmd_class2 END = btr.cmd_class
	WHERE cmd.cmd_code = @cmd_code
	AND btr.billto_id = @billto

ELSE
	SELECT @grossnet = 'G'

SELECT isnull(@grossnet, 'G')

RETURN


GO
GRANT EXECUTE ON  [dbo].[d_gross_net_volume_sp] TO [public]
GO
