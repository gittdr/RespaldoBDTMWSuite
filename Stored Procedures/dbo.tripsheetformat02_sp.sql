SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[tripsheetformat02_sp] (@pl_movnumber int) as
	Create table #output ( stp_number int not null,
												 ord_hdrnumber int not null,
												 lgh_number int null,
												 shipto_id varchar(8) not null,
												 shipto_name varchar(100) not null,
												 stp_mfh_sequence int not null,
												 shipto_nmstct varchar(30) null,
												 total_volume money null,
												 total_count money null ,
												 ord_number char(12) null,
												  ship_date datetime null,
													driver varchar(8)  null,
													tractor varchar(8) null,
													trailer varchar(13)	null,
													cmp_addr1 varchar(60) null,
													cmp_addr2 varchar(60) null,
													cmp_addr3 varchar(60) null,
													cmp_addr4 varchar(60) null,
													cmp_phone1 varchar(20) null,
													cmp_phone2 varchar(60) null,
													cmp_fax1 varchar(60) null,
													cmp_fax2 varchar(60) null)



	Insert into #output 
	select stp_number, ord_hdrnumber, lgh_number,cmp_id , cmp_name ,stp_mfh_sequence, cty_nmstct,0,0,null,null,null,null,null,
	null,null,null,null,null,null,null,null
	 from stops,city
		where stops.ord_hdrnumber in (select ord_hdrnumber from orderheader where mov_number = @pl_movnumber) and
					stops.stp_type = 'DRP' and stops.stp_city = city.cty_code 

	
	
	update #output set total_volume = (select sum(fgt_volume) from  freightdetail where freightdetail.stp_number = #output.stp_number)
	update #output set total_count = (select sum(fgt_count) from  freightdetail where freightdetail.stp_number = #output.stp_number)
	update #output set ord_number = orderheader.ord_number from orderheader where #output.ord_hdrnumber = orderheader.ord_hdrnumber
	update #output set ship_date = (select min(stp_arrivaldate) from stops where mov_number = @pl_movnumber)
	update #output  set driver = lgh_driver1, tractor =lgh_tractor, trailer = lgh_primary_trailer from legheader
	where #output.lgh_number = legheader.lgh_number

	Update #output set  cmp_addr1 = gi_string1,cmp_addr2 = gi_string2,
				 cmp_addr3 = gi_string3,cmp_addr4 = gi_string4 from generalinfo where gi_name = 'PODCompany'

	Update #output set  cmp_phone1 = gi_string1,cmp_phone2 = gi_string2,
				 cmp_fax1 = gi_string3,cmp_fax2 = gi_string4 from generalinfo where gi_name = 'PODCompanyPhoneInfo'


	
	select * from #output order by stp_mfh_sequence

GO
GRANT EXECUTE ON  [dbo].[tripsheetformat02_sp] TO [public]
GO
