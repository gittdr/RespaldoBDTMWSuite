SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[quitaacentos](@source as varchar(300))
RETURNS varchar(300) AS
BEGIN

declare @charList as varchar(20)
declare @temp as varchar(300)
declare @i as int

set @temp = @source
set @charList = 'aeiou'

set @i = 0
while @i <= len(@charList)
begin
set @temp = replace(@temp,  substring(@charList, @i, 1)  ,  substring(@charList, @i, 1)  )
set @i = @i + 1
end
set @temp = Replace(@temp, '’', '''')
set @temp = Replace(@temp, 'ñ', 'n')

set @temp = Upper(@temp)

return @temp

END
GO
