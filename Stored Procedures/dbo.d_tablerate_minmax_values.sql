SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_tablerate_minmax_values] 		(@tar_number int, 
						@row_sequence int, 
						@col_sequence int)
AS
/*
PTS40260 4/9/08 recode Pauls 23795 into main source DPETE
PTS46985 7/14/2009 Bottom of proc; Processing if new GI is SET.
PTS66776 Documention wants to change the max table rate amoutn to ALWAYS require a fixed rate flag
    prior to now it was nto required on a single row or single column table
*/


DECLARE	@value		decimal(14,4),
	@value2		decimal(14,4),
	@minrule	varchar(255),
	@maxrule	varchar(255),
	@colcount	int,
	@count		int, 
	@type		char(1) 

CREATE TABLE #tar_minmax (
	tar_number 		int null,
	row_min			decimal(14,4) null,
	row_minqty		char(1) null,
	row_max			decimal(14,4) null,
	col_min			decimal(14,4) null,
	col_minqty		char(1) null,
	col_max			decimal(14,4) null,
	table_min		decimal(14,4) null,
	table_minqty		char(1) null,
	table_max		decimal(14,4) null,
	max_rule		varchar(255),
	min_rule		varchar(255)
	)

If @col_sequence is null
	set @col_sequence = 0

Insert into #tar_minmax (tar_number,
			max_rule,
			min_rule)
	SELECT 		@tar_number,
			(SELECT gi_string1
			FROM 	generalinfo
			where	gi_name = 'MaxTblRateAdjustmentRule'),
			(SELECT gi_string1
			FROM 	generalinfo
			where	gi_name = 'MinTblRateAdjustmentRule')

	
-- ROW MIN
set @value = -1
--select 		@value = IsNull(tariffrate.tra_rate,0)
select 		@value = IsNull(tariffrate.tra_minrate,0), 
                @type = IsNull(tariffrate.tra_minqty, 'N') 
from 		tariffrate, 
		tariffrowcolumn row, 
		tariffrowcolumn col
where 		tariffrate.trc_number_row = row.trc_number AND
		IsNull(tariffrate.tra_apply, 'Y') = 'Y' AND
		(tariffrate.tra_rateasflat = 'Y' OR 
                 (tariffrate.tra_rateasflat = 'N' AND col.trc_rangevalue <= -2147483647)) AND
		row.tar_number = @tar_number AND
		row.trc_sequence = @row_sequence AND
		row.trc_rowcolumn = 'R' AND
		tariffrate.trc_number_col = col.trc_number AND
		col.tar_number = @tar_number AND
		col.trc_sequence = (select MIN(trc_sequence)
					from	tariffrowcolumn trc
					where 	trc.tar_number = col.tar_number AND
						trc_rowcolumn = 'C') AND
		col.trc_rowcolumn = 'C'

UPDATE		#tar_minmax
SET		row_min = @value, 
                row_minqty = @type 
-- END ROW MIN


-- ROW MAX
set @value = -1
select 		@value = IsNull(tariffrate.tra_rate,0)
from 		tariffrate, 
		tariffrowcolumn row, 
		tariffrowcolumn col
where 		tariffrate.trc_number_row = row.trc_number AND
		IsNull(tariffrate.tra_apply, 'Y') = 'Y' AND
		tariffrate.tra_rateasflat = 'Y' AND
		row.tar_number = @tar_number AND
		row.trc_sequence = @row_sequence AND
		row.trc_rowcolumn = 'R' AND
		tariffrate.trc_number_col = col.trc_number AND
		col.tar_number = @tar_number AND
		col.trc_sequence = (select max(trc_sequence)
					from	tariffrowcolumn trc
					where 	trc.tar_number = col.tar_number AND
						trc_rowcolumn = 'C') AND
		col.trc_rowcolumn = 'C'

UPDATE		#tar_minmax
SET		row_max = @value
-- END ROW MAX


-- COL MIN
set @value = -1
--select 		@value = IsNull(tariffrate.tra_rate,0)
select 		@value = IsNull(tariffrate.tra_minrate,0), 
                @type = IsNull(tariffrate.tra_minqty, 'N') 
from 		tariffrate, 
		tariffrowcolumn row, 
		tariffrowcolumn col
where 		tariffrate.trc_number_col = col.trc_number AND
		IsNull(tariffrate.tra_apply, 'Y') = 'Y' AND
		(tariffrate.tra_rateasflat = 'Y' OR 
                 (tariffrate.tra_rateasflat = 'N' AND row.trc_rangevalue <= -2147483647)) AND
		col.tar_number = @tar_number AND
		col.trc_sequence = @col_sequence AND
		col.trc_rowcolumn = 'C' AND
		tariffrate.trc_number_row = row.trc_number AND
		row.tar_number = @tar_number AND
		row.trc_sequence = (select MIN(trc_sequence)
					from	tariffrowcolumn trc
					where 	trc.tar_number = row.tar_number AND
						trc_rowcolumn = 'R') AND
		row.trc_rowcolumn = 'R'

UPDATE		#tar_minmax
SET		col_min = @value, 
                col_minqty = @type 
-- END COL MIN


-- COL MAX
set @value = -1
select 		@value = IsNull(tariffrate.tra_rate,0)
from 		tariffrate, 
		tariffrowcolumn row, 
		tariffrowcolumn col
where 		tariffrate.trc_number_col = col.trc_number AND
		IsNull(tariffrate.tra_apply, 'Y') = 'Y' AND
		tariffrate.tra_rateasflat = 'Y' AND
		col.tar_number = @tar_number AND
		col.trc_sequence = @col_sequence AND
		col.trc_rowcolumn = 'C' AND
		tariffrate.trc_number_row = row.trc_number AND
		row.tar_number = @tar_number AND
		row.trc_sequence = (select max(trc_sequence)
					from	tariffrowcolumn trc
					where 	trc.tar_number = row.tar_number AND
						trc_rowcolumn = 'R') AND
		row.trc_rowcolumn = 'R'

UPDATE		#tar_minmax
SET		col_max = @value
-- END COL MAX

-- Get the dimensions of the source table to know how to get the MIN/MAX values
select 	@colcount = count(distinct(trc_number))
from 	tariffrowcolumn
where 	tar_number = @tar_number and 
	trc_rowcolumn = 'C'

-- Table MIN no columns
set @value = -1
If @colcount < 2
	select 	@value = tra_minrate, 
                @type = IsNull(tariffrate.tra_minqty, 'N') 
	from 	tariffrate 
	where 	trc_number_row = (select 	trc_number 
				 from 		tariffrowcolumn 
				 where 		tar_number = @tar_number and 
						trc_rowcolumn = 'R' AND
			 			trc_rangevalue <= -2147483647) and 
			            isnull(tra_apply, 'Y') = 'Y' AND
			 			tariffrate.tra_rateasflat = 'Y'  --66776

-- TABLE MIN with columns
If @value < 1 
   BEGIN
	set @value = -1
	select 		@value = IsNull(tariffrate.tra_rate,0), 
	                @type = IsNull(tariffrate.tra_minqty, 'N') 
	from 		tariffrate, tariffrowcolumn row, tariffrowcolumn col
	where 		trc_number_row = row.trc_number and 
			row.tar_number = @tar_number and
			row.trc_rangevalue = -2147483647 and
			row.trc_rowcolumn = 'R' and
			trc_number_col = col.trc_number and 
			col.tar_number = @tar_number and
			col.trc_rangevalue = -2147483647 and
			col.trc_rowcolumn = 'C' and
			tra_rate > 0 and 
			isnull(tra_apply, 'Y') = 'Y' AND
			tariffrate.tra_rateasflat = 'Y'
   END
UPDATE		#tar_minmax
SET		table_min = @value, 
                table_minqty = @type 
-- END TABLE MIN

-- Table MAX no columns
set @value = -1
If @colcount < 2
   	select 	@value = tra_rate 
	from 	tariffrate 
	where 	trc_number_row = (select MIN(trc_number) 
                                    from tariffrowcolumn 
                                   where tar_number = @tar_number AND 
                                         trc_rowcolumn = 'R' AND
                                         --PTS23054 MBR 05/14/04
                                         trc_matchvalue = 'UNKNOWN' AND
                                         trc_rangevalue >= 2147483647) and 
			                             isnull(tra_apply, 'Y') = 'Y'AND  --66776
			                             tariffrate.tra_rateasflat = 'Y'   --66776
-- TABLE MAX
If @value < 1
   BEGIN
	set @value = -1
	select 		@value = IsNull(tariffrate.tra_rate,0)
	from 		tariffrate, tariffrowcolumn row, tariffrowcolumn col
	where 		trc_number_row = row.trc_number and 
			row.tar_number = @tar_number and
			row.trc_rangevalue = 2147483647 and
			row.trc_rowcolumn = 'R' and
			trc_number_col = col.trc_number and 
			col.tar_number = @tar_number and
			col.trc_rangevalue = 2147483647 and
			col.trc_rowcolumn = 'C' and
			tra_rate > 0 and 
			isnull(tra_apply, 'Y') = 'Y' AND
			tariffrate.tra_rateasflat = 'Y' 
   END

UPDATE		#tar_minmax
SET		table_max = @value
-- END TABLE MAX

-- MIN/MAX RULE
set @minrule = ''
set @maxrule = ''
select 		@minrule = IsNull(tariffheader.tar_minrule,''),
		@maxrule = IsNull(tariffheader.tar_maxrule,'')
from 		tariffheader
where 		tariffheader.tar_number = @tar_number

If @minrule <> ''
UPDATE		#tar_minmax
SET		min_rule = @minrule

If @maxrule <> ''
UPDATE		#tar_minmax
SET		max_rule = @maxrule
-- END MIN/MAX RULE

-- PTS 46985 <<start>>
-- If there are NO min/max settings and this GI is on - return values as if not found.
If exists (select * from generalinfo where gi_name = 'IgnoreRateAsFlatonMaxMinProc' and gi_string1 = 'Y')
BEGIN
		declare @stop_gap_minmax int
		declare @stop_gap_rateasflat int
		select @stop_gap_rateasflat = ( select count(*) from tariffrate where tar_number = @tar_number and tra_rateasflat <> 'N')
		select @stop_gap_minmax = ( select count(*) from tariffrate where tar_number = @tar_number and tra_minrate > 0  OR tra_minqty <> 'N' or tra_mincharge > 0 )
		IF (  @stop_gap_rateasflat <> 0 AND @stop_gap_minmax = 0 ) 
		BEGIN 
		Update #tar_minmax
		SET row_min = -1,
			row_max = -1,
			col_min = -1,
			col_max = -1,
			table_min = -1,
			table_max = -1
		END
END
-- PTS 46985 <<end>>

SELECT 	tar_number,
	row_min,
	row_max,
	col_min,
	col_max,
	table_min,
	table_max,
	min_rule,
	max_rule, 
        row_minqty, 
        col_minqty, 
        table_minqty 
FROM	#tar_minmax

DROP TABLE #tar_minmax
GO
GRANT EXECUTE ON  [dbo].[d_tablerate_minmax_values] TO [public]
GO
