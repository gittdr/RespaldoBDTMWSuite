SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[count_cities] @pattern varchar(40), @states varchar(6),
			         @city_count int OUTPUT AS
declare @statestring varchar(6)

select @statestring  = isnull(@states, '')

if @statestring != '' select @pattern = @pattern + ' AND cty_state LIKE' +  @statestring + '%'

SELECT @city_count=COUNT(cty_name) FROM city WHERE UPPER(cty_name) LIKE @pattern


GO
GRANT EXECUTE ON  [dbo].[count_cities] TO [public]
GO
