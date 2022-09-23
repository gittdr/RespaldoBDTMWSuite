SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 18411 BOL format designed for Linden
CREATE PROCEDURE [dbo].[d_bolformat06_sp] (@ord_hdrnumber int, @batch_number int)
AS

declare @fgt_counter int
declare @cur_cmd_code varchar(8)
declare @stp_type varchar(3)
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--PTS 24702 new loop counter
declare 	@loop_counter int
select 	@loop_counter= 0

select  @fgt_counter = 0,  @cur_cmd_code = NULL, @stp_type = NULL

create table #all_fgt_details (	
				_counter int IDENTITY,
				fgt_number int null, 
				cmd_code varchar(8) null, 
				fgt_volume int null, 
				stp_type varchar (3) null,
				ord_hdrnumber int null,
				stp_number int null)

 create table #matches (	fgt_number int null, 
				cmd_code varchar(8) null,
 				ord_hdrnumber int null,
				match_fgt_number int null,
				stp_number int null)


 create table #no_matches(	fgt_number int null, 
 				cmd_code varchar(8) null, 
 				missing_from varchar(3) null,
				stp_number int null,
				ord_hdrnumber int null,
				ord_number char(12) null,
				cmd_name varchar(60) null,
				batch_number int null)

 create table #output(	
			drp_fgt_number int null,
			drp_stp_number int null,
			pup_fgt_number int null,
			pup_stp_number int null,
			ord_hdrnumber int null, 
 			bill_miles int null, 
 			pup_date varchar(10) null, 
 			pup_times varchar(11) null,
 			pup_mpp_fullname varchar(84) null, 
 			pup_trc_number varchar(8) null, 
 			pup_trl_number varchar(13) null, 
 			container varchar(42) null, 
 			shipper_name varchar(100) null, 
 			shipper_address1 varchar(100) null, 
 			shipper_address2 varchar(100) null,
 			shipper_address3 varchar(100) null,
			shipper_city_state varchar(25) null,
			shipper_information varchar(254) null,
			shipper_number varchar(30) null,
 			drp_date varchar(10) null, 
 			drp_times varchar(11) null,
 			drp_mpp_fullname varchar(84) null, 
 			drp_trc_number varchar(8) null, 
 			drp_trl_number varchar(13) null, 			
 			receiver_name varchar(100) null, 
 			receiver_address1 varchar(100) null, 
 			receiver_address2 varchar(100) null,
 			receiver_address3 varchar(100) null,
			receiver_city_state varchar(25) null,
			receiver_information varchar(254) null,
			receiver_number varchar(30) null,
 			fgt_volume int null,
 			hazmat_flag char(1) null,
 			cmd_line1 varchar (60) null,
			cmd_line2 varchar(60) null,
			cmd_line3 varchar (70) null)

--get a batchnumber for error reporting (missing commodity drops or pickups)
--PTS 21932  getting the batch number in powerbuilder now
--exec @batch_number = getsystemnumber 'BATCHQ',''

--get all the freightdetails on the order
insert into #all_fgt_details (fgt_number, stp_number, cmd_code, fgt_volume, stp_type, ord_hdrnumber)
select 	freightdetail.fgt_number,
	stops.stp_number,
	freightdetail.cmd_code, 
	freightdetail.fgt_volume,
	stp_type,
	ord_hdrnumber	
from freightdetail,stops 
where stops.ord_hdrnumber = @ord_hdrnumber
	and stops.stp_number = freightdetail.stp_number
order by stp_type desc ,fgt_number

-- PTS  24702
--select @fgt_counter = min(fgt_number) from #all_fgt_details
select @fgt_counter = fgt_number from #all_fgt_details where _counter = 1
select @stp_type = stp_type from #all_fgt_details where fgt_number = @fgt_counter

--if there is a drop that has no corresponding pickup put it in the temp table for error reporting
if exists (select fgt_number from #all_fgt_details where stp_type = 'DRP' and cmd_code not in (select cmd_code from #all_fgt_details where stp_type = 'pup'))
  insert into #no_matches (fgt_number, cmd_code, missing_from, stp_number, ord_hdrnumber)
  select fgt_number, cmd_code, 'PUP', stp_number, ord_hdrnumber from #all_fgt_details where stp_type = 'DRP' and cmd_code not in (select cmd_code from #all_fgt_details where stp_type = 'pup')


-- PTS  24702 Changed Loop BYoung
--while isnull(@fgt_counter,0) > 0 and @stp_type = 'PUP'
while 1=1
	
  begin
	
	select @loop_counter = min(_counter) from #all_fgt_details where _counter > @loop_counter
	if @loop_counter is NULL BREAK

	select @cur_cmd_code = cmd_code from #all_fgt_details where fgt_number = @fgt_counter
	-- if there is a pickup with no corresponding drop put it in the temp table for error reporting
	if NOT EXISTS (select cmd_code from #all_fgt_details where cmd_code = @cur_cmd_code and fgt_number <> @fgt_counter and stp_type = 'DRP')
	begin
	  insert into #no_matches (fgt_number, cmd_code, missing_from, stp_number, ord_hdrnumber)
	  select fgt_number, cmd_code, 'DRP', stp_number, ord_hdrnumber from #all_fgt_details where fgt_number = @fgt_counter
	   --now get all the relevant info on the table for error reporting
	   update #no_matches 
	   set #no_matches.ord_number = orderheader.ord_number,
	       #no_matches.cmd_name = commodity.cmd_name,
	       #no_matches.batch_number = @batch_number
	   from orderheader, commodity 
	   where #no_matches.ord_hdrnumber = orderheader.ord_hdrnumber
	     and #no_matches.cmd_code = commodity.cmd_code
	end
	else
	-- all the pickups have corresponding drops so begin generating output
	  begin
		select @cur_cmd_code = cmd_code from #all_fgt_details where fgt_number = @fgt_counter
		--get all the drops that have the current commodity
		insert into #matches(cmd_code, match_fgt_number, stp_number)
		select @cur_cmd_code, fgt_number, stp_number from #all_fgt_details where cmd_code = @cur_cmd_code and stp_type = 'drp'
		
		--now update those with the matching pickup
		update #matches set #matches.fgt_number = #all_fgt_details.fgt_number, #matches.ord_hdrnumber = #all_fgt_details.ord_hdrnumber
		from #all_fgt_details
		where #matches.cmd_code = #all_fgt_details.cmd_code
		  and #all_fgt_details.stp_type = 'pup'
	  end
	select @fgt_counter = min(fgt_number) from #all_fgt_details where fgt_number > @fgt_counter and stp_type = 'PUP'
	select @stp_type = stp_type from #all_fgt_details where fgt_number = @fgt_counter
		
	--PTS 24702
	select 	@loop_counter = min(_counter)
	from 	#all_fgt_details
	where 	_counter > @loop_counter


  end
--Put all errors in the error log with the batch number passed into the proc
insert into tts_errorlog (err_batch, err_user_id, err_message, err_date, err_number, err_title, err_item_number)
select @batch_number, @tmwuser, 'Commodity does not have matching pickup and drop events on order ' + rtrim(ltrim(ord_number)), getdate(), ord_hdrnumber, cmd_name, missing_from from #no_matches

--getting generalized info, commodity info, and drop's asset information,
insert into #output (	drp_fgt_number, 	
			ord_hdrnumber,		
			bill_miles,	 	
			drp_date,
			drp_times,
			drp_mpp_fullname,
			drp_trc_number,
			drp_trl_number,
			hazmat_flag,
			cmd_line1,
			cmd_line2,
			cmd_line3,
			shipper_number,
			receiver_number)
select
	#matches.match_fgt_number AS 'drp_fgt_number',
	orderheader.ord_hdrnumber AS 'ord_hdrnumber',
	ISNULL(orderheader.ord_totalmiles,0) AS 'bill_miles',
	(right('00' + convert(varchar(2),datepart(mm,stp_schdtearliest)),2) + '/' + right('00' + convert(varchar(2),datepart(dd,stp_schdtearliest)),2) + '/' + convert(varchar(4),datepart(yy,stp_schdtearliest))) AS drp_date,
	(right('00' + convert(varchar(2),datepart(hh,stp_schdtearliest)),2) + ':' + right('00' + convert(varchar(2),datepart(mi,stp_schdtearliest)),2) + '-' + right('00' + convert(varchar(2),datepart(hh,stp_schdtlatest)),2) + ':' + right('00' + convert(varchar(2),datepart(mi,stp_schdtlatest)),2)) AS drp_time,
	ISNULL(mpp_firstname + ' '+ CASE ISNULL(ltrim(rtrim(mpp_middlename)),'') WHEN '' THEN mpp_lastname ELSE mpp_middlename + '. ' + mpp_lastname END,'') as drp_mpp_fullname,
	CASE legheader.lgh_tractor WHEN 'UNKNOWN' THEN '' ELSE legheader.lgh_tractor END AS drp_trc_number,
	CASE legheader.lgh_primary_trailer WHEN 'UNKNOWN' THEN '' ELSE legheader.lgh_primary_trailer END AS drp_trl_number,
	CASE cmd_hazardous WHEN 1 THEN 'Y' ELSE 'N' END AS hazmat_flag,
	cmd_name AS cmd_line1,
	CASE cmd_hazardous WHEN 1 THEN ISNULL(cmd_dot_name,'') ELSE '' END AS cmd_line2,
	CASE cmd_hazardous 
		WHEN 1 THEN
		( CASE a.name 
			when null then '' 
			when 'UNKNOWN' then ''
			when '' then ''
			else a.name
		  end 
		+ CASE cmd_haz_num
			when null then '' 
			when 'UNKNOWN' then ''
			when '' then ''
			else ', UN' + cmd_haz_num
		  end
		+ CASE b.name 
			when null then '' 
			when 'UNKNOWN' then ''
			when '' then ''
			else ', ' + b.name 
		  end 
		+ CASE c.name 
			when null then '' 
			when 'UNKNOWN' then ''
			when '' then ''
			else ', ' + c.name 
		  end ) 
		ELSE
			''
	END
	AS cmd_line3,
	'' AS shipper_number,
	'' AS receiver_number
from orderheader, stops, legheader, manpowerprofile, tractorprofile, freightdetail, commodity, #matches, labelfile a, labelfile b, labelfile c
where orderheader.ord_hdrnumber = stops.ord_hdrnumber
  and legheader.lgh_number = stops.lgh_number
  and manpowerprofile.mpp_id = lgh_driver1
  and tractorprofile.trc_number = lgh_tractor
  and commodity.cmd_code = freightdetail.cmd_code
  and stops.stp_number = #matches.stp_number
  and freightdetail.fgt_number = #matches.fgt_number
	  and a.abbr = CASE commodity.cmd_haz_class WHEN '' then 'UNK' WHEN NULL then 'UNK' else cmd_haz_class END
--	  and a.abbr = commodity.cmd_haz_class
	  and a.labeldefinition = 'CmdHazClass'
	  and b.abbr = CASE commodity.cmd_haz_subclass WHEN '' then 'UNK' WHEN NULL then 'UNK' else cmd_haz_subclass END
--	  and b.abbr = commodity.cmd_haz_subclass
	  and b.labeldefinition = 'CmdSubHazClass'
	  and c.abbr = CASE commodity.cmd_haz_subclass2 WHEN '' then 'UNK' WHEN NULL then 'UNK' else cmd_haz_subclass2 END
--	  and c.abbr = commodity.cmd_haz_subclass2
	  and c.labeldefinition = 'CmdSubHazClass2'

--stamp the output with the pickup freightdetail
update #output 
set 	#output.pup_fgt_number = #matches.fgt_number
from #output, #matches
where #output.drp_fgt_number = #matches.match_fgt_number

--get the drop's stop number for sorting later
update #output
set	#output.drp_stp_number = #all_fgt_details.stp_number, #output.fgt_volume = ISNULL(#all_fgt_details.fgt_volume,0)
from #output, #all_fgt_details
where #output.drp_fgt_number = #all_fgt_details.fgt_number

--get the pup's stop number for sorting later
update #output
set 	#output.pup_stp_number = #all_fgt_details.stp_number
from #output, #all_fgt_details
where #output.pup_fgt_number = #all_fgt_details.fgt_number

--create the new BOL from each pickup to the supplier if one exists
IF (select isnull(ord_supplier,'UNKNOWN') from orderheader where ord_hdrnumber = @ord_hdrnumber) <> 'UNKNOWN'
begin
	insert into #output (	ord_hdrnumber,		
				pup_fgt_number,
				pup_stp_number,
				bill_miles,
				fgt_volume,	 	
				drp_date,
				drp_times,
				drp_mpp_fullname,
				drp_trc_number,
				drp_trl_number,
				hazmat_flag,
				cmd_line1,
				cmd_line2,
				cmd_line3,
				receiver_number,
				shipper_number,
				receiver_name,
				receiver_address1,
				receiver_address2,
				receiver_address3,
				receiver_city_state
				)
	select	#all_fgt_details.ord_hdrnumber as 'orderheader',
		#all_fgt_details.fgt_number as 'pup_fgt_number',
		#all_fgt_details.stp_number,
		ISNULL(orderheader.ord_totalmiles,0) AS 'bill_miles',
		#all_fgt_details.fgt_volume,
		(right('00' + convert(varchar(2),datepart(mm,stp_schdtearliest)),2) + '/' + right('00' + convert(varchar(2),datepart(dd,stp_schdtearliest)),2) + '/' + convert(varchar(4),datepart(yy,stp_schdtearliest))) AS drp_date,
		(right('00' + convert(varchar(2),datepart(hh,stp_schdtearliest)),2) + ':' + right('00' + convert(varchar(2),datepart(mi,stp_schdtearliest)),2) + '-' + right('00' + convert(varchar(2),datepart(hh,stp_schdtlatest)),2) + ':' + right('00' + convert(varchar(2),datepart(mi,stp_schdtlatest)),2)) AS drp_time,
		ISNULL(mpp_firstname + ' '+ CASE ISNULL(ltrim(rtrim(mpp_middlename)),'') WHEN '' THEN mpp_lastname ELSE mpp_middlename + '. ' + mpp_lastname END,'') as drp_mpp_fullname,
		CASE legheader.lgh_tractor WHEN 'UNKNOWN' THEN '' ELSE legheader.lgh_tractor END AS drp_trc_number,
		CASE legheader.lgh_primary_trailer WHEN 'UNKNOWN' THEN '' ELSE legheader.lgh_primary_trailer END AS drp_trl_number,
		CASE cmd_hazardous WHEN 1 THEN 'Y' ELSE 'N' END AS hazmat_flag,
		cmd_name AS cmd_line1,
		CASE cmd_hazardous WHEN 1 THEN ISNULL(cmd_dot_name,'') ELSE '' END AS cmd_line2,
		CASE cmd_hazardous 
			WHEN 1 THEN
			( CASE a.name 
				when null then '' 
				when 'UNKNOWN' then ''
				when '' then ''
				else a.name
			  end 
			+ CASE cmd_haz_num
				when null then '' 
				when 'UNKNOWN' then ''
				when '' then ''
				else ', UN' + cmd_haz_num
			  end
			+ CASE b.name 
				when null then '' 
				when 'UNKNOWN' then ''
				when '' then ''
				else ', ' + b.name 
			  end 
			+ CASE c.name 
				when null then '' 
				when 'UNKNOWN' then ''
				when '' then ''
				else ', ' + c.name 
			  end ) 
			ELSE
				''
		END
		AS cmd_line3,
		'' AS shipper_number,
		'' AS receiver_number,
		ISNULL(company.cmp_name,''), 
		ISNULL(company.cmp_address1,''), 
		ISNULL(company.cmp_address2,''),
		ISNULL(company.cmp_address3,''),
		CASE cty_nmstct WHEN 'UNKNOWN' THEN '' ELSE left(cty_nmstct,len(cty_nmstct) - 1)END
	from orderheader, stops, legheader, manpowerprofile, tractorprofile, freightdetail, commodity, #all_fgt_details, labelfile a, labelfile b, labelfile c, company, #matches
	where orderheader.ord_hdrnumber = stops.ord_hdrnumber
	  and legheader.lgh_number = stops.lgh_number
	  and manpowerprofile.mpp_id = lgh_driver1
	  and tractorprofile.trc_number = lgh_tractor
	  and commodity.cmd_code = freightdetail.cmd_code
	  and stops.stp_number = #all_fgt_details.stp_number
	  and freightdetail.fgt_number = #all_fgt_details.fgt_number
	  and a.abbr = CASE commodity.cmd_haz_class WHEN '' then 'UNK' WHEN NULL then 'UNK' else cmd_haz_class END
--	  and a.abbr = commodity.cmd_haz_class
	  and a.labeldefinition = 'CmdHazClass'
	  and b.abbr = CASE commodity.cmd_haz_subclass WHEN '' then 'UNK' WHEN NULL then 'UNK' else cmd_haz_subclass END
--	  and b.abbr = commodity.cmd_haz_subclass
	  and b.labeldefinition = 'CmdSubHazClass'
	  and c.abbr = CASE commodity.cmd_haz_subclass2 WHEN '' then 'UNK' WHEN NULL then 'UNK' else cmd_haz_subclass2 END
--	  and c.abbr = commodity.cmd_haz_subclass2
	  and c.labeldefinition = 'CmdSubHazClass2'
	  and #all_fgt_details.stp_type = 'PUP'
	  and orderheader.ord_supplier = company.cmp_id
	  and #all_fgt_details.fgt_number = #matches.fgt_number
	group by #all_fgt_details.stp_number, #all_fgt_details.ord_hdrnumber, #all_fgt_details.fgt_number, orderheader.ord_totalmiles, #all_fgt_details.fgt_volume, stops.stp_schdtearliest, stops.stp_schdtlatest, manpowerprofile.mpp_firstname, manpowerprofile.mpp_middlename, manpowerprofile.mpp_lastname, legheader.lgh_tractor, legheader.lgh_primary_trailer, commodity.cmd_hazardous, commodity.cmd_name, commodity.cmd_dot_name, commodity.cmd_hazardous, a.name, commodity.cmd_haz_num, b.name, c.name, company.cmp_name, company.cmp_address1, company.cmp_address2, company.cmp_address3, company.cty_nmstct
end
	--get the pickup's asset information
	update #output
	set 	#output.pup_mpp_fullname = ISNULL(mpp_firstname + ' '+ CASE ISNULL(ltrim(rtrim(mpp_middlename)),'') WHEN '' THEN mpp_lastname ELSE mpp_middlename + '. ' + mpp_lastname END,''),
	 	#output.pup_trc_number = CASE legheader.lgh_tractor WHEN 'UNKNOWN' THEN '' ELSE legheader.lgh_tractor END,
	 	#output.pup_trl_number = CASE legheader.lgh_primary_trailer WHEN 'UNKNOWN' THEN '' ELSE legheader.lgh_primary_trailer END,
	        #output.pup_date = (right('00' + convert(varchar(2),datepart(mm,stp_schdtearliest)),2) + '/' + right('00' + convert(varchar(2),datepart(dd,stp_schdtearliest)),2) + '/' + convert(varchar(4),datepart(yy,stp_schdtearliest))),
		#output.pup_times = (right('00' + convert(varchar(2),datepart(hh,stp_schdtearliest)),2) + ':' + right('00' + convert(varchar(2),datepart(mi,stp_schdtearliest)),2) + '-' + right('00' + convert(varchar(2),datepart(hh,stp_schdtlatest)),2) + ':' + right('00' + convert(varchar(2),datepart(mi,stp_schdtlatest)),2))
	from legheader, stops, freightdetail, manpowerprofile
	where freightdetail.fgt_number = #output.pup_fgt_number
	  and stops.stp_number = freightdetail.stp_number
	  and stops.lgh_number = legheader.lgh_number
	  and manpowerprofile.mpp_id = legheader.lgh_driver1
	
	--update the shipper's info
	update #output 
	set	#output.shipper_name = ISNULL(company.cmp_name,''), 
		#output.shipper_address1 = ISNULL(company.cmp_address1,''), 
		#output.shipper_address2 = ISNULL(company.cmp_address2,''),
		#output.shipper_address3 = ISNULL(company.cmp_address3,''),
		#output.shipper_city_state = CASE cty_nmstct WHEN 'UNKNOWN' THEN '' ELSE left(cty_nmstct,len(cty_nmstct) - 1)END,
		#output.shipper_information = ISNULL(stp_comment,'')
	from company, stops, freightdetail
	where freightdetail.stp_number = stops.stp_number
	  and stops.cmp_id = company.cmp_id
	  and freightdetail.fgt_number = #output.pup_fgt_number

--update the shipper number
--21971 BY - changed to pull from order level
--21971 JLB 3/5 changed back to pull from stop level
update #output
set #output.shipper_number = ISNULL(ref_number,'')
from referencenumber, #output
where #output.pup_stp_number = ref_tablekey
  and referencenumber.ref_type = 'PU'
  and referencenumber.ref_table = 'stops'

--update the receiver number
--21971 BY - changed to pull from order level
--21971 JLB 3/5 changed back to pull from stop level
update #output
set #output.receiver_number = ISNULL(ref_number,'')
from referencenumber, #output
where #output.drp_stp_number = ref_tablekey
  and referencenumber.ref_type = 'DEL'
  and referencenumber.ref_table = 'stops'
--update the receiver's info
update #output 
set	#output.receiver_name = ISNULL(company.cmp_name,''),  
	#output.receiver_address1 = ISNULL(company.cmp_address1,''), 
	#output.receiver_address2 = ISNULL(company.cmp_address2,''),
	#output.receiver_address3 = ISNULL(company.cmp_address3,''),
	#output.receiver_city_state = CASE cty_nmstct WHEN 'UNKNOWN' THEN '' ELSE left(cty_nmstct,len(cty_nmstct) - 1)END,
	#output.receiver_information = ISNULL(stp_comment,'')
from company, stops, freightdetail
where freightdetail.stp_number = stops.stp_number
  and stops.cmp_id = company.cmp_id
  and freightdetail.fgt_number = #output.drp_fgt_number

--set the container on the output based on two referencenumbers cont1 and cont2
--2 or more containers recorded take the cont1 and cont2
IF (select count(*) from referencenumber where ref_tablekey  = @ord_hdrnumber and ref_table = 'orderheader' and ref_type = 'cont1') = 1  AND
   (select count(*) from referencenumber where ref_tablekey  = @ord_hdrnumber and ref_table = 'orderheader' and ref_type = 'cont2') = 1
BEGIN 
	update #output set #output.container =  isnull(a.ref_number,'') + CASE a.ref_number WHEN NULL THEN isnull(b.ref_number,'') ELSE ', ' + isnull(b.ref_number,'') END
	from referencenumber a, referencenumber b
	where a.ord_hdrnumber = @ord_hdrnumber
	  and b.ord_hdrnumber = @ord_hdrnumber
	  and a.ref_type = 'cont1'
	  and b.ref_type = 'cont2'
	  and #output.ord_hdrnumber = @ord_hdrnumber
	  and a.ref_tablekey = @ord_hdrnumber
	  and a.ref_table = 'orderheader'
	  and b.ref_tablekey = @ord_hdrnumber
	  and b.ref_table = 'orderheader'
END
--1 container in the cont1 ref number recorded take cont1 referencenumber
ELSE IF (select count(*) from referencenumber where ref_tablekey = @ord_hdrnumber and ref_table = 'orderheader' and ref_type  = 'cont1') = 1 AND
	(select count(*) from referencenumber where ref_tablekey  = @ord_hdrnumber and ref_table = 'orderheader' and ref_type in ('cont1','cont2')) = 1
BEGIN	
	update #output set #output.container =  isnull(ref_number,'')
	from referencenumber
	where #output.ord_hdrnumber = @ord_hdrnumber
	  and ref_type = 'cont1'
	  and ref_tablekey = @ord_hdrnumber
	  and ref_table = 'orderheader'
	
END
--1 container in the cont2 ref number recorded take cont1 referencenumber
ELSE IF (select count(*) from referencenumber where ref_tablekey = @ord_hdrnumber and ref_table = 'orderheader' and ref_type  = 'cont2') = 1 AND
	(select count(*) from referencenumber where ref_tablekey  = @ord_hdrnumber and ref_table = 'orderheader'  and ref_type in ('cont1','cont2')) = 1
BEGIN 
	update #output set #output.container =  isnull(ref_number,'')
	from referencenumber
	where #output.ord_hdrnumber = @ord_hdrnumber
	  and ref_type = 'cont2'
	  and ref_tablekey = @ord_hdrnumber
	  and ref_table = 'orderheader'
	
END
--no containers recorded or to many recorded
--do nothing with the container field

--If there is a supplier on the order than we need to change all of the shipper locations to this supplier and produce a
--BOL for each pickup to the supplier
IF (select isnull(ord_supplier,'UNKNOWN') from orderheader where ord_hdrnumber = @ord_hdrnumber) <> 'UNKNOWN'
update #output 
set	#output.shipper_name = ISNULL(company.cmp_name,''), 
	#output.shipper_address1 = ISNULL(company.cmp_address1,''), 
	#output.shipper_address2 = ISNULL(company.cmp_address2,''),
	#output.shipper_address3 = ISNULL(company.cmp_address3,''),
	#output.shipper_city_state = CASE cty_nmstct WHEN 'UNKNOWN' THEN '' ELSE left(cty_nmstct,len(cty_nmstct) - 1)END,
	#output.shipper_information = ''
from company,orderheader
where orderheader.ord_supplier = company.cmp_id
  and orderheader.ord_hdrnumber = @ord_hdrnumber
  and #output.receiver_name <> (select cmp_name 
				from company, orderheader 
				where cmp_id = orderheader.ord_supplier 
				  and ord_hdrnumber = @ord_hdrnumber)




--debugs
--select * from #all_fgt_details
--select * from #matches
--select * from #no_matches

select * from #output order by receiver_name, drp_fgt_number
drop table #all_fgt_details
drop table #matches
drop table #no_matches
drop table #output

GO
GRANT EXECUTE ON  [dbo].[d_bolformat06_sp] TO [public]
GO
