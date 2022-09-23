SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMWImaging_GetInvoices]
@STARTDATE DATETIME = NULL
, @ENDDATE DATETIME = NULL
, @BILLTO VARCHAR(8) = NULL
, @ORDERNUMBER CHAR(12) = NULL
, @INVOICENUMBERS as Varchar50InParm READONLY
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides invoices by date range and optionally by the Bill To.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/08/2017   Jennifer Jackson WE-209655    Created
*******************************************************************************************************************/
--DECLARE 
--@STARTDATE DATETIME = NULL
--, @ENDDATE DATETIME = NULL
--, @BILLTO VARCHAR(8) = NULL
--, @ORDERNUMBER CHAR(12) = NULL
--, @INVOICENUMBERS as Varchar50InParm

--SELECT @STARTDATE = '2010-07-01'
--SELECT  @ENDDATE = '2016-07-31'
--SELECT  @BILLTO = 'FREPUY01'
--SELECT @ORDERNUMBER = 3015846
--insert @INVOICENUMBERS (VarcharItem) SELECT '690A'
--insert @INVOICENUMBERS (VarcharItem) SELECT '858A'

DECLARE @QUERY NVARCHAR(MAX)
SET @QUERY = ' SELECT I.*, C.cmp_edi210, C.cmp_geoloc_forsearch '
SET @QUERY = @QUERY + ' FROM	invoiceheader I LEFT OUTER JOIN '
SET @QUERY = @QUERY + ' company C ON I.ivh_billto = C.cmp_id '

IF ((SELECT COUNT(*) FROM @INVOICENUMBERS) > 0 )
SET @QUERY = @QUERY + '  INNER JOIN @INVNUMS I1 ON I.ivh_invoicenumber = I1.VarcharItem '

SET @QUERY = @QUERY + ' WHERE 1=1 '
		
IF (@BILLTO IS NOT NULL)
	SET @QUERY = @QUERY + ' AND I.ivh_billto = ''' + @BILLTO + ''''

IF (@STARTDATE IS NOT NULL)
	SET @QUERY = @QUERY + ' AND I.ivh_printdate >= ''' + CONVERT(VARCHAR(10),@STARTDATE, 101)  + ''''

IF (@ENDDATE IS NOT NULL)
	SET @QUERY = @QUERY + ' AND I.ivh_printdate <= ''' + CONVERT(VARCHAR(10),@ENDDATE, 101) + ' 23:59:59''' 
	
IF (@ORDERNUMBER IS NOT NULL)
	SET @QUERY = @QUERY + ' AND I.ord_number = ''' + @ORDERNUMBER  + ''''

IF ((SELECT COUNT(*) FROM @INVOICENUMBERS) > 0 )
	EXEC sp_executesql @QUERY, N'@INVNUMS Varchar50InParm READONLY', @INVOICENUMBERS
ELSE
	EXEC sp_executesql @QUERY

GO
GRANT EXECUTE ON  [dbo].[TMWImaging_GetInvoices] TO [public]
GO
