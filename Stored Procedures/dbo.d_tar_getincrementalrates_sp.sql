SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[d_tar_getincrementalrates_sp] 
@TarNum 			int , 
@RowSeq 			int , 
@ColSeq 			int , 
@Incremental 	char(1),
@billdate		datetime
AS

/**
 * 
 * NAME:
 * dbo.d_tar_getincrementalrates_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data d_tar_getincrementalrates_sp
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * All the valid table entries for the incremental rate selected
 *
 * PARAMETERS:
 * 001 - @TarNum			int
 *       The tariff number for the rate in question
 * 002 - @RowSeq 			int
 *       Maximum sequence # of the rows to return in the table rate
*		 Send -1 for all
 * 003 - @ColSeq 			int 
 *       Maximum sequence # of the columns to return in the table rate
 *		 Send -1 for all
 * 004 - @Incremental 	char(1)
 *       Indicates whether the rate is by Rows, Columns or Both
 * 005 - @billdate datetime
 * 		 The appropriate billing date used to validate expired cells
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 10/10/2006.01 - PTS34656 - ILB - added retire date check to the whereclause to exclcude table rate entries which have 
 *                                 been expired.  
 * 04/13/2007.01 - PTS36234 - EMK - Added billdate input parameter for apply/dont apply, active and expire date lookup
 * DPETE PTS40260 recode Paul's Hauing - add cell minimum fields to return set
 * DPETE PTS43036 Add requires to ensure cell minimum columns exist on tariffrate
 * DPETE PTS 43227 one set of returned columns was put on wrong line of proc
* DPETE 54241 get no records returned if the order only has 1/1/1950 dates on it
 **/


-- PTS 36234 EMK
-- If -1 is passed, Set Column and row maximums to a large number to retrieve all rows 
IF @ColSeq = -1 SET @ColSeq = 99999
IF @RowSeq = -1 SET @RowSeq = 99999


IF @Incremental = 'R' 

	IF @ColSeq = 0 
		SELECT tariffrowcolumn.trc_rangevalue , 
		tariffrate.tra_rate,tariffrowcolumn.trc_sequence
        ,tra_rateasflat,tra_minqty,tra_minrate
		FROM tariffrate , 
		tariffrowcolumn 
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrowcolumn.tar_number = @TarNum ) and 
		( tariffrowcolumn.trc_rowcolumn = 'R' ) and 
		( tariffrowcolumn.trc_number = tariffrate.trc_number_row ) and 
		( tariffrate.trc_number_col = 0 ) and 
		( tariffrowcolumn.trc_sequence <= @RowSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006
		ORDER BY tariffrowcolumn.trc_sequence ASC 

	ELSE 
		SELECT tariffrow.trc_rangevalue , 
		tariffrate.tra_rate,tariffrow.trc_sequence 
        ,tra_rateasflat,tra_minqty,tra_minrate
		FROM tariffrate , 
		tariffrowcolumn tariffrow , 
		tariffrowcolumn tariffcolumn 
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrow.tar_number = @TarNum ) and 
		( tariffrow.trc_rowcolumn = 'R' ) and 
		( tariffcolumn.tar_number = @TarNum ) and 
		( tariffcolumn.trc_rowcolumn = 'C' ) and 
		( tariffrate.trc_number_row = tariffrow.trc_number ) and 
		( tariffrate.trc_number_col = tariffcolumn.trc_number ) and 
		( tariffrow.trc_sequence <= @RowSeq ) and 
		( tariffcolumn.trc_sequence = @ColSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006
		ORDER BY tariffrow.trc_sequence ASC 

ELSE IF @Incremental = 'C' 
	IF @RowSeq = 0 
		SELECT tariffrowcolumn.trc_rangevalue , 
		tariffrate.tra_rate,tariffrowcolumn.trc_sequence 
        ,tra_rateasflat,tra_minqty,tra_minrate
		FROM tariffrate , 
		tariffrowcolumn 
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrowcolumn.tar_number = @TarNum ) and 
		( tariffrowcolumn.trc_rowcolumn = 'C' ) and 
		( tariffrowcolumn.trc_number = tariffrate.trc_number_col ) and 
		( tariffrate.trc_number_row = 0 ) and 
		( tariffrowcolumn.trc_sequence <= @ColSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006
		ORDER BY tariffrowcolumn.trc_sequence ASC 

	ELSE 
		SELECT tariffcolumn.trc_rangevalue, 
		tariffrate.tra_rate, tariffcolumn.trc_sequence 
        ,tra_rateasflat,tra_minqty,tra_minrate        
		FROM tariffrate, 
		tariffrowcolumn tariffrow , 
		tariffrowcolumn tariffcolumn 
        
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrow.tar_number = @TarNum ) and 
		( tariffrow.trc_rowcolumn = 'R' ) and 
		( tariffcolumn.tar_number = @TarNum ) and 
		( tariffcolumn.trc_rowcolumn = 'C' ) and 
		( tariffrate.trc_number_row = tariffrow.trc_number ) and 
		( tariffrate.trc_number_col = tariffcolumn.trc_number ) and 
		( tariffrow.trc_sequence = @RowSeq ) and 
		( tariffcolumn.trc_sequence <= @ColSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006
		ORDER BY tariffcolumn.trc_sequence ASC 

ELSE                       
	IF @ColSeq = 0 
		SELECT 0 , 
		tariffrate.tra_rate,tariffrowcolumn.trc_sequence 
        ,tra_rateasflat,tra_minqty,tra_minrate
		FROM tariffrate , 
		tariffrowcolumn 
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrowcolumn.tar_number = @TarNum ) and 
		( tariffrowcolumn.trc_rowcolumn = 'R' ) and 
		( tariffrate.trc_number_row = tariffrowcolumn.trc_number ) and 
		( tariffrate.trc_number_col = 0 ) and 
		( tariffrowcolumn.trc_sequence = @RowSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006

	ELSE IF @RowSeq = 0 
		SELECT 0 , 
		tariffrate.tra_rate,tariffrowcolumn.trc_sequence
        ,tra_rateasflat,tra_minqty,tra_minrate 
		FROM tariffrate , 
		tariffrowcolumn 
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrowcolumn.tar_number = @TarNum ) and 
		( tariffrowcolumn.trc_rowcolumn = 'C' ) and 
		( tariffrate.trc_number_row = 0 ) and 
		( tariffrate.trc_number_col = tariffrowcolumn.trc_number ) and 
		( tariffrowcolumn.trc_sequence = @ColSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006

	ELSE 
		SELECT 0 , 
		tariffrate.tra_rate,tariffrow.trc_sequence 
        ,tra_rateasflat,tra_minqty,tra_minrate 
		FROM tariffrate , 
		tariffrowcolumn tariffrow , 
		tariffrowcolumn tariffcolumn 
		WHERE ( tariffrate.tar_number = @TarNum ) and 
		( tariffrow.tar_number = @TarNum ) and 
		( tariffcolumn.tar_number = @TarNum ) and 
		( tariffrow.trc_rowcolumn = 'R' ) and 
		( tariffcolumn.trc_rowcolumn = 'C' ) and 
		( tariffrate.trc_number_row = tariffrow.trc_number ) and 
		( tariffrate.trc_number_col = tariffcolumn.trc_number ) and 
		( tariffrow.trc_sequence = @RowSeq ) and 
		( tariffcolumn.trc_sequence = @ColSeq ) and
		-- EMK PTS#36234 10/06/2006
		--( isnull(tra_retired,'12/31/2049') > getdate()) --ILB PTS#34656 10/06/2006 
		( isnull(tra_retired,'12/31/2049') >= @billdate) and 
		( isnull(tra_apply,'Y') = 'Y') and
		( isnull(tra_activedate,'01/01/1950') <= @billdate)
		 -- EMK PTS#36234 10/06/2006

GO
GRANT EXECUTE ON  [dbo].[d_tar_getincrementalrates_sp] TO [public]
GO
