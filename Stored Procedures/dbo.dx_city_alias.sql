SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE                         proc [dbo].[dx_city_alias]
( 
@inCityName varchar(100)='UNK',
@inState varchar(6)= ''
)
AS
begin
	create table #wip
	(
	original nvarchar(50),
	Token nvarchar(50),
	TokenGroup int,
	hook int,
	ilevel int
	)
	--To build temp table of record sets
	declare @tmpToken nvarchar(50)
	declare @pos int
	declare @iLevel int
	declare @wipString nvarchar(50)
	declare @slength int
	declare @exitNext int


	--To build dynamic SQL to do the joins for the possibilities
	declare @ssql nvarchar(660)
	declare @sselectpart nvarchar(200)
	declare @sjoinpart nvarchar(200)
	declare @swherepart nvarchar(200)

	declare @sLevel nvarchar(10)
	declare @sLevelNext nvarchar(10)
	--clean up input string

	select @wipString=upper(ltrim(rtrim(isnull(@inCityName,''))))
	select @wipString=replace(@wipString, '.','')
	select @wipString=replace(@wipString, ',','')

	select cty_code, cty_name, cty_state, cty_zip into #cities from city where cty_name like @wipString and cty_state = @inState
	if (select count(*) from #cities) = 1
	begin
		select * from #cities
		drop table #cities
	end
	else
	begin
		--set up for parse of input string in reverse order
		select @sLength = charindex(' ',reverse(@wipString)) - 1
		if @sLength = -1 
		begin
			select @sLength = len(@wipString)
			select @pos = 1
			select @exitNext = 1
		end
		else
		begin
			select @pos=(len(@wipString)- @sLength) + 1
			select @exitNext = 0
		end
		select @iLevel = 1


		--parse in reverse and get synonyms for each token into a temp table

		while @iLevel > 0
		begin
			--parse token into local variable
			select @tmpToken = substring(@wipString,@pos,@slength)
			--insert into temp table #wip with level and recordset of synonyms
			--returned by alias stored proc
			insert into #wip
			exec alias @tmpToken, @iLevel
			--Get out of parse loop
			if @exitNext = 1 
			begin
				break
			end
			
			--set up for next pass
			select @iLevel = @ilevel + 1
			select @wipString = substring(@wipString, 1, @pos - 2)
			select @sLength = charindex(' ',reverse(@wipString)) - 1
			if @sLength <= 0 
			begin 
				select @sLength = len(@wipString)
				select @exitNext = 1
			end
			select @pos=(len(@wipString)- @sLength) + 1

		end 
		--Build dynamic SQL based on number of tokens in string to 
		--return record set of all possible strings

		select @ssql = ''

		select @sselectpart = 'SELECT '
		select @sLevel = cast(@iLevel as nvarchar(10)) 
		select @sjoinpart = ' AS Alias FROM #wip w' + @sLevel
		select @swherepart = ' WHERE '

		select @tmpToken = ' + ' + '''' + ' ' + '''' + ' + '
		--build the SQL in three parts, the select part, the join part, 
		--and the where part
		while @iLevel > 0
		begin
			select @sLevel = cast(@iLevel as nvarchar(10)) 
			select @sLevelNext = cast((@iLevel - 1) as nvarchar(10)) 
			select @sselectpart = @sselectpart + 'w' + @slevel + '.Token '
			if @iLevel > 1
			begin
				select @sselectpart = @sselectpart + @tmpToken
				select @sjoinpart = @sjoinpart + ' INNER JOIN #wip w' + @sLevelNext
				select @sjoinpart = @sjoinpart + ' on w' + @sLevel + '.hook = w' + @sLevelNext + '.hook'
			end
			select @swherepart = @swherepart + '(w' + @sLevel + '.iLevel = ' + @sLevel + ')'
			if @iLevel <> 1
			begin
				select @swherepart = @swherepart + ' AND '
			end
			select @iLevel = @iLevel - 1
		end
		--Put the parts together as one statement
		select @ssql = @sselectpart + @sjoinpart + @swherepart
		select @tmpToken = '''' + @inState + '%' + '''' + ' '
		select @ssql = 'SELECT cty_code, cty_name, cty_state, cty_zip from city where cty_state LIKE
		 ' + @tmpToken + ' and cty_name in
		 (' + @ssql +')'
		--execute dynamic SQL
		exec sp_executesql @ssql
	end
	drop table #wip
end

GO
GRANT EXECUTE ON  [dbo].[dx_city_alias] TO [public]
GO
