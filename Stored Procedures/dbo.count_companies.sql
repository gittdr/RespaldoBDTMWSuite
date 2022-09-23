SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.count_companies    Script Date: 6/1/99 11:54:08 AM ******/
create procedure [dbo].[count_companies] @pattern varchar(40), @zipcode varchar(10),
			         @company_count int OUTPUT AS
declare @zipstring varchar(10)

select @zipstring  = isnull(@zipcode, "")

if @zipstring != "" select @pattern = @pattern + " AND cmp_zip LIKE" +  @zipstring + "%"

SELECT @company_count=COUNT(cmp_name) FROM company WHERE UPPER(cmp_name) LIKE @pattern


GO
GRANT EXECUTE ON  [dbo].[count_companies] TO [public]
GO
