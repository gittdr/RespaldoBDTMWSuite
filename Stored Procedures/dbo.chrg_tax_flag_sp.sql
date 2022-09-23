SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.chrg_tax_flag_sp    Script Date: 6/1/99 11:54:07 AM ******/
CREATE PROCEDURE [dbo].[chrg_tax_flag_sp] (@ChrgType	varchar(12))
As
	select cht_taxtable1, cht_taxtable2, cht_taxtable3, cht_taxtable4
	from chargetype
	Where cht_itemcode = @ChrgType


GO
GRANT EXECUTE ON  [dbo].[chrg_tax_flag_sp] TO [public]
GO
