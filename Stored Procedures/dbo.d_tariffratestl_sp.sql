SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_tariffratestl_sp] (@pl_tarnum int) as

exec autogenerate_tariffratehistory_sp @pl_tarnum


SELECT IsNull((select trh.tra_rate from tariffratehistorystl trh where trh.tar_number = @pl_tarnum and 
		trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
		getdate() between trh_fromdate and trh_todate) ,
		(select trh.tra_rate from tariffratehistorystl trh where trh.tar_number = @pl_tarnum and 
		trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
		trh_todate = (select max(trh_todate) from tariffratehistorystl trh2 where trh2.tar_number = @pl_tarnum and 
		trh2.trc_number_row = tariffrow.trc_number and trh2.trc_number_col = tariffcolumn.trc_number))) as tra_rate,
	tariffratestl.trc_number_row,
	tariffratestl.trc_number_col,
	tariffratestl.tar_number,
	tariffrow.trc_sequence tariffrow_sequence,
	tariffcolumn.trc_sequence tariffcolumn_sequence,
	(select trh.trh_todate from tariffratehistorystl trh where trh.tar_number = @pl_tarnum and 
		trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
		getdate() between trh_fromdate and trh_todate)tra_retired,
	(select trh.trh_fromdate from tariffratehistorystl trh where trh.tar_number = @pl_tarnum and 
		trh.trc_number_row = tariffrow.trc_number and trh.trc_number_col = tariffcolumn.trc_number and 
		getdate() between trh_fromdate and trh_todate) tra_activedate
FROM tariffratestl 
	inner join tariffrowcolumn as tariffrow on tariffratestl.trc_number_row = tariffrow.trc_number
	inner join tariffrowcolumn as tariffcolumn on tariffratestl.trc_number_col = tariffcolumn.trc_number	
where tariffratestl.tar_number = @pl_tarnum
GO
GRANT EXECUTE ON  [dbo].[d_tariffratestl_sp] TO [public]
GO
