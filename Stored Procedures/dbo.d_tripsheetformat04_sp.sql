SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_tripsheetformat04_sp] (@pl_mov int ) 
as 
declare @li_ord int
declare @li_stp int,@li_seq int,@li_disp_seq int
declare @ldec_totalweight money,@ldec_totalvolume money
	Create table #temp (seq_num int identity not null,					
						mov_number int not null,
						ord_hdrnumber int not null,
						stp_number int null,
						ord_number char(12) null,
						ord_refnum varchar(20) null,
						ord_startdate datetime null,
						mpp_id varchar(8) null,
						mpp_fullname varchar(100) null,
						trc_number varchar(8) null,
						mpp_payhours money null,
						plan_revenue money null,
						plan_drive_hrs varchar(6) null, --datetime null,
						plan_stp_hrs varchar(6) null, --datetime null,
						plan_tot_hrs varchar(6) null, --datetime null,
						ord_totalweight money null,
						ord_totalvolume money null,
						ord_plan_miles int null,
						ord_startodmeter int null,	
						ord_endodmeter int null,
						ord_totodmeter int null,
						stp_mfh_sequence int null,
						trailer_number varchar(13) null,	
						stp_arrivaldate datetime null,	
						stp_departuredate datetime null,
						stp_hrs varchar(6) null, --datetime null,
						stp_est_drv_time varchar(6) null, --datetime null,
						stp_lgh_mileage int null,
						stp_cmp_id varchar(8) null,
						sv_cmp_type varchar(25) null,
						stp_cmp_name varchar(60) null,
						stp_cmp_address1 varchar(50) null,
						stp_cmp_address2 varchar(50) null,
						cty_nmstct varchar(25) null,
						stp_cmp_zip varchar(10) null,
						stp_cmp_primaryphone varchar(20) null,
						stp_comment varchar(255) null, -- del instr
						lgh_number int null,
						ord_remarks varchar(255) null,
						stp_display_seq int null,
						fgt_weight money null, -- 29927 JD
						fgt_volume money null  -- 29927 JD
							) 

--insert into #temp (



--insert into #temp (first stop)
select @li_ord = 0
WHILE 1 =1 
BEGIN
	select @li_ord = min(ord_hdrnumber) from stops where mov_number = @pl_mov and ord_hdrnumber > @li_ord 

	If @li_ord is null
		BREAK
	select @li_seq = min(stp_mfh_sequence) from stops where mov_number = @pl_mov and ord_hdrnumber = @li_ord
	select @li_disp_seq = 0
	
	--Insert into #temp (mov_number,ord_hdrnumber,stp_display_seq)
	--Values(@pl_mov,@li_ord,-1 )
	Insert into #temp(
	mov_number,ord_hdrnumber,stp_number,ord_number,ord_refnum,ord_startdate,mpp_id,
	mpp_fullname,trc_number,mpp_payhours,plan_revenue,plan_drive_hrs,
	plan_stp_hrs,plan_tot_hrs,ord_totalweight,ord_totalvolume,
	ord_plan_miles,ord_startodmeter,ord_endodmeter,ord_totodmeter,
	stp_mfh_sequence,trailer_number,stp_arrivaldate,stp_departuredate,
	stp_hrs,stp_est_drv_time,stp_lgh_mileage,stp_cmp_id,sv_cmp_type, stp_cmp_name,
	stp_cmp_address1,stp_cmp_address2,cty_nmstct,stp_cmp_zip,stp_cmp_primaryphone,stp_comment,lgh_number,stp_display_seq)
	Select mov_number , ord_hdrnumber ,stp_number, null,null,null,null,
	null,null,null,null,null,
	null,null,null,null,
	null,null,null,null,
	stp_mfh_sequence,null,stp_arrivaldate,stp_departuredate,
	null,null,stp_lgh_mileage,cmp_id,null, null,
	null,null,null,null,null,stp_comment,lgh_number,@li_disp_seq
	from stops where mov_number = @pl_mov and stp_mfh_sequence = @li_seq
	
	
--	select @li_seq = 0
	While 2 = 2
	BEGIN
			select @li_seq = min(stp_mfh_sequence) from stops where stp_mfh_sequence > @li_seq and mov_number = @pl_mov and ord_hdrnumber = @li_ord --and stp_type = 'DRP'
			If @li_seq is null 
			begin
				break
			end
			
/*			 insert into #temp (mov_number,ord_hdrnumber,stp_number,stp_mfh_sequence,stp_cmp_name,stp_est_drv_time,stp_lgh_mileage)
			 select mov_number,ord_hdrnumber,stp_number,stp_mfh_sequence,'drive',null,stp_lgh_mileage from stops 
			 where mov_number = @pl_mov and ord_hdrnumber = @li_ord and stp_mfh_sequence = @li_seq */
			-- insert into #temp (stop detail row)
	
			select @li_disp_seq = @li_disp_seq + 1
			Insert into #temp(
			mov_number,ord_hdrnumber,stp_number,ord_number,ord_refnum,ord_startdate,mpp_id,
			mpp_fullname,trc_number,mpp_payhours,plan_revenue,plan_drive_hrs,
			plan_stp_hrs,plan_tot_hrs,ord_totalweight,ord_totalvolume,
			ord_plan_miles,ord_startodmeter,ord_endodmeter,ord_totodmeter,
			stp_mfh_sequence,trailer_number,stp_arrivaldate,stp_departuredate,
			stp_hrs,stp_est_drv_time,stp_lgh_mileage,stp_cmp_id,sv_cmp_type, stp_cmp_name,
			stp_cmp_address1,stp_cmp_address2,cty_nmstct,stp_cmp_zip,stp_cmp_primaryphone,stp_comment,lgh_number,stp_display_seq)
			Select mov_number , ord_hdrnumber ,stp_number, null,null,null,null,
			null,null,null,null,null,
			null,null,null,null,
			null,null,null,null,
			stp_mfh_sequence,null,stp_arrivaldate,stp_departuredate,
			null,null,stp_lgh_mileage,cmp_id,null, null,
			null,null,null,null,null,stp_comment,lgh_number,@li_disp_seq
			from stops where mov_number = @pl_mov and ord_hdrnumber = @li_ord and stp_mfh_sequence = @li_seq
			
			
	END
	
	IF EXISTS(SELECT * from #temp where ord_hdrnumber = @li_ord) 
	BEGIN
		UPDATE #temp set sv_cmp_type = col_data from extra_info_data
		where #temp.stp_cmp_id = extra_info_data.table_key
		and extra_info_data.extra_id = 5
		and extra_info_data.tab_id = 1
		and extra_info_data.col_id = 3

		UPDATE #temp set stp_cmp_name = cmp_name , stp_cmp_address1= cmp_address1,
						 stp_cmp_address2 = cmp_address2,cty_nmstct = company.cty_nmstct ,stp_cmp_zip = cmp_zip,
						 stp_cmp_primaryphone = cmp_primaryphone from company 
			where stp_cmp_id = cmp_id and   ord_hdrnumber = @li_ord

		UPDATE #temp set stp_cmp_name = 'Check-in & depart domicile' , stp_cmp_address1= null,
						 stp_cmp_address2 = null,cty_nmstct = null ,stp_cmp_zip = null,
						 stp_cmp_primaryphone = null 
		where ord_hdrnumber = @li_ord 
		and seq_num = (select min(seq_num) from #temp where ord_hdrnumber = @li_ord and stp_display_seq = 0 )
		and sv_cmp_type = 'DC'

		UPDATE #temp set stp_cmp_name = 'Arrive domicile & check-out' , stp_cmp_address1= null,
						 stp_cmp_address2 = null,cty_nmstct = null ,stp_cmp_zip = null,
						 stp_cmp_primaryphone = null 
		where ord_hdrnumber = @li_ord and seq_num = (select max(seq_num) from #temp where ord_hdrnumber = @li_ord)
		and sv_cmp_type = 'DC'
	
	
	
		UPDATE #temp set plan_drive_hrs = (select case when (sum(stp_est_drv_time)/ 60) > 9 then convert(varchar(2) ,sum(stp_est_drv_time)/60)  
		 else '0'+convert(varchar(2) ,sum(stp_est_drv_time)/60)  end + ':'+
		case when (sum(stp_est_drv_time) - ((sum(stp_est_drv_time)/60 ) * 60 )) > 9 then  convert( varchar(2) ,sum(stp_est_drv_time) - ((sum(stp_est_drv_time)/60 ) * 60 ))
		else '0' + convert( varchar(2) ,sum(stp_est_drv_time) - ((sum(stp_est_drv_time)/60 ) * 60 )) end
		from stops where mov_number = @pl_mov and ord_hdrnumber = @li_ord )
		Where #temp.ord_hdrnumber = @li_ord
	
		UPDATE #temp set plan_stp_hrs = (select case when (sum(stp_est_activity)/60) > 9 then  convert(varchar(2) ,sum(stp_est_activity)/60)  
		else '0' + convert(varchar(2) ,sum(stp_est_activity)/60) end  + ':'+
		case when  (sum(stp_est_activity) - ((sum(stp_est_activity)/60 ) * 60 )) > 9 then  convert( varchar(2) ,sum(stp_est_activity) - ((sum(stp_est_activity)/60 ) * 60 ))
		else '0' + convert( varchar(2) ,sum(stp_est_activity) - ((sum(stp_est_activity)/60 ) * 60 )) end
		from stops where mov_number = @pl_mov and ord_hdrnumber = @li_ord )
		Where #temp.ord_hdrnumber = @li_ord
	
		UPDATE #temp set plan_tot_hrs = (select case when ((sum(stp_est_drv_time) + sum(stp_est_activity))/60) > 9 then convert(varchar(2) ,(sum(stp_est_drv_time) + sum(stp_est_activity))/60)  
		else '0' + convert(varchar(2) ,(sum(stp_est_drv_time) + sum(stp_est_activity))/60)  end+ ':'+
		case when (sum(stp_est_drv_time) + sum(stp_est_activity) - (((sum(stp_est_drv_time) + sum(stp_est_activity))/60 ) * 60 )) > 9 then
			 convert( varchar(2) ,sum(stp_est_drv_time) + sum(stp_est_activity) - (((sum(stp_est_drv_time) + sum(stp_est_activity))/60 ) * 60 ))
		else  '0' + convert( varchar(2) ,sum(stp_est_drv_time) + sum(stp_est_activity) - (((sum(stp_est_drv_time) + sum(stp_est_activity))/60 ) * 60 ))
		end 
		from stops where mov_number = @pl_mov and ord_hdrnumber = @li_ord )
		Where #temp.ord_hdrnumber = @li_ord
	
		UPDATE #temp set ord_plan_miles = 
		(select sum(stp_lgh_mileage) from stops where mov_number = @pl_mov and ord_hdrnumber =@li_ord )
		Where #temp.ord_hdrnumber = @li_ord
	
	
	/*
	   UPDATE #temp set plan_drive_hrs = 
		(select dateadd(mi,sum(stp_est_drv_time),'19500101 00:00') from stops where mov_number = @pl_mov and ord_hdrnumber > 0 ),
			plan_stp_hrs = 
		(select dateadd(mi,sum(stp_est_activity),'19500101 00:00') from stops where mov_number = @pl_mov and ord_hdrnumber > 0 ),
		plan_tot_hrs =
		(select dateadd(mi,sum(stp_est_drv_time) + sum(stp_est_activity),'19500101 00:00') from stops where mov_number = @pl_mov and ord_hdrnumber > 0 ),
		ord_plan_miles = 
		(select sum(stp_lgh_mileage) from stops where mov_number = @pl_mov and ord_hdrnumber > 0 )
	
		UPDATE #temp set 	stp_hrs = dateadd(mi,stp_est_activity,'19500101 00:00'),
							stp_est_drv_time = dateadd(mi,stops.stp_est_drv_time,'19500101 00:00') 
		from stops where #temp.stp_number = stops.stp_number
	*/
	
	
	END 
END -- end of loop for orders
IF exists (select * from #temp)
BEGIN
	UPDATE #temp set stp_comment = '' where stp_comment is null
	UPDATE #temp set stp_comment =	 Isnull(substring(stp_comment,1,252 - datalength( IsNull(substring(cmp_directions,1,200),''))),'')+ 
	case when datalength(IsNull(rtrim(substring(cmp_directions,1,200)),'')) = 0    or
	 datalength(IsNull(rtrim(stp_comment),'')) = 0   then '' else  ' / ' end +
	 case   when datalength(IsNull(rtrim(substring(stp_comment,1,252)),'')) = 0  then 
	IsNull(rtrim(substring(cmp_directions,1,252)),'') 
	when datalength(IsNull(rtrim(substring(stp_comment,1,252)),''))  < 52 then IsNull(rtrim(substring(cmp_directions,1,252 -datalength(IsNull(rtrim(substring(stp_comment,1,252)),'')))),'')
	else 	IsNull(rtrim(substring(cmp_directions,1,200)),'') end

	from company 
	where stp_cmp_id = cmp_id and stp_cmp_id <> 'UNKNOWN'
--	UPDATE #temp set stp_comment = cmp_directions from company where 
--	stp_comment is null and stp_cmp_id = cmp_id and stp_cmp_id <> 'UNKNOWN'	
	
	UPDATE #temp set mpp_id = lgh_driver1,trailer_number =lgh_primary_trailer ,trc_number = lgh_tractor
	from legheader where #temp.lgh_number = legheader.lgh_number

	UPDATE #temp set mpp_fullname = mpp_firstname + ' ' + mpp_lastname from manpowerprofile 
			where #temp.mpp_id = manpowerprofile.mpp_id and #temp.mpp_id <> 'UNKNOWN'
	
	UPDATE #temp set trc_number = NULL where trc_number = 'UNKNOWN'
	UPDATE #temp set mpp_id = NULL where mpp_id = 'UNKNOWN'
	UPDATE #temp set trailer_number = NULL where trailer_number = 'UNKNOWN'



--	UPDATE #temp set ord_number = o.ord_number ,ord_refnum = substring(o.ord_refnum,1,charindex('-',o.ord_refnum) -1 ) ,ord_startdate = o.ord_startdate,
	UPDATE #temp set ord_number = o.ord_number ,ord_refnum = o.ord_refnum ,ord_startdate = o.ord_startdate,ord_remarks = o.ord_remark
					 -- ,ord_totalweight=o.ord_totalweight,ord_totalvolume= o.ord_totalvolume -- 29927 Change Request for totals
				from orderheader o where o.ord_hdrnumber = #temp.ord_hdrnumber

--29927 JD 11/16/2005 
	

	If exists (select * from stops where mov_number = @pl_mov and stp_type = 'DRP' and stp_mfh_sequence < (select max(stp_mfh_sequence) from stops where 
				stops.mov_number = @pl_mov )) 
		select @ldec_totalweight = sum(fgt_weight) ,@ldec_totalvolume = sum(fgt_volume) from freightdetail ,stops where stops.mov_number = @pl_mov and 
		freightdetail.stp_number = stops.stp_number and stp_type = 'DRP' and stp_mfh_sequence < (select max(stp_mfh_sequence) from stops where 
		stops.mov_number = @pl_mov )
	else
	BEGIN		
		IF ((select count(*) from stops where mov_number = @pl_mov) = 2)		
			select @ldec_totalweight = sum(fgt_weight) ,@ldec_totalvolume = sum(fgt_volume) from freightdetail ,stops where stops.mov_number = @pl_mov and 
			freightdetail.stp_number = stops.stp_number and stp_type = 'DRP'
		ELSE			
			select @ldec_totalweight = sum(fgt_weight) ,@ldec_totalvolume = sum(fgt_volume) from freightdetail ,stops where stops.mov_number = @pl_mov and 
			freightdetail.stp_number = stops.stp_number and stp_type = 'PUP'
	END

	update #temp set ord_totalweight = @ldec_totalweight, ord_totalvolume = @ldec_totalvolume
-- end 29927 JD

	UPDATE #temp set stp_hrs =  case when (stp_est_activity/60) > 9 then  convert(varchar(2) ,stp_est_activity/60)  
	else '0' + convert(varchar(2) ,stp_est_activity/60)  end + ':'+
	case when (stp_est_activity - ((stp_est_activity/60 ) * 60 )) > 9 then 
		convert( varchar(2) ,stp_est_activity - ((stp_est_activity/60 ) * 60 ))
	else '0' + convert( varchar(2) ,stp_est_activity - ((stp_est_activity/60 ) * 60 )) end
	from stops where #temp.stp_number = stops.stp_number


	UPDATE #temp set stp_est_drv_time = case when (stops.stp_est_drv_time/60) > 9 then 
			  convert(varchar(2) ,stops.stp_est_drv_time/60) 
	else '0' + convert(varchar(2) ,stops.stp_est_drv_time/60) end +  ':'+
	case when (stops.stp_est_drv_time - ((stops.stp_est_drv_time/60 ) * 60 )) > 9 then
	 convert( varchar(2) ,stops.stp_est_drv_time - ((stops.stp_est_drv_time/60 ) * 60 ))
	else '0' +  convert( varchar(2) ,stops.stp_est_drv_time - ((stops.stp_est_drv_time/60 ) * 60 )) end 
	from stops where #temp.stp_number = stops.stp_number

--	update #temp set stp_cmp_id = 'drive' where stp_cmp_id is null  and stp_display_seq is null

-- 29927 JD
	update #temp set fgt_weight = (select sum(fgt_weight) from freightdetail,stops where freightdetail.stp_number = #temp.stp_number and freightdetail.stp_number = stops.stp_number and stp_type = 'DRP')
	update #temp set fgt_volume = (select sum(fgt_volume) from freightdetail,stops where freightdetail.stp_number = #temp.stp_number and freightdetail.stp_number = stops.stp_number and stp_type = 'DRP')

-- 29927 JD end

END
--***********************SV Added Code***********************************
update 	orderheader
set 	ord_extrainfo3 = 'Printed'
where 	mov_number = @pl_mov

update 	legheader_active
set 	lgh_extrainfo3 = 'Printed'
where 	mov_number = @pl_mov					
--*****************************end SV Added Code***************************

select seq_num,mov_number,ord_hdrnumber,lgh_number,ord_number,ord_refnum,ord_startdate,mpp_id,
mpp_fullname,trc_number,mpp_payhours,plan_revenue,plan_drive_hrs,
plan_stp_hrs,plan_tot_hrs,ord_totalweight,ord_totalvolume,
ord_plan_miles,ord_startodmeter,ord_endodmeter,ord_totodmeter,
stp_mfh_sequence,trailer_number,stp_arrivaldate,stp_departuredate,
stp_hrs,stp_est_drv_time,stp_lgh_mileage,stp_cmp_id,stp_cmp_name,
stp_cmp_address1,stp_cmp_address2,cty_nmstct,stp_cmp_zip,stp_cmp_primaryphone,stp_comment,ord_remarks,
stp_display_seq,fgt_weight,fgt_volume from #temp
order by  seq_num

					
GO
GRANT EXECUTE ON  [dbo].[d_tripsheetformat04_sp] TO [public]
GO
