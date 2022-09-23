SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_tax_names_sp    Script Date: 6/1/99 11:54:28 AM ******/
create PROCEDURE [dbo].[d_tax_names_sp]
As
	select code, abbr 
	from labelfile 
	where SUBSTRING(labeldefinition, 1, 7) = 'TaxType'
	order by code


GO
GRANT EXECUTE ON  [dbo].[d_tax_names_sp] TO [public]
GO
