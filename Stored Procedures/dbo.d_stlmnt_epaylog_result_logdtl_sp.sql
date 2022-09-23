SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROC [dbo].[d_stlmnt_epaylog_result_logdtl_sp] 
      ( @Query_ID          varchar(30)
      , @reference_number  varchar(30)
      , @voucher_number    varchar(30)
      )
AS

/*
*
*
* NAME:
* dbo.d_stlmnt_epaylog_result_logdtl_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to fetch paydetail from epaytransadd_log table
*
* RETURNS:
*
* NOTHING:
*
* 05/13/2011 PTS55706 SPN - Created Initial Version
*
*/ 

DECLARE @line_item_code varchar(30)
      , @line_item_desc varchar(500)
      , @line_item_amt  money
      , @i              int
      , @ls_SQL         nvarchar(4000)
      , @pyt_itemcode   varchar(100)

BEGIN

   DECLARE @epay_log TABLE
   ( pyd_number         varchar(30)    NULL
   , pyt_itemcode       varchar(6)     NULL
   , pyd_description    varchar(500)   NULL
   , pyd_amount         money          NULL
   )
   
   CREATE TABLE #temp
   ( line_item_code     varchar(30)    NULL
   , line_item_desc     varchar(500)   NULL
   , line_item_amt      money          NULL
   )

   --**********************************--
   -- Read all 100 columns in EPay Log --
   --**********************************--
   SET @i = 0
   WHILE @i < 100
   BEGIN
      SET @ls_SQL = 'INSERT #temp (line_item_code,line_item_desc,line_item_amt)
                     SELECT line_item_code_'  + CAST(@i AS VARCHAR) +
                        ' , line_item_descr_' + CAST(@i AS VARCHAR) +
                        ' , line_item_amt_'   + CAST(@i AS VARCHAR) +
                     ' FROM epaytransadd_log' +
                    ' WHERE query_id = ''' + @Query_id + '''' +
                      ' AND reference_number = ''' + @reference_number + '''' + 
                      ' AND voucher_number = ''' + @voucher_number + ''''

      SET @i = @i + 1

      EXEC sp_executesql @ls_SQL

      SELECT @line_item_code = line_item_code
           , @line_item_desc = line_item_desc
           , @line_item_amt =  line_item_amt
        FROM #temp
      DELETE FROM #temp

      --check pyd_number
      IF @line_item_code IS NULL
      BEGIN
         SELECT @i = 100
         CONTINUE
      END

      --check if line_item_desc has a matching pyt_itemcode in TMWSuite
      SELECT @pyt_itemcode = MAX(pyt_itemcode)
        FROM paytype
       WHERE pyt_description = @line_item_desc


      INSERT INTO @epay_log
      ( pyd_number
      , pyt_itemcode
      , pyd_description
      , pyd_amount
      )
      VALUES 
      ( @line_item_code
      , @pyt_itemcode
      , @line_item_desc
      , @line_item_amt
      )

   END
   
   DROP TABLE #temp

   SELECT *
     FROM @epay_log
END
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_epaylog_result_logdtl_sp] TO [public]
GO
