SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKExpressCodeDelete]
		@tck_expresscode_tck_account_number varchar (10),
		@tck_expresscode_tex_expresscodenumber varchar (20),
		@tck_expresscode_tex_currency varchar (6)
AS
	DELETE FROM [tck_expresscode] 
	WHERE  	tck_account_number = @tck_expresscode_tck_account_number
	AND	tex_expresscodenumber = @tck_expresscode_tex_expresscodenumber
	AND	tex_currency = @tck_expresscode_tex_currency

GO
GRANT EXECUTE ON  [dbo].[core_TCKExpressCodeDelete] TO [public]
GO
