SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.return_holidays    Script Date: 6/1/99 11:54:38 AM ******/
create procedure [dbo].[return_holidays] @year integer

as

select * from holidays
where datepart(yy,holiday) = @year


GO
GRANT EXECUTE ON  [dbo].[return_holidays] TO [public]
GO
