SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE        PROCEDURE [dbo].[dx_get_commodity_by_trading_partner]
	@cmd_name varchar(60),
	@trp_id varchar(20),
	@@cmd_code varchar(8) OUT
 AS 

DECLARE @retcode int, @test_cmd_code varchar(8)

IF RTRIM(ISNULL(@@cmd_code,'')) = '' SELECT @@cmd_code = 'UNKNOWN'

IF @@cmd_code <> 'UNKNOWN'
BEGIN
	EXEC @retcode = dx_does_commodity_exist @@cmd_code
	RETURN @retcode
END

SELECT @@cmd_code = 'UNKNOWN', @test_cmd_code = ''

SELECT @test_cmd_code = MAX(cmd_id)
  FROM commodity_xref
 WHERE cmd_name = RTRIM(ISNULL(@cmd_name,''))
   AND src_system = 'EDI'
   AND src_tradingpartner = @trp_id

IF ISNULL(@test_cmd_code,'') > ''
BEGIN
	EXEC @retcode = dx_does_commodity_exist @test_cmd_code
	IF @retcode = 1
		SELECT @@cmd_code = @test_cmd_code
	ELSE
		DELETE commodity_xref WHERE cmd_id = @test_cmd_code
END

RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_get_commodity_by_trading_partner] TO [public]
GO
