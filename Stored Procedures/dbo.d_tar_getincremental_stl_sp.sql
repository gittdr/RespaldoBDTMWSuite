SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROC [dbo].[d_tar_getincremental_stl_sp]
   @TarNum        int ,
   @RowSeq        int ,
   @ColSeq        int ,
   @Incremental   char(1)
 , @billdate      datetime
AS

-- PTS 36234
-- Set Column and row maxiums to a large number
IF @ColSeq = -1 SET @ColSeq = 99999
IF @RowSeq = -1 SET @RowSeq = 99999

if @Incremental = 'R'

   if @ColSeq = 0

      SELECT tariffrowcolumnstl.trc_rangevalue ,
            tariffratestl.tra_rate,tariffrowcolumnstl.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.trc_rowcolumn = 'R' ) and
               ( tariffrowcolumnstl.trc_number = tariffratestl.trc_number_row ) and
               ( tariffratestl.trc_number_col = 0 ) and
               ( tariffrowcolumnstl.trc_sequence <= @RowSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN
         ORDER BY tariffrowcolumnstl.trc_sequence ASC

   else

      SELECT tariffrow.trc_rangevalue ,
            tariffratestl.tra_rate ,tariffrow.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl tariffrow ,
               tariffrowcolumnstl tariffcolumn
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrow.tar_number = @TarNum ) and
               ( tariffrow.trc_rowcolumn = 'R' ) and
               ( tariffcolumn.tar_number = @TarNum ) and
               ( tariffcolumn.trc_rowcolumn = 'C' ) and
               ( tariffratestl.trc_number_row = tariffrow.trc_number ) and
               ( tariffratestl.trc_number_col = tariffcolumn.trc_number ) and
               ( tariffrow.trc_sequence <= @RowSeq ) and
               ( tariffcolumn.trc_sequence = @ColSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN
         ORDER BY tariffrow.trc_sequence ASC

else if @Incremental = 'C'

   if @RowSeq = 0

      SELECT tariffrowcolumnstl.trc_rangevalue ,
            tariffratestl.tra_rate,tariffrowcolumnstl.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.trc_rowcolumn = 'C' ) and
               ( tariffrowcolumnstl.trc_number = tariffratestl.trc_number_col ) and
               ( tariffratestl.trc_number_row = 0 ) and
               ( tariffrowcolumnstl.trc_sequence <= @ColSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN
         ORDER BY tariffrowcolumnstl.trc_sequence ASC

   else

      SELECT tariffcolumn.trc_rangevalue ,
            tariffratestl.tra_rate,tariffcolumn.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl tariffrow ,
               tariffrowcolumnstl tariffcolumn
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrow.tar_number = @TarNum ) and
               ( tariffrow.trc_rowcolumn = 'R' ) and
               ( tariffcolumn.tar_number = @TarNum ) and
               ( tariffcolumn.trc_rowcolumn = 'C' ) and
               ( tariffratestl.trc_number_row = tariffrow.trc_number ) and
               ( tariffratestl.trc_number_col = tariffcolumn.trc_number ) and
               ( tariffrow.trc_sequence = @RowSeq ) and
               ( tariffcolumn.trc_sequence <= @ColSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN
         ORDER BY tariffcolumn.trc_sequence ASC

else /* not incremental */

   if @ColSeq = 0

      SELECT 0 ,
            tariffratestl.tra_rate,tariffrowcolumnstl.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.trc_rowcolumn = 'R' ) and
               ( tariffratestl.trc_number_row = tariffrowcolumnstl.trc_number ) and
               ( tariffratestl.trc_number_col = 0 ) and
               ( tariffrowcolumnstl.trc_sequence = @RowSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN

   else if @RowSeq = 0

      SELECT 0 ,
            tariffratestl.tra_rate ,tariffrowcolumnstl.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.tar_number = @TarNum ) and
               ( tariffrowcolumnstl.trc_rowcolumn = 'C' ) and
               ( tariffratestl.trc_number_row = 0 ) and
               ( tariffratestl.trc_number_col = tariffrowcolumnstl.trc_number ) and
               ( tariffrowcolumnstl.trc_sequence = @ColSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN

   else

      SELECT 0 ,
            tariffratestl.tra_rate,tariffcolumn.trc_sequence
         FROM tariffratestl ,
               tariffrowcolumnstl tariffrow ,
               tariffrowcolumnstl tariffcolumn
         WHERE ( tariffratestl.tar_number = @TarNum ) and
               ( tariffrow.tar_number = @TarNum ) and
               ( tariffcolumn.tar_number = @TarNum ) and
               ( tariffrow.trc_rowcolumn = 'R' ) and
               ( tariffcolumn.trc_rowcolumn = 'C' ) and
               ( tariffratestl.trc_number_row = tariffrow.trc_number ) and
               ( tariffratestl.trc_number_col = tariffcolumn.trc_number ) and
               ( tariffrow.trc_sequence = @RowSeq ) and
               ( tariffcolumn.trc_sequence = @ColSeq )
           --BEGIN PTS 65313 SPN
           AND ( IsNull(tariffratestl.tra_retired,'12/31/2049') >= @billdate)
           AND ( IsNull(tariffratestl.tra_apply,'Y') = 'Y')
           AND ( IsNull(tariffratestl.tra_activedate,'01/01/1950') <= @billdate)
           --END PTS 65313 SPN



GO
GRANT EXECUTE ON  [dbo].[d_tar_getincremental_stl_sp] TO [public]
GO
