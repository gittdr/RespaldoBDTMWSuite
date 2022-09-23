SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_timeline_detail]
	@tlh_number integer
as

Create Table #t (
	[tld_sequence] [int] NULL ,
	[tld_master_ordnum] [varchar] (12) NULL ,
	[tld_route] [varchar] (15) NULL ,
	[tld_origin] [varchar] (8) NULL ,
	[tld_arrive_yard_day_orig] [datetime] NULL ,
	[tld_arrive_yard_time_orig] [datetime] NULL ,
	[tld_arrive_lead_o] [int] NULL, 	
	[tld_dest] [varchar] (8) NULL ,
	[tld_arrive_yard_day_dest] [datetime] NULL ,
	[tld_arrive_yard_time_dest] [datetime] NULL ,
	[tld_arrive_lead_d] [int] NULL
)

-- Need to do this by header, sequence
Insert into #t ([tld_sequence],
	[tld_master_ordnum],
	[tld_route],
	[tld_origin],
	[tld_arrive_yard_day_orig],
	[tld_arrive_yard_time_orig],
	[tld_arrive_lead_o])
	select tld_sequence, tld_master_ordnum, tld_route, 
		tld_origin, tld_arrive_yard, tld_arrive_yard, tld_arrive_lead 
		from timeline_detail where @tlh_number = tlh_number and isnull(tld_dest, '') = ''

update #t set [tld_dest] = b.tld_dest,
	[tld_arrive_yard_day_dest] = b.tld_arrive_yard,
	[tld_arrive_yard_time_dest]= b.tld_arrive_yard, 
	[tld_arrive_lead_d] = b.tld_arrive_lead 
	from timeline_detail b where @tlh_number = tlh_number and isnull(b.tld_origin, '') = '' and #t.tld_sequence = b.tld_sequence


select * from #t

drop table #t

GO
GRANT EXECUTE ON  [dbo].[d_timeline_detail] TO [public]
GO
