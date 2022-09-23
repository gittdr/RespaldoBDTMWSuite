SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.get_unit_conv_factor_sp    Script Date: 6/1/99 11:54:33 AM ******/
CREATE PROCEDURE [dbo].[get_unit_conv_factor_sp] (@from		varchar(6),
					  @to		varchar(6),
					  @flag		char(1))
AS	
	
	SELECT unc_factor
	FROM unitconversion u
	WHERE 	u.unc_from = @from
		AND u.unc_to = @to
		AND u.unc_convflag = @flag


GO
GRANT EXECUTE ON  [dbo].[get_unit_conv_factor_sp] TO [public]
GO
