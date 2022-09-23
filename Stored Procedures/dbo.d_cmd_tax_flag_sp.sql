SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_cmd_tax_flag_sp    Script Date: 6/1/99 11:54:09 AM ******/
CREATE PROCEDURE [dbo].[d_cmd_tax_flag_sp] (@CmdCode	varchar(12))
As
	select cmd_taxtable1, cmd_taxtable2, cmd_taxtable3, cmd_taxtable4
	from commodity
	Where cmd_code = @CmdCode


GO
GRANT EXECUTE ON  [dbo].[d_cmd_tax_flag_sp] TO [public]
GO
