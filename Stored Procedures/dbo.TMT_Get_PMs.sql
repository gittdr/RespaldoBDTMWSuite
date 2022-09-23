SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[TMT_Get_PMs]
as
declare @server nvarchar(128), @database varchar(128), @SQL nvarchar(4000)

SET ANSI_WARNINGS ON
SET ANSI_NULLS ON

IF (select gi_string1 from generalinfo where gi_name = 'Shoplink') is not null
BEGIN
select @server = (select gi_string1 from generalinfo where gi_name = 'Shoplink')
select @database = (select gi_string2 from generalinfo where gi_name = 'Shoplink')
--	set @SQL = 'select distinct codekey, code, descrip into ##tshoplink from [' + @database + ']..cmponent where codekey in (select compcdkey from [' + @database + ']..pmsched where code = compcode) and code not in (select compcode from TMTPM)'
--	MRH 7/8/2002 Multiserver support
set @SQL = 'select distinct codekey, code, descrip into ##tshoplink from [' + @server + '].[' + @database + '].dbo.cmponent where codekey in (select compcdkey from [' + @server + '].[' + @database + '].dbo.pmsched where code = compcode) and code not in (select compcode from TMTPM)'
EXEC sp_executesql @sql
insert TMTPM select codekey, descrip, code, '' from ##tshoplink
drop table ##tshoplink
--	select codekey, descript, compcode, exp_priority from TMTPM
end
SET ANSI_WARNINGS OFF
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON  [dbo].[TMT_Get_PMs] TO [public]
GO
