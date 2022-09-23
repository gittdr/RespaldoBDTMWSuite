SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE procedure [dbo].[d_hubmiles_entry_sp]
	@vl_id 			integer
	,@vs_id_type	char(1) = 'M'
as
/* d_hubmiles_entry_sp
	Selects all stops/events for the passed Move or LegHeader, so the user may later update the hub
	miles (via PowerSuite app).

	Parameters:	@vl_id			The mov_number or lgh_number for which to select data.
				@vs_id_type		The scope: M=Move, L=LegHeader.
	
	Returns:	void (result set)

	Revision History:
	Date		Name			Label	PTS #	Description
	-----------	---------------	-------	-------	-------------------------------------------------------------------
	01/10/2002	Vern Jewett		(none)	12853	Original.
	10/18/2002	Vern Jewett		vmj1	15759	Renamed parm @mov_number to @vl_id and added @vs_id_type, so we can
												retrieved by Move (for billing/dispatch) or LegHeader (for 
												settlements).
	04/14/2003	Vern Jewett		vmj2	17818	Pass stops.stp_loadstatus so we can further 
												differentiate between empty & loaded hub miles.
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
*/

create table #stop_scope
		(stp_number	int	null)


--vmj1+
if upper(@vs_id_type) = 'L'
	insert into #stop_scope
			(stp_number)
	  select stp_number
	  from	stops
	  where	lgh_number = @vl_id
else
	insert into #stop_scope
			(stp_number)
	  select stp_number
	  from	stops
	  where	mov_number = @vl_id


select	e.evt_driver1
        ,e.evt_tractor
        ,e.evt_trailer1
        ,s.ord_hdrnumber
        ,s.stp_number
        ,s.stp_city
        ,e.evt_startdate
        ,s.cmp_id
        ,s.cmp_name
        ,e.evt_enddate
        ,s.lgh_number
        ,s.stp_sequence
        ,e.evt_hubmiles
        ,e.evt_carrier
        ,e.evt_sequence
        ,s.stp_mfh_sequence
        ,fd.fgt_sequence
        ,fd.fgt_number
        ,oh.ord_billto
        ,e.evt_number
        ,e.evt_pu_dr
        ,e.evt_eventcode
        ,e.evt_status
        ,s.stp_mfh_mileage
        ,s.stp_ord_mileage
        ,s.stp_lgh_mileage
        ,s.mfh_number
	 	,(select co.cmp_name from company co where co.cmp_id = oh.ord_billto) as billto_name
		,c.cty_nmstct cty_nmstct
		,s.mov_number
		,s.stp_region1
        ,s.stp_state
        ,1 as skip_trigger
        ,s.stp_zipcode
        ,s.stp_address
		,isnull(sign(abs(s.ord_hdrnumber)), 0) as billable_flag
		,s.stp_departure_status
        ,fd.cht_itemcode
        ,fd.cht_basisunit
		,tp.trc_currenthub
		,0 as prev_hub
		,e.evt_hubmiles as evt_hubmiles_calc

		--vmj2+
		,s.stp_loadstatus
		--vmj2-
		,s.stp_trip_mileage
  --pts40462 outer join conversion
  from	freightdetail fd  RIGHT OUTER JOIN  stops s  ON  fd.stp_number  = s.stp_number   
			LEFT OUTER JOIN  orderheader oh  ON  oh.ord_hdrnumber  = s.ord_hdrnumber   
			LEFT OUTER JOIN  city c  ON  c.cty_code  = s.stp_city ,
		tractorprofile tp  RIGHT OUTER JOIN  event e  ON  tp.trc_number  = e.evt_tractor ,
		#stop_scope ss 
  where	s.stp_number = ss.stp_number
	and	e.stp_number = s.stp_number
	and	e.evt_sequence = 1
--	and	fd.stp_number =* s.stp_number
--	and	oh.ord_hdrnumber =* s.ord_hdrnumber
--	and	c.cty_code =* s.stp_city
--	and	tp.trc_number =* e.evt_tractor

/* Original select..
select	e.evt_driver1
        ,e.evt_tractor
        ,e.evt_trailer1
        ,s.ord_hdrnumber
        ,s.stp_number
        ,s.stp_city
        ,e.evt_startdate
        ,s.cmp_id
        ,s.cmp_name
        ,e.evt_enddate
        ,s.lgh_number
        ,s.stp_sequence
        ,e.evt_hubmiles
        ,e.evt_carrier
        ,e.evt_sequence
        ,s.stp_mfh_sequence
        ,fd.fgt_sequence
        ,fd.fgt_number
        ,oh.ord_billto
        ,e.evt_number
        ,e.evt_pu_dr
        ,e.evt_eventcode
        ,e.evt_status
        ,s.stp_mfh_mileage
        ,s.stp_ord_mileage
        ,s.stp_lgh_mileage
        ,s.mfh_number
	 	,(select co.cmp_name from company co where co.cmp_id = oh.ord_billto) as billto_name
		,c.cty_nmstct cty_nmstct
		,@mov_number mov_number
		,s.stp_region1
        ,s.stp_state
        ,1 as skip_trigger
        ,s.stp_zipcode
        ,s.stp_address
		,isnull(sign(abs(s.ord_hdrnumber)), 0) as billable_flag
		,s.stp_departure_status
        ,fd.cht_itemcode
        ,fd.cht_basisunit
		,tp.trc_currenthub
		,0 as prev_hub
		,e.evt_hubmiles as evt_hubmiles_calc
  from	stops s
		,event e
		,freightdetail fd
		,orderheader oh
		,city c
		,tractorprofile tp
  where	s.mov_number = @mov_number
	and	e.stp_number = s.stp_number
	and	e.evt_sequence = 1
	and	fd.stp_number =* s.stp_number
	and	oh.ord_hdrnumber =* s.ord_hdrnumber
	and	c.cty_code =* s.stp_city
	and	tp.trc_number =* e.evt_tractor
*/

drop table #stop_scope
--vmj1-
GO
GRANT EXECUTE ON  [dbo].[d_hubmiles_entry_sp] TO [public]
GO
