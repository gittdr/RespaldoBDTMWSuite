SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [dbo].[get_backhaul_leg_list_for_a_specific_legheader] 
@lgh_number int, @added_miles int = 9999, @days_out tinyint, @max_rows as int = 10,
@percentage int = 100, @includedBillTos varchar(max) = null,
@excludedBillTos varchar(max) = null
as
begin
       declare @miles_as_meters int
       set @miles_as_meters = @added_miles * 1609.344
       set @days_out = @days_out + 1
       declare @startcity geography
	   declare @endcity geography
	   declare @emptyMiles int
	   declare @headHaulMiles decimal

       select @startcity = citypoint from city c inner join legheader_active l on 
       c.cty_code = l.lgh_startcity where l.lgh_number = @lgh_number

	   select @endcity = citypoint from city c inner join legheader_active l on 
       c.cty_code = l.lgh_endcity where l.lgh_number = @lgh_number
	   
	   select @headHaulMiles = (@startcity.STDistance(@endcity) / 1609.344)

       select top (@max_rows) 
		lae.lgh_number, --0
	    lae.lgh_enddate, --1
		datediff(dd, las.lgh_enddate,lae.lgh_startdate) as days_out, --2
		lae.lgh_startdate, -- 3
		bh_s.citypoint.STDistance(@startcity) / 1609.344 as miles_apart,  -- 4
		bh_s.citypoint.Lat,-- 5
		bh_s.citypoint.Long, --6
		lae.lgh_endcty_nmstct, -- 7
		lae.ord_billto, -- 8
		lae.lgh_driver1, -- 9
		lae.lgh_driver2, -- 10
		lae.ord_hdrnumber, -- 11
		lae.ord_hdrnumber, -- 12
		lae.lgh_miles, -- 13
		lae.cmp_id_start, -- 14
		lae.cmp_id_end, -- 15
		lae.lgh_startcty_nmstct, -- 16
		lae.mov_number, -- 17
		CONVERT(INT, (bh_s.citypoint.STDistance(bh_e.citypoint) / 1609.344)), -- 18
		lae.lgh_ord_charge, -- 19
	    bh_e.citypoint.Lat, -- 20
		bh_e.citypoint.Long, -- 21
		las.lgh_number as headhaulLegNumber, --22

		las.lgh_miles + -- headhaul
		(@endcity.STDistance(bh_s.citypoint) / 1609.344) + -- empty miles to bh
		(bh_s.citypoint.STDistance(bh_e.citypoint) / 1609.344) + -- backhaul
		(bh_e.citypoint.STDistance(@startcity) / 1609.344) -- return to origin
		as totalmileswithHH, -- 23

		las.lgh_miles +
	   (@endcity.STDistance(bh_s.citypoint) / 1609.344) + 
	   (bh_s.citypoint.STDistance(bh_e.citypoint) / 1609.344) +
	   (bh_e.citypoint.STDistance(@startcity) / 1609.344) -
	   (las.lgh_miles + @headHaulMiles)
		as addedairmiles -- 24

	   from
       legheader_active las, legheader_active lae,
	   city bh_s,
	   city bh_e
	   where
	   las.lgh_miles +
	   (@endcity.STDistance(bh_s.citypoint) / 1609.344) + 
	   (bh_s.citypoint.STDistance(bh_e.citypoint) / 1609.344) +
	   (bh_e.citypoint.STDistance(@startcity) / 1609.344) -
	   (las.lgh_miles + @headHaulMiles)
	   < @added_miles

	   and 
	   (las.lgh_miles + (@endcity.STDistance(bh_s.citypoint) / 1609.344) + 
	   (bh_s.citypoint.STDistance(bh_e.citypoint) / 1609.344) + 
	   (bh_e.citypoint.STDistance(@startcity) / 1609.344) - 
	   (las.lgh_miles + @headHaulMiles)) /
	   (las.lgh_miles + (@endcity.STDistance(bh_s.citypoint) / 1609.344) + 
	   (bh_s.citypoint.STDistance(bh_e.citypoint) / 1609.344) + 
	   (bh_e.citypoint.STDistance(@startcity) / 1609.344)) 
	   * 100 < 
	   @percentage

	   and lae.lgh_endcity = bh_e.cty_code
       and las.lgh_enddate < lae.lgh_startdate
       and datediff(dd, las.lgh_enddate,lae.lgh_startdate) < @days_out
       and lae.lgh_outstatus = 'AVL'
       and las.lgh_number <> lae.lgh_number
	   and (@includedBillTos is null or (lae.ord_billto in (select * from splitstrings_bigger(@includedBillTos, ','))))
	   and (@excludedBillTos is null or (lae.ord_billto not in (select * from splitstrings_bigger(@excludedBillTos, ','))))
	   and bh_s.cty_code= lae.lgh_startcity
	   and bh_e.cty_code = lae.lgh_endcity
	   and las.lgh_number = @lgh_number
	   and lae.ordercount = 1
       order by addedairmiles
END
GO
GRANT EXECUTE ON  [dbo].[get_backhaul_leg_list_for_a_specific_legheader] TO [public]
GO
