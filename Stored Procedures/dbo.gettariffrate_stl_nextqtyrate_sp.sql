SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[gettariffrate_stl_nextqtyrate_sp] (@pl_tarnum int, @pdec_qty money, @ps_destzip varchar(10) , @pdec_nextqty money output,@pdec_nextrate money output)
as

-- JD 44416 CREATED
-- the proc returns the qty and rate from the bracket that is higher than the current qty bracket.
-- Qty 0 - 500 Rate 17, Qty 500-999 Rate 16, Qty 1000 - 1999 Rate 12, Qty 2000-4999 Rate 11 , MAX 10
-- if you pass in 4200 the Qty Returned will be 5000(4999 + 1) and the rate returned will be from the next bracket i.e 10
-- THIS PROC currently ONLY Searches Rows and is currently only used at Murphy. If required we can change this to search cols as well.

declare @li_seq int,@trc_row int,@trc_col int
declare @tar_colbasis varchar(6)

select @tar_colbasis = tar_colbasis from tariffheaderstl where tar_number = @pl_tarnum

if right(@tar_colbasis,1) = 'P' 
begin
	select @ps_destzip = left(@ps_destzip,3)
end


SELECT	@trc_col = trc_number 
FROM	tariffrowcolumnstl 
WHERE	( tar_number = @pl_tarnum ) AND ( trc_rowcolumn = 'C' ) AND 
			( trc_rangevalue >= 2147483647 )  AND
			( @ps_destzip  = 
				case when Substring(trc_matchvalue, 1, 1) = char(176) then 
					case when @ps_destzip not in ('') and charindex(@ps_destzip + ';', trc_multimatch) > 0 then @ps_destzip
						else 'nomatch'
					end
				     else trc_matchvalue  
				end) 


select @trc_col = Isnull(@trc_col,0)


select	@li_seq = min(trc_sequence) 
from	tariffrowcolumnstl 
where	tar_number = @pl_tarnum and trc_rowcolumn = 'R' and trc_rangevalue >= @pdec_qty



--if @li_seq is null 
--	select	@li_seq = max(trc_sequence) 
--	from	tariffrowcolumnstl 
--	where	tar_number = @pl_tarnum and trc_rowcolumn = 'R' and trc_rangevalue <= @pdec_qty


if @li_seq is not null
BEGIN
	select	@trc_row = trc_number,@pdec_nextqty = trc_rangevalue 
	from	tariffrowcolumnstl 
	where	tar_number = @pl_tarnum and trc_rowcolumn='R' and trc_sequence = @li_seq

	select @pdec_nextqty = @pdec_nextqty + 1
	if exists (select * from tariffrowcolumnstl where tar_number = @pl_tarnum and trc_rowcolumn = 'R' and trc_sequence > @li_seq)
	BEGIN
		select @li_seq = min(trc_sequence) from tariffrowcolumnstl where tar_number = @pl_tarnum and trc_rowcolumn = 'R' and trc_sequence > @li_seq
		select @trc_row = trc_number from tariffrowcolumnstl where tar_number = @pl_tarnum and trc_rowcolumn='R' and trc_sequence = @li_seq
	END
	else
	BEGIN
		select @pdec_nextqty = @pdec_qty
	END
	
	
	select @pdec_nextrate = tra_rate from tariffratestl where tar_number = @pl_tarnum and trc_number_row = @trc_row and trc_number_col = @trc_col

END

GO
GRANT EXECUTE ON  [dbo].[gettariffrate_stl_nextqtyrate_sp] TO [public]
GO
