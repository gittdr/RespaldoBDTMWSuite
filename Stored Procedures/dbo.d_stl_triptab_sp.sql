SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROC [dbo].[d_stl_triptab_sp] 
		(@lgh_number 		int
		,@vl_ord_hdrnumber	int	= 0
		, @ps_asgn_type char(1)) -- 19443 JD 
AS

/**
 *
 * NAME:
 * dbo.d_stl_triptab_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for the settlement trip tab.
 *
 * RETURNS:
 *
 * RESULT SETS:
*
* Modified: 11/24/97 wsc pts#3242 to add return of asset type based on driver accounting type
* LOR - add drvtype1 and altid	
*
* KM 4-13-99 - PTS #5505, Do not use MIN(evt_number) for anything.  USE lgh_number instead
* dpete pts 12062 10/5/01 add labelfile name for trctype4 field
*
* Vern Jewett 04/15/2003 - PTS 17805, label=vmj1:	Added parm @vl_ord_hdrnumber so the correct
*	Third Party could be retrieved.  It defaults to 0, which causes the SP to act as before.
*
* PTS 31021 - DJM - Modified to return the pyd_status of the Asset Assignment record for each type of asset.
*
* MRH 31225 - 3rd party support
* SLM 38494 - 8/15/2007 Get trl_number from assetassignment when it does not exist on the legheader table.
* 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
* 07-15-2009 PTS46967 - added Carrier SCAC code
* 08/12/2009.01 - PTS48116 - vjh - move carrier payto to after carrier determination
* 09/09/2010 PTS51909 - SPN - added ref_number
* 09/09/2010 PTS52810 - SPN - added pyd_number
* 10/15/2010 PTS52686 - SPN - added pyd_carinvnum
* 05/10/2011 PTS54402 - vjh - Added Pay to and Co-Pay To
* 08/15/2011 PTS57720 - SPN - tpr_count for agent pay should come from existing paydetail
*/ 

DECLARE @num_type	char(1),
	@asgn_type		char(1),
	@drv1_asgn		int,
	@drv2_asgn		int,
	@trc_asgn		int,
	@car_asgn		int,
	@trl1_asgn		int,
	@min_evt		int,
	@ord_num		char(12),
	@mov_num		int,
	@lgh_hdr		int,
	@ord_hdr		int,
	@event			int,
	@drv1			varchar(8),
	@drv1_status	varchar(6),
	@drv1_acctg_type	char(1),
	@drv2			varchar(8),
	@drv2_acctg_type	char(1),
	@drv2_status	varchar(6),
	@trc			varchar(8),
	@trc_status		varchar(6),
	@trl1			varchar(13),
	@trl1_status	varchar(6),
	@car			varchar(8),
	@car_status		varchar(6),
	@stl_status		varchar(6),
	@mpp_type1		varchar(6),
	@mpp_type1_2	varchar(6),
	@drv1_altid		varchar(8),
	@drv2_altid		varchar(8),
	@tpr_id			varchar(8), 
	@revtype4		varchar(6),
	@order_list	varchar(255),
	@ls_ordnum		char(12),
	@trctype4		varchar(6),
	@ord_status		varchar(6),
	@drv1_stlstatus	varchar(6),
	@drv2_stlstatus	varchar(6),
	@trc_stlstatus	varchar(6),
	@car_stlstatus	varchar(6),
	@trl_stlstatus	varchar(6),
	@tpr_count		int,
	@trc_acctg_type char(1),
	@car_acctg_type char(1),
	@trl_acctg_type char(1),
	@ls_acctg_type char(1),
	-- JET - 12/9/08 - PTS 45384, recode of KPM's changes in Command source of 2006.05_10.0977 SP7
	@car_payto		varchar (12),
	@car_paytoname	varchar(100),
	@car_paytoaddress1 varchar(100),
	@car_paytoaddress2 varchar(100),
	@car_paytocity	varchar(60),
	@car_paytostate	varchar(6),
	@car_paytozip	varchar(10),	-- JET - 12/9/08 - PTS 45384
	@car_SCAC		varchar(4)		-- PTS46967
	, @pyd_number	INT				--PTS 52810 SPN
	, @ref_number	VARCHAR(30)		--PTS 51909 SPN
	, @pyd_carinvnum VARCHAR(30)	--PTS 52686
	, @payto1		varchar (12)	--vjh 54402
	, @payto2		varchar (12)	--vjh 54402
	, @agent   VARCHAR(13)  --SPN 57720


SELECT @num_type = '3',
	@asgn_type = '1'

/* Find the minimum event # for the trip seg from the assetassignment table */
--SELECT @min_evt = MIN(evt_number)
--FROM assetassignment a
--WHERE a.lgh_number = @lgh_number

--IF @min_evt = null
--	SELECT @stl_status = 'NOASGN'
--ELSE
	BEGIN

	--vmj1+
	if @vl_ord_hdrnumber > 0
	begin 
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
			
		-- If AgentComiss is not on return the thirdparty.
		if (select left(isnull(gi_string1, 'N'),1) from generalinfo where gi_name = 'AgentCommiss') = 'N' and
				(select left(isnull(gi_string1, 'N'),1) from generalinfo where gi_name = 'AdvancedAgentPay') = 'N' 
			--	LOR	PTS# 62520 + 65272 fix
			--select	@tpr_id = ISNULL(min(t.tpr_id), 'UNKNOWN')
			--from 	thirdpartyassignment t
			--where	t.lgh_number = @lgh_number
			select	@tpr_id = ISNULL(tpr_id, 'UNKNOWN')
			from 	thirdpartyassignment 
			where	tpr_number = (select min(tpr_number) 
									from thirdpartyassignment 
									where lgh_number = @lgh_number
										and tpa_status <> 'DEL')
			--	LOR
	end
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
		@drv1_acctg_type = mpp.mpp_actg_type,
		@mpp_type1 = mpp.mpp_type1,
		@drv1_altid = mpp.mpp_otherid,
		@drv1_stlstatus = asgn.pyd_status
	FROM assetassignment asgn, manpowerprofile mpp
	WHERE asgn.asgn_type = 'DRV'
	AND asgn.asgn_id = @drv1
	AND @drv1 <> 'UNKNOWN'
	AND asgn.asgn_id = mpp.mpp_id 
	AND asgn.lgh_number = @lgh_number
--	AND asgn.evt_number = @min_evt

	SELECT @drv2_asgn = asgn_number,
		@drv2_status = asgn_status,
		@drv2_acctg_type = mpp.mpp_actg_type,
		@mpp_type1_2 = mpp.mpp_type1,
		@drv2_altid = mpp.mpp_otherid,
		@drv2_stlstatus = a.pyd_status
	FROM assetassignment a, manpowerprofile mpp
	WHERE a.asgn_type = 'DRV'
	AND a.asgn_id = @drv2
	AND @drv2 <> 'UNKNOWN'
	AND a.asgn_id = mpp.mpp_id
	AND a.lgh_number = @lgh_number
--	AND a.evt_number = @min_evt


	SELECT @trc_asgn = asgn_number,
		@trc_status = asgn_status,
		@trc_stlstatus = pyd_status,
		@trc_acctg_type = trc_actg_type
		, @payto1 = trc_owner
		, @payto2 = trc_owner2
	FROM assetassignment, tractorprofile
	WHERE asgn_type = 'TRC'
	AND asgn_id = @trc 
	AND trc_number = @trc
	AND @trc <> 'UNKNOWN'
	AND lgh_number = @lgh_number
--	AND evt_number = @min_evt

	SELECT @car_asgn = asgn_number,
		@car_status = asgn_status,
		@car_stlstatus = pyd_status,
		@car_acctg_type = car_actg_type
	FROM assetassignment,carrier
	WHERE asgn_type = 'CAR'
	AND asgn_id = @car
	AND car_id = @car
	AND @car <> 'UNKNOWN'
	AND lgh_number = @lgh_number
--	AND evt_number = @min_evt

	SELECT @trl1_asgn = asgn_number,
		@trl1_status = asgn_status,
		@trl_stlstatus = pyd_status,
		@trl_acctg_type = trl_actg_type
	FROM assetassignment,trailerprofile
	WHERE asgn_type = 'TRL'
	AND asgn_id = @trl1
	AND trl_id = @trl1
	AND @trl1 <> 'UNKNOWN'
	AND lgh_number = @lgh_number
--	AND evt_number = @min_evt

--BEGIN SLM 38494 - 8/15/2007
if @ord_hdr = 0 and @trl1 = 'UNKNOWN'
select @trl1 = asgn_id from assetassignment where lgh_number = @lgh_number
and asgn_type = 'TRL'
--END SLM 38494 - 8/15/2007

-- MRH 12/02/04 PTS 23843
	if (select left(isnull(gi_string1, 'N'),1) from generalinfo where gi_name = 'AgentCommiss') = 'N' and
			(select left(isnull(gi_string1, 'N'),1) from generalinfo where gi_name = 'AdvancedAgentPay') = 'N' 
		--	LOR	PTS# 62520
		--SELECT @tpr_id = min(tpr_id)
		--FROM thirdpartyassignment
		--WHERE lgh_number = @lgh_number
		--and tpa_status <> 'DEL'	--36019 BDH	
		select	@tpr_id = tpr_id
		from 	thirdpartyassignment 
		where	tpr_number = (select min(tpr_number) from thirdpartyassignment where lgh_number = @lgh_number)
				and tpa_status <> 'DEL'
		--	LOR
-- 23843

	/* Any assetassignment's leg is complete, trip is complete */
	--	LOR	PTS# 71976	check asset type and moved below, after @ps_asgn_type gets re-set
	--	vjh PTS# 71976	some enhancement to still support retrieval for Order and Third Party
	--IF (@drv1_status = 'CMP' OR
	--	@drv2_status = 'CMP' OR
	--	@trc_status = 'CMP' OR
	--	@trl1_status = 'CMP' OR
	--	@car_status = 'CMP')

	END

-- JD 30677 New logic for default asset type
IF @drv1 IS null
	SELECT @drv1 = 'UNKNOWN',@drv1_status = 'UNK',@drv1_acctg_type = 'N'

IF @drv2 IS null
	SELECT @drv2 = 'UNKNOWN',@drv2_status = 'UNK',@drv2_acctg_type = 'N'

IF @trc IS null
	SELECT @trc = 'UNKNOWN',@trc_status = 'UNK',@trc_acctg_type = 'N'

IF @trl1 IS null
	SELECT @trl1 = 'UNKNOWN', @trl1_status = 'UNK',@trl_acctg_type = 'N'

IF @car IS null
	SELECT @car = 'UNKNOWN', @car_status = 'UNK',@car_acctg_type = 'N'

if @ps_asgn_type = '1' select @ls_acctg_type = @drv1_acctg_type
if @ps_asgn_type = '2' select @ls_acctg_type = @drv2_acctg_type
if @ps_asgn_type = '3' select @ls_acctg_type = @trc_acctg_type
if @ps_asgn_type = '4' select @ls_acctg_type = @car_acctg_type
if @ps_asgn_type = '5' select @ls_acctg_type = @trl_acctg_type

select @ls_acctg_type = IsNull(@ls_acctg_type,'N')

--vjh PTS48116 move the payto address block to after the asset type determination
-- JET - 12/9/08 - PTS 45384, recode of KPM's changes in Command source of 2006.05_10.0977 SP7
--if @ps_asgn_type = '4' and @car <> 'UNKNOWN'
--begin 
--<snip>
--end

if (@ls_acctg_type = 'N') and cast (@ps_asgn_type as int) < 6
Begin
	if 	IsNull(@drv1_acctg_type,'N') <> 'N'
		select @ps_asgn_type = '1'
	else
	begin
		if IsNull(@drv2_acctg_type,'N') <> 'N'
			select @ps_asgn_type = '2'
		else
		begin
			if IsNull(@trc_acctg_type,'N') <> 'N'
				select @ps_asgn_type = '3'
			else
			begin
				if IsNull(@car_acctg_type,'N') <> 'N'
					select @ps_asgn_type = '4'
				else
				begin
					if IsNull(@trl_acctg_type,'N') <> 'N'
						select @ps_asgn_type = '5'
				end
			end 
		end
	end	
end

	IF ((@drv1_status = 'CMP' and @ps_asgn_type = '1') OR
		(@drv2_status = 'CMP'  and @ps_asgn_type = '2') OR
		(@trc_status = 'CMP'  and @ps_asgn_type = '3') OR
		(@trl1_status = 'CMP'  and @ps_asgn_type = '5')OR
		(@car_status = 'CMP' and @ps_asgn_type = '4') OR 
		(@ps_asgn_type = '6' and (@drv1_status = 'CMP' or
									@drv2_status = 'CMP' or
									@trc_status = 'CMP' or
									@trl1_status = 'CMP' or
									@car_status = 'CMP')) OR
		(@ps_asgn_type = '7' and (@drv1_status = 'CMP' or
									@drv2_status = 'CMP' or
									@trc_status = 'CMP' or
									@trl1_status = 'CMP' or
									@car_status = 'CMP')) 	)	
		SELECT @stl_status = 'CMP'

--vjh 54402 tractor (3) needs to be replaced with payto (8)
if (select left(isnull(gi_string1, 'N'),1) from generalinfo where gi_name = 'coownerpaytos') = 'Y'
	and @ps_asgn_type = '3'
	select @ps_asgn_type = '8'

--vjh PTS48116 move the payto address block to after the asset type determination
-- JET - 12/9/08 - PTS 45384, recode of KPM's changes in Command source of 2006.05_10.0977 SP7
if @ps_asgn_type = '4' and @car <> 'UNKNOWN'
begin 

	-- PTS46967 <<start>>
	Select @car_SCAC = car_scac from carrier where @car = car_id
	-- PTS46967 <<end>>

   Select @car_payto = pto_id From carrier where @car = car_id
	IF @car_payto <> 'UNKNOWN' 
      SELECT @car_paytoname   =  case when pto_companyname is not null or len (pto_companyname) > 0 then pto_companyname when isnull (pto_fname, '') +  isnull (pto_lname, '') <> '' then isnull (pto_fname, '') +  isnull (pto_lname, '') else car_name end, 
		@car_paytoaddress1 = isnull (pto_address1, ''),
		@car_paytoaddress2 = isnull (pto_address2, ''),
		@car_paytocity    = isnull (cty_name, ''),
		@car_paytostate   = isnull (cty_state, ''),
		@car_paytozip   = isnull (pto_zip, '')
      FROM PAYTO, CITY, carrier
		WHERE @car_payto = payto.PTO_ID AND pto_city = city.CTY_CODE  and carrier.PTO_ID = payto.PTO_ID

   else 
      select   @car_paytoname   = isnull (car_name, ''),
		@car_paytoaddress1 = isnull (car_address1, ''),
		@car_paytoaddress2 = isnull (car_address1, ''),
		@car_paytocity  = isnull (cty_name, ''),
		@car_paytostate   = isnull (cty_state, ''),
		@car_paytozip   = isnull (car_zip, '')
      FROM carrier, CITY
		WHERE @car_payto = car_ID AND carrier.cty_code = city.CTY_CODE 
end
-- JET - 12/9/08 - PTS 45384

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
		/* PTS 26088 - DJM - Modified to use the Ord_hdrnumber parameter instead of trip segment	*/
		select @ord_status = ord_status from orderheader where ord_hdrnumber = @vl_ord_hdrnumber 
		if @ord_status = 'CAN' or @ord_status = 'ICO'
		begin
			if exists (select * from cancelledtripresources where ord_hdrnumber = @vl_ord_hdrnumber)
			begin
				select @stl_status = 'CMP'

				-- PTS 26088 - Added Carrier and Thirdparty
				select @drv1=lgh_driver1 ,
					@drv2 = lgh_driver2 , 
					@trc = lgh_tractor,
					@trl1 = lgh_trailer,
					@car = car_id,
					@tpr_id = tpr_id
				from cancelledtripresources
			 	where ord_hdrnumber = @vl_ord_hdrnumber

				select @drv1_acctg_type = mpp_actg_type,@mpp_type1 = mpp_type1 from manpowerprofile where mpp_id = @drv1
			end				
		end		
	end 
end   

-- JD 30677 JD 
-- --PTS 27422 - Optionally allow auto swicth to carrier, if current asset type is unknown
-- if exists (select * from generalinfo where gi_name = 'SettleAutoSwitchToCarrier' and gi_string1 = 'Y') BEGIN
-- 	IF @drv1 = 'UNKNOWN' AND @drv2 = 'UNKNOWN' AND @trc = 'UNKNOWN' AND @trl1 = 'UNKNOWN'
-- 		SELECT @ps_asgn_type = '4'
-- END

--BEGIN PTS 57720 SPN
--select @tpr_count = (select count(0) from thirdpartyassignment where lgh_number = @lgh_number and tpa_status <> 'DEL')
IF (SELECT LEFT(IsNull(gi_string1, 'N'),1)
      FROM generalinfo
     WHERE gi_name = 'AgentCommiss'
   ) = 'N'
   AND
	(SELECT LEFT(IsNull(gi_string1, 'N'),1)
	   FROM generalinfo
	  WHERE gi_name = 'AdvancedAgentPay'
	) = 'N'
BEGIN
   SELECT @tpr_count = COUNT(1)
     FROM thirdpartyassignment
    WHERE lgh_number = @lgh_number
      AND tpa_status <> 'DEL'
END
ELSE
BEGIN
   SELECT @tpr_count = 0
   SELECT @agent = p.asgn_id
     FROM paydetail p
     JOIN thirdpartyprofile t ON p.asgn_id = t.tpr_id
    WHERE p.lgh_number = @lgh_number
      AND p.asgn_type = 'TPR'
      AND t.tpr_thirdpartytype1 = 'Y'
   IF @agent IS NOT NULL
   BEGIN
      SELECT @tpr_count = (CASE WHEN IsNull(tpr_salesperson1,'UNKNOWN') = 'UNKNOWN' THEN 0 ELSE 1 END)
                        + (CASE WHEN IsNull(tpr_salesperson2,'UNKNOWN') = 'UNKNOWN' THEN 0 ELSE 1 END)
        FROM thirdpartyprofile
       WHERE tpr_id = @agent
   END
END
--END PTS 57720

-- 19443 JD return the passed in asgn_type back to the proc
SELECT @ps_asgn_type, --19443
	@num_type,
	@drv1,
	@drv1_asgn,
	@drv2,
	@drv2_asgn,
	@trc,
	@trc_asgn,
	@trl1,
	@lgh_hdr,
	@mov_num,
	@ord_num,
	@ord_hdr,
	@car 'carrier',
	@car_asgn 'carrier_asgn',
	@trl1_asgn,
	@stl_status,
	@drv1_acctg_type,
	@mpp_type1,
	'DrvType1',
	@drv1_altid,
	@drv2_altid,
	@mpp_type1_2,
	@tpr_id,
	@revtype4,
	'RevType4',
	@order_list,
	@trctype4,
	'TrcType4',
	@drv1_stlstatus,
	@drv2_stlstatus,
	@trc_stlstatus,
	@trl_stlstatus,
	@car_stlstatus,
	@tpr_count,
	-- JET - 12/9/08 - PTS 45384, recode of KPM's changes in Command source of 2006.05_10.0977 SP7
	@car_payto ,
	@car_paytoname,
	@car_paytoaddress1,
	@car_paytoaddress2,
	@car_paytocity,
	@car_paytostate,
	@car_paytozip,		-- JET - 12/9/08 - PTS 45384
	@car_SCAC 'scac'	-- PTS 46967
	, @pyd_number --PTS 52810 SPN
	, @ref_number --PTS 51909 SPN
	, @pyd_carinvnum --PTS 52686 SPN
	, @payto1
	, @payto2
return

GO
GRANT EXECUTE ON  [dbo].[d_stl_triptab_sp] TO [public]
GO
