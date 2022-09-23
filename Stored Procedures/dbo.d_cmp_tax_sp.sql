SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_cmp_tax_sp    Script Date: 6/1/99 11:54:09 AM ******/
CREATE PROCEDURE [dbo].[d_cmp_tax_sp] (@CmpId	varchar(12))
AS
	select company.cmp_taxtable1, company.cmp_taxtable2,
	       company.cmp_taxtable3, company.cmp_taxtable4	
	from company
	where company.cmp_id = @CmpId


GO
GRANT EXECUTE ON  [dbo].[d_cmp_tax_sp] TO [public]
GO
