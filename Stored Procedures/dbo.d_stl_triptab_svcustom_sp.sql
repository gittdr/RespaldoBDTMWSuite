SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_stl_triptab_svcustom_sp]  		(@lgh_number 		int	,@vl_ord_hdrnumber	int	= 0,
@ps_num_type char(1) , @ps_asgn_type varchar(3) , @ps_asgn_id varchar(20) ,@pdt_from_date datetime , @pdt_to_date datetime )
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @num_type	char(1),
	@asgn_type	char(1),
	@drv1_asgn      int,
        @drv2_asgn      int,
        @trc_asgn       int,
        @car_asgn       int,
        @trl1_asgn	int,
        @min_evt        int,
        @ord_num        char(12),
        @mov_num        int,
        @lgh_hdr        int,
        @ord_hdr        int,
        @event          int,
        @drv1           varchar(8),
	@drv1_status	varchar(6),
	@drv1_prorap	char(1),
        @drv2           varchar(8),
	@drv2_status	varchar(6),
        @trc            varchar(8),
	@trc_status	varchar(6),
        @trl1           varchar(13),
	@trl1_status	varchar(6),
        @car            varchar(8),
	@car_status	varchar(6),
	@stl_status	varchar(6),
	@mpp_type1	varchar(6),
	@mpp_type1_2	varchar(6),
	@drv1_altid	varchar(8),
	@drv2_altid	varchar(8),
	@tpr_id		varchar(8), 
	@revtype4	varchar(6),
	@order_list     varchar(255),
	@ls_ordnum	char(12),
	@trctype4      varchar(6),
	@ord_status    varchar(6)

If convert(int ,@ps_num_type) > 3 
Begin
	select @num_type = @ps_num_type
	If @num_type = '4' or @num_type = '5'
	BEGIN
		select @asgn_type = @ps_asgn_type
		If @asgn_type = '1'
				select 	@drv1 = @ps_asgn_id
		If @asgn_type = '2'			
				select @drv2 = @ps_asgn_id
		If @asgn_type = '3'			
				select @trc = @ps_asgn_id
	END
	SELECT @stl_status = 'CMP'		 					

End
Else
BEGIN
			SELECT @num_type = '3',
				@asgn_type = '1'
			
				BEGIN
			
				--vmj1+
				if @vl_ord_hdrnumber > 0 
					select	@drv1 = l.lgh_driver1
							,@drv2 = l.lgh_driver2
			        		,@trc = l.lgh_tractor 
					        ,@ord_num = ISNULL(o.ord_number, 'UNKNOWN')
			    		    ,@ord_hdr = l.ord_hdrnumber
			        		,@mov_num = l.mov_number
				        	,@lgh_hdr = l.lgh_number
				    	    ,@trl1 = l.lgh_primary_trailer
			    	    	,@car = l.lgh_carrier
				    	    ,@tpr_id = ISNULL(o.ord_thirdpartytype1, 'UNKNOWN')
			    	    	,@revtype4 = o.ord_revtype4
				        	,@trctype4 = o.opt_trc_type4  
					  from	orderheader o  RIGHT OUTER JOIN  stops s  ON  (o.ord_hdrnumber  = s.ord_hdrnumber and o.ord_hdrnumber = @vl_ord_hdrnumber),
							legheader l 
					  where	l.lgh_number = @lgh_number 
						and	s.mov_number = l.mov_number
					  group by l.lgh_driver1
							,l.lgh_driver2
			        		,l.lgh_tractor 
					        ,o.ord_number
			    		    ,l.ord_hdrnumber
			        		,l.mov_number
				        	,l.lgh_number
				    	    ,l.lgh_primary_trailer
			    	    	,l.lgh_carrier
				    	    ,o.ord_thirdpartytype1
			    	    	,o.ord_revtype4
				        	,o.opt_trc_type4
				else
					--vmj1-
					SELECT @drv1 = lgh_driver1,  
			    	           @drv2 = lgh_driver2, 
			        	       @trc = lgh_tractor, 
			            	   @ord_num = ISNULL(ord_number, 'UNKNOWN'), 
				               @ord_hdr = legheader.ord_hdrnumber, 
			    	           @mov_num	= legheader.mov_number, 
			        	       @lgh_hdr = lgh_number, 
			            	   @trl1 = lgh_primary_trailer, 
				               @car = lgh_carrier, 
			    	           @tpr_id = ISNULL(ord_thirdpartytype1, 'UNKNOWN'), 
			        	       @revtype4 =ord_revtype4,
					       @trctype4 = opt_trc_type4	 
					FROM legheader LEFT OUTER JOIN orderheader on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
					WHERE lgh_number = @lgh_number 
			
				/* If no order number on the minimum event related stop then
				find an order number from the other stops if there is one */
				IF @ord_hdr = 0
					BEGIN
			
					SELECT @ord_hdr = ISNULL(MAX(ord.ord_hdrnumber), 0),
						@ord_num = ISNULL(MAX(ord_number), 'UNKNOWN'), 
						@tpr_id = ISNULL(MAX(ord_thirdpartytype1), 'UNKNOWN'), -- select agent for order PTS #4149
						@revtype4	= ord.ord_revtype4
					FROM stops stp, orderheader ord
					WHERE stp.mov_number = @mov_num
						AND stp.ord_hdrnumber = ord.ord_hdrnumber
						--vmj1+
						and	(@vl_ord_hdrnumber = 0
							or ord.ord_hdrnumber = @vl_ord_hdrnumber)
						--vmj1-
					GROUP BY ord.ord_revtype4
			
					/* If there still isn't one, set 'no load' */
					IF @ord_hdr IS null
						SELECT @ord_hdr = 0,
							@ord_num = 'NO LOAD',
							@tpr_id = 'UNKNOWN'
					END
			
				SELECT @drv1_asgn = asgn.asgn_number,
					@drv1_status = asgn.asgn_status,
					@drv1_prorap = mpp.mpp_actg_type,
					@mpp_type1 = mpp.mpp_type1,
					@drv1_altid = mpp.mpp_otherid
				FROM assetassignment asgn, manpowerprofile mpp
				WHERE asgn.asgn_type = 'DRV'
				AND asgn.asgn_id = @drv1
				AND @drv1 <> 'UNKNOWN'
				AND asgn.asgn_id = mpp.mpp_id 
				AND asgn.lgh_number = @lgh_number
			--	AND asgn.evt_number = @min_evt
			
				SELECT @drv2_asgn = asgn_number,
					@drv2_status = asgn_status,
					@mpp_type1_2 = mpp.mpp_type1,
					@drv2_altid = mpp.mpp_otherid
				FROM assetassignment a, manpowerprofile mpp
				WHERE a.asgn_type = 'DRV'
				AND a.asgn_id = @drv2
				AND @drv2 <> 'UNKNOWN'
				AND a.asgn_id = mpp.mpp_id
				AND a.lgh_number = @lgh_number
			--	AND a.evt_number = @min_evt
			
				SELECT @trc_asgn = asgn_number,
					@trc_status = asgn_status
				FROM assetassignment
				WHERE asgn_type = 'TRC'
				AND asgn_id = @trc
				AND @trc <> 'UNKNOWN'
				AND lgh_number = @lgh_number
			--	AND evt_number = @min_evt
			
				SELECT @car_asgn = asgn_number,
					@car_status = asgn_status
				FROM assetassignment
				WHERE asgn_type = 'CAR'
				AND asgn_id = @car
				AND @car <> 'UNKNOWN'
				AND lgh_number = @lgh_number
			--	AND evt_number = @min_evt
			
				SELECT @trl1_asgn = asgn_number,
					@trl1_status = asgn_status
				FROM assetassignment
				WHERE asgn_type = 'TRL'
				AND asgn_id = @trl1
				AND @trl1 <> 'UNKNOWN'
				AND lgh_number = @lgh_number
			--	AND evt_number = @min_evt
			
				/* Any assetassignment's leg is complete, trip is complete */
				IF (@drv1_status = 'CMP' OR
					@drv2_status = 'CMP' OR
					@trc_status = 'CMP' OR
					@trl1_status = 'CMP' OR
					@car_status = 'CMP')
					SELECT @stl_status = 'CMP'
			
				END
			
			/* Set initial asset type */
			IF @drv1 IS null
				SELECT @drv1 = 'UNKNOWN',
					@drv1_status = 'UNK'
			
			IF @drv2 IS null
				SELECT @drv2 = 'UNKNOWN',
					@drv2_status = 'UNK'
			ELSE
				IF @drv1 = 'UNKNOWN'
					SELECT @asgn_type = '2'
			
			IF @trc IS null
				SELECT @trc = 'UNKNOWN',
					@trc_status = 'UNK'
			ELSE
				IF @drv1 = 'UNKNOWN' AND @drv2 = 'UNKNOWN'
					SELECT @asgn_type = '3'
			
			IF @trl1 IS null
				SELECT @trl1 = 'UNKNOWN', @trl1_status = 'UNK'
			ELSE
				IF @drv1 = 'UNKNOWN' AND @drv2 = 'UNKNOWN' AND @trc = 'UNKNOWN'
					SELECT @asgn_type = '4'
			
			IF @car IS null
				SELECT @car = 'UNKNOWN', @car_status = 'UNK'
			ELSE
				IF @drv1 = 'UNKNOWN' AND @drv2 = 'UNKNOWN' AND @trc = 'UNKNOWN' AND @trl1 = 'UNKNOWN'
					SELECT @asgn_type = '4'
			
			IF @drv1 != 'UNKNOWN'
				IF @drv1_prorap = 'P'
					SELECT @asgn_type = '1'
			
			IF @drv1 != 'UNKNOWN' AND @trc != 'UNKNOWN'
				IF @drv1_prorap = 'A'
					SELECT @asgn_type = '3'
			
			/* Set default return mode */
			IF @ord_hdr = 0 AND @mov_num > 0
				SELECT @num_type = '2'
			
			IF @ord_hdr = 0 AND @mov_num = 0 AND @lgh_hdr > 0
				SELECT @num_type = '1'
			
			Select @order_list = ''
			Select @ls_ordnum  = ''
			IF (Select count(*) from orderheader where mov_number = @mov_num) > 1 
			Begin
				While 1 = 1
				Begin
				    select @ls_ordnum = min(ord_number) from orderheader 
				    where  mov_number = @mov_num and ord_number > @ls_ordnum
				    if @ls_ordnum is null
					break
				    select @order_list = rtrim(@order_list + @ls_ordnum )+ ' '
				End	
				select @order_list = rtrim(@order_list)
			End 
			Else
				Select @order_list = Null
			
			/*JD 12/16/02 PTS 16433 */
			if exists (select * from generalinfo where gi_name = 'SettleCancelledTrips' and gi_string1 = 'Y')
			begin
				if @lgh_number > 0 
				begin 
					select @ord_status = ord_status from orderheader where ord_hdrnumber = @lgh_number --this is the order number in this case.
					if @ord_status = 'CAN' or @ord_status = 'ICO'
					begin
							if exists (select * from cancelledtripresources where ord_hdrnumber = @lgh_number)
							begin
								select @stl_status = 'CMP'
							 select @drv1=lgh_driver1 ,@drv2 = lgh_driver2 , @trc = lgh_tractor,@trl1 = lgh_trailer from cancelledtripresources
							 where ord_hdrnumber = @lgh_number
								select @drv1_prorap = mpp_actg_type,@mpp_type1 = mpp_type1 from manpowerprofile where mpp_id = @drv1
							end				
					end		
			
				end 
			end   
END -- else for ps_num_type > 3 check

SELECT @asgn_type  asgn_type,
	@num_type num_type,
	@drv1 driver1,
	@drv1_asgn driver1asgnnumber,
	@drv2 driver2,
	@drv2_asgn driver2asgnnumber,
	@trc tractor,
	@trc_asgn tractorasgnnumber,
	@trl1 trailer1,
	@lgh_hdr legheadernumber,
	@mov_num movnumber,
	@ord_num ordnumber,
	@ord_hdr ordhdrnumber,
	@car carrier,
	@car_asgn carrierasgnnumber ,
	@trl1_asgn trailerasgnnumber,
	@stl_status stl_status,
	@drv1_prorap drv1_prorap,
	@mpp_type1 drivertype1,
	'DrvType1' drivertype1label,
	@drv1_altid driver1altid,
	@drv2_altid driver2altid,
	@mpp_type1_2 drivertype1_2,
	@tpr_id tprid,
	@revtype4 revtype4,
	'RevType4' revtype4label,
	@order_list orderlist,
	@trctype4 trctype4,
	'TrcType4' trctype4label,
	@pdt_from_date fromdate,	
	@pdt_to_date todate
return

GO
GRANT EXECUTE ON  [dbo].[d_stl_triptab_svcustom_sp] TO [public]
GO
