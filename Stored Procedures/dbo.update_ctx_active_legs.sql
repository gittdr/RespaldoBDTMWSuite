SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create proc [dbo].[update_ctx_active_legs] @lgh_number int
as

/*
Revision History:
Date		Name			PTS		Label	Description
-----------	---------------	-------	-------	--------------------------------------------------
01/24/2003	Vern Jewett		16885	(none)	Original, copied from CTX source and modified.
*/

declare @mov_number integer,
		@ord_hdrnumber integer,
		@lgh_active char(1),
		@stoptime datetime,
		@lastckctime datetime,
		@stpdiff integer,
		@currenttime datetime,
		@hourdiff integer,
		@char8   varchar(8),
		@char30  varchar(30),
		@char25  varchar(25),
		@char6   varchar(6),
		@char12  varchar(12),
		@chrysler varchar(64),
		@lgh_outstatus char(6),
		@firststp int,
		@laststp int,
        @origin_cmp_id varchar(8),
        @dest_cmp_id varchar(8),
        @orderby_cmp_id varchar(8),
        @billto_cmp_id varchar(8),
        @origin_cmp_name varchar(30),
        @dest_cmp_name varchar(30),
        @orderby_cmp_name varchar(30),
        @orderby_cty_nmstct varchar(25),
        @billto_cmp_name varchar(30),
        @billto_cty_nmstct varchar(25),
		@origin_cty_nmstct varchar(25),
		@dest_cty_nmstct varchar(25),
		@ord_totalweight integer,
		@ord_totalpieces integer,
		@last_ckc_time datetime,
		@disp_loaded char(1),
		@disp_for_pu char(1), @minseq int, @maxseq int,
		@no_response char(1)


--init
select @lgh_active='N', @ord_hdrnumber = 0

--if legheader is deleted then init values will cause delete
select @mov_number = mov_number,
	@ord_hdrnumber = ord_hdrnumber,
	@lgh_active = lgh_active,
	@lgh_outstatus = lgh_outstatus
from legheader
where lgh_number = @lgh_number

if @lgh_active='N' or @ord_hdrnumber = 0
begin
	delete ctx_active_legs where lgh_number = @lgh_number
end
else
begin
	--do insert then update
	if not exists (select * from ctx_active_legs where lgh_number = @lgh_number)
		insert ctx_active_legs (lgh_number) values (@lgh_number)

	if (select lgh_outstatus from  ctx_active_legs
		where lgh_number = @lgh_number) = 'STD'
		update ctx_active_legs
		set  last_ckc_time = (select max(ckc_date)
					 from   checkcall 
					 where  ckc_lghnumber = @LGH_NUMBER  and
						ckc_updatedby <> 'TMAIL')
		where ctx_active_legs.lgh_number = @lgh_number


	if @lgh_outstatus ='STD'
		select  @last_ckc_time = max(ckc_date)
		 from   checkcall c 
			 where  c.ckc_lghnumber = @LGH_NUMBER and c.ckc_updatedby <> 'TMAIL' 

	SELECT @ord_totalweight = SUM ( isnull(fgt_weight,0)) 
		FROM 	stops, freightdetail 
		WHERE 	stops.ord_hdrnumber = @ord_hdrnumber 
		  AND	stops.stp_number = freightdetail.stp_number 
		  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )

	SELECT 	@ord_totalpieces = SUM ( isnull(fgt_count,0)) 
		FROM 	stops, freightdetail 
		WHERE 	stops.ord_hdrnumber = @ord_hdrnumber
		  AND	stops.stp_number = freightdetail.stp_number 
		  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )

	-- RE - PTS #42121 BEGIN
	--PTS# 20847 ILB 03/18/04
	SELECT --@minseq = ISNULL(MIN(stp_sequence),0) 
			@minseq = ISNULL(MIN(stp_mfh_sequence),0) 
	  FROM stops 
	 WHERE --stops.ord_hdrnumber = @ord_hdrnumber 
			stops.mov_number = @mov_number
           AND stops.stp_type = 'PUP'               
	       AND stops.stp_status <> 'DNE'
	       
        IF @minseq = 0 
           BEGIN             
	     SELECT --@minseq = Max(stp_sequence) 
				@minseq = Max(stp_mfh_sequence) 
	       FROM stops 
	      WHERE --stops.ord_hdrnumber = @ord_hdrnumber 
				stops.mov_number = @mov_number
                    AND stops.stp_type = 'PUP'
                    AND stops.stp_status = 'DNE'               
           END

	select @firststp = stp_number
	  from stops
	 where --stp_sequence = @minseq 
			stp_mfh_sequence = @minseq
	       AND --stops.ord_hdrnumber = @ord_hdrnumber 
				stops.mov_number = @mov_number
           AND	stops.stp_type = 'PUP'
              
	SELECT --@maxseq = ISNULL(Max(stp_sequence),0) 
			@maxseq = ISNULL(Max(stp_mfh_sequence),0) 
	  FROM stops 
	 WHERE --stops.ord_hdrnumber = @ord_hdrnumber 
			stops.mov_number = @mov_number
               AND stops.stp_type = 'DRP'               
               AND stops.stp_status <> 'DNE'               

        IF @maxseq = 0 
           BEGIN
	     SELECT --@maxseq = Max(stp_sequence) 
				@maxseq = Max(stp_mfh_sequence) 
	       FROM stops 
	      WHERE --stops.ord_hdrnumber = @ord_hdrnumber 
				stops.mov_number = @mov_number
                    AND stops.stp_type = 'DRP'
                    AND stops.stp_status = 'DNE'               
           END	

	select @laststp = stp_number
	  from stops
	 where --stp_sequence =  @maxseq 
			stp_mfh_sequence =  @maxseq 
               AND --stops.ord_hdrnumber = @ord_hdrnumber 
					stops.mov_number = @mov_number
               AND stops.stp_type = 'DRP'   
	-- RE - PTS #42121 END
        /*
	SELECT @minseq = MIN(stp_sequence) 
	FROM stops 
	WHERE stops.ord_hdrnumber = @ord_hdrnumber AND 	stops.stp_type = 'PUP'

	select @firststp = stp_number
	from stops
	where stp_sequence = @minseq and
		stops.ord_hdrnumber = @ord_hdrnumber AND stops.stp_type = 'PUP'

	SELECT @maxseq = Max(stp_sequence) 
	FROM stops 
	WHERE stops.ord_hdrnumber = @ord_hdrnumber AND 	stops.stp_type = 'DRP'

	select	@laststp = stp_number
	from stops
	where stp_sequence =  @maxseq and
		stops.ord_hdrnumber = @ord_hdrnumber AND stops.stp_type = 'DRP'
        */
        --PTS# 20847 ILB 03/18/04	

	select @origin_cmp_id = ord_shipper,
	        @dest_cmp_id = ord_consignee,
        	@orderby_cmp_id = ord_company,
	        @billto_cmp_id = ord_billto
	from orderheader
	where ord_hdrnumber = @ord_hdrnumber

        select @origin_cmp_name = cmp_name,
		@origin_cty_nmstct = cty_nmstct
	from company
	where cmp_id = @origin_cmp_id

        select @dest_cmp_name = cmp_name,
		@dest_cty_nmstct = cty_nmstct
	from company
	where cmp_id = @dest_cmp_id

        select @orderby_cmp_name = cmp_name,
		@orderby_cty_nmstct = cty_nmstct
	from company
	where cmp_id = @orderby_cmp_id

        select @billto_cmp_name = cmp_name,
		@billto_cty_nmstct = cty_nmstct	
	from company
	where cmp_id = @billto_cmp_id

	select @currenttime = getdate()

	select @disp_loaded = 'N',
		@disp_for_pu = 'N'
	if @lgh_outstatus = 'STD'
	begin
		if exists(select * from stops
			   where  stops.lgh_number = @lgh_number
				    AND stp_type = 'PUP' and stp_status = 'DNE' 
					AND stp_departure_status = 'DNE') 
			    select @disp_loaded = 'Y'

		IF exists (SELECT *
				FROM	stops
				WHERE	stops.lgh_number = @lgh_number
				  AND	stp_type = 'PUP'
				  AND	stops.stp_departure_status = 'OPN'
				  AND	stp_sequence = 1 )
				select @disp_for_pu = 'Y'

		if not exists (select *
				from 	stops 
				where	stops.lgh_number = @lgh_number
			    	   AND	stp_type = 'PUP' 
				  and 	stp_status = 'DNE')
				select @disp_for_pu = 'Y'
	end

	select @no_response = 'N'
	if @lgh_outstatus = 'AVL'
	if EXISTS (SELECT * FROM preplan_assets p1
		WHERE	p1.ppa_lgh_number = @lgh_number  AND p1.ppa_status = 'NO RESPONSE' )
	begin
		select @no_response = 'Y'
	end

	select @chrysler = gi_string1
	from   generalinfo
	where  gi_name = 'ExpcolorComp'

     	 update ctx_active_legs
		set
	  	ord_number = orderheader.ord_number ,
           	ord_hdrnumber = orderheader.ord_hdrnumber,
           	origin_cmp_id = @origin_cmp_id ,
           	origin_cmp_name = @origin_cmp_name ,
           	dest_cmp_id = @dest_cmp_id,
           	dest_cmp_name = @dest_cmp_name,
           	orderby_cmp_id = @orderby_cmp_id,
	        orderby_cmp_name = @orderby_cmp_name,
	        orderby_cty_nmstct = @orderby_cty_nmstct,
	        billto_cmp_id = @billto_cmp_id,
           	billto_cmp_name = @billto_cmp_name,
		billto_cty_nmstct = @billto_cty_nmstct,
		lgh_outstatus = @lgh_outstatus,
		lgh_startdate = ORDERHEADER.ord_startdate,
		lgh_completiondate = orderheader.ord_completiondate,
		lgh_origincity = legheader.lgh_startcity,
		lgh_destcity = legheader.lgh_endcity,	
		lgh_originstate = legheader.lgh_startstate,
		lgh_deststate = legheader.lgh_endstate,
		ord_revtype1 = orderheader.ord_revtype1,
		orderheader_ord_revtype1_t = 'RevType1' ,
		ord_revtype2 = orderheader.ord_revtype2,
		orderheader_ord_revtype2_t = 'RevType2' ,
		ord_revtype3 = orderheader.ord_revtype3,
		orderheader_ord_revtype3_t = 'RevType3' ,
		ord_revtype4 = orderheader.ord_revtype4,
		orderheader_ord_revtype4_t = 'RevType4' ,
		mov_number = legheader.mov_number,
		ord_charge = isnull(orderheader.ord_charge,0),
		ord_totalcharge = orderheader.ord_totalcharge,
		ord_totalweight = @ord_totalweight,
		ord_totalpieces = @ord_totalpieces,
		ord_accessorial_chrg = isnull(orderheader.ord_accessorial_chrg,0),
		ord_priority = orderheader.ord_priority,
		ord_originregion1 = legheader.lgh_startregion1,
		ord_destregion1 = lgh_endregion1,
		ord_reftype = orderheader.ord_reftype,
		ord_refnum = orderheader.ord_refnum,
		ord_invoicestatus = orderheader.ord_invoicestatus,
		origin_cty_nmstct = @origin_cty_nmstct,
           	dest_cty_nmstct = @dest_cty_nmstct,
		lld_arrivaltime =  firststp.stp_arrivaldate, 
		lld_departuretime = firststp.stp_departuredate, 
		lld_arrivalstatus = firststp.stp_status, 
		lld_departurestatus = firststp.stp_departure_status,
		lld_eta = firststp.stp_eta,
		lul_arrivaltime = laststp.stp_arrivaldate ,
		lul_departuretime = laststp.stp_departuredate, 
		lul_arrivalstatus = laststp.stp_departure_status,
		lul_origarrivalstatus = laststp.stp_status,
		lul_eta = laststp.stp_eta,
		min_to_arr_lld = 0,
		min_since_arr_lld = 0,	
		min_to_arr_lul = 0,	
		min_since_arr_lul = 0,	
		min_ckc_to_arr_lul = 99999,	
		last_ckc_time = @last_ckc_time,
		min_since_last_ckc = 99999,
		no_response = @no_response,
		lgh_tractor = legheader.lgh_tractor,
		lgh_driver = legheader.lgh_driver1,
		lgh_load_origin = legheader.lgh_load_origin,
		disp_for_pu = @disp_for_pu,
		disp_loaded = @disp_loaded,
		 chryslercmp = Case when @billto_cmp_name LIKE '%' + @chrysler + '%' Then 'Y'
				else 'N' end,
		 color = 0,
		firststp = @minseq,
		laststp = @maxseq,
		ordratingunit = orderheader.ord_ratingunit
        FROM    legheader,
		orderheader ,
	(select stp_number, stp_arrivaldate, stp_status, stp_departuredate, stp_departure_status, stp_eta
		from stops
		where stp_number = @firststp) firststp,
	(select stp_number, stp_arrivaldate, stp_status, stp_departuredate, stp_departure_status, stp_eta
		from stops
		where stp_number = @laststp) laststp

        WHERE legheader.lgh_number = @lgh_number and
		(legheader.ord_hdrnumber = orderheader.ord_hdrnumber) and
		ctx_active_legs.lgh_number = @lgh_number
end
GO
GRANT EXECUTE ON  [dbo].[update_ctx_active_legs] TO [public]
GO
