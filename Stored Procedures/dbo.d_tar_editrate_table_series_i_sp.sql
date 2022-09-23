SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[d_tar_editrate_table_series_i_sp] 
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
 * dbo.d_tar_editrate_table_series_i_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for inserting into table tariffrowcolumn and tariffrate
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

   --Create ROW when needed
   IF @row_abbr <> 'NOT'
   BEGIN
      If @row_trc_number IS NULL OR @row_trc_number <= 0
      BEGIN
         SELECT @row_trc_number = trc_number
           FROM tariffrowcolumn
          WHERE tar_number = @tar_number
            AND trc_rowcolumn = 'R'
            AND trc_matchvalue = @row_matchvalue
            AND trc_rangevalue = @row_rangevalue
      END
      IF @row_trc_number IS NULL OR @row_trc_number <= 0
         BEGIN
            EXECUTE @row_trc_number = dbo.getsystemnumber 'TARRC', ''
          
            INSERT INTO tariffrowcolumn
            ( tar_number
            , trc_number
            , trc_sequence
            , trc_rowcolumn
            , trc_matchvalue
            , trc_rangevalue
            , trc_multimatch
            , last_updateby
            , last_updatedate
            )
            VALUES
            ( @tar_number
            , @row_trc_number
            , @row_trc_sequence
            , 'R'
            , @row_matchvalue
            , @row_rangevalue
            , @row_multimatch
            , @last_updateby
            , @last_updatedate
            )
         END
      Else
         BEGIN
            UPDATE tariffrowcolumn
               SET trc_matchvalue  = @row_matchvalue
                 , trc_rangevalue  = @row_rangevalue
                 , trc_multimatch  = @row_multimatch
                 , last_updateby   = @last_updateby
                 , last_updatedate = @last_updatedate
             WHERE tar_number = @tar_number
               AND trc_number = @row_trc_number
         END
   END

   --Create COL when needed
   IF @col_abbr <> 'NOT'
   BEGIN
      If @col_trc_number IS NULL OR @col_trc_number <= 0
      BEGIN
         SELECT @col_trc_number = trc_number
           FROM tariffrowcolumn
          WHERE tar_number = @tar_number
            AND trc_rowcolumn = 'C'
            AND trc_matchvalue = @col_matchvalue
            AND trc_rangevalue = @col_rangevalue
      END
      If @col_trc_number IS NULL OR @col_trc_number <= 0
         BEGIN
            EXECUTE @col_trc_number = dbo.getsystemnumber 'TARRC', ''
            INSERT INTO tariffrowcolumn
            ( tar_number
            , trc_number
            , trc_sequence
            , trc_rowcolumn
            , trc_matchvalue
            , trc_rangevalue
            , trc_multimatch
            , last_updateby
            , last_updatedate
            )
            VALUES
            ( @tar_number
            , @col_trc_number
            , @col_trc_sequence
            , 'C'
            , @col_matchvalue
            , @col_rangevalue
            , @col_multimatch
            , @last_updateby
            , @last_updatedate
            )
         END
      Else
         BEGIN
            UPDATE tariffrowcolumn
               SET trc_matchvalue  = @col_matchvalue
                 , trc_rangevalue  = @col_rangevalue
                 , trc_multimatch  = @col_multimatch
                 , last_updateby   = @last_updateby
                 , last_updatedate = @last_updatedate
             WHERE tar_number = @tar_number
               AND trc_number = @col_trc_number
         END
   END

  If @row_trc_number IS NULL 
     SELECT @row_trc_number = 0
  If @col_trc_number IS NULL 
     SELECT @col_trc_number = 0

   --Create Rate when needed
   INSERT INTO tariffrate
   ( tar_number
   , trc_number_row
   , trc_number_col
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
   VALUES
   ( @tar_number
   , @row_trc_number
   , @col_trc_number
   , @tra_rate
   , @tra_apply
   , @tra_retired
   , @tra_activedate
   , @tra_rateasflat
   , @tra_minrate
   , @tra_minqty
   , @tra_remarks1
   , @tra_remarks2
   , @tra_remarks3
   , @tra_remarks4
   , @last_updateby
   , @last_updatedate
   )
   
END
GO
GRANT EXECUTE ON  [dbo].[d_tar_editrate_table_series_i_sp] TO [public]
GO
