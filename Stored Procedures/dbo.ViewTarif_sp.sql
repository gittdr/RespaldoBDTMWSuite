SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[ViewTarif_sp] (@pl_tarnum1 int) 
as

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

insert into #temp
execute dbo.d_tariffrate_sp   @pl_tarnum = @pl_tarnum1

select tar_number,TRA_APPLY AS ACTIVA,(SELECT city.cty_nmstctFROM tariffrowcolumn, cityWHERE ( city.cty_code = convert ( int , tariffrowcolumn.trc_matchvalue ) ) and 
( ( tariffrowcolumn.tar_number = @pl_tarnum1 ) AND 
( tariffrowcolumn.trc_rowcolumn = 'R' ) ) and tp.trc_number_row=trc_number) as Fila,(SELECT city.cty_nmstctFROM tariffrowcolumn, cityWHERE ( city.cty_code = convert ( int , tariffrowcolumn.trc_matchvalue ) ) and 
( ( tariffrowcolumn.tar_number = @pl_tarnum1 ) AND 
( tariffrowcolumn.trc_rowcolumn = 'C' ) ) and tp.trc_number_col=trc_number) as Columna,
 tra_rate
from #temp tp
where tra_rate > 0 AND ISNULL(tra_apply,'Y') <> 'N'
ORDER BY Fila, Columna
GO
