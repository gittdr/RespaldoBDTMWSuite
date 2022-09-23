SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[d_tariffrate_sp] (@pl_tarnum int) as
-- 1-8-2009 33529 core recode:  replace tra_minqty_kag with  tra_minrate.
-- 1-8-2009 33529 core recode:  ADD tra_minqty (money)with  tra_minqty char(1).
-- 1-8-2009 33529 core recode:  ADD "cellmins" columns to match datashare.
-- 4/28/09 DPETE 46788 existing records with null tra_activedate are set to dark grey background
--     on tariff window (KAG recode  33529) No one can 
-- 6/26/09 DPETE PTS48037 try to improve speed for non "cellhistory" users 
set nocount on
declare @li_cellhistory int
select @li_cellhistory = 0

if exists (select * from generalinfo where gi_name = 'Tar_Show_Cell_History' and gi_string1 = 'Y') -- new gi setting
select @li_cellhistory = 1

if @li_cellhistory = 1
exec autogenerate_tariffratehistory_sp @pl_tarnum


-- do this regardless of the li_cellhistory value.
create table #temp(tra_rate money null,
					trc_number_row int null,
					trc_number_col int null,
					tar_number int null,
					tariffrow_sequence int null,
					tariffcolumn_sequence int null,
					tra_apply char(1) null,
					tra_retired datetime null,
					tra_activedate datetime null,
					tra_minrate money null,
					tra_mincharge money null,
					tra_billmiles money null,
					tra_paymiles money null,
					tra_standardhours money null,
					tra_minqty char(1) null,
					--- cellmins dw needs to match for datashare
						tra_rateasflat char(1) null,			
						tariffrow_trc_rangevalue money null,			
						tariffcolumn_trc_rangevalue	 money null
)
/*					

IsNull((select	trh.tra_rate from tariffratehistory trh  where trh.tar_number = @pl_tarnum and 
						trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
						getdate() between trh_fromdate and trh_todate) ,
				(select trh.tra_rate from tariffratehistory trh where trh.tar_number = @pl_tarnum and 
				trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
				trh_todate = (select max(trh_todate) from tariffratehistory trh2 where trh2.tar_number = @pl_tarnum and 
				trh2.trc_number_row = tariffrow.trc_number and trh2.trc_number_col = tariffcolumn.trc_number))) as tra_rate,

			(select trh.trh_todate from tariffratehistory trh where trh.tar_number = @pl_tarnum and 
					trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
					getdate() between trh_fromdate and trh_todate)tra_retired,
			(select trh.trh_fromdate from tariffratehistory trh where trh.tar_number = @pl_tarnum and 
					trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
					getdate() between trh_fromdate and trh_todate) tra_activedate,
*/
insert into #temp
SELECT		tra_rate,  --null,
			tariffrate.trc_number_row,
			tariffrate.trc_number_col,
			tariffrate.tar_number,
			tariffrow.trc_sequence tariffrow_sequence,
			tariffcolumn.trc_sequence tariffcolumn_sequence,
			tra_apply,
			tra_retired, --null,
			tra_activedate, --null,
			tra_minrate,
			tra_mincharge,
			tra_billmiles,
			tra_paymiles,
			tra_standardhours,
			tra_minqty,
			--- cellmins dw needs to match for datashare	
			tra_rateasflat,				
			tariffrow.trc_rangevalue,		
			tariffcolumn.trc_rangevalue		
FROM	tariffrate 
		left outer join tariffrowcolumn as tariffrow on tariffrate.trc_number_row = tariffrow.trc_number
		left outer join tariffrowcolumn as tariffcolumn on tariffrate.trc_number_col = tariffcolumn.trc_number	
WHERE	tariffrate.tar_number = @pl_tarnum

if @li_cellhistory = 1 
BEGIN
    update #temp
    set tra_rate = null, tra_activedate = null, tra_retired = null

	update	#temp set tra_rate = trh.tra_rate 
	from	tariffratehistory trh  
	where	trh.tar_number = @pl_tarnum and 
			trh.trc_number_row = #temp.trc_number_row and trh.trc_number_col = #temp.trc_number_col and 
			getdate() between trh_fromdate and trh_todate
	
	update	#temp set tra_rate = trh.tra_rate 
	from	tariffratehistory trh 
	where	trh.tar_number = @pl_tarnum and 
			#temp.tra_rate is null and
			trh.trc_number_row = #temp.trc_number_row and trh.trc_number_col = #temp.trc_number_col and 
			trh_todate =	(select max(trh_todate) from tariffratehistory trh2 where trh2.tar_number = @pl_tarnum and 
							trh2.trc_number_row = #temp.trc_number_row and trh2.trc_number_col = #temp.trc_number_col)
	
	update	#temp set tra_retired = trh.trh_todate 
	from	tariffratehistory trh 
	where	trh.tar_number = @pl_tarnum and 
			trh.trc_number_row = #temp.trc_number_row and trh.trc_number_col = #temp.trc_number_col and 
			getdate() between trh_fromdate and trh_todate
	
	update	#temp set tra_activedate = trh.trh_fromdate 
	from	tariffratehistory trh 
	where	trh.tar_number = @pl_tarnum and 
			trh.trc_number_row = #temp.trc_number_row and trh.trc_number_col = #temp.trc_number_col and 
			getdate() between trh_fromdate and trh_todate
END
/*  rates provided above , takes too long to update here
ELSE --JD support existing tariff rates if cell history is not enabled
BEGIN
	Update #temp set tra_rate = tariffrate.tra_rate,
					 tra_activedate = tariffrate.tra_activedate,
					 tra_retired = tariffrate.tra_retired
	from tariffrate 
	where tariffrate.tar_number = #temp.tar_number and 
		  tariffrate.trc_number_row = #temp.trc_number_row and
		  tariffrate.trc_number_col = #temp.trc_number_col	

END
*/
Select		tra_rate,
			trc_number_row ,
			trc_number_col ,
			tar_number,
			tariffrow_sequence,
			tariffcolumn_sequence,
			tra_apply,
			tra_retired,
			-- 46788 older rates displaying dark grey tra_activedate,
            isnull(tra_activedate,'19500101 00:00') tra_activedate,
			tra_minrate,
			tra_mincharge,
			tra_billmiles,
			tra_paymiles,
			tra_standardhours,
			tra_minqty,
			tra_rateasflat,					
			tariffrow_trc_rangevalue 'trc_rowrangevalue',				
			tariffcolumn_trc_rangevalue 'trc_colrangevalue'	 
from #temp	
	
GO
GRANT EXECUTE ON  [dbo].[d_tariffrate_sp] TO [public]
GO
