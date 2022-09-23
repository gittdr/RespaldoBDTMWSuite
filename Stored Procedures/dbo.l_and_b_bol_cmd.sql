SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[l_and_b_bol_cmd] @ord int 
as

declare @drp1 int,
        @drp2 int,
	@drp3 int,
	@drp4 int,
	@mov  int

select @mov = mov_number
from orderheader
where ord_hdrnumber = @ord

select @drp1=min(stp_number) 
from stops
where mov_number = @mov and
	stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s2
				where s2.mov_number = @mov and
					stp_type='DRP')

select @drp2=min(stp_number) 
from stops
where mov_number= @mov and
	stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s2
				where s2.mov_number = @mov and
					stp_type='DRP' and
					stp_number <> @drp1)

select @drp3=min(stp_number) 
from stops
where mov_number= @mov and
	stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s2
				where s2.mov_number = @mov and
					stp_type='DRP'and
					stp_number not in (@drp1,@drp2))

select @drp4=min(stp_number) 
from stops
where mov_number= @mov and
	stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s2
				where s2.mov_number = @mov and
					stp_type='DRP' and
					stp_number not in (@drp1,@drp2,@drp3))
select case cmd_hazardous
	when 1 then 'X'
	else '' end 'HM',
	isnull(cmd_misc1,'')+cmd_name 'desc',
	case
	when isnull(cmd_class,'')='UNKNOWN' then ''
	else isnull(cmd_class,'') end 'class',
	isnull(cmd_pin,'') 'pin',
	isnull(cmd_misc2,'') 'pg',
	isnull(cmd_misc3,'') 'plac',
	sum(isnull(fgt_quantity,0)) 'gal',
	(case min(stp_number)when @drp1 then 1 when @drp2 then 2 when @drp3 then 3 else 4 end)  'seq'
from freightdetail, commodity 
where freightdetail.cmd_code = commodity.cmd_code and
stp_number in ( @drp1,@drp2,@drp3,@drp4)
group by commodity.cmd_code,cmd_hazardous,cmd_misc1,cmd_name,cmd_class,cmd_pin,cmd_misc2,cmd_misc3
order by seq

GO
GRANT EXECUTE ON  [dbo].[l_and_b_bol_cmd] TO [public]
GO
