SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[l_and_b_bol_header] @mov int 
as
/**
 * 
 * NAME:
 * dbo.l_and_b_bol_header 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


declare @pup int, @drp1 int, @drp2 int, @drp3 int, @drp4 int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @pup=min(stp_number) 
from stops
where mov_number= @mov and
	stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s2
				where s2.mov_number = @mov and
					stp_type='PUP')

select @drp1=min(stp_number) 
from stops
where mov_number= @mov and
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
					stp_type='DRP' and
					stp_number not in (@drp1,@drp2))

select @drp4=min(stp_number) 
from stops
where mov_number= @mov and
	stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s2
				where s2.mov_number = @mov and
					stp_type='DRP' and
					stp_number not in (@drp1,@drp2,@drp3))

/*ord_number='1234'
dispatcher='Bob'
po='PO12434'
orderby='mark'
releaseno='r1234'
loaddate='1/1/00'
loadtime='23:59'
driver1='Bob'
tractor1='TRC123'
trailer1='g543'
deldate='1/2/00'
deltime='08:00'
driver2='UNKNOWN'
tractor2='UNKNOWN'
trailer2='UNKNOWN'
billto='Test~r123 south st ~r234~rCleveland oh 44212'
consignee1='Cons~r123 south st ~r234~rCleveland oh 44212'
consignee2=''
consignee3=''
consignee4=''
shipper='Ship~r123 south st ~r234~rCleveland oh 44212'
notes='notes'*/
select ord_number, 
	@tmwuser 'dispatcher',
	(SELECT ISNULL(MIN(ref_number),'') FROM referencenumber
	where ref_table = 'orderheader' and ref_tablekey = convert(varchar(12),orderheader.ord_hdrnumber) and
		ref_type='PO') ref_number_po,
	ord_bookedby,
	(SELECT ISNULL(MIN(ref_number),'') FROM referencenumber
	where ref_table = 'orderheader' and ref_tablekey = convert(varchar(12),orderheader.ord_hdrnumber) and
		ref_type='REL') ref_number_rel,
	 convert(varchar(8),ord_startdate,1) 'pu_date',
	convert(varchar(5),ord_startdate,108) 'pu_time',
	pup.evt_driver1,
	pup.evt_tractor,
	pup.evt_trailer1,
	 convert(varchar(8),ord_completiondate,1) 'del_date',
	convert(varchar(5),ord_completiondate,108) 'del_time',
	case when drp.evt_driver1 = pup.evt_driver1 then ''
		else drp.evt_driver1 end 'driver2',
	case when drp.evt_tractor = pup.evt_tractor then ''
		else drp.evt_tractor end 'tractor2',
	case when drp.evt_trailer1 = pup.evt_trailer1 then ''
		else drp.evt_trailer1 end 'trailer2',
	(select cmp_name+char(13)+char(10)+
		isnull(cmp_address1+char(13)+char(10),'')+
		isnull(cmp_address2+char(13)+char(10),'')+       
		cty_name+', '+cty_state+' '+isnull(cmp_zip,'')
		from company, city
		where cmp_city = cty_code AND 
			orderheader.ord_billto = cmp_id) Billto,
	(select company.cmp_name+char(13)+char(10)+
		isnull(cmp_address1+char(13)+char(10),'')+
		isnull(cmp_address2+char(13)+char(10),'')+       
		cty_name+', '+cty_state+' '+isnull(cmp_zip,'')
		from company, city, stops
		where cmp_city = cty_code AND 
			stops.cmp_id = company.cmp_id and
			stp_number = @drp1) drp1,
	(select company.cmp_name+char(13)+char(10)+
		isnull(cmp_address1+char(13)+char(10),'')+
		isnull(cmp_address2+char(13)+char(10),'')+       
		cty_name+', '+cty_state+' '+isnull(cmp_zip,'')
		from company, city, stops
		where cmp_city = cty_code AND 
			stops.cmp_id = company.cmp_id and
			stp_number = @drp2) drp2,
	(select company.cmp_name+char(13)+char(10)+
		isnull(cmp_address1+char(13)+char(10),'')+
		isnull(cmp_address2+char(13)+char(10),'')+       
		cty_name+', '+cty_state+' '+isnull(cmp_zip,'')
		from company, city, stops
		where cmp_city = cty_code AND 
			stops.cmp_id = company.cmp_id and
			stp_number = @drp3) drp3,
	(select company.cmp_name+char(13)+char(10)+
		isnull(cmp_address1+char(13)+char(10),'')+
		isnull(cmp_address2+char(13)+char(10),'')+       
		cty_name+', '+cty_state+' '+isnull(cmp_zip,'')
		from company, city, stops
		where cmp_city = cty_code AND 
			stops.cmp_id = company.cmp_id and
			stp_number = @drp4) drp4,
	(select company.cmp_name+char(13)+char(10)+
		isnull(cmp_address1+char(13)+char(10),'')+
		isnull(cmp_address2+char(13)+char(10),'')+       
		cty_name+', '+cty_state+' '+isnull(cmp_zip,'')
		from company, city, stops
		where cmp_city = cty_code AND 
			stops.cmp_id = company.cmp_id and
			stp_number = @pup) shipper,
	ord_remark,
	@drp1 cmd_stop
               		

from orderheader, (select evt_tractor, evt_driver1, evt_trailer1
			from event 
			where stp_number = @pup and evt_sequence = 1) pup,
		(select evt_tractor, evt_driver1, evt_trailer1
			from event 
			where stp_number = @drp1 and evt_sequence = 1) drp

where mov_number = @mov
GO
GRANT EXECUTE ON  [dbo].[l_and_b_bol_header] TO [public]
GO
