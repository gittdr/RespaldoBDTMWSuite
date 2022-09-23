SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[d_tar_editrate_table_series_sp] 
( @tar_number  INT
, @row_abbr    VARCHAR(6)
, @col_abbr    VARCHAR(6)
) AS

/**
 *
 * NAME:
 * dbo.d_tar_editrate_table_series_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow d_tar_editrate_table_series
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * @tar_number      INT
 *
 * REVISION HISTORY:
 * PTS 55664 SPN Created 03/22/11
 * 
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @row_matchvalue_masked VARCHAR(100)
   DECLARE @col_matchvalue_masked VARCHAR(100)

   DECLARE @temp TABLE
   ( tar_number               INT          NULL
   , row_abbr                 VARCHAR(6)   NULL
   , row_trc_number           INT          NULL
   , row_trc_sequence         INT          NULL
   , row_matchvalue           VARCHAR(50)  NULL
   , row_matchvalue_masked    VARCHAR(100) NULL
   , row_rangevalue           MONEY        NULL
   , row_multimatch           VARCHAR(255) NULL
   , col_abbr                 VARCHAR(6)   NULL
   , col_trc_number           INT          NULL
   , col_trc_sequence         INT          NULL
   , col_matchvalue           VARCHAR(50)  NULL
   , col_matchvalue_masked    VARCHAR(100) NULL
   , col_rangevalue           MONEY        NULL
   , col_multimatch           VARCHAR(255) NULL
   , tra_rate                 MONEY        NULL
   , tra_apply                CHAR(1)      NULL
   , tra_retired              DATETIME     NULL
   , tra_activedate           DATETIME     NULL
   , tra_rateasflat           CHAR(1)      NULL
   , tra_minrate              MONEY        NULL
   , tra_minqty               CHAR(1)      NULL
   , tra_remarks1             VARCHAR(254) NULL
   , tra_remarks2             VARCHAR(254) NULL
   , tra_remarks3             VARCHAR(254) NULL
   , tra_remarks4             VARCHAR(254) NULL
   , last_updateby            VARCHAR(256) NULL
   , last_updatedate          DATETIME     NULL
   )

   DECLARE @rowdef TABLE
   ( tar_number         INT          NOT NULL
   , trc_number         INT          NOT NULL
   , trc_sequence       INT          NOT NULL
   , trc_matchvalue     VARCHAR(50)  NULL
   , trc_rangevalue     MONEY        NULL
   , trc_multimatch     VARCHAR(255) NULL
   )

   DECLARE @coldef TABLE
   ( tar_number         INT          NOT NULL
   , trc_number         INT          NOT NULL
   , trc_sequence       INT          NOT NULL
   , trc_matchvalue     VARCHAR(50)  NULL
   , trc_rangevalue     MONEY        NULL
   , trc_multimatch     VARCHAR(255) NULL
   )

   DECLARE @tarrate TABLE
   ( tar_number         INT          NOT NULL
   , trc_number_row     INT          NULL
   , trc_number_col     INT          NULL
   , tra_rate           MONEY        NULL
   , tra_rateasflat     CHAR(1)      NULL
   , tra_minqty         CHAR(1)      NULL
   , tra_minrate        MONEY        NULL
   , tra_standardhours  MONEY        NULL
   , tra_apply          CHAR(1)      NULL
   , tra_retired        DATETIME     NULL
   , tra_activedate     DATETIME     NULL
   , tra_remarks1       VARCHAR(254) NULL
   , tra_remarks2       VARCHAR(254) NULL
   , tra_remarks3       VARCHAR(254) NULL
   , tra_remarks4       VARCHAR(254) NULL
   , last_updateby      VARCHAR(256) NULL
   , last_updatedate    DATETIME     NULL
   )

   --Row Definition
   INSERT INTO @rowdef
   ( tar_number
   , trc_number
   , trc_sequence
   , trc_matchvalue
   , trc_rangevalue
   , trc_multimatch
   )
   SELECT tar_number
        , trc_number
        , trc_sequence
        , trc_matchvalue
        , trc_rangevalue
        , trc_multimatch
     FROM tariffrowcolumn NOLOCK
    WHERE trc_rowcolumn = 'R'
      AND tar_number = @tar_number

   --Column Definition
   INSERT INTO @coldef
   ( tar_number
   , trc_number
   , trc_sequence
   , trc_matchvalue
   , trc_rangevalue
   , trc_multimatch
   )
   SELECT tar_number
        , trc_number
        , trc_sequence
        , trc_matchvalue
        , trc_rangevalue
        , trc_multimatch
     FROM tariffrowcolumn NOLOCK
    WHERE trc_rowcolumn = 'C'
      AND tar_number = @tar_number

   --Rates as defined
   INSERT INTO @tarrate
   ( tar_number
   , trc_number_row
   , trc_number_col
   , tra_rate
   , tra_rateasflat
   , tra_minqty
   , tra_minrate
   , tra_standardhours
   , tra_apply
   , tra_retired
   , tra_activedate
   , tra_remarks1
   , tra_remarks2
   , tra_remarks3
   , tra_remarks4
   , last_updateby
   , last_updatedate
   )
   SELECT tar_number
        , trc_number_row
        , trc_number_col
        , tra_rate
        , tra_rateasflat
        , tra_minqty
        , tra_minrate
        , tra_standardhours
        , tra_apply
        , tra_retired
        , tra_activedate
        , tra_remarks1
        , tra_remarks2
        , tra_remarks3
        , tra_remarks4
        , last_updateby
        , last_updatedate
     FROM tariffrate NOLOCK
    WHERE tar_number = @tar_number

   --Build Table Series
   INSERT INTO @temp
   ( tar_number           
   , row_abbr             
   , row_trc_number       
   , row_trc_sequence     
   , row_matchvalue       
   , row_matchvalue_masked
   , row_rangevalue       
   , row_multimatch       
   , col_abbr             
   , col_trc_number       
   , col_trc_sequence     
   , col_matchvalue       
   , col_matchvalue_masked
   , col_rangevalue       
   , col_multimatch       
   , tra_rate             
   , tra_apply            
   , tra_retired          
   , tra_activedate       
   , tra_rateasflat       
   , tra_minrate          
   , tra_minqty           
   , tra_remarks1         
   , tra_remarks2         
   , tra_remarks3         
   , tra_remarks4         
   , last_updateby        
   , last_updatedate      
   )
   SELECT v.tar_number              AS tar_number
        , @row_abbr                 AS row_abbr
        , v.trc_number_row          AS row_trc_number
        , r.trc_sequence            AS row_trc_sequence
        , r.trc_matchvalue          AS row_matchvalue
        , @row_matchvalue_masked    AS row_matchvalue_masked
        , r.trc_rangevalue          AS row_rangevalue
        , r.trc_multimatch          AS row_multimatch
        , @col_abbr                 AS col_abbr
        , v.trc_number_col          AS col_trc_number
        , c.trc_sequence            AS col_trc_sequence
        , c.trc_matchvalue          AS col_matchvalue
        , @col_matchvalue_masked    AS col_matchvalue_masked
        , c.trc_rangevalue          AS col_rangevalue
        , c.trc_multimatch          AS col_multimatch
        , v.tra_rate                AS tra_rate
        , v.tra_apply               AS tra_apply
        , v.tra_retired             AS tra_retired
        , v.tra_activedate          AS tra_activedate
        , v.tra_rateasflat          AS tra_rateasflat
        , v.tra_minrate             AS tra_minrate
        , v.tra_minqty              AS tra_minqty
        , v.tra_remarks1            AS tra_remarks1
        , v.tra_remarks2            AS tra_remarks2
        , v.tra_remarks3            AS tra_remarks3
        , v.tra_remarks4            AS tra_remarks4
        , v.last_updateby           AS last_updateby
        , v.last_updatedate         AS last_updatedate
     FROM @tarrate v
   LEFT OUTER JOIN @rowdef r ON v.trc_number_row = r.trc_number
   LEFT OUTER JOIN @coldef c ON v.trc_number_col = c.trc_number


   --Populate Masked Values
   --City for Row
   IF @row_abbr = 'OCT' OR @row_abbr = 'DCT' OR @row_abbr = 'SCT'
   BEGIN
     UPDATE t
        SET t.row_matchvalue_masked = c.cty_nmstct
       FROM @temp t
     LEFT OUTER JOIN city c ON CONVERT(INT, t.row_matchvalue) = c.cty_code
   END
   --City for Col
   IF @col_abbr = 'OCT' OR @col_abbr = 'DCT' OR @col_abbr = 'SCT'
   BEGIN
     UPDATE t
        SET t.col_matchvalue_masked = c.cty_nmstct
       FROM @temp t
     LEFT OUTER JOIN city c ON CONVERT(INT, t.col_matchvalue) = c.cty_code
   END
   --Route for Row
   IF @row_abbr = 'ROUTE'
   BEGIN
     UPDATE t
        SET t.row_matchvalue_masked = r.rth_name
       FROM @temp t
     LEFT OUTER JOIN routeheader r ON CONVERT(INT, t.row_matchvalue) = r.rth_id
   END
   --Route for Col
   IF @col_abbr = 'ROUTE'
   BEGIN
     UPDATE t
        SET t.col_matchvalue_masked = r.rth_name
       FROM @temp t
     LEFT OUTER JOIN routeheader r ON CONVERT(INT, t.col_matchvalue) = r.rth_id
   END
   
   SELECT *
     FROM @temp

END
GO
GRANT EXECUTE ON  [dbo].[d_tar_editrate_table_series_sp] TO [public]
GO
