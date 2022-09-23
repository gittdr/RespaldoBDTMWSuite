SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[d_tar_editrate_table_series_u_sp] 
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
 * dbo.d_tar_editrate_table_series_u_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for updating into table tariffrowcolumn and tariffrate
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

   --Update ROW
   IF @row_abbr <> 'NOT'
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

   --Update COL
   IF @col_abbr <> 'NOT'
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

   --Update Rate
   UPDATE tariffrate
      SET tra_rate         = @tra_rate
        , tra_apply        = @tra_apply
        , tra_retired      = @tra_retired
        , tra_activedate   = @tra_activedate
        , tra_rateasflat   = @tra_rateasflat
        , tra_minrate      = @tra_minrate
        , tra_minqty       = @tra_minqty
        , tra_remarks1    = @tra_remarks1
        , tra_remarks2    = @tra_remarks2
        , tra_remarks3    = @tra_remarks3
        , tra_remarks4    = @tra_remarks4
        , last_updateby    = @last_updateby
        , last_updatedate  = @last_updatedate
    WHERE tar_number     = @tar_number
      AND trc_number_row = @row_trc_number
      AND trc_number_col = @col_trc_number

END
GO
GRANT EXECUTE ON  [dbo].[d_tar_editrate_table_series_u_sp] TO [public]
GO
