SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE proc [dbo].[update_legheader_active] @lgh_number int
as

/**
 * 
 * NAME:
 * dbo.UPDATE_LEGHEADER_ACTIVE
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
 *
 * RETURNS:
 * 
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @lgh_number, int, input, null;
 *       This parameter indicates the LEGHEADER NUMBER(ie.lgh_number)
 *       The value must be non-null and non-empty.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 *
 * REVISION HISTORY:
 * 03/01/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 03/31/2005 PTS26766 - DJM - Recode changes for PTS 19028 from Eagle source Added lgh_originzip and lgh_destzip columns 
 * 11/21/2005 PTS29623 - ILB - Add free form comments field (lgh_trc_comment) in the Tractor view of the Planning Worksheet
 * 08/16/2006 PTS34041 - AJR - Add ACE status field to update(lgh_ace_status)
 * 9/13/2006 PTS 33890 - BDH - Added 2nd next drop fields.
 * 08/30/2007 PTS39133 - SLM - Based on General Info Setting 'PWSumOrdExtraInfo' update lgh_extrainfo1 with SUM of orderheader.ord_extrainfo1
 * 4/19/08 PTS40260 Pauls recode add 35379 jguo remove index hints 
 * 07/07/2011 PTS57693 MTC Added nolocks on selects to reduce deadlocks when very a high volume DB
 * 10/31/11 PTS58289 add fields for Appian interface to TMWSuite lgh_optimizestatus and lgh_optimizedrouteid
 *              (the latter the key drh_id to the directroutehdr table entry for htis routing)
**/  

declare @v_mov_number integer,
	@v_ord_hdrnumber integer,
	@v_lgh_active char(1),
	@v_lgh_outstatus char(6),
	@v_next_drp_stp_number int,
	@v_next_pup_stp_number int,
	@v_ord_totalweight int,
	--jlb PTS 40833
	--@v_ord_totalvolume int,
	@v_ord_totalvolume float,
	@v_cmd_count int,
	@v_cmd_freight_count int,
	@v_cmd_pieces_count int,
	@v_ordercount smallint, 
	@v_xdock int,
	@v_ord_stopcount tinyint, 
	@v_washstatus varchar(1),
	@v_ref_type varchar(6),
	@v_ref_number varchar(30),
	--JLB PTS 40833
	--@v_tot_count int,
	@v_tot_count decimal(9,2),
	@v_npup_cmpid varchar(8), 
	@v_npup_cmpname varchar(30),
	@v_npup_ctyname varchar(25),
	@v_npup_state varchar(6),
	@v_npup_arrivaldate datetime,
	@v_ndrp_cmpid varchar(8) ,
	@v_ndrp_cmpname varchar(30),
	@v_ndrp_ctyname varchar(25),
	@v_ndrp_state varchar(6),
	@v_ndrp_arrivaldate datetime,
	@v_npup_departuredate datetime,
	@v_ndrp_departuredate datetime,
	@v_ndrp_earliest varchar(30),
	@v_ndrp_latest varchar(30),
	@v_cmd_count_setting varchar(10),
	@v_generalinforunDRPs varchar (5),
	@v_stopnumber int,
	@v_totalstops int,
	@v_eventcode varchar (6),
	--vmj1+	PTS 15033	07/31/2002	Add Planning Worksheet comments..
	@v_lgh_comment varchar(255),
	--vmj1-
	@v_optn_on	CHAR(1),
	@v_gps		VARCHAR(255),
	@v_gpsDate 	VARCHAR(30),
	--DPH PTS 19787   01/26/04
	@v_ReftypeRestriction1 varchar(10),
	@v_ReftypeRestriction2 varchar(10),
	--DPH PTS 19787   01/26/04
	--PTS# 29623 ILB 11/17/2005
	@v_lgh_trc_comment varchar(255),
	--PTS# 29623 ILB 11/17/2005	
	-- PTS 33890 BDH 9/11/2006
	@v_next_next_drp_stp_number int,  
	@v_next_ndrp_cmpid varchar(8) ,
	@v_next_ndrp_cmpname varchar(30),
	@v_next_ndrp_ctyname varchar(25),
	@v_next_ndrp_state varchar(6),
	@v_next_ndrp_arrivaldate datetime,
	@v_seq int,
	@v_next_seq int,
	-- PTS 33890 BDH 9/11/2006
	@v_ma_transaction_id bigint,		-- RE - PTS #48722
	@v_ma_tour_number int,				-- RE - PTS #48722
	@v_ma_tour_max_sequence tinyint,	-- RE - PTS #48722
	@v_min_lgh int,						-- RE - PTS #48722
	@UseUnknownCmpId  CHAR(1) --PTS67320 MBR 02/19/13

SELECT	@v_optn_on = LEFT(gi_string1, 1)
  FROM	generalinfo with (nolock) 
 WHERE	gi_name = 'CopyGPSToLH'

--PTS67320 MBR 02/19/13
SELECT @useUnknownCmpId = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
  FROM generalinfo
 WHERE gi_name = 'UseUnknownCmpId'

select @v_generalinforunDRPs = UPPER (isnull(left (gi_string1, 5), '')) from generalinfo  with (nolock) where gi_name = 'RunDRPs'
--init
select @v_lgh_active='N', @v_ord_hdrnumber = 0
select @v_cmd_count_setting = upper(isnull(gi_string1,'Pieces')) from generalinfo  with (nolock) where gi_name = 'cmd_total'
if @v_cmd_count_setting <> 'FREIGHT' select @v_cmd_count_setting = 'PIECES'

--if legheader is deleted then init values will cause delete
select @v_mov_number = mov_number,
	@v_ord_hdrnumber = ord_hdrnumber,
	@v_lgh_active = lgh_active,
	@v_lgh_outstatus = lgh_outstatus,
	--vmj1+
	@v_lgh_comment = lgh_comment,
	--vmj1-
	--PTS# 29623 ILB 11/17/2005
	@v_lgh_trc_comment = lgh_trc_comment,
	--PTS# 29623 ILB 11/17/2005
	@v_ma_transaction_id = ISNULL(ma_transaction_id, -1),	-- RE - PTS #48722
	@v_ma_tour_number = ISNULL(ma_tour_number, -1)			-- RE - PTS #48722
from legheader with (nolock) 
where lgh_number = @lgh_number

-- RE - PTS #48722 BEGIN
IF @v_ma_transaction_id > 0 AND @v_ma_tour_number > 0
BEGIN
	SELECT	@v_ma_tour_max_sequence = MAX(ISNULL(ma_tour_sequence, 1))
	  FROM	legheader with (nolock) 
	 WHERE	ma_transaction_id = @v_ma_transaction_id
	   AND	ma_tour_number = @v_ma_tour_number
END
-- RE - PTS #48722 END

if @v_lgh_active='N' 
begin
	delete legheader_active  where lgh_number = @lgh_number
end
else
begin
	SELECT	@v_optn_on = LEFT(gi_string1, 1)
	  FROM	generalinfo  with (nolock) 
	 WHERE	gi_name = 'CopyGPSToLH'

	IF @v_optn_on = 'Y'
	BEGIN
		SELECT	@v_gps = trc_gps_desc,
				@v_gpsDate = convert(varchar(5), trc_gps_date, 1) + ' ' + convert(varchar(5), trc_gps_date, 8)
		  FROM 	tractorprofile with (nolock) ,
				legheader with (nolock) 
		 WHERE	trc_number = lgh_tractor AND
				lgh_tractor <> 'UNKNOWN' AND
				lgh_number = @lgh_number
	END

	-- RE - 03/04/02 - PTS #13363 added isnull's and change to look at freight instead of stops
	SELECT 	@v_ord_totalvolume = SUM(ISNULL(freightdetail.fgt_volume, 0)), 
			@v_ord_totalweight = SUM(ISNULL(freightdetail.fgt_weight, 0)),
			@v_tot_count = SUM( ISNULL(freightdetail.fgt_count,0)), 
			@v_cmd_freight_count = COUNT( freightdetail.cmd_code ),
			@v_cmd_pieces_count = SUM(ISNULL(freightdetail.fgt_count,0))
	FROM 	stops with (nolock) , freightdetail  with (nolock) 
	WHERE 	stops.lgh_number = @lgh_number
	  AND	stops.stp_number = freightdetail.stp_number 
	  AND	(stops.stp_event = 'XDU' OR stops.stp_type = 'DRP' )

	if @v_cmd_count_setting = 'PIECES'
		select @v_cmd_count = @v_cmd_pieces_count
	else
		select @v_cmd_count = @v_cmd_freight_count

	SELECT @v_ordercount = COUNT ( DISTINCT stops.ord_hdrnumber)
	FROM	stops with (nolock) 
	WHERE	stops.lgh_number = @lgh_number 
		  AND	stops.ord_hdrnumber > 0

	--PTS67320 MBR 02/19/13
	IF @UseUnknownCmpId = 'Y' 
        BEGIN
	   SELECT @v_ord_stopcount = COUNT(stops.cmp_id)
	     FROM stops WITH (NOLOCK)
	    WHERE stops.lgh_number = @lgh_number
	END
	ELSE
	BEGIN
	   SELECT @v_ord_stopcount = COUNT(DISTINCT stops.cmp_id)
	     FROM stops WITH (NOLOCK) 
	    WHERE stops.lgh_number = @lgh_number
 	END

	SELECT	 @v_xdock = MIN ( mov_number )
	FROM	stops with (nolock) , (SELECT distinct ord_hdrnumber FROM stops with (nolock) 
				WHERE mov_number = @v_mov_number and ord_hdrnumber <> 0) orders
	WHERE	stops.ord_hdrnumber = orders.ord_hdrnumber
	  AND	stops.mov_number <> @v_mov_number 

	select @v_stopnumber =  stp_mfh_sequence, @v_eventcode = stp_event 
        from stops S1  with (nolock) 
       where stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                   FROM stops s2 with (nolock) , eventcodetable  with (nolock) 
                                   WHERE stp_status = 'OPN' AND 
                                         stp_event = abbr AND 
-- PTS 30725 -- BL (Start)
--					 s2.mov_number = @v_mov_number) AND 
--             s1.mov_number = @v_mov_number
					 s2.lgh_number = @lgh_number) AND 
             s1.lgh_number = @lgh_number
-- PTS 30725 -- BL (end)
      
	select @v_totalstops = count (*)
                      from stops with (nolock) 
                     where mov_number = @v_mov_number 
      
	SELECT @v_next_pup_stp_number = min(stp_number)
        FROM stops s1 with (nolock) 
       WHERE stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                   FROM stops s2 with (nolock) , eventcodetable  with (nolock) 
                                   WHERE stp_status = 'OPN' AND 
                                         stp_event = abbr AND 
                                         (fgt_event = 'PUP' or stp_event = 'XDL') AND 
										-- RE - 03/04/02 - PTS #13375
	                                    -- s2.lgh_number = @lgh_number AND 
										 s2.mov_number = @v_mov_number AND
                                         s2.ord_hdrnumber > 0) AND 
			-- RE - 03/04/02 - PTS #13375
            -- s1.lgh_number = @lgh_number AND 
			 s1.mov_number = @v_mov_number AND
             s1.ord_hdrnumber > 0


	if @v_generalinforunDRPs = 'STOPS'
	begin
		set @v_next_pup_stp_number = -999

		-- 33890 BDH 9/11/2006 get the seq & next_seq first to get next_next_drp_stp_number later.
		SELECT @v_seq = MIN(stp_mfh_sequence) 
                FROM stops s2 with (nolock) , eventcodetable  with (nolock) 
                WHERE stp_status = 'OPN' AND 
                	stp_event = abbr AND 
                	s2.mov_number = @v_mov_number

		SELECT @v_next_seq = MIN(stp_mfh_sequence) 
                FROM stops s2 with (nolock) , eventcodetable  with (nolock) 
                WHERE stp_status = 'OPN' AND 
                	stp_event = abbr AND 
                	s2.mov_number = @v_mov_number and
			stp_mfh_sequence > @v_seq
           
		SELECT @v_next_drp_stp_number = min(stp_number)
             	FROM stops s1 with (nolock) 
            	WHERE stp_mfh_sequence = @v_seq AND
                  s1.mov_number = @v_mov_number 

		-- 33890 BDH 9/11/2006 start
		SELECT @v_next_next_drp_stp_number = min(stp_number)
             	FROM stops s1 with (nolock) 
            	WHERE stp_mfh_sequence = @v_next_seq AND
                s1.mov_number = @v_mov_number
		-- 33890 BDH 9/11/2006 end
	end
	else
	begin
		-- 33890 BDH 9/11/2006 get the seq & next_seq first to get next_next_drp_stp_number later.
		SELECT @v_seq = MIN(stp_mfh_sequence) 
                FROM stops s2 with (nolock) , eventcodetable with (nolock)  
                WHERE stp_status = 'OPN' AND 
                	stp_event = abbr AND 
	                (fgt_event = 'DRP' or stp_event = 'XDU')AND 
			-- RE - 03/04/02 - PTS #13375
	                -- s2.lgh_number = @lgh_number AND 
	                s2.mov_number = @v_mov_number AND
	                s2.ord_hdrnumber > 0

		SELECT @v_next_seq = MIN(stp_mfh_sequence) 
                FROM stops s2 with (nolock) , eventcodetable  with (nolock) 
                WHERE stp_status = 'OPN' AND 
                	stp_event = abbr AND 
	                (fgt_event = 'DRP' or stp_event = 'XDU')AND 
			-- RE - 03/04/02 - PTS #13375
	                -- s2.lgh_number = @lgh_number AND 
	                s2.mov_number = @v_mov_number AND
	                s2.ord_hdrnumber > 0 and
			stp_mfh_sequence > @v_seq


		SELECT @v_next_drp_stp_number = min(stp_number)
             	FROM stops s1 with (nolock) 
            	WHERE stp_mfh_sequence = @v_seq AND 
			-- RE - 03/04/02 - PTS #13375
			-- s1.lgh_number = @lgh_number AND 
                	s1.mov_number = @v_mov_number AND
                  	s1.ord_hdrnumber > 0

		-- 33890 BDH 9/11/2006 start
		SELECT @v_next_next_drp_stp_number = min(stp_number)
             	FROM stops s1 with (nolock) 
            	WHERE stp_mfh_sequence = @v_next_seq AND 
			-- RE - 03/04/02 - PTS #13375
			-- s1.lgh_number = @lgh_number AND 
                	s1.mov_number = @v_mov_number AND
                	s1.ord_hdrnumber > 0 
		-- 33890 BDH 9/11/2006 end


	end

	select @v_ndrp_cmpid = company.cmp_id, @v_ndrp_cmpname = company.cmp_name, 
		@v_ndrp_ctyname = city.cty_nmstct, @v_ndrp_state = cty_state,
		@v_ndrp_arrivaldate  = stp_arrivaldate,
		@v_ndrp_departuredate  = stp_departuredate,
		@v_ndrp_earliest = convert(char(5), stp_schdtearliest, 1) + ' ' + convert(char(5), stp_schdtearliest, 8),
		@v_ndrp_latest = convert(char(5), stp_schdtlatest, 1) + ' ' + convert(char(5), stp_schdtlatest, 8)
	 from stops with (nolock) , company with (nolock) , city with (nolock) 
	 where stp_number = @v_next_drp_stp_number and
		stp_city = cty_code and
		stops.cmp_id = company.cmp_id

	-- PTS 33890 BDH start
	select @v_next_ndrp_cmpid = company.cmp_id, @v_next_ndrp_cmpname = company.cmp_name, 
		@v_next_ndrp_ctyname = city.cty_nmstct, @v_next_ndrp_state = cty_state,
		@v_next_ndrp_arrivaldate  = stp_arrivaldate
	 from stops with (nolock) , company with (nolock) , city with (nolock) 
	 where stp_number = @v_next_next_drp_stp_number and
		stp_city = cty_code and
		stops.cmp_id = company.cmp_id
	-- PTS 33890 BDH end

	select @v_npup_cmpid = company.cmp_id, @v_npup_cmpname = company.cmp_name, 
		@v_npup_ctyname = city.cty_nmstct, @v_npup_state = cty_state,
		@v_npup_arrivaldate  = stp_arrivaldate,
		@v_npup_departuredate  = stp_departuredate
	 from stops with (nolock) , company with (nolock) , city with (nolock) 
	 where stp_number = @v_next_pup_stp_number and
		stp_city = cty_code and
		stops.cmp_id = company.cmp_id



	--DPH PTS 19787   01/26/04   START

	select @v_ReftypeRestriction1 = gi_string1 from generalinfo where gi_name = 'ReferenceTypeRestriction'
	select @v_ReftypeRestriction2 = gi_string2 from generalinfo where gi_name = 'ReferenceTypeRestriction'

	if (isnull(@v_ReftypeRestriction1,'') <> '' or isnull(@v_ReftypeRestriction2,'') <> '')  
	   begin
		SElecT 	@v_ref_type = max(r.ref_type),
			@v_ref_number = max(r.ref_number)
		FROM	referencenumber r  with (nolock) --with (index=sk_ref_ship)
		WHERE	 r.ref_tablekey = @v_ord_hdrnumber and
		 	r.ref_table = 'orderheader' and 
			 r.ref_type = @v_ReftypeRestriction1
		
		if (isnull(@v_ref_number,'') = '') 
		   begin
 		
			SElecT 	@v_ref_type = max(r.ref_type),
				@v_ref_number = max(r.ref_number)
			FROM	referencenumber r  with (nolock) --with (index=sk_ref_ship)
			WHERE	 r.ref_tablekey = @v_ord_hdrnumber and
		 		r.ref_table = 'orderheader' and 
			 	r.ref_type = @v_ReftypeRestriction2
	   	   end
	   end
	
	else
	   begin
		SElecT 	@v_ref_type = max(r.ref_type),
			@v_ref_number = max(r.ref_number)
		FROM	referencenumber r  with (nolock) --with (index=sk_ref_ship)
		WHERE	 r.ref_tablekey = @v_ord_hdrnumber and
			 r.ref_table = 'orderheader' and 
			 r.ref_sequence = 1
	   end

	--DPH PTS 19787   01/26/04   END



	if exists( select * from stops  with (nolock) 
			where   stops.lgh_number = @lgh_number and
				stp_event in ('WSH','DTW'))
		select   @v_washstatus = 'P' 


	--do insert then update
	if not exists (select * from legheader_active  with (nolock) where lgh_number = @lgh_number)
		insert legheader_active (lgh_number) values (@lgh_number)

	update  legheader_active
	set lgh_firstlegnumber=lgh.lgh_firstlegnumber, 
	lgh_lastlegnumber=lgh.lgh_lastlegnumber, 
	lgh_drvtripnumber=lgh.lgh_drvtripnumber, 
	lgh_cost=lgh.lgh_cost, 
	lgh_revenue=lgh.lgh_revenue, 
	lgh_odometerstart=lgh.lgh_odometerstart, 
	lgh_odometerend=lgh.lgh_odometerend, 
	lgh_milesshortest=lgh.lgh_milesshortest, 
	lgh_milespractical=lgh.lgh_milespractical, 
	lgh_allocfactor=lgh.lgh_allocfactor, 
	lgh_startdate=lgh.lgh_startdate, 
	lgh_enddate=lgh.lgh_enddate, 
	lgh_startcity=lgh.lgh_startcity, 
	lgh_endcity=lgh.lgh_endcity, 
	lgh_startregion1=lgh.lgh_startregion1, 
	lgh_endregion1 = lgh.lgh_endregion1, 
	lgh_startstate =lgh.lgh_startstate, 
	lgh_endstate =lgh.lgh_endstate, 
	lgh_outstatus =lgh.lgh_outstatus, 
	lgh_startlat =lgh.lgh_startlat, 
	lgh_startlong =lgh.lgh_startlong, 
	lgh_endlat =lgh.lgh_endlat, 
	lgh_endlong =lgh.lgh_endlong, 
	lgh_class1 =lgh.lgh_class1, 
	lgh_class2 =lgh.lgh_class2, 
	lgh_class3 =lgh.lgh_class3, 
	lgh_class4 =lgh.lgh_class4, 
	stp_number_start =lgh.stp_number_start, 
	stp_number_end =lgh.stp_number_end, 
	cmp_id_start =lgh.cmp_id_start, 
	cmp_id_end =lgh.cmp_id_end, 
	lgh_startregion2 =lgh.lgh_startregion2, 
	lgh_startregion3 =lgh.lgh_startregion3, 
	lgh_startregion4 =lgh.lgh_startregion4, 
	lgh_endregion2 =lgh.lgh_endregion2, 
	lgh_endregion3 =lgh.lgh_endregion3, 
	lgh_endregion4 =lgh.lgh_endregion4, 
	lgh_instatus =lgh.lgh_instatus, 
	lgh_driver1 =lgh.lgh_driver1, 
	lgh_driver2 =lgh.lgh_driver2, 
	lgh_tractor =lgh.lgh_tractor, 
	lgh_primary_trailer =lgh.lgh_primary_trailer, 
	mov_number =lgh.mov_number, 
	fgt_number =lgh.fgt_number, 
	lgh_priority =lgh.lgh_priority, 
	lgh_schdtearliest =lgh.lgh_schdtearliest, 
	lgh_schdtlatest =lgh.lgh_schdtlatest, 
	cmd_code =lgh.cmd_code, 
	fgt_description =lgh.fgt_description, 
	mpp_teamleader =lgh.mpp_teamleader, 
	mpp_fleet =lgh.mpp_fleet, 
	mpp_division =lgh.mpp_division,
	mpp_domicile =lgh.mpp_domicile, 
	mpp_company =lgh.mpp_company, 
	mpp_terminal =lgh.mpp_terminal, 
	mpp_type1 =lgh.mpp_type1, 
	mpp_type2 =lgh.mpp_type2, 
	mpp_type3 =lgh.mpp_type3, 
	mpp_type4 =lgh.mpp_type4, 
	trc_company =lgh.trc_company, 
	trc_division =lgh.trc_division, 
	--PTS 55244 JJF 20110309
	trc_teamleader = lgh.trc_teamleader,
	--END PTS 55244 JJF 20110309
	trc_fleet =lgh.trc_fleet, 
	trc_terminal =lgh.trc_terminal, 
	trc_type1 =lgh.trc_type1, 
	trc_type2 =lgh.trc_type2, 
	trc_type3 =lgh.trc_type3, 
	trc_type4 =lgh.trc_type4, 
	mfh_number =lgh.mfh_number, 
	trl_company =lgh.trl_company, 
	trl_fleet =lgh.trl_fleet, 
	trl_division =lgh.trl_division, 
	trl_terminal =lgh.trl_terminal, 
	trl_type1 =lgh.trl_type1, 
	trl_type2 =lgh.trl_type2, 
	trl_type3 =lgh.trl_type3, 
	trl_type4 =lgh.trl_type4, 
	ord_hdrnumber =lgh.ord_hdrnumber, 
	lgh_fueltaxstatus =lgh.lgh_fueltaxstatus, 
	lgh_mtmiles =lgh.lgh_mtmiles, 
	lgh_prjdate1 =lgh.lgh_prjdate1, 
	lgh_etaalert1 =lgh.lgh_etaalert1, 
	lgh_etamins1 =lgh.lgh_etamins1, 
	lgh_outofroute_routing =lgh.lgh_outofroute_routing, 
	lgh_type1 =lgh.lgh_type1, 
	lgh_alloc_revenue =lgh.lgh_alloc_revenue, 
	lgh_primary_pup =lgh.lgh_primary_pup, 
	lgh_prod_hr =lgh.lgh_prod_hr, 
	lgh_tot_hr =lgh.lgh_tot_hr, 
	lgh_ld_unld_time =lgh.lgh_ld_unld_time, 
	lgh_load_time =lgh.lgh_load_time, 
	lgh_startcty_nmstct =lgh.lgh_startcty_nmstct, 
	lgh_endcty_nmstct =lgh.lgh_endcty_nmstct, 
	lgh_carrier =lgh.lgh_carrier, 
	lgh_enddate_arrival =lgh.lgh_enddate_arrival, 
	lgh_dsp_date =lgh.lgh_dsp_date, 
	lgh_geo_date =lgh.lgh_geo_date, 
	lgh_nexttrailer1 =lgh.lgh_nexttrailer1, 
	lgh_nexttrailer2 =lgh.lgh_nexttrailer2, 
	lgh_etamilestofinal =lgh.lgh_etamilestofinal, 
	lgh_etamintofinal =lgh.lgh_etamintofinal, 
	lgh_split_flag =lgh.lgh_split_flag, 
	lgh_createdby =lgh.lgh_createdby, 
	lgh_createdon =lgh.lgh_createdon, 
	lgh_createapp =lgh.lgh_createapp, 
	lgh_updatedby =lgh.lgh_updatedby, 
	lgh_updatedon =lgh.lgh_updatedon, 
	lgh_updateapp =lgh.lgh_updateapp, 
	lgh_rstartdate =lgh.lgh_rstartdate, 
	lgh_renddate =lgh.lgh_renddate, 
	lgh_rstartcity =lgh.lgh_rstartcity, 
	lgh_rendcity =lgh.lgh_rendcity, 
	lgh_rstartregion1 =lgh.lgh_rstartregion1, 
	lgh_rendregion1 =lgh.lgh_rendregion1, 
	lgh_rstartstate =lgh.lgh_rstartstate, 
	lgh_rendstate =lgh.lgh_rendstate, 
	lgh_rstartlat =lgh.lgh_rstartlat, 
	lgh_rstartlong =lgh.lgh_rstartlong, 
	lgh_rendlat =lgh.lgh_rendlat, 
	lgh_rendlong =lgh.lgh_rendlong, 
	stp_number_rstart =lgh.stp_number_rstart, 
	stp_number_rend =lgh.stp_number_rend, 
	cmp_id_rstart  =lgh.cmp_id_rstart, 
	cmp_id_rend =lgh.cmp_id_rend, 
	lgh_rstartregion2 =lgh.lgh_rstartregion2, 
	lgh_rstartregion3 =lgh.lgh_rstartregion3, 
	lgh_rstartregion4 =lgh.lgh_rstartregion4, 
	lgh_rendregion2 =lgh.lgh_rendregion2, 
	lgh_rendregion3 =lgh.lgh_rendregion3, 
	lgh_rendregion4 =lgh.lgh_rendregion4, 
	lgh_rstartcty_nmstct =lgh.lgh_rstartcty_nmstct, 
	lgh_rendcty_nmstct =lgh.lgh_rendcty_nmstct, 
	lgh_feetavailable =lgh.lgh_feetavailable, 
	can_cap_expires =lgh.can_cap_expires, 
	can_ld_expires =lgh.can_ld_expires, 
	lgh_dispatchdate =lgh.lgh_dispatchdate, 
	lgh_asset_lock =lgh.lgh_asset_lock, 
	lgh_asset_lock_dtm =lgh.lgh_asset_lock_dtm, 
	lgh_asset_lock_user =lgh.lgh_asset_lock_user, 
/*	lgh_load_origin =lgh.lgh_load_origin, 
	lgh_est_lhrate =lgh.lgh_est_lhrate, 
	lgh_est_lhpay =lgh.lgh_est_lhpay, 
	lgh_est_dhrate =lgh.lgh_est_dhrate, 
	lgh_est_dhpay =lgh.lgh_est_dhpay, 
	lgh_est_accessorials =lgh.lgh_est_accessorials, */ 
	drvplan_number =lgh.drvplan_number, --vjh 22980 removed drvplan_number from commented columns
	next_drp_stp_number = @v_next_drp_stp_number,
	next_pup_stp_number = @v_next_pup_stp_number,
	ord_totalweight = @v_ord_totalweight, 
	ord_totalvolume = @v_ord_totalvolume,
	tot_count = @v_tot_count,
	cmd_count = @v_cmd_count,
	ordercount = @v_ordercount, 
	xdock = @v_xdock,
	ord_stopcount = @v_ord_stopcount, 
	washstatus = @v_washstatus,
	ref_type = @v_ref_type,
	ref_number = @v_ref_number,
	ndrp_cmpid = @v_ndrp_cmpid, 
	ndrp_cmpname = @v_ndrp_cmpname, 
	ndrp_ctyname = @v_ndrp_ctyname, 
	ndrp_state = @v_ndrp_state,
	ndrp_arrivaldate = @v_ndrp_arrivaldate,
	npup_cmpid = @v_npup_cmpid, 
	npup_cmpname = @v_npup_cmpname, 
	npup_ctyname = @v_npup_ctyname, 
	npup_state = @v_npup_state, 
	npup_arrivaldate = @v_npup_arrivaldate,
	npup_departuredate = @v_npup_departuredate,
	ndrp_departuredate = @v_ndrp_departuredate, 
--LOR
	lgh_type2 =lgh.lgh_type2,
	lgh_tm_status = lgh.lgh_tm_status,
	lgh_tour_number = lgh.lgh_tour_number,

--mf 12/31/01
	lgh_extrainfo1 = CASE WHEN @v_optn_on = 'Y' THEN @v_gps
		 			 ELSE ord_extrainfo1 END,
	lgh_extrainfo2 = CASE WHEN @v_optn_on = 'Y' THEN @v_gpsdate 
					 ELSE ord_extrainfo2 END,
	lgh_extrainfo3 = ord_extrainfo3 ,
	lgh_extrainfo4 = ord_extrainfo4 ,
	lgh_extrainfo5 = ord_extrainfo5 ,
	lgh_extrainfo6 = ord_extrainfo6 ,
	lgh_extrainfo7 = ord_extrainfo7 ,
	lgh_extrainfo8 = ord_extrainfo8 ,
	lgh_extrainfo9 = ord_extrainfo9 ,
	lgh_extrainfo10 = ord_extrainfo10 ,
	lgh_extrainfo11 = ord_extrainfo11 ,
	lgh_extrainfo12 = ord_extrainfo12 ,
	lgh_extrainfo13 = ord_extrainfo13 ,
	lgh_extrainfo14 = ord_extrainfo14 ,
	lgh_extrainfo15 = ord_extrainfo15,
	o_cmpname = left(company_a.cmp_name,30),
	d_cmpname = left(company_b.cmp_name,30),
	f_cmpid = orderheader.ord_originpoint,
	f_cmpname = (select left(cmp_name,30) from company  with (nolock) where cmp_id = orderheader.ord_originpoint),
	f_ctyname = (select cty_nmstct from city  with (nolock) where cty_code = orderheader.ord_origincity),
	f_state = (select cmp_state from company  with (nolock) where cmp_id = orderheader.ord_originpoint),
	l_cmpid = orderheader.ord_destpoint,
	l_cmpname = (select left(cmp_name,30) from company  with (nolock) where cmp_id =  orderheader.ord_destpoint),
	l_ctyname = (select left(cty_nmstct,25) from city  with (nolock) where cty_code = orderheader.ord_destcity),
	l_state = (select cmp_state from company  with (nolock) where cmp_id = orderheader.ord_destpoint) ,

	evt_driver1_name = (select mpp_lastfirst from manpowerprofile  with (nolock) where mpp_id=lgh.lgh_driver1),
	evt_driver2_name = (select mpp_lastfirst from manpowerprofile  with (nolock) where mpp_id=lgh.lgh_driver2),
	lgh_outstatus_name = (select name from labelfile  with (nolock) where lgh.lgh_outstatus=abbr and labeldefinition = 'DispStatus'),
	lgh_instatus_name = (select name from labelfile  with (nolock) where lgh.lgh_instatus=abbr and labeldefinition = 'InStatus'),
	lgh_priority_name = (select name from labelfile  with (nolock) where lgh.lgh_priority = abbr AND labeldefinition = 'OrderPriority'),
	trl_type1_name = (select name from labelfile  with (nolock) where orderheader.trl_type1 = abbr AND labeldefinition = 'TrlType1'),
	lgh_class1_name = (select name from labelfile  with (nolock) where lgh.lgh_class1 = abbr AND labeldefinition = 'RevType1') ,
	lgh_class2_name = (select name from labelfile  with (nolock) where lgh.lgh_class2 = abbr AND labeldefinition = 'RevType2') ,
	lgh_class3_name = (select name from labelfile  with (nolock) where lgh.lgh_class3 = abbr AND labeldefinition = 'RevType3') ,
	lgh_class4_name = (select name from labelfile  with (nolock) where lgh.lgh_class4 = abbr AND labeldefinition = 'RevType4') ,

	opt_trc_type4_label = (Select name from labelfile  with (nolock) where labelfile.labeldefinition = 'TrcType4' and labelfile.abbr = orderheader.opt_trc_type4),
	opt_trl_type4_label = (Select name from labelfile  with (nolock) where labelfile.labeldefinition = 'TrlType4' and labelfile.abbr = orderheader.opt_trl_type4),
	c_lgh_type1 = (select name from labelfile  with (nolock) where lgh.lgh_type1 = abbr AND labeldefinition = 'LghType1') ,
	c_lgh_type2 = (select name from labelfile  with (nolock) where lgh.lgh_type2 = abbr AND labeldefinition = 'LghType2') ,
	mpp_fleet_name = isnull((select name from labelfile  with (nolock) where lgh.mpp_fleet = abbr AND labeldefinition = 'Fleet'),lgh.mpp_fleet),
	ord_ord_subcompany = orderheader.ord_subcompany,
	-- PTS 16182 - DJM - 11/12/02
	ord_bookedby = LTrim(Rtrim(orderheader.ord_bookedby)),
	ord_trl_type1 = orderheader.trl_type1,
	o_cmp_geoloc = IsNull(company_a.cmp_geoloc,''),
	d_cmp_geoloc = IsNull(company_b.cmp_geoloc,''),
	d_address1 = left(company_b.cmp_address1,40),
	d_address2 = left(company_b.cmp_address2,40),
	ord_totalmiles = ISNULL(orderheader.ord_totalmiles,0),
	next_stp_event_code = @v_eventcode,
	next_stop_of_total  =  CASE WHEN @v_stopnumber IS NULL OR @v_stopnumber = 0 Then ''
                                    ELSE Convert(varchar (3), @v_stopnumber)  + ' OF ' + convert (varchar (3), @v_totalstops) 
                               END,
	--vmj1+
	lgh_comment = @v_lgh_comment,
	--vmj1-
	lgh_miles = lgh.lgh_miles,
	lgh_linehaul = lgh.lgh_linehaul,
	lgh_ord_charge = lgh.lgh_ord_charge,
	lgh_act_weight = lgh.lgh_act_weight,
	lgh_est_weight = lgh.lgh_est_weight,
	lgh_tot_weight = lgh.lgh_tot_weight,
	lgh_max_weight_exceeded = lgh.lgh_max_weight_exceeded,
-- PTS18226 MBR 08/08/03
	lgh_reftype = lgh.lgh_reftype,
	lgh_refnum = lgh.lgh_refnum,
	trc_type1name = (select name from labelfile  with (nolock) where lgh.trc_type1 = abbr AND labeldefinition = 'TrcType1'),
	trc_type2name = (select name from labelfile  with (nolock) where lgh.trc_type2 = abbr AND labeldefinition = 'TrcType2'),
	trc_type3name = (select name from labelfile  with (nolock) where lgh.trc_type3 = abbr AND labeldefinition = 'TrcType3'),
	trc_type4name = (select name from labelfile  with (nolock) where lgh.trc_type4 = abbr AND labeldefinition = 'TrcType4'),
	lgh_detstatus=lgh.lgh_detstatus,
	lgh_tmstatusstopnumber = lgh.lgh_tmstatusstopnumber,
	lgh_tm_statusname = (select name from labelfile  with (nolock) where lgh.lgh_tm_status = abbr AND labeldefinition = 'TotalMailStatus'),
	ord_billto = orderheader.ord_billto,
	lgh_hzd_cmd_class = lgh.lgh_hzd_cmd_class, /*PTS 23162 CGK 9/1/2004*/
	lgh_washplan = lgh.lgh_washplan,
	lgh_originzip = lgh.lgh_originzip,
	lgh_destzip = lgh.lgh_destzip,
	ord_company = orderheader.ord_company,
	lgh_204status = (select name from labelfile  with (nolock) where lgh.lgh_204status = abbr and labeldefinition = 'Lgh204Status'),
	lgh_route = lgh.lgh_route,
	lgh_booked_revtype1 = lgh.lgh_booked_revtype1,
	lgh_permit_status = ISNULL(lgh.lgh_permit_status, 'UNK'),
	lgh_204date = lgh.lgh_204date,
	 --PTS# 29623 ILB 11/17/2005
	lgh_trc_comment = @v_lgh_trc_comment,
	--PTS# 29623 ILB 11/17/2005
	--PTS# 34041 AJR 8/16/06
	lgh_ace_status = lgh.lgh_ace_status,
	--PTS# 34041 AJR 8/16/06
	-- 33890 BDH 9/12/06
	next_ndrp_cmpid = @v_next_ndrp_cmpid, 
	next_ndrp_cmpname = @v_next_ndrp_cmpname, 
	next_ndrp_ctyname = @v_next_ndrp_ctyname, 
	next_ndrp_state = @v_next_ndrp_state,
	next_ndrp_arrivaldate = @v_next_ndrp_arrivaldate,
	-- 33890 BDH 9/12/06
	--35199 AROSS 1/04/07
	lgh_ace_status_name = (select name from labelfile  with (nolock) where lgh.lgh_ace_status = abbr AND labeldefinition = 'AceEdiStatus'),
	lgh_prev_seg_status = lgh.lgh_prev_seg_status, -- RE - PTS #44966
	lgh_prev_seg_status_last_updated = lgh.lgh_prev_seg_status_last_updated ,-- RE - PTS #44966
	lgh_204_tradingpartner = lgh.lgh_204_tradingpartner	,		--AR PTS 40745
	lgh_total_mov_bill_miles = lgh.lgh_total_mov_bill_miles, /* 07/31/2009 MDH PTS 42281: Added */
	lgh_total_mov_miles = lgh.lgh_total_mov_miles,			/* 07/31/2009 MDH PTS 42281: Added */
	lgh_mile_overage_message = lgh.lgh_mile_overage_message, /* 08/31/2009 MDH PTS 42281: Added */
	ma_transaction_id = lgh.ma_transaction_id,		-- RE - PTS #48722
	ma_tour_number = lgh.ma_tour_number,			-- RE - PTS #48722
	ma_tour_sequence = lgh.ma_tour_sequence,		-- RE - PTS #48722
	ma_trc_number = lgh.ma_trc_number,				-- RE - PTS #48722
	ma_mpp_id = lgh.ma_mpp_id,						-- RE - PTS #48722
	ma_tour_max_sequence = @v_ma_tour_max_sequence,		-- RE - PTS #48722
	lgh_raildispatchstatus = lgh.lgh_raildispatchstatus,  	--PTS46536 MBR
	lgh_car_rate = lgh.lgh_car_rate,			--PTS42845 MBR
	lgh_car_charge = lgh.lgh_car_charge,			--PTS42845 MBR
	lgh_car_accessorials = lgh.lgh_car_accessorials,	--PTS42845 MBR
	lgh_car_totalcharge = lgh.lgh_car_totalcharge,		--PTS42845 MBR
	lgh_recommended_car_id = lgh.lgh_recommended_car_id,	--PTS42845 MBR
	lgh_spot_rate = lgh.lgh_spot_rate,			--PTS42845 MBR
	lgh_spot_rate_updateddt = lgh.lgh_spot_rate_updateddt,	--PTS42845 MBR
	lgh_spot_rate_updatedby = lgh.lgh_spot_rate_updatedby,	--PTS42845 MBR
	lgh_ship_status = lgh.lgh_ship_status,			--PTS42845 MBR
        lgh_protected_rate = lgh.lgh_protected_rate,		--PTS42845 MBR
	lgh_avg_rate = lgh.lgh_avg_rate,			--PTS42845 MBR
	lgh_edi_counter = lgh.lgh_edi_counter,			--PTS42845 MBR
	lgh_faxemail_created = lgh.lgh_faxemail_created,	--PTS42845 MBR
	lgh_externalrating_miles = lgh.lgh_externalrating_miles,--PTS42845 MBR
	lgh_acc_fsc = lgh.lgh_acc_fsc,				--PTS42845 MBR
	lgh_chassis = lgh.lgh_chassis,
	lgh_chassis2 = lgh.lgh_chassis2,
	lgh_dolly = lgh.lgh_dolly,
	lgh_dolly2 = lgh.lgh_dolly2,
	lgh_trailer3 = lgh.lgh_trailer3,
	lgh_trailer4 = lgh.lgh_trailer4,
	lgh_optimizestatus = lgh.lgh_optimizestatus,
	lgh_optimizedrouteid = lgh.lgh_optimizedrouteid,
	lgh_other_status1 = lgh.lgh_other_status1,		-- RE - PTS #60362
	lgh_other_status2 = lgh.lgh_other_status2,		-- RE - PTS #60362
	lgh_direct_route_status1 = lgh.lgh_direct_route_status1, --KPM PTS 66628
	lgh_autoloadmaxgvw = lgh.lgh_autoloadmaxgvw -- PTS 83283
	FROM  legheader lgh  with (nolock) 
	      LEFT OUTER JOIN orderheader  with (nolock) ON (lgh.ord_hdrnumber = orderheader.ord_hdrnumber), company company_a, company company_b
	where legheader_active.lgh_number = @lgh_number and 
		lgh.lgh_number = @lgh_number and		
	        lgh.cmp_id_start = company_a.cmp_id AND 
		lgh.cmp_id_end = company_b.cmp_id
		--legheader.ord_hdrnumber *= orderheader.ord_hdrnumber and

-- pts 14458 dsk 10/14/02
	if @v_generalinforunDRPs = 'STOPS'
		UPDATE legheader_active 
		SET lgh_extrainfo3 = @v_ndrp_earliest
			, lgh_extrainfo4 = @v_ndrp_latest
		WHERE lgh_number = @lgh_number


	-- BEGIN SLM PTS 39133 
	If (select Upper(isnull(gi_string1,'N')) from generalinfo  with (nolock) where gi_name = 'PWSumOrdExtraInfo') = 'Y'
		--JLB PTS 40833 make sure the values can actually be converted to an int to prevent casting errors
		begin
		if (select min(isnumeric(ord_extrainfo1)) from orderheader o with (nolock) inner join legheader_active l  with (nolock) ON l.mov_number = o.mov_number and o.mov_number = @v_mov_number) =1
		begin
			--PTS71879 JJF 20130903 - changed to initially convert to money, which allows a wider range of numeric conversions as opposed to float.
									--Initial problem was that "." passes IsNumeric, yet causes a conversion error
			UPDATE legheader_active 
				--SET lgh_extrainfo1 = (select convert(varchar(255),sum(convert(int,convert(float,isnull(o.ord_extrainfo1,0)))))
				SET lgh_extrainfo1 = (select convert(varchar(255),sum(convert(int,convert(money,isnull(o.ord_extrainfo1,0)))))
										from orderheader o  with (nolock) inner join legheader_active l  with (nolock) ON l.mov_number = o.mov_number 
										WHERE l.lgh_number = @lgh_number)
				WHERE lgh_number = @lgh_number
		end
		-- END SLM PTS 39133
	end
   
	-- RE - PTS #48722 BEGIN
	IF @v_ma_transaction_id > 0 AND @v_ma_tour_number > 0
	BEGIN
		SELECT	@v_min_lgh = MIN(lgh_number)
		  FROM	legheader_active with (nolock) 
		 WHERE	ma_transaction_id = @v_ma_transaction_id
		   AND	ma_tour_number = @v_ma_tour_number
		   AND	ma_tour_max_sequence <> @v_ma_tour_max_sequence

		WHILE ISNULL(@v_min_lgh, -1) > 0
		BEGIN
			UPDATE	legheader_active
			   SET	ma_tour_max_sequence = @v_ma_tour_max_sequence
			 WHERE	lgh_number = @v_min_lgh

			SELECT	@v_min_lgh = MIN(lgh_number)
			  FROM	legheader_active with (nolock) 
			 WHERE	ma_transaction_id = @v_ma_transaction_id
			   AND	ma_tour_number = @v_ma_tour_number
			   AND	ma_tour_max_sequence <> @v_ma_tour_max_sequence
			   AND	lgh_number > @v_min_lgh
		END
	END
	-- RE - PTS #48722 END

	 --PTS 57714 JJF/wjemuck 20111013
	DECLARE	@LegActivePostProcessor varchar (256),  
			@LegActivePostProcessorSwitch varchar (1)  
	
	SET @LegActivePostProcessor = ''  
	SET @LegActivePostProcessorSwitch = ''  
	
	SELECT	@LegActivePostProcessorSwitch = isnull(gi_string1,'N'), 
			@LegActivePostProcessor = isnull(gi_string2,'')  
	FROM	generalinfo   
	WHERE	gi_name = 'LegActivePostProcessing'  

	IF @LegActivePostProcessorSwitch = 'Y' AND LTRIM(@LegActivePostProcessor) > '' BEGIN
		EXEC (@LegActivePostProcessor + ' ' + @lgh_number)    
	END
	--END PTS 57714 JJF/wjemuck 20111013

end
GO
GRANT EXECUTE ON  [dbo].[update_legheader_active] TO [public]
GO
