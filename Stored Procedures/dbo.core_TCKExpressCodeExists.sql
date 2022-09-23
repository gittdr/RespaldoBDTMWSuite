SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKExpressCodeExists]
		@tck_expresscode_tck_account_number varchar (10),
		@tck_expresscode_tex_expresscodenumber varchar (20),
		@tck_expresscode_tex_currency varchar (6)
AS
	IF Exists (	SELECT tex_expresscodenumber
			FROM [tck_expresscode]
			WHERE  	tck_account_number = @tck_expresscode_tck_account_number
			AND	tex_expresscodenumber = @tck_expresscode_tex_expresscodenumber
			AND	tex_currency = @tck_expresscode_tex_currency)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End


-- 	SELECT 
-- 	Count(tex_expresscodenumber)
-- 	FROM [tck_expresscode]
-- 	WHERE  	tck_account_number = @tck_expresscode_tck_account_number
-- 	AND	tex_expresscodenumber = @tck_expresscode_tex_expresscodenumber
-- 	AND	tex_currency = @tck_expresscode_tex_currency


GO
GRANT EXECUTE ON  [dbo].[core_TCKExpressCodeExists] TO [public]
GO
