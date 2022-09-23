SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[TMT_GetCustomers]
as
/**
*
* NAME:
* dbo.TMT_GetCustomers
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Get vendor information from Transman
*
* RETURNS:
* Transman vendor info.
* RESULT SETS:
* none.
*
* PARAMETERS:
*
* REVISION HISTORY:
* 2/27/2005 - MRH – Created
* MB  05/07/2009 Expand String @SQL to 4000
*
**/


Declare @shoplink int
Declare @sql 			nvarchar(4000),
@tmtserver		varchar(80),
@tmtdb			varchar(25)

SELECT @shoplink =
COUNT(1)
FROM generalinfo
where gi_name = 'Shoplink' and
gi_integer1 > 0

IF @shoplink = 0 return                 -- SHOPLINK NOT Installed

SET ANSI_NULLS ON
set ANSI_WARNINGS ON

IF ISNULL((select gi_string1 from generalinfo where gi_name = 'Shoplink'), '') <> ''
BEGIN
select @tmtserver = '[' + gi_string1 + ']' from generalinfo where gi_name = 'Shoplink'
select @tmtdb = '[' + gi_string2 + ']' from generalinfo where gi_name = 'Shoplink'
SET @SQL= 'SELECT CUSTID, NAME FROM ' + @tmtserver + '.' + @tmtdb + '.dbo.VIEW_CUSTOMERS ORDER BY CUSTID'
EXEC sp_executesql @sql
END
ELSE
BEGIN
select @tmtdb = '[' + gi_string2 + ']' from generalinfo where gi_name = 'Shoplink'
SET @SQL= 'SELECT CUSTID, NAME FROM ' + @tmtdb + '.dbo.VIEW_CUSTOMERS ORDER BY CUSTID'
EXEC sp_executesql @sql
END
SET ANSI_NULLS OFF
set ANSI_WARNINGS OFF
GO
GRANT EXECUTE ON  [dbo].[TMT_GetCustomers] TO [public]
GO
