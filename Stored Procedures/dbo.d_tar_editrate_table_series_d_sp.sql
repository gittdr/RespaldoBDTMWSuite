SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[d_tar_editrate_table_series_d_sp] 
( @tar_number           INT
, @row_abbr             VARCHAR(6)
, @row_trc_number       INT
, @row_trc_sequence     INT
, @row_matchvalue       VARCHAR(50)
, @row_rangevalue       MONEY
, @row_multimatch       VARCHAR(255)
, @col_abbr             VARCHAR(6)
, @col_trc_number       INT
, @col_trc_sequence     INT
, @col_matchvalue       VARCHAR(50)
, @col_rangevalue       MONEY
, @col_multimatch       VARCHAR(255)
, @tra_rate             MONEY
, @tra_apply            CHAR(1)
, @tra_retired          DATETIME
, @tra_activedate       DATETIME
, @tra_rateasflat       CHAR(1)
, @tra_minrate          MONEY
, @tra_minqty           CHAR(1)
, @tra_remarks1         VARCHAR(254)
, @tra_remarks2         VARCHAR(254)
, @tra_remarks3         VARCHAR(254)
, @tra_remarks4         VARCHAR(254)
, @last_updateby        VARCHAR(256)
, @last_updatedate      DATETIME
) AS

/**
 *
 * NAME:
 * dbo.d_tar_editrate_table_series_d_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for deleting from table tariffrowcolumn and tariffrate
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 *
 * @tar_number           INT
 * @row_trc_number       INT
 * @row_trc_sequence     INT
 * @row_matchvalue       VARCHAR(50)
 * @row_rangevalue       MONEY
 * @row_multimatch       VARCHAR(255)
 * @col_trc_number       INT
 * @col_trc_sequence     INT
 * @col_matchvalue       VARCHAR(50)
 * @col_rangevalue       MONEY
 * @col_multimatch       VARCHAR(255)
 * @tra_rate             MONEY
 * @tra_apply            CHAR(1)
 * @tra_retired          DATETIME
 * @tra_activedate       DATETIME
 * @tra_rateasflat       CHAR(1)
 * @tra_minrate          MONEY
 * @tra_minqty           CHAR(1)
 * @tra_remarks1         VARCHAR(254)
 * @tra_remarks2         VARCHAR(254)
 * @tra_remarks3         VARCHAR(254)
 * @tra_remarks4         VARCHAR(254)
 * @last_updateby        VARCHAR(256)
 * @last_updatedate      DATETIME
 *
 * REVISION HISTORY:
 * PTS 55664 SPN Created 04/01/11
 * 
 **/

SET NOCOUNT ON

BEGIN

DECLARE @count_row INT
DECLARE @count_col INT

   --Delete Rate
   DELETE FROM tariffrate
    WHERE tar_number     = @tar_number
      AND trc_number_row = @row_trc_number
      AND trc_number_col = @col_trc_number
   
   --Check and Delete ROW when not in use by any rate
   IF @row_abbr <> 'NOT'
   BEGIN
      SELECT @count_row = COUNT(1)
        FROM tariffrate
       WHERE tar_number     = @tar_number
         AND trc_number_row = @row_trc_number
         AND trc_number_row <> 0
      If @count_row = 0
         DELETE FROM tariffrowcolumn
          WHERE tar_number = @tar_number
            AND trc_number = @row_trc_number
            AND trc_number <> 0
            AND trc_rowcolumn = 'R'
   END

   --Check and Delete COL when not in use by any rate
   IF @col_abbr <> 'NOT'
   BEGIN
      SELECT @count_col = COUNT(1)
        FROM tariffrate
       WHERE tar_number     = @tar_number
         AND trc_number_col = @col_trc_number
         AND trc_number_col <> 0
      If @count_col = 0
         DELETE FROM tariffrowcolumn
          WHERE tar_number = @tar_number
            AND trc_number = @col_trc_number
            AND trc_number <> 0
            AND trc_rowcolumn = 'C'
   END

END
GO
GRANT EXECUTE ON  [dbo].[d_tar_editrate_table_series_d_sp] TO [public]
GO
