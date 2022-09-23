SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_tripsbydaterange_svcustom_sp] (@ps_asgn_type varchar(6),@ps_asgn_id varchar(20),@from_date datetime ,@to_date datetime)
as
CREATE TABLE #temp_rtn (
	lgh_number int not null,
	asgn_type varchar(6) not null,
 	asgn_id varchar(8) not null,
 	asgn_date datetime null,
	asgn_enddate datetime null,
	cmp_id_start varchar(8) null,
	cmp_id_end varchar(8) null,
	mov_number int null,
 	asgn_number int null,
 	ord_hdrnumber int null,
 	lgh_startcity int null,
 	lgh_endcity int null,
	ord_number varchar(12) null,
	name varchar(64) null,
	cmp_name_start varchar(30) null,
	cmp_name_end varchar(30) null,
	cty_nmstct_start varchar(25) null,
	cty_nmstct_end varchar(25) null)




	Insert into #temp_rtn
   SELECT lgh_number, asgn_type, asgn_id, asgn_date, asgn_enddate, '', '', 
          mov_number, asgn_number, 0, 0, 0, '', ''rsc_name, 
          '', '', '', ''
   FROM assetassignment
	WHERE asgn_type = @ps_asgn_type
		AND asgn_id = @ps_asgn_id
		AND asgn_status = 'CMP' 
		AND pyd_status = 'NPD' 
		AND asgn_enddate BETWEEN @from_date and @to_date
	
	update #temp_rtn set ord_hdrnumber = (select min(orderheader.ord_hdrnumber) 
	from orderheader
	where #temp_rtn.mov_number = orderheader.mov_number)

	update #temp_rtn set ord_number = orderheader.ord_number from orderheader where #temp_rtn.ord_hdrnumber = orderheader.ord_hdrnumber

	select * from #temp_rtn
GO
GRANT EXECUTE ON  [dbo].[d_tripsbydaterange_svcustom_sp] TO [public]
GO
