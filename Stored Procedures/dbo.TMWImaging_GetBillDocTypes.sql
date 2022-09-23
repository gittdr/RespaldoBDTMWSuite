SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TMWImaging_GetBillDocTypes] 
    @COMPANY VARCHAR(8) = NULL,
    @ORDERHEADERNUMBER INT = NULL
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides the bill document types for a particular company.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/08/2017   Chase Plante     WE-209653    Created
*******************************************************************************************************************/

     --DECLARE @COMPANY VARCHAR(8) = NULL
     --SELECT  @COMPANY = 'IMPCLE'

     --DECLARE @ORDERHEADERNUMBER INT = NULL
     --SELECT  @ORDERHEADERNUMBER = 52

     DECLARE @QUERY NVARCHAR(MAX);

     SET @QUERY = ' SELECT cmp_id, bdt_doctype, bdt_sequence ';
     SET @QUERY = @QUERY+' FROM billdoctypes ';

     SET @QUERY = @QUERY+' WHERE 1=1 ';

     IF(@COMPANY IS NOT NULL)
         SET @QUERY = @QUERY+' AND cmp_id = '''+@COMPANY+'''';

     IF(@ORDERHEADERNUMBER IS NOT NULL AND EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'bdt_terms' AND Object_ID = OBJECT_ID(N'schemaName.billdoctypes')))
         BEGIN
             DECLARE @TERMS AS VARCHAR(6)= NULL;
             SELECT @TERMS = ord_terms
             FROM orderheader
             WHERE ord_hdrnumber = @ORDERHEADERNUMBER;

             IF(@TERMS = 'PPD')
                 SET @QUERY = @QUERY+' AND bdt_terms IN (''P'', ''B'') ';
             IF(@TERMS = 'COL')

                 SET @QUERY = @QUERY+' AND bdt_terms IN (''C'', ''B'') ';
         END;

     IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'bdt_inv_required' AND Object_ID = OBJECT_ID(N'schemaName.billdoctypes'))
         SET @QUERY = @QUERY+' AND (bdt_inv_attach <> ''N'' OR (bdt_inv_required IS NULL AND bdt_inv_attach IS NULL)) ';

     EXEC sp_executesql @QUERY;
GO
GRANT EXECUTE ON  [dbo].[TMWImaging_GetBillDocTypes] TO [public]
GO
