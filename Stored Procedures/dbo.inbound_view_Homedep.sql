SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DROP PROC inbound_view_Homedep
CREATE   PROCEDURE [dbo].[inbound_view_Homedep]
--	@revtype1 				VARCHAR(254),
--	@revtype2 				VARCHAR(254),
	@revtype3 				VARCHAR(254),
--	@revtype4 				VARCHAR(254),
--	@mpptype1 				VARCHAR(254),   -- 05
--	@mpptype2 				VARCHAR(254),
--	@mpptype3 				VARCHAR(254),
--	@mpptype4 				VARCHAR(254),
	@teamleader 				VARCHAR(254),
--	@domicile 				VARCHAR(254),   -- 10
--	@trctype1 				VARCHAR(254),
--	@trctype2 				VARCHAR(254),
--	@trctype3 				VARCHAR(254),
--	@trctype4 				VARCHAR(254),
--	@trltype1 				VARCHAR(254),   -- 15
--	@trltype2 				VARCHAR(254),
--	@trltype3 				VARCHAR(254),
--	@trltype4 				VARCHAR(254),
--	@fleet 					VARCHAR(254),
--	@division 				VARCHAR(254),   -- 20
--	@company 				VARCHAR(254),
--	@terminal 				VARCHAR(254),
--	@states 				VARCHAR(254),
--	@cmpids					VARCHAR(254),
	@reg1 					VARCHAR(254),   -- 25
	@reg2 					VARCHAR(254),
	@reg3 					VARCHAR(254),
	@reg4 					VARCHAR(254),
	@city 					INT,
	@driver 				CHAR(8),        -- 30
	@tractor 				CHAR(8),
	@hoursback 				INT,
	@hoursout 				INT,
	@days 					INT,
	@status 				VARCHAR(254),   -- 35
	@instatus 				VARCHAR(254),
	@bookedby 				VARCHAR(254),
	@lgh_type1 				VARCHAR(254),
	@lgh_type2 				VARCHAR(254),
	@last_event 			VARCHAR(254),	-- 40
	@d_states 				VARCHAR(254),
	@d_cmpids 				VARCHAR(254),
	@d_reg1 				VARCHAR(254),
	@d_reg2 				VARCHAR(254),
	@d_reg3 				VARCHAR(254),   -- 45
	@d_reg4 				VARCHAR(254),
	@d_city 				INT,
	@next_event 			VARCHAR(254),
	@next_cmp_id 			VARCHAR(254),
	@next_city 				INT, 			-- 50
	@next_state 			VARCHAR(254),
	@next_region1 			VARCHAR(254),
	@next_region2 			VARCHAR(254),
	@next_region3 			VARCHAR(254),
	@next_region4			VARCHAR(254),   -- 55
	@carrier				varchar(8),
	@drv_qualifications 	varchar(254),
	@trc_accessories 		varchar(254),
	@trl_accessories 		varchar(254),
	@drv_status				VARCHAR(254),	-- 60
	@drvdays				int,
	@trcdays				int,
	@inctrlexps				CHAR(1),
	@billto					VARCHAR(254),
	@orderedby				VARCHAR(254),   -- 65
	@o_servicearea			varchar(256),
	@o_servicezone			varchar(256),
	@o_servicecenter		varchar(256),
	@o_serviceregion		varchar(256),
	@dest_servicearea		varchar(256),	-- 70
	@dest_servicezone		varchar(256),
	@dest_servicecenter		varchar(256),
	@dest_serviceregion		varchar(256),
	@lgh_route				varchar(256),
	@lgh_booked_revtype1	varchar(256),   -- 75
	/* 02/14/2008 MDH PTS 39077: Added 3 fields for cmp_othertype1 */
	@cmp_othertype1			varchar(256) = 'UNK',
	@prior_cmp_othertype1	varchar(256) = 'UNK',
	@next_cmp_othertype1	varchar(256) = 'UNK'
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
 *
/* MF pts 4175 add extra cols*/
--PTS 3675 Testied with new index for 400 release
-- PTS 3436 PG 1/8/98 Performance Enhancement added NOLOCK on expiration
/* MF 11/12/97 PTS 3215 changed to use newly populated fields on LGH including lgh_active */
/* LOR	5/12/98	PTS# 3905	add shipper/consignee states, drivers' names, trltypes labels */
/*PTS 4381 - Tune experation performacne*/
/*PTS 6200 - Really Tune experation performance by denormalizing expirations*/
-- JET - 10/20/99 - PTS #6490	changed the where clause on the select
-- JET - 10/28/99 - PTS #6644	added check for rev types = NULL for MT moves
-- RJE - 7/14/00 added can_cap_expires for CAN
-- DJM - 10/11/00 - PTS #8503   added lgh_feetavailable to result set
-- 07/31/2001	Vern Jewett (label=vmj1)	PTS 11594: DB performance (Manfredi)
--dpete pts12599 add cmp_geoloc for origin and dest companies for Gibson
-- 08/08/2002	Vern Jewett (label=vmj2)	PTS 14054: Add carrier to Resources view.
-- LOR	PTS# 14926	add terminal
-- 08/23/2002	Vern Jewett	(label=vmj3)	PTS 14054: Add @carrier parm so we may restrict
--											by carrier (PTS re-assigned).
-- PJC  01/03/2003  PTS 16318
--	added l_ctycode to the result set
-- 06/12/2003	Vern Jewett	(label=vmj4)	PTS 15338: Standardize loghours result to be
--											consistent with inbound_view_drv.
-- 09/02/2003	Vern Jewett	(label=vmj6)	PTS 18417: pull lgh_etaalert1 column.
-- 04/27/2004   Greg Kanzinger add logic for PTS 21259 and 21260
-- 03/28/2005   DJM	PTS 26766 - Recoded custom fields from Eagle build to support Views
--		Recode 19028 - restrict by OrderedBy
--		recode 22601 - Restrict by Localization values
--		recode 23836 - Modified Localization logic to use Zip from the Stops table or Origin/Destination zip from
--			the legheader to determine the Localization values.
-- 09/20/2005	DJM	27820 - Add the mpp_alternatephone field to the result set.
-- 09/20/2005	DJM	27820(29994) - Add the lgh_comment field to the result set.
-- 10/10/2005   ILB     29650 -Add current_avl_date and latest_avl_date to the result set for client sorting purposes
-- 11/14/2005   ILB     29623 -Add lgh_trc_comment to the result set for client editing
-- 01/05/2006	RJE		31172 - Performance enhancement
-- 01/30/2006	DJM	28420 - Removed index hints and made joins for affected Queries ANSI compliant
-- 03/01/2006   JG      31811 - create SQL 2000 table variable version to reduce number of recompiles
--			Add conditional check for bypassing the logic in PTS29650, PTS31172
-- 05/02/2006   DPH     32698 -Add mpp_pta_date to the result set for client editing
-- 12/04/2006	SLM 	35068 - Added default value for mpp_pta_date column
-- 03/12/2007   JLB     32387 - Add logic to adjust available date time to reflect unstarted expirations on the fly
/* DPETE 35747 allow for GI option of alltimes in local time zone support
       return a minutes offset in each row to apply to Today()in datawindow for comparison (see attachemnt to PTS for how this works)*/
-- 4/24/07		DJM		35482 - Add Billto Restriction
-- 6/04/07 SGB 37620 Update company name label to pull from label file
-- 9/26/2007	DJM		38765 - Added Mobilecomm fields from tractorprofile
-- DJM 38765 09/26/2007 - Added fields to planning worksheet.
 * 11/12/2007.01 – PTS40187 - JGUO – convert old style outer join syntax to ansi outer join syntax.
 -- 04/18/08 PTS 41931 SGB changed ord_booked by to varchar and changed charindex logic so filter will work
 -- DJM 42829 06/18/2008 - Added trc_lastpos_lat and trc_lastpos_long to planning worksheet
*
 **/

DECLARE	@revtype1 				VARCHAR(254),
	@revtype2 				VARCHAR(254),
--	@revtype3 				VARCHAR(254),
	@revtype4 				VARCHAR(254),
	@mpptype1 				VARCHAR(254),   -- 05
	@mpptype2 				VARCHAR(254),
	@mpptype3 				VARCHAR(254),
	@mpptype4 				VARCHAR(254),
	@domicile 				VARCHAR(254),   -- 10
	@trctype1 				VARCHAR(254),
	@trctype2 				VARCHAR(254),
	@trctype3 				VARCHAR(254),
	@trctype4 				VARCHAR(254),
	@trltype1 				VARCHAR(254),   -- 15
	@trltype2 				VARCHAR(254),
	@trltype3 				VARCHAR(254),
	@trltype4 				VARCHAR(254),
	@fleet 					VARCHAR(254),
	@division 				VARCHAR(254),   -- 20
	@company 				VARCHAR(254),
	@terminal 				VARCHAR(254),
	@states 				VARCHAR(254),
	@cmpids					VARCHAR(254),
	@char8					CHAR(8),
		@char6					CHAR(6),
		@dt 					DATETIME,
		@char1					CHAR(1),
		@neardate				DATETIME,
		@int 					SMALLINT,
		@servicerule			CHAR(6),
		@logdays				INT,
		@loghrs 				INT,
		@pos					INT,
		@strdays				CHAR(3),
		@strhrs					CHAR(3),
		@avlhrs 				FLOAT(2),
		@float					FLOAT(2),
		@drv 					CHAR(6),
		@min 					INT,
		@varchar20				VARCHAR(20),
		@varchar25				VARCHAR(25),
		@varchar30				VARCHAR(30),
		@varchar13				VARCHAR(13),
		@char2					CHAR(2),
		@varchar45				VARCHAR(45),
		@hoursbackdate			DATETIME,
		@hoursoutdate			DATETIME,
		@runpups       	 		CHAR(1),
		@rundrops       		CHAR(1),
		@runweight      		CHAR(1),
		@retvarchar     		VARCHAR(3),
		@avl					CHAR(3),
		@varchar6				VARCHAR(6),
		@ls_whats_left			VARCHAR(255),
		@li_pos					INT,
		@ls_value				VARCHAR(255),
		@li_count				INT,
		@varchar8				VARCHAR(8),
		@ls_dayname				CHAR(3),
		@ld_comparedate			DATETIME,
		@revclass1labelname		VARCHAR(20),
		@revclass2labelname 	VARCHAR(20),
		@revclass3labelname 	VARCHAR(20),
		@revclass4labelname		VARCHAR(20),
		@lgh_type1_labelname	VARCHAR(20),
		@lgh_type2_labelname	VARCHAR(20),
		@trltype1labelname		VARCHAR(20),
		@trltype2labelname		VARCHAR(20),
		@trltype3labelname		VARCHAR(20),
		@trltype4labelname		VARCHAR(20),
		@LateWarnMode	VARCHAR(60),
		@drvneardate			datetime,
		@trcneardate			datetime,
		@ldt_yesterday			datetime,
		@trctype1labelname		varchar(20),
		@trctype2labelname		varchar(20),
		@trctype3labelname		varchar(20),
		@trctype4labelname		varchar(20),
		@drvtype1labelname		varchar(20),
		@drvtype2labelname		varchar(20),
		@drvtype3labelname		varchar(20),
		@drvtype4labelname		varchar(20),
		@drvteamleaderlabelname		varchar(20),
		@service_revtype		varchar(10),
		@service_revvalue		varchar(8),
		@evt_tractor 			varchar(8),			--PTS# 29650 ILB 10/07/2004 <<BEGIN>>
   		@curr_avail_date 		datetime,
   		@latest_avail_date 		datetime,			--PTS# 29650 ILB 10/07/2004 <<END>>
		@AVLDTTM_ONLYSETBY_OPENEXPS	varchar(1),		-- PTS 31211 -- BL Added
		@localization			char(1), -- PTS 28420 - DJM
		@UseShowAsShipperConsignee		CHAR(1),
		@vs_counter						varchar(13),--JLB PTS 32387 <<START>>
		@vdtm_avl_date					datetime,
		@vdtm_exp_completiondate		datetime,	--JLB PTS 32387 <<END>>
	    @V_GILocalTImeOption        varchar(20),	--35747 <<START>>
	    @v_LocalCityTZAdjFactor     int,
	    @InDSTFactor                int,
	    @DSTCountryCode             int
	    ,@V_LocalGMTDelta    smallint
	    ,@v_LocalDSTCode     smallint
	    ,@V_LocalAddnlMins   smallint,				--35747 <<END>>
    	@CompanyNameLabel Varchar(20)				-- 37620 SGB added variable for CompanyName column label

DECLARE @mpp_shift_max_minutes integer		/* 09/04/2008 MDH PTS 43538: Added */
DECLARE @mpp_shift_off_minutes integer		/* 09/04/2008 MDH PTS 43538: Added */

--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
declare @tmwuser varchar(255)
--END PTS 40155 JJF 20071128


select	@revtype1= ''
select	@revtype2= ''
--select	@revtype3= ''
select	@revtype4= ''
select	@mpptype1= ''
select	@mpptype2= ''
select	@mpptype3= ''
select	@mpptype4 = ''
select		@domicile = ''
select		@trctype1 = ''
select		@trctype2 = ''
select		@trctype3 = ''
select		@trctype4 = ''
select		@trltype1 = ''
select		@trltype2 = ''
select		@trltype3 = ''
select		@trltype4 = ''
select		@fleet  = ''
select		@division = ''
select		@company = ''
select		@terminal = ''
select		@states = ''
select		@cmpids = ''





DECLARE @TT TABLE(
	lgh_number 				INT,                                                                                        -- 001
	stp_number_start 		INT			NULL,                                                                           -- 002
	stp_number_end			INT	NULL,                                                                                   -- 003
	o_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 004
	o_cmpname 				VARCHAR(100) NULL,                                                                          -- 005
	o_ctyname 				VARCHAR(25) NULL,                                                                           -- 006
	d_cmpid					VARCHAR(8) 	NULL,                                                                           -- 007
	d_cmpname 				VARCHAR(100) NULL,	-- JET - 3/20/2003 - PTS #17705, changed field size from 30 to 100      -- 008
	d_ctyname 				VARCHAR(25) NULL,                                                                           -- 009
	f_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 010
	f_cmpname 				VARCHAR(100) NULL,                                                                          -- 011
	f_ctycode 				INT 		NULL,                                                                           -- 012
	f_ctyname 				VARCHAR(25) NULL,                                                                           -- 013
	l_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 014
	l_cmpname 				VARCHAR(100) NULL,                                                                          -- 015
	l_ctycode 				INT 		NULL,                                                                           -- 016
	l_ctyname 				VARCHAR(25) NULL,                                                                           -- 017
	lgh_startdate 			DATETIME 	NULL,                                                                           -- 018
	lgh_enddate 			DATETIME 	NULL,                                                                           -- 019
	o_state 				VARCHAR(6) 	NULL,                                                                           -- 020
	d_state 				VARCHAR(6) 	NULL,                                                                           -- 021
	lgh_outstatus 			VARCHAR(6) 	NULL,                                                                           -- 022
	lgh_instatus 			VARCHAR(6) 	NULL,                                                                           -- 023
	lgh_priority 			VARCHAR(6) 	NULL,                                                                           -- 024
	lgh_schdtearliest 		DATETIME 	NULL,                                                                           -- 025
	lgh_schdtlatest 		DATETIME 	NULL,                                                                           -- 026
	cmd_code 				VARCHAR(8) 	NULL,                                                                           -- 027
	fgt_description 		VARCHAR(60) NULL,                                                                           -- 028
	ord_hdrnumber 			INT 		NULL,                                                                           -- 029
	mpp_type1 				VARCHAR(6) 	NULL,                                                                           -- 030
	mpp_type2 				VARCHAR(6) 	NULL,                                                                           -- 031
	mpp_type3 				VARCHAR(6) 	NULL,                                                                           -- 032
	mpp_type4 				VARCHAR(6) 	NULL,                                                                           -- 033
	mpp_teamleader 			VARCHAR(6) 	NULL,                                                                           -- 034
	mpp_fleet 				VARCHAR(6) 	NULL,                                                                           -- 035
	mpp_division 			VARCHAR(6) 	NULL,                                                                           -- 036
	mpp_domicile 			VARCHAR(6) 	NULL,                                                                           -- 037
	mpp_company 			VARCHAR(6) 	NULL,                                                                           -- 038
	mpp_terminal 			VARCHAR(6) 	NULL,                                                                           -- 039
	mpp_last_home 			DATETIME 	NULL,                                                                           -- 040
	mpp_want_home 			DATETIME 	NULL,                                                                           -- 041
	lgh_class1 				VARCHAR(6) 	NULL,                                                                           -- 042
	lgh_class2 				VARCHAR(6) 	NULL,                                                                           -- 043
	lgh_class3				VARCHAR(6) 	NULL,                                                                           -- 044
	lgh_class4 				VARCHAR(6) 	NULL,                                                                           -- 045
	trc_type1 				VARCHAR(6) 	NULL,                                                                           -- 046
	trc_type2 				VARCHAR(6) 	NULL,                                                                           -- 047
	trc_type3 				VARCHAR(6) 	NULL,                                                                           -- 048
	trc_type4 				VARCHAR(6) 	NULL,                                                                           -- 049
	trl_type1 				VARCHAR(6) 	NULL,                                                                           -- 050
	trl_type2 				VARCHAR(6) 	NULL,                                                                           -- 051
	trl_type3 				VARCHAR(6) 	NULL,                                                                           -- 052
	trl_type4 				VARCHAR(6) 	NULL,                                                                           -- 053
	trc_company 			VARCHAR(6) 	NULL,                                                                           -- 054
	trc_division 			VARCHAR(6) 	NULL,                                                                           -- 055
	trc_fleet 				VARCHAR(6) 	NULL,                                                                           -- 056
	trc_terminal 			VARCHAR(6) 	NULL,                                                                           -- 057
	evt_driver1 			VARCHAR(8) 	NULL,                                                                           -- 058
	evt_driver2 			VARCHAR(8) 	NULL,                                                                           -- 059
	evt_tractor 			VARCHAR(8) 	NULL,                                                                           -- 060
	lgh_primary_trailer 	VARCHAR(13) NULL,                                                                           -- 061
	mov_number 				INT 		NULL,                                                                           -- 062
	ord_number 				CHAR(13) 	NULL,                                                                           -- 063
	o_city 					INT 		NULL,                                                                           -- 064
	d_city 					INT 		NULL,                                                                           -- 065
	filtflag 				VARCHAR(1) 	NULL,                                                                           -- 066
	outstatname 			VARCHAR(20) NULL,                                                                           -- 067
	instatname 				VARCHAR(20) NULL,                                                                           -- 068
	companyname 			VARCHAR(20) NULL,                                                                           -- 069
	trltype1name 			VARCHAR(20) NULL,                                                                           -- 070
	trltype1labelname 		VARCHAR(20) NULL,                                                                           -- 071
	revclass1name 			VARCHAR(20) NULL,                                                                           -- 072
	revclass2name 			VARCHAR(20) NULL,                                                                           -- 073
	revclass3name 			VARCHAR(20) NULL,                                                                           -- 074
	revclass4name 			VARCHAR(20) NULL,                                                                           -- 075
	revclass1labelname 		VARCHAR(20) NULL,                                                                           -- 076
	revclass2labelname 		VARCHAR(20) NULL,                                                                           -- 077
	revclass3labelname 		VARCHAR(20) NULL,                                                                           -- 078
	revclass4labelname 		VARCHAR(20) NULL,                                                                           -- 079
	pri1exp 			INT 		NULL,                                                                               -- 080
	pri1expsoon 			INT 		NULL,                                                                           -- 081
	pri2exp 			INT 		NULL,                                                                               -- 082
	pri2expsoon 			INT 		NULL,                                                                           -- 083
	loghours 				FLOAT 		NULL,                                                                           -- 084
	drvstat 				INT 		NULL,                                                                           -- 085
	trcstat 				INT 		NULL,                                                                           -- 086
	ord_bookedby 			VARCHAR(20) 	NULL, -- PTS 41931 SGB 04/18/08                                             -- 087
	lgh_primary_pup 		VARCHAR(13) NULL,                                                                           -- 088
	servicerule 			CHAR(6) 	NULL,                                                                           -- 089
	trltype2name 			VARCHAR(20) NULL,                                                                           -- 090
	trltype2labelname 		VARCHAR(20) NULL,                                                                           -- 091
	trltype3name 			VARCHAR(20) NULL,                                                                           -- 092
	trltype3labelname 		VARCHAR(20) NULL,                                                                           -- 093
	trltype4name 			VARCHAR(20) NULL,                                                                           -- 094
	trltype4labelname 		VARCHAR(20) NULL,                                                                           -- 095
	f_state 				VARCHAR(6) 	NULL,                                                                           -- 096
	l_state 				VARCHAR(6) 	NULL,                                                                           -- 097
	mpp_lastfirst_1			VARCHAR(45) NULL,                                                                           -- 098
	mpp_lastfirst_2 		VARCHAR(45) NULL,                                                                           -- 099
	lgh_enddate_arrival 	DATETIME 	NULL,                                                                           -- 100
	lgh_dsp_date			DATETIME 	NULL,                                                                           -- 101
	lgh_geo_date			DATETIME 	NULL,                                                                           -- 102
	trc_driver				CHAR(8) 	NULL,                                                                           -- 103
	p_date					DATETIME 	NULL, /*trc_pln_date*/                                                          -- 104
	p_cmpid					CHAR(8) 	NULL, /*trc_pln_cmp_id*/                                                        -- 105
	p_cmpname				VARCHAR(100) NULL,                                                                          -- 106
	p_ctycode				INT 		NULL, /*trc_pln_city*/                                                          -- 107
	p_ctyname				VARCHAR(25) NULL,                                                                           -- 108
	p_state					CHAR(8) 	NULL,                                                                           -- 109
	trc_gps_desc			VARCHAR(45) NULL,                                                                           -- 110
	trc_gps_date			DATETIME 	NULL,                                                                           -- 111
	trc_exp1_date 			DATETIME 	NULL,                                                                           -- 112
	trc_exp2_date 			DATETIME 	NULL,                                                                           -- 113
	trl_exp1_date 			DATETIME 	NULL,                                                                           -- 114
	trl_exp2_date 			DATETIME 	NULL,                                                                           -- 115
	mpp_exp1_date 			DATETIME 	NULL,                                                                           -- 116
	mpp_exp2_date 			DATETIME 	NULL,                                                                           -- 117
	tot_weight				INT 		NULL,                                                                           -- 118
	tot_count				INT 		NULL,                                                                           -- 119
	tot_volume				INT 		NULL,                                                                           -- 120
	ordercount				INT 		NULL,                                                                           -- 121
	npup_cmpid				VARCHAR(8) 	NULL,                                                                           -- 122
	npup_cmpname			VARCHAR(100) NULL,                                                                          -- 123
	npup_ctyname			VARCHAR(25) NULL,                                                                           -- 124
	npup_state 				VARCHAR(6) 	NULL,                                                                           -- 125
	npup_arrivaldate 		DATETIME 	NULL,                                                                           -- 126
	ndrp_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 127
	ndrp_cmpname 			VARCHAR(100) NULL,                                                                          -- 128
	ndrp_ctyname 			VARCHAR(25) NULL,                                                                           -- 129
	ndrp_state 				VARCHAR(6) 	NULL,                                                                           -- 130
	ndrp_arrivaldate 		DATETIME 	NULL,                                                                           -- 131
	can_cap_expires 		DATETIME 	NULL,                                                                           -- 132
	ord_originregion1 		VARCHAR(6) 	NULL,                                                                           -- 133
	ord_originregion2 		VARCHAR(6) 	NULL,                                                                           -- 134
	ord_originregion3 		VARCHAR(6) 	NULL,                                                                           -- 135
	ord_originregion4 		VARCHAR(6) 	NULL,                                                                           -- 136
	ord_destregion1 		VARCHAR(6) 	NULL,                                                                           -- 137
	ord_destregion2 		VARCHAR(6) 	NULL,                                                                           -- 138
	ord_destregion3 		VARCHAR(6) 	NULL,                                                                           -- 139
	ord_destregion4 		VARCHAR(6) 	NULL,                                                                           -- 140
	lgh_feetavailable		INT 		NULL,                                                                           -- 141
	ord_fromorder	 		VARCHAR(12) NULL,                                                                           -- 142
	lgh_type1 				VARCHAR(6) 	NULL,                                                                           -- 143
	lgh_type2 				VARCHAR(6) 	NULL,                                                                           -- 144
	lgh_type1_name 			VARCHAR(20) NULL,                                                                           -- 145
	lgh_type1_labelname 	VARCHAR(20) NULL,                                                                           -- 146
	lgh_type2_name 			VARCHAR(20) NULL,                                                                           -- 147
	lgh_type2_labelname 	VARCHAR(20) NULL,                                                                           -- 148
	event 					CHAR(6) 	NULL,                                                                           -- 149
	trc_prior_event 		CHAR(6) 	NULL,                                                                           -- 150
	trc_prior_cmp_id 		VARCHAR(8) 	NULL,                                                                           -- 151
	trc_prior_city 			INT 		NULL,                                                                           -- 152
	trc_prior_ctyname 		VARCHAR(25) NULL,                                                                           -- 153
	trc_prior_state 		VARCHAR(6) 	NULL,                                                                           -- 154
	trc_prior_region1 		VARCHAR(6) 	NULL,                                                                           -- 155
	trc_prior_region2 		VARCHAR(6) 	NULL,                                                                           -- 156
	trc_prior_region3 		VARCHAR(6) 	NULL,                                                                           -- 157
	trc_prior_region4 		VARCHAR(6) 	NULL,                                                                           -- 158
	trc_prior_cmp_name 		VARCHAR(100) NULL,                                                                          -- 159
	trc_next_event 			CHAR(6)		NULL,                                                                           -- 160
	trc_next_cmp_id 		VARCHAR(8) 	NULL,                                                                           -- 161
	trc_next_city 			INT 		NULL,                                                                           -- 162
	trc_next_ctyname 		VARCHAR(25) NULL,                                                                           -- 163
	trc_next_state 			VARCHAR(6) 	NULL,                                                                           -- 164
	trc_next_region1 		VARCHAR(6) 	NULL,                                                                           -- 165
	trc_next_region2 		VARCHAR(6) 	NULL,                                                                           -- 166
	trc_next_region3 		VARCHAR(6) 	NULL,                                                                           -- 167
	trc_next_region4 		VARCHAR(6) 	NULL,                                                                           -- 168
	trc_next_cmp_name 		VARCHAR(100) NULL,                                                                          -- 169
	o_cmp_geoloc 			VARCHAR(50) NULL,                                                                           -- 170
	d_cmp_geoloc 			VARCHAR(50) NULL,                                                                           -- 171
	mpp_dailyhrsest 		FLOAT 		NULL,                                                                           -- 172
	mpp_weeklyhrsest 		FLOAT 		NULL,                                                                           -- 173
	mpp_lastlog_cmp_id 		VARCHAR(8) 	NULL,                                                                           -- 174
	mpp_lastlog_cmp_name	VARCHAR(30) NULL,                                                                           -- 175
	mpp_lastlog_estdate		DATETIME 	NULL,                                                                           -- 176
	mpp_estlog_datetime 	DATETIME 	NULL,                                                                           -- 177
	trc_trailer1			VARCHAR(13)	NULL,                                                                           -- 178
	next_stp_event_code	varchar (6) NULL,                                                                               -- 179
	next_stop_of_total 	varchar (10) NULL,                                                                              -- 180
	evt_carrier				varchar(8)	null,                                                                           -- 181
	terminal	varchar(6) null,                                                                                        -- 182
	ord_completiondate datetime null,                                                                                   -- 183
	evt_latedate			DATETIME	NULL,                                                                           -- 184
	drvpri1exp 			INT 		NULL,                                                                               -- 185
	drvpri1expsoon 			INT 		NULL,                                                                           -- 186
	drvpri2exp 			INT 		NULL,                                                                               -- 187
	drvpri2expsoon 			INT 		NULL,                                                                           -- 188
	trcpri1exp 			INT 		NULL,                                                                               -- 189
	trcpri1expsoon 			INT 		NULL,                                                                           -- 190
	trcpri2exp 			INT 		NULL,                                                                               -- 191
	trcpri2expsoon 			INT 		NULL,                                                                           -- 192
	trc_type1_t			VARCHAR(20) NULL,                                                                               -- 193
	trc_type1name			varchar(20) null,                                                                           -- 194
	trc_type2_t			varchar(20) null,                                                                               -- 195
	trc_type2name			varchar(20) null,                                                                           -- 196
	trc_type3_t			varchar(20) null,                                                                               -- 197
	trc_type3name			varchar(20) null,                                                                           -- 198
	trc_type4_t			varchar(20) null,                                                                               -- 199
	trc_type4name			varchar(20) null,                                                                           -- 200
	lgh_etaalert1			char(1)	null,                                                                               -- 201
	drv_type1_t			VARCHAR(20) NULL,                                                                               -- 202
	drv_type1name			varchar(20) null,                                                                           -- 203
	drv_type2_t			varchar(20) null,                                                                               -- 204
	drv_type2name			varchar(20) null,                                                                           -- 205
	drv_type3_t			varchar(20) null,                                                                               -- 206
	drv_type3name			varchar(20) null,                                                                           -- 207
	drv_type4_t			varchar(20) null,                                                                               -- 208
	drv_type4name			varchar(20) null,                                                                           -- 209
	drv_teamleader_t		varchar(20) null,                                                                           -- 210
	drv_teamleadername		varchar(20) null,                                                                           -- 211
	lgh_washplan 			varchar(20) null,                                                                           -- 212
	lgh_nexttrailer1		varchar(13) null,                                                                           -- 213
	lgh_nexttrailer2		varchar(13) null,                                                                           -- 214
	lgh_detstatus			int null,                                                                                   -- 215
	lgh_originzip			VARCHAR(10) NULL,                                                                           -- 216
	lgh_destzip			VARCHAR(10) NULL,                                                                               -- 217
	ord_company			VARCHAR(8) NULL,                                                                                -- 218
	origin_servicezonename		varchar(20) null,                                                                       -- 219
	origin_servicezone_labelname	varchar(20) null,                                                                   -- 220
	origin_serviceareaname		varchar(20) null,                                                                       -- 221
	origin_sericearea_labelname	varchar(20) null,                                                                       -- 222
	origin_servicecentername	varchar(20) null,                                                                       -- 223
	origin_servicecenter_labelname	varchar(20) null,                                                                   -- 224
	origin_serviceregionname	varchar(20) null,                                                                       -- 225
	origin_serviceregion_labelname	varchar(20) null,                                                                   -- 226
	dest_servicezonename		varchar(20) null,                                                                       -- 227
	dest_servicezone_labelname	varchar(20) null,                                                                       -- 228
	dest_serviceareaname		varchar(20) null,                                                                       -- 229
	dest_sericearea_labelname	varchar(20) null,                                                                       -- 230
	dest_servicecentername		varchar(20) null,                                                                       -- 231
	dest_servicecenter_labelname	varchar(20) null,                                                                   -- 232
	dest_serviceregionname		varchar(20) null,                                                                       -- 233
	dest_serviceregion_labelname	varchar(20) null,                                                                   -- 234
	mpp_hours1_week			float	null,                                                                               -- 235
-- PTS 29089 -- BL (start)
--	dest_cmp_lat 			decimal(7,4) null,
--	dest_cmp_long 			decimal (7,4) null,
--	dest_cty_lat 			decimal (7,4) null,
--	dest_cty_long 			decimal (7,4) null,
	dest_cmp_lat 			decimal(12,4) null,                                                                         -- 236
	dest_cmp_long 			decimal (12,4) null,                                                                        -- 237
	dest_cty_lat 			decimal (12,4) null,                                                                        -- 238
	dest_cty_long 			decimal (12,4) null,                                                                        -- 239
-- PTS 29089 -- BL (end)
	lgh_route			varchar(15) NULL,                                                                               -- 240
	lgh_booked_revtype1		varchar(12) NULL,                                                                           -- 241
        lgh_tm_status			varchar(6) NULL,                                                                        -- 242
        lgh_tm_statusname		varchar(25) NULL,                                                                       -- 243
	mpp_alternatephone		varchar(20) null,                                                                           -- 244
	lgh_comment			varchar(255) null,                                                                              -- 245
        --PTS# 29650 ILB 10/07/2004
        current_avl_date 		datetime null,                                                                          -- 246
        latest_avl_date                 datetime null,                                                                  -- 247
	--PTS# 29650 ILB 10/07/2004
	--PTS# 29623 ILB 11/14/2005
        lgh_trc_comment                 varchar(255)null,                                                               -- 248
	--PTS# 29623 ILB 11/14/2005
	mpp_pta_date			datetime null,	--DPH PTS 32698                                                             -- 249
	ord_billto				varchar(8)	null, -- DJM PTS 35482                                                          -- 250
	CompanyName_t			varchar(20)		null,	-- SGB 37620                                                        -- 251
	trc_latest_ctyst	    varchar(30)		null,                                                                       -- 252
	trc_latest_cmpid			varchar(8)	null,                                                                       -- 253
	trc_last_mobcomm_received	datetime	null,                                                                       -- 254
	trc_mobcomm_type			varchar(20)	null,                                                                       -- 255
	trc_nearest_mobcomm_nmstct	varchar(20)	null,-- PTS 38765                                                           -- 256
	ord_reftype					varchar(6)	null,		--PTS 40883 JJF 20080212                                        -- 257
	ord_refnum					varchar(30)	null,		--PTS 40883 JJF 20080212                                        -- 258
	trc_lastpos_lat			float			null,		-- PTS 42829 - DJM                                              -- 259
	trc_lastpos_long		float			null, 		-- PTS 42829 - DJM                                              -- 260
	drv1_shift_start		datetime		null, /* 09/04/2008 MDH PTS 43538: Added */									-- 261
	drv1_shift_end			datetime		null  /* 09/04/2008 MDH PTS 43538: Added */									-- 262
)

DECLARE @TT1 TABLE(
	lgh_number 				INT,                                                                                        -- 001
	stp_number_start 		INT			NULL,                                                                           -- 002
	stp_number_end			INT	NULL,                                                                                   -- 003
	o_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 004
	o_cmpname 				VARCHAR(100) NULL,                                                                          -- 005
	o_ctyname 				VARCHAR(25) NULL,                                                                           -- 006
	d_cmpid					VARCHAR(8) 	NULL,                                                                           -- 007
	d_cmpname 				VARCHAR(100) NULL,                                                                          -- 008
	d_ctyname 				VARCHAR(25) NULL,                                                                           -- 009
	f_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 010
	f_cmpname 				VARCHAR(100) NULL,                                                                          -- 011
	f_ctycode 				INT 		NULL,                                                                           -- 012
	f_ctyname 				VARCHAR(25) NULL,                                                                           -- 013
	l_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 014
	l_cmpname 				VARCHAR(100) NULL,                                                                          -- 015
	l_ctycode 				INT 		NULL,                                                                           -- 016
	l_ctyname 				VARCHAR(25) NULL,                                                                           -- 017
	lgh_startdate 			DATETIME 	NULL,                                                                           -- 018
	lgh_enddate 			DATETIME 	NULL,                                                                           -- 019
	o_state 				VARCHAR(6) 	NULL,                                                                           -- 020
	d_state 				VARCHAR(6) 	NULL,                                                                           -- 021
	lgh_outstatus 			VARCHAR(6) 	NULL,                                                                           -- 022
	lgh_instatus 			VARCHAR(6) 	NULL,                                                                           -- 023
	lgh_priority 			VARCHAR(6) 	NULL,                                                                           -- 024
	lgh_schdtearliest 		DATETIME 	NULL,                                                                           -- 025
	lgh_schdtlatest 		DATETIME 	NULL,                                                                           -- 026
	cmd_code 				VARCHAR(8) 	NULL,                                                                           -- 027
	fgt_description 		VARCHAR(60) NULL,                                                                           -- 028
	ord_hdrnumber 			INT 		NULL,                                                                           -- 029
	mpp_type1 				VARCHAR(6) 	NULL,                                                                           -- 030
	mpp_type2 				VARCHAR(6) 	NULL,                                                                           -- 031
	mpp_type3 				VARCHAR(6) 	NULL,                                                                           -- 032
	mpp_type4 				VARCHAR(6) 	NULL,                                                                           -- 033
	mpp_teamleader 			VARCHAR(6) 	NULL,                                                                           -- 034
	mpp_fleet 				VARCHAR(6) 	NULL,                                                                           -- 035
	mpp_division 			VARCHAR(6) 	NULL,                                                                           -- 036
	mpp_domicile 			VARCHAR(6) 	NULL,                                                                           -- 037
	mpp_company 			VARCHAR(6) 	NULL,                                                                           -- 038
	mpp_terminal 			VARCHAR(6) 	NULL,                                                                           -- 039
	mpp_last_home 			DATETIME 	NULL,                                                                           -- 040
	mpp_want_home 			DATETIME 	NULL,                                                                           -- 041
	lgh_class1 				VARCHAR(6) 	NULL,                                                                           -- 042
	lgh_class2 				VARCHAR(6) 	NULL,                                                                           -- 043
	lgh_class3				VARCHAR(6) 	NULL,                                                                           -- 044
	lgh_class4 				VARCHAR(6) 	NULL,                                                                           -- 045
	trc_type1 				VARCHAR(6) 	NULL,                                                                           -- 046
	trc_type2 				VARCHAR(6) 	NULL,                                                                           -- 047
	trc_type3 				VARCHAR(6) 	NULL,                                                                           -- 048
	trc_type4 				VARCHAR(6) 	NULL,                                                                           -- 049
	trl_type1 				VARCHAR(6) 	NULL,                                                                           -- 050
	trl_type2 				VARCHAR(6) 	NULL,                                                                           -- 051
	trl_type3 				VARCHAR(6) 	NULL,                                                                           -- 052
	trl_type4 				VARCHAR(6) 	NULL,                                                                           -- 053
	trc_company 			VARCHAR(6) 	NULL,                                                                           -- 054
	trc_division 			VARCHAR(6) 	NULL,                                                                           -- 055
	trc_fleet 				VARCHAR(6) 	NULL,                                                                           -- 056
	trc_terminal 			VARCHAR(6) 	NULL,                                                                           -- 057
	evt_driver1 			VARCHAR(8) 	NULL,                                                                           -- 058
	evt_driver2 			VARCHAR(8) 	NULL,                                                                           -- 059
	evt_tractor 			VARCHAR(8) 	NULL,                                                                           -- 060
	lgh_primary_trailer 	VARCHAR(13) NULL,                                                                           -- 061
	mov_number 				INT 		NULL,                                                                           -- 062
	ord_number 				CHAR(13) 	NULL,                                                                           -- 063
	o_city 					INT 		NULL,                                                                           -- 064
	d_city 					INT 		NULL,                                                                           -- 065
	filtflag 				VARCHAR(1) 	NULL,                                                                           -- 066
	outstatname 			VARCHAR(20) NULL,                                                                           -- 067
	instatname 				VARCHAR(20) NULL,                                                                           -- 068
	companyname 			VARCHAR(20) NULL,                                                                           -- 069
	trltype1name 			VARCHAR(20) NULL,                                                                           -- 070
	trltype1labelname 		VARCHAR(20) NULL,                                                                           -- 071
	revclass1name 			VARCHAR(20) NULL,                                                                           -- 072
	revclass2name 			VARCHAR(20) NULL,                                                                           -- 073
	revclass3name 			VARCHAR(20) NULL,                                                                           -- 074
	revclass4name 			VARCHAR(20) NULL,                                                                           -- 075
	revclass1labelname 		VARCHAR(20) NULL,                                                                           -- 076
	revclass2labelname 		VARCHAR(20) NULL,                                                                           -- 077
	revclass3labelname 		VARCHAR(20) NULL,                                                                           -- 078
	revclass4labelname 		VARCHAR(20) NULL,                                                                           -- 079
	pri1exp 				INT 		NULL,                                                                           -- 080
	pri1expsoon 			INT 		NULL,                                                                           -- 081
	pri2exp 				INT 		NULL,                                                                           -- 082
	pri2expsoon 			INT 		NULL,                                                                           -- 083
	loghours 				FLOAT 		NULL,                                                                           -- 084
	drvstat 				INT 		NULL,                                                                           -- 085
	trcstat 				INT 		NULL,                                                                           -- 086
	ord_bookedby 			VARCHAR(20) 	NULL,   -- PTS 41931 SGB 04/18/08                                           -- 087
	lgh_primary_pup 		VARCHAR(13) NULL,                                                                           -- 088
	servicerule 			CHAR(6) 	NULL,                                                                           -- 089
	trltype2name 			VARCHAR(20) NULL,                                                                           -- 090
	trltype2labelname 		VARCHAR(20) NULL,                                                                           -- 091
	trltype3name 			VARCHAR(20) NULL,                                                                           -- 092
	trltype3labelname 		VARCHAR(20) NULL,                                                                           -- 093
	trltype4name 			VARCHAR(20) NULL,                                                                           -- 094
	trltype4labelname 		VARCHAR(20) NULL,                                                                           -- 095
	f_state 				VARCHAR(6) 	NULL,                                                                           -- 096
	l_state 				VARCHAR(6) 	NULL,                                                                           -- 097
	mpp_lastfirst_1			VARCHAR(45) NULL,                                                                           -- 098
	mpp_lastfirst_2 		VARCHAR(45) NULL,                                                                           -- 099
	lgh_enddate_arrival 	DATETIME 	NULL,                                                                           -- 100
	lgh_dsp_date			DATETIME 	NULL,                                                                           -- 101
	lgh_geo_date			DATETIME 	NULL,                                                                           -- 102
	trc_driver				CHAR(8) 	NULL,                                                                           -- 103
	p_date					DATETIME 	NULL, /*trc_pln_date*/                                                          -- 104
	p_cmpid					CHAR(8) 	NULL, /*trc_pln_cmp_id*/                                                        -- 105
	p_cmpname				VARCHAR(100) NULL,                                                                          -- 106
	p_ctycode				INT 		NULL, /*trc_pln_city*/                                                          -- 107
	p_ctyname				VARCHAR(25) NULL,                                                                           -- 108
	p_state					CHAR(8) 	NULL,                                                                           -- 109
	trc_gps_desc			VARCHAR(45) NULL,                                                                           -- 110
	trc_gps_date			DATETIME 	NULL,                                                                           -- 111
	trc_exp1_date 			DATETIME 	NULL,                                                                           -- 112
	trc_exp2_date 			DATETIME 	NULL,                                                                           -- 113
	trl_exp1_date 			DATETIME 	NULL,                                                                           -- 114
	trl_exp2_date 			DATETIME 	NULL,                                                                           -- 115
	mpp_exp1_date 			DATETIME 	NULL,                                                                           -- 116
	mpp_exp2_date 			DATETIME 	NULL,                                                                           -- 117
	tot_weight				INT 		NULL,                                                                           -- 118
	tot_count				INT 		NULL,                                                                           -- 119
	tot_volume				INT 		NULL,                                                                           -- 120
	ordercount				INT 		NULL,                                                                           -- 121
	npup_cmpid				VARCHAR(8) 	NULL,                                                                           -- 122
	npup_cmpname			VARCHAR(100) NULL,                                                                          -- 123
	npup_ctyname			VARCHAR(25) NULL,                                                                           -- 124
	npup_state 				VARCHAR(6) 	NULL,                                                                           -- 125
	npup_arrivaldate 		DATETIME 	NULL,                                                                           -- 126
	ndrp_cmpid 				VARCHAR(8) 	NULL,                                                                           -- 127
	ndrp_cmpname 			VARCHAR(100) NULL,                                                                          -- 128
	ndrp_ctyname 			VARCHAR(25) NULL,                                                                           -- 129
	ndrp_state 				VARCHAR(6) 	NULL,                                                                           -- 130
	ndrp_arrivaldate 		DATETIME 	NULL,                                                                           -- 131
	can_cap_expires 		DATETIME 	NULL,                                                                           -- 132
	ord_originregion1 		VARCHAR(6) 	NULL,                                                                           -- 133
	ord_originregion2 		VARCHAR(6) 	NULL,                                                                           -- 134
	ord_originregion3 		VARCHAR(6) 	NULL,                                                                           -- 135
	ord_originregion4 		VARCHAR(6) 	NULL,                                                                           -- 136
	ord_destregion1 		VARCHAR(6) 	NULL,                                                                           -- 137
	ord_destregion2 		VARCHAR(6) 	NULL,                                                                           -- 138
	ord_destregion3 		VARCHAR(6) 	NULL,                                                                           -- 139
	ord_destregion4 		VARCHAR(6) 	NULL,                                                                           -- 140
	lgh_feetavailable		INT 		NULL,                                                                           -- 141
	ord_fromorder	 		VARCHAR(12) NULL,                                                                           -- 142
	lgh_type1 				VARCHAR(6) 	NULL,                                                                           -- 143
	lgh_type2 				VARCHAR(6) 	NULL,                                                                           -- 144
	lgh_type1_name 			VARCHAR(20) NULL,                                                                           -- 145
	lgh_type1_labelname 	VARCHAR(20) NULL,                                                                           -- 146
	lgh_type2_name 			VARCHAR(20) NULL,                                                                           -- 147
	lgh_type2_labelname 	VARCHAR(20) NULL,                                                                           -- 148
	event 					CHAR(6) 	NULL,                                                                           -- 149
	trc_prior_event 		CHAR(6) 	NULL,                                                                           -- 150
	trc_prior_cmp_id 		VARCHAR(8) 	NULL,                                                                           -- 151
	trc_prior_city 			INT 		NULL,                                                                           -- 152
	trc_prior_ctyname 		VARCHAR(25) NULL,                                                                           -- 153
	trc_prior_state 		VARCHAR(6) 	NULL,                                                                           -- 154
	trc_prior_region1 		VARCHAR(6) 	NULL,                                                                           -- 155
	trc_prior_region2 		VARCHAR(6) 	NULL,                                                                           -- 156
	trc_prior_region3 		VARCHAR(6) 	NULL,                                                                           -- 157
	trc_prior_region4 		VARCHAR(6) 	NULL,                                                                           -- 158
	trc_prior_cmp_name 		VARCHAR(100) NULL,                                                                          -- 159
	trc_next_event 			CHAR(6)		NULL,                                                                           -- 160
	trc_next_cmp_id 		VARCHAR(8) 	NULL,                                                                           -- 161
	trc_next_city 			INT 		NULL,                                                                           -- 162
	trc_next_ctyname 		VARCHAR(25) NULL,                                                                           -- 163
	trc_next_state 			VARCHAR(6) 	NULL,                                                                           -- 164
	trc_next_region1 		VARCHAR(6) 	NULL,                                                                           -- 165
	trc_next_region2 		VARCHAR(6) 	NULL,                                                                           -- 166
	trc_next_region3 		VARCHAR(6) 	NULL,                                                                           -- 167
	trc_next_region4 		VARCHAR(6) 	NULL,                                                                           -- 168
	trc_next_cmp_name 		VARCHAR(100) NULL,                                                                          -- 169
	o_cmp_geoloc 			VARCHAR(50) NULL,                                                                           -- 170
	d_cmp_geoloc 			VARCHAR(50) NULL,                                                                           -- 171
	mpp_fleet_name 			VARCHAR(20) NULL,                                                                           -- 172
	mpp_dailyhrsest 		FLOAT 		NULL,                                                                           -- 173
	mpp_weeklyhrsest 		FLOAT 		NULL,                                                                           -- 174
	mpp_lastlog_cmp_id 		VARCHAR(8) 	NULL,                                                                           -- 175
	mpp_lastlog_cmp_name	VARCHAR(30) NULL,                                                                           -- 176
	mpp_lastlog_estdate		DATETIME 	NULL,                                                                           -- 177
	mpp_estlog_datetime 	DATETIME 	NULL,                                                                           -- 178
	trc_trailer1			VARCHAR(13)	NULL,                                                                           -- 179
	mpp_next_exp_code		VARCHAR(6) NULL,                                                                            -- 180
	mpp_next_exp_name		VARCHAR(20) NULL,                                                                           -- 181
   	mpp_next_exp_date		DATETIME NULL,                                                                              -- 182
	mpp_next_exp_compldate  DATETIME NULL,                                                                              -- 183
	next_stp_event_code		varchar (6) NULL,                                                                           -- 184
	next_stop_of_total		VARCHAR (10) NULL,                                                                          -- 185
	--vmj2+
	evt_carrier				varchar(8)	null,                                                                           -- 186
	terminal	varchar(6) null,                                                                                        -- 187
	ord_completiondate datetime null,                                                                                   -- 188
	last_stop_dep_status varchar(6) NULL,                                                                               -- 189
	evt_latedate			DATETIME	NULL,                                                                           -- 190
	mpp_status_desc 	varchar(20) NULL,                                                                               -- 191
	drvpri1exp 			INT 		NULL,                                                                               -- 192
	drvpri1expsoon 			INT 		NULL,                                                                           -- 193
	drvpri2exp 			INT 		NULL,                                                                               -- 194
	drvpri2expsoon 			INT 		NULL,                                                                           -- 195
	trcpri1exp 			INT 		NULL,                                                                               -- 196
	trcpri1expsoon 			INT 		NULL,                                                                           -- 197
	trcpri2exp 			INT 		NULL,                                                                               -- 198
	trcpri2expsoon 			INT 		NULL,                                                                           -- 199
	trc_gps_latitude	INT	NULL,                                                                                       -- 200
	trc_gps_longitude	INT	NULL,                                                                                       -- 201
	trc_type1_t			VARCHAR(20) NULL,                                                                               -- 202
	trc_type1name			varchar(20) null,                                                                           -- 203
	trc_type2_t			varchar(20) null,                                                                               -- 204
	trc_type2name			varchar(20) null,                                                                           -- 205
	trc_type3_t			varchar(20) null,                                                                               -- 206
	trc_type3name			varchar(20) null,                                                                           -- 207
	trc_type4_t			varchar(20) null,                                                                               -- 208
	trc_type4name			varchar(20) null,                                                                           -- 209
	--vmj6+
	lgh_etaalert1			char(1)		null,                                                                           -- 210
	--vmj6-
	drv_type1_t			VARCHAR(20) NULL,                                                                               -- 211
	drv_type1name			varchar(20) null,                                                                           -- 212
	drv_type2_t			varchar(20) null,                                                                               -- 213
	drv_type2name			varchar(20) null,                                                                           -- 214
	drv_type3_t			varchar(20) null,                                                                               -- 215
	drv_type3name			varchar(20) null,                                                                           -- 216
	drv_type4_t			varchar(20) null,                                                                               -- 217
	drv_type4name			varchar(20) null,                                                                           -- 218
	drv_teamleader_t		varchar(20) null,                                                                           -- 219
	drv_teamleadername		varchar(20) null,                                                                           -- 220
	lgh_washplan 			varchar(20) null,                                                                           -- 221
	lgh_nexttrailer1		varchar(13) null,                                                                           -- 222
	lgh_nexttrailer2		varchar(13) null,                                                                           -- 223
	lgh_detstatus			int null,                                                                                   -- 224
	lgh_originzip			VARCHAR(10) NULL,                                                                           -- 225
	lgh_destzip				VARCHAR(10) NULL,                                                                           -- 226
	ord_company				VARCHAR(8) NULL,                                                                            -- 227
	origin_servicezonename			varchar(20) null,                                                                   -- 228
	origin_servicezone_labelname	varchar(20) null,                                                                   -- 229
	origin_serviceareaname			varchar(20) null,                                                                   -- 230
	origin_sericearea_labelname		varchar(20) null,                                                                   -- 231
	origin_servicecentername		varchar(20) null,                                                                   -- 232
	origin_servicecenter_labelname	varchar(20) null,                                                                   -- 233
	origin_serviceregionname		varchar(20) null,                                                                   -- 234
	origin_serviceregion_labelname	varchar(20) null,                                                                   -- 235
	dest_servicezonename			varchar(20) null,                                                                   -- 236
	dest_servicezone_labelname		varchar(20) null,                                                                   -- 237
	dest_serviceareaname			varchar(20) null,                                                                   -- 238
	dest_sericearea_labelname		varchar(20) null,                                                                   -- 239
	dest_servicecentername			varchar(20) null,                                                                   -- 240
	dest_servicecenter_labelname	varchar(20) null,                                                                   -- 241
	dest_serviceregionname			varchar(20) null,                                                                   -- 242
	dest_serviceregion_labelname	varchar(20) null,                                                                   -- 243
	mpp_hours1_week			float	null,                                                                               -- 244
-- PTS 29089 -- BL (start)
--	dest_cmp_lat 			decimal(7,4) null,
--	dest_cmp_long 			decimal (7,4) null,
--	dest_cty_lat 			decimal (7,4) null,
--	dest_cty_long 			decimal (7,4) null,
	dest_cmp_lat 			decimal (12,4) null,                                                                        -- 245
	dest_cmp_long 			decimal (12,4) null,                                                                        -- 246
	dest_cty_lat 			decimal (12,4) null,                                                                        -- 247
	dest_cty_long 			decimal (12,4) null,                                                                        -- 248
-- PTS 29089 -- BL (end)
	lgh_route				varchar(15) NULL,                                                                           -- 249
	lgh_booked_revtype1		varchar(12) NULL,                                                                           -- 250
    lgh_tm_status			varchar(6) NULL,                                                                        	-- 251
    lgh_tm_statusname		varchar(25) NULL,                                                                       	-- 252
	mpp_alternatephone		varchar(20) null,                                                                           -- 253
	lgh_comment				varchar(255) null,                                                                          -- 254
	--PTS# 29650 ILB 10/07/2004
        current_avl_date 		datetime null,                                                                          -- 255
        latest_avl_date         datetime null,                                                                  		-- 256
	--PTS# 29650 ILB 10/07/2004
	--PTS# 29623 ILB 11/14/2005
        lgh_trc_comment			varchar(255) null,                                                                      -- 257
	--PTS# 29623 ILB 11/14/2005
	mpp_pta_date			datetime null, --DPH PTS 32698                                                              -- 258
    exp_affects_avail_dtm	char(1) null, --JLB PTS 35133                                                               -- 259
    TimeZoneAdjMins         int             null,  --PTS35747                                                           -- 260
	ord_billto				varchar(8)	null, -- DJM PTS 35482 --DPH PTS 32698                                          -- 270
	CompanyName_t			varchar(20)		null,			  -- SGB 37620                                              -- 271
	trc_latest_ctyst	    varchar(30)		null,                                                                       -- 272
	trc_latest_cmpid			varchar(8)	null,                                                                       -- 273
	trc_last_mobcomm_received	datetime	null,                                                                       -- 274
	trc_mobcomm_type			varchar(20)	null,                                                                       -- 275
	trc_nearest_mobcomm_nmstct	varchar(20)	null,	-- PTS 38765                                                        -- 276
	trc_comment1				varchar(255)	null,                                                                   -- 277
	ord_reftype					varchar(6)	null,		--PTS 40883 JJF 20080212                                        -- 278
	ord_refnum					varchar(30)	null,		--PTS 40883 JJF 20080212                                        -- 279
	trc_lastpos_lat			float			null,		-- PTS 42829 - DJM                                              -- 280
	trc_lastpos_long		float			null,		-- PTS 42829 - DJM                                              -- 281
	drv1_shift_start		datetime		null, /* 09/04/2008 MDH PTS 43538: Added */									-- 282
	drv1_shift_end			datetime		null  /* 09/04/2008 MDH PTS 43538: Added */									-- 283
)

DECLARE @l_mpp TABLE(
	name 					VARCHAR(20) NOT NULL,
	abbr 					VARCHAR(6) 	NOT NULL,
	code 					INT NULL  )

DECLARE @l_trc TABLE(
	name 					VARCHAR(20) NOT NULL,
	abbr 					VARCHAR(6)	NOT NULL,
	code 					INT 		NULL )

DECLARE @1_pups TABLE(
	cmp_id					VARCHAR(8),
	cmp_name				VARCHAR(100),
	cty_nmstct				VARCHAR(25),
	stp_state				VARCHAR(20),
	stp_arrivaldate			DATETIME,
	ord_hdrnumber			INT)

DECLARE @1_drps TABLE(
	cmp_id					VARCHAR(8),
	cmp_name				VARCHAR(100),
	cty_nmstct				VARCHAR(25),
	stp_state				VARCHAR(20),
	stp_arrivaldate			DATETIME,
	ord_hdrnumber			INT)

--vmj1+	create temp table to store parm list for @terminal..
DECLARE @terminal_table TABLE(
	trc_terminal			VARCHAR(6)	NULL)

-- RE - 10/15/02 - PTS #15024
SELECT @LateWarnMode = gi_string1 FROM generalinfo WHERE gi_name = 'PlnWrkshtLateWarnMode'

-- PTS 31211 -- BL (start)
SELECT @AVLDTTM_ONLYSETBY_OPENEXPS = LEFT(upper(gi_string1), 1) FROM generalinfo WHERE gi_name = 'AVLDTTM_ONLYSETBY_OPENEXPS'
-- PTS 31211 -- BL (end)

--Parse @terminal into a temptable possibly containing multiple values.  This will allow an index read on
--legheader_active, where the older charindex function prevented that.  This assumes, as the older code did,
--that the list is comma-delimited..
SELECT @ls_whats_left = ISNULL(LTRIM(RTRIM(@terminal)), '')
SELECT @li_pos = CHARINDEX(',', @ls_whats_left)

WHILE @li_pos > 0
BEGIN
	SELECT @ls_value = ISNULL(LTRIM(RTRIM(SUBSTRING(@ls_whats_left, 1, @li_pos - 1))), '')
	IF @ls_value <> '' AND @ls_value <> 'UNK'
	BEGIN
		INSERT INTO @terminal_table
			(trc_terminal)
		VALUES
			(@ls_value)
	END

	--Find the next comma..
	SELECT @ls_whats_left = ISNULL(LTRIM(RTRIM(SUBSTRING(@ls_whats_left, @li_pos + 1, 255))), '')
	SELECT @li_pos = CHARINDEX(',', @ls_whats_left)
END

--Get the last value..
IF @ls_whats_left <> ''
	INSERT INTO @terminal_table
		(trc_terminal)
	VALUES
		(@ls_whats_left)
--vmj1-

--vmj4+	Calculate the beginning of the day yesterday..
select @ldt_yesterday = convert(datetime, left(convert(varchar(30),
												dateadd(day, -1, getdate()), 120), 10))
--vmj4-


IF PATINDEX('%AVL%', @status) > 0
	SELECT @avl = 'AVL'
ELSE
	SELECT @avl = '!'

SELECT @neardate = DATEADD(dy, @days, GETDATE())
SELECT @drvneardate = DATEADD(dy, @drvdays, GETDATE())
SELECT @trcneardate = DATEADD(dy, @trcdays, GETDATE())

IF @hoursback = 0
	SELECT @hoursback= 1000000

IF @hoursout = 0
	SELECT @hoursout = 1000000

-- Get the hoursback and  hoursout into variables
SELECT @hoursbackdate = DATEADD(hour, -@hoursback, GETDATE())
SELECT @hoursoutdate = DATEADD(hour,  @hoursout, GETDATE())

/* 35747 Is local time option set (GI integer1 is the city code of the dispatch office) */
select @V_GILocalTimeOption = Upper(isnull(gi_string1,''))
from generalinfo where gi_name = 'LocalTimeOption'
Select @V_GILocalTimeOption = isnull(@V_GILocalTimeOption,'')
select @v_LocalCityTZAdjFactor = 0
If @V_GILocalTimeOption = 'LOCAL'
  BEGIN
    /* if server is in different time zone that dipatch office there may be a few hours of error going in and out of DST */
    select @DSTCountryCode = 0 /* if you want to work outside North America, set this value see proc ChangeTZ */
    select @InDSTFactor = case dbo.InDst(getdate(),@DSTCountryCode) when 'Y' then 1 else 0 end
    select @v_LocalCityTZAdjFactor = 0
/*
    If @v_GIDispatchCity > 0 and exists (select 1 from city where cty_code = @v_GIDispatchCity)
       select @v_LocalCityTZAdjFactor = ((isnull(cty_GMTDelta,5)
       + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else -1 end))) * 60)
       + isnull(cty_TZMins,0)
       From city where cty_code = @v_GIDIspatchCity
    else /* assume EST if nto dispatch office city code in GI*/
       select @v_LocalCityTZAdjFactor = (5 * 60)
*/
     exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
     select @v_LocalCityTZAdjFactor =
       ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
  END
/* 35747 end */

IF @city IS NULL
   SELECT @city = 0
IF @reg1 IS NULL OR @reg1 = ''
   SELECT @reg1 = 'UNK'
IF @reg2 IS NULL OR @reg2 = ''
   SELECT @reg2 = 'UNK'
IF @reg3 IS NULL OR @reg3 = ''
   SELECT @reg3 = 'UNK'
IF @reg4 IS NULL OR @reg4 = ''
   SELECT @reg4 = 'UNK'
IF @status IS NULL
   SELECT @status = ''
IF @states IS NULL
   SELECT @states = ''
IF @bookedby = '' OR @bookedby IS NULL
   SELECT @bookedby = 'ALL'
--LOR
IF @d_city IS NULL
   SELECT @d_city = 0
IF @d_states IS NULL
   SELECT @d_states = ''
--PTS13155 MBR 1/30/02
IF @d_reg1 IS NULL OR @d_reg1 = ''
   SELECT @d_reg1 = 'UNK'
IF @d_reg2 IS NULL OR @d_reg2 = ''
   SELECT @d_reg2 = 'UNK'
IF @d_reg3 IS NULL OR @d_reg3 = ''
   SELECT @d_reg3 = 'UNK'
IF @d_reg4 IS NULL OR @d_reg4 = ''
   SELECT @d_reg4 = 'UNK'
IF @next_city IS NULL
   SELECT @next_city = 0
IF @next_region1 IS NULL OR @next_region1 = ''
   SELECT @next_region1 = 'UNK'
IF @next_region2 IS NULL OR @next_region2 = ''
   SELECT @next_region2 = 'UNK'
IF @next_region3 IS NULL OR @next_region3 = ''
   SELECT @next_region3 = 'UNK'
IF @next_region4 IS NULL OR @next_region4 = ''
   SELECT @next_region4 = 'UNK'
IF @next_state IS NULL
   SELECT @next_state = ''
IF @next_event IS NULL
   SELECT @next_event = ''
IF @last_event IS NULL
   SELECT @last_event = ''
if @lgh_booked_revtype1 IS NULL or @lgh_booked_revtype1 = ''
   SELECT @lgh_booked_revtype1 = 'UNK'
/* 02/14/2008 MDH PTS 39077: Added validations for new cmp_type1 parameters <<BEGIN>> */
IF @cmp_othertype1 IS NULL or @cmp_othertype1 = ''
	SELECT @cmp_othertype1 = 'UNK'
IF @prior_cmp_othertype1 IS NULL or @prior_cmp_othertype1 = ''
	SELECT @prior_cmp_othertype1 = 'UNK'
IF @next_cmp_othertype1 IS NULL or @next_cmp_othertype1 = ''
	SELECT @next_cmp_othertype1 = 'UNK'
SELECT @cmp_othertype1 = ',' + LTRIM(RTRIM(ISNULL(@cmp_othertype1, ''))) + ','
SELECT @prior_cmp_othertype1 = ',' + LTRIM(RTRIM(ISNULL(@prior_cmp_othertype1, ''))) + ','
SELECT @next_cmp_othertype1 = ',' + LTRIM(RTRIM(ISNULL(@next_cmp_othertype1, ''))) + ','
/* 02/14/2008 MDH PTS 39077: <<END>> */

/* 09/04/2008 MDH PTS 43538: <<BEGIN>> */
SELECT @mpp_shift_max_minutes = gi_integer1 FROM generalinfo WHERE gi_name = 'ValidateShiftDuration'
SET @mpp_shift_max_minutes = COALESCE (@mpp_shift_max_minutes, 0)
SELECT @mpp_shift_off_minutes = gi_integer1 FROM generalinfo WHERE gi_name = 'ValidateShiftOff'
SET @mpp_shift_off_minutes = COALESCE (@mpp_shift_off_minutes, 0)
/* 09/04/2008 MDH PTS 43538: <<END>> */

SELECT @bookedby = ',' + LTRIM(RTRIM(ISNULL(@bookedby, ''))) + ','
SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ','
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ','
SELECT @cmpids = ',' + LTRIM(RTRIM(ISNULL(@cmpids, ''))) + ','
SELECT @trctype1 = ',' + LTRIM(RTRIM(ISNULL(@trctype1, ''))) + ','
SELECT @trctype2 = ',' + LTRIM(RTRIM(ISNULL(@trctype2, ''))) + ','
SELECT @trctype3 = ',' + LTRIM(RTRIM(ISNULL(@trctype3, ''))) + ','
SELECT @trctype4 = ',' + LTRIM(RTRIM(ISNULL(@trctype4, ''))) + ','
SELECT @fleet = ',' + LTRIM(RTRIM(ISNULL(@fleet, ''))) + ','
SELECT @division = ',' + LTRIM(RTRIM(ISNULL(@division, ''))) + ','
SELECT @company = ',' + LTRIM(RTRIM(ISNULL(@company, ''))) + ','
SELECT @terminal = ',' + LTRIM(RTRIM(ISNULL(@terminal, ''))) + ','
SELECT @mpptype1 = ',' + LTRIM(RTRIM(ISNULL(@mpptype1, ''))) + ','
SELECT @mpptype2 = ',' + LTRIM(RTRIM(ISNULL(@mpptype2, ''))) + ','
SELECT @mpptype3 = ',' + LTRIM(RTRIM(ISNULL(@mpptype3, ''))) + ','
SELECT @mpptype4 = ',' + LTRIM(RTRIM(ISNULL(@mpptype4, ''))) + ','
SELECT @teamleader = ',' + LTRIM(RTRIM(ISNULL(@teamleader, ''))) + ','
SELECT @domicile = ',' + LTRIM(RTRIM(ISNULL(@domicile, ''))) + ','
SELECT @trltype1 = ',' + LTRIM(RTRIM(ISNULL(@trltype1, ''))) + ','
SELECT @trltype2 = ',' + LTRIM(RTRIM(ISNULL(@trltype2, ''))) + ','
SELECT @trltype3 = ',' + LTRIM(RTRIM(ISNULL(@trltype3, ''))) + ','
SELECT @trltype4 = ',' + LTRIM(RTRIM(ISNULL(@trltype4, ''))) + ','
--LOR
SELECT @reg1 = ',' + LTRIM(RTRIM(ISNULL(@reg1, '')))  + ','
SELECT @reg2 = ',' + LTRIM(RTRIM(ISNULL(@reg2, '')))  + ','
SELECT @reg3 = ',' + LTRIM(RTRIM(ISNULL(@reg3, '')))  + ','
SELECT @reg4 = ',' + LTRIM(RTRIM(ISNULL(@reg4, '')))  + ','
SELECT @lgh_type1 = ',' + LTRIM(RTRIM(ISNULL(@lgh_type1, '')))  + ','
SELECT @lgh_type2 = ',' + LTRIM(RTRIM(ISNULL(@lgh_type2, '')))  + ','
SELECT @d_reg1 = ',' + LTRIM(RTRIM(ISNULL(@d_reg1, '')))  + ','
SELECT @d_reg2 = ',' + LTRIM(RTRIM(ISNULL(@d_reg2, '')))  + ','
SELECT @d_reg3 = ',' + LTRIM(RTRIM(ISNULL(@d_reg3, '')))  + ','
SELECT @d_reg4 = ',' + LTRIM(RTRIM(ISNULL(@d_reg4, '')))  + ','
SELECT @d_cmpids = ',' + LTRIM(RTRIM(ISNULL(@d_cmpids, ''))) + ','
SELECT @next_cmp_id = ',' + LTRIM(RTRIM(ISNULL(@next_cmp_id, ''))) + ','
SELECT @next_region1 = ',' + LTRIM(RTRIM(ISNULL(@next_region1, '')))  + ','
SELECT @next_region2 = ',' + LTRIM(RTRIM(ISNULL(@next_region2, '')))  + ','
SELECT @next_region3 = ',' + LTRIM(RTRIM(ISNULL(@next_region3, '')))  + ','
SELECT @next_region4 = ',' + LTRIM(RTRIM(ISNULL(@next_region4, '')))  + ','
SELECT @drv_status = ',' + LTRIM(RTRIM(ISNULL(@drv_status, ''))) + ','
SELECT @billto = ',' + LTRIM(RTRIM(ISNULL(@billto, ''))) + ',' --vjh 21250

SELECT @drv_qualifications = IsNull(@drv_qualifications,'')
SELECT @trc_accessories = IsNull(@trc_accessories,'')
SELECT @trl_accessories = IsNull(@trl_accessories,'')

-- PTS 26766 - DJM - recode 19028
SELECT @orderedby = ',' + LTRIM(RTRIM(ISNULL(@orderedby, ''))) + ','
-- PTS 27667 - DJM - Recode 22601
SELECT @o_servicearea = ',' + LTRIM(RTRIM(ISNULL(@o_servicearea, '')))  + ','
SELECT @o_servicezone = ',' + LTRIM(RTRIM(ISNULL(@o_servicezone, '')))  + ','
SELECT @o_servicecenter = ',' + LTRIM(RTRIM(ISNULL(@o_servicecenter, '')))  + ','
SELECT @o_serviceregion	= ',' + LTRIM(RTRIM(ISNULL(@o_serviceregion, '')))  + ','
SELECT @dest_servicearea = ',' + LTRIM(RTRIM(ISNULL(@dest_servicearea, '')))  + ','
SELECT @dest_servicezone = ',' + LTRIM(RTRIM(ISNULL(@dest_servicezone, '')))  + ','
SELECT @dest_servicecenter = ',' + LTRIM(RTRIM(ISNULL(@dest_servicecenter, '')))  + ','
SELECT @dest_serviceregion = ',' + LTRIM(RTRIM(ISNULL(@dest_serviceregion, '')))  + ','


/* PTS 20302 - DJM - display the localization settings for the Origin and Desitinations	*/
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'

-- 27352
SELECT @lgh_route = ',' + LTRIM(RTRIM(ISNULL(@lgh_route, '')))  + ','
SELECT @lgh_booked_revtype1 = ',' + LTRIM(RTRIM(ISNULL(@lgh_booked_revtype1, '')))  + ','

-- JET - 3/20/2003 - PTS 17705, make @carrier = UNKNOWN when it is NULL or ''
IF @carrier IS NULL OR LTRIM(RTRIM(@carrier)) = ''
   SET @carrier = 'UNKNOWN'

/* PTS14927 MBR 7/22/02 */
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'IgnoreOtherAssetsInbound' and substring(gi_string1,1,1) = 'Y' )
BEGIN
     SELECT @teamleader = ',,'
     SELECT @domicile = ',,'
     SELECT @mpptype1 = ',,'
     SELECT @mpptype2 = ',,'
     SELECT @mpptype3 = ',,'
     SELECT @mpptype4 = ',,'
     SELECT @trltype1 = ',,'
     SELECT @trltype2 = ',,'
     SELECT @trltype3 = ',,'
     SELECT @trltype4 = ',,'
END

--PTS32875 MBR 05/17/06
SELECT @UseShowAsShipperConsignee = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
  FROM generalinfo
 WHERE gi_name = 'UseShowAsShipperConsignee'

--vmj1+	If any values were passed in on the @terminal parm, use a faster select..
SELECT	@li_count = count(*)
  FROM	@terminal_table

 --PTS 37620 SGB Added select to get label name for company label
select @CompanyNameLabel = isnull((Select DISTINCT userlabelname from labelfile where  labeldefinition = 'Company'),'Company')
If @CompanyNameLabel = ''
BEGIN
	Select @CompanyNameLabel = 'Company'
END

IF @li_count > 0
BEGIN
	INSERT INTO	@TT
	SELECT	legheader.lgh_number,                     							-- 001
			legheader.stp_number_start,
			legheader.stp_number_end,
			company_a.cmp_id o_cmpid,
			company_a.cmp_name o_cmpname,
			lgh_startcty_nmstct o_ctyname,
			company_b.cmp_id d_cmpid,
			company_b.cmp_name d_cmpname,
			lgh_endcty_nmstct d_ctyname,
			--PTS32875 MBR 05/17/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_originpoint <> ord_showshipper AND ord_showshipper <> 'UNKNOWN' and ord_showshipper IS NOT NULL THEN
                                  ord_showshipper
                             ELSE orderheader.ord_originpoint END f_cmpid,		-- 010
			@varchar30 f_cmpname,
			--PTS32875 MBR 05/17/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_originpoint <> ord_showshipper AND ord_showshipper <> 'UNKNOWN' AND ord_showshipper IS NOT NULL THEN
			     (SELECT cmp_city from company where cmp_id = ord_showshipper)
			     ELSE orderheader.ord_origincity END f_ctycode,
			@varchar25 f_ctyname,
			--PTS32875 MBR 05/24/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_destpoint <> ord_showcons AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN
				  ord_showcons
			     ELSE orderheader.ord_destpoint END l_cmpid,
			@varchar30 l_cmpname,
			--PTS32875 MBR 05/24/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_destpoint <> ord_showcons AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN
			     (SELECT cmp_city FROM company WHERE cmp_id = ord_showcons)
			     ELSE orderheader.ord_destcity END l_ctycode,
			@varchar25 l_ctyname,
			legheader.lgh_startdate,
			legheader.lgh_enddate,
			lgh_startstate o_state,                                             -- 020
			lgh_endstate d_state,
			legheader.lgh_outstatus,
			legheader.lgh_instatus,
			legheader.lgh_priority,
			legheader.lgh_schdtearliest,
			legheader.lgh_schdtlatest,
			legheader.cmd_code,
			legheader.fgt_description,
			legheader.ord_hdrnumber,
			legheader.mpp_type1 mpp_type1,                                      -- 030
			legheader.mpp_type2 mpp_type2,
			legheader.mpp_type3 mpp_type3,
			legheader.mpp_type4 mpp_type4,
			legheader.mpp_teamleader mpp_teamleader,
			legheader.mpp_fleet mpp_fleet,
			legheader.mpp_division mpp_division,
			legheader.mpp_domicile mpp_domicile,
			legheader.mpp_company mpp_company,
			legheader.mpp_terminal mpp_terminal,
			@dt mpp_last_home,                                                  -- 040
			@dt mpp_want_home,
			legheader.lgh_class1,
			legheader.lgh_class2,
			legheader.lgh_class3,
			legheader.lgh_class4,
			legheader.trc_type1,
			legheader.trc_type2,
			legheader.trc_type3,
			legheader.trc_type4,
			legheader.trl_type1,                                                -- 050
			legheader.trl_type2,
			legheader.trl_type3,
			legheader.trl_type4,
			legheader.trc_company,
			legheader.trc_division,
			legheader.trc_fleet,
			legheader.trc_terminal,
			lgh_driver1 evt_driver1,
			lgh_driver2 evt_driver2,
			legheader.lgh_tractor evt_tractor,                                  -- 060
			legheader.lgh_primary_trailer,
			legheader.mov_number,
			orderheader.ord_number,
			lgh_startcity o_city,
			lgh_endcity d_city,
			'F' filtflag,
			@varchar20 outstatname ,
			@varchar20 instatname ,
			@varchar20 companyname ,
			@varchar20 trltype1name,                                            -- 070
			@varchar20 trltype1labelname ,
			@varchar20 revclass1name ,
			@varchar20 revclass2name ,
			@varchar20 revclass3name ,
			@varchar20 revclass4name ,
			@varchar20 revclass1labelname,
			@varchar20 revclass2labelname,
			@varchar20 revclass3labelname,
			@varchar20 revclass4labelname,
			@int pri1exp,                                                       -- 080
			@int pri1expsoon,
			@int pri2exp,
			@int pri2expsoon,
			@float loghours,
			@int drvstat,
			@int trcstat,
			orderheader.ord_bookedby,
			legheader.lgh_primary_pup,
			@char6 servicerule,
			@varchar20 trltype2name,                                            -- 090
			@varchar20 trltype2labelname ,
			@varchar20 trltype3name,
			@varchar20 trltype3labelname ,
			@varchar20 trltype4name,
			@varchar20 trltype4labelname,
			@varchar6 f_state,
			@varchar6 l_state,
			LEFT(m.mpp_lastfirst,45) mpp_lastfirst_1,
			--LEFT(m2.mpp_lastfirst,45) mpp_lastfirst_2,
			-- PTS 15524  DJM - used case so query doesn't always have overhead of extra join
			Case
				when lgh_driver2 = 'UNKNOWN' then 'UNKNOWN'
				else (select LEFT(mpp_lastfirst,45)
					from manpowerprofile
					where lgh_driver2 = manpowerprofile.mpp_id)
			End mpp_lastfirst_2,
			lgh_enddate_arrival,                                                -- 100
			lgh_dsp_date,
			lgh_geo_date,
			@char8 trc_driver,
			@dt p_date, /*trc_pln_date*/
			@char8 p_cmpid, /*trc_pln_cmp_id*/
			@varchar30 p_cmpname,
			CONVERT(INT, 0) p_ctycode, /*trc_pln_city*/
			@varchar25 p_ctyname,
			@char8 p_state,
			@varchar45 trc_gps_desc,
			@dt trc_gps_date,
			@dt trc_exp1_date,
			@dt trc_exp2_date,
			@dt trl_exp1_date,
			@dt trl_exp2_date,
			@dt mpp_exp1_date,
			@dt mpp_exp2_date,
			legheader.ord_totalweight tot_weight,
			legheader.tot_count tot_count,
	   		legheader.ord_totalvolume tot_volume,
			legheader.ordercount ordercount,
			npup_cmpid,
			npup_cmpname,
			npup_ctyname,
			npup_state,
			npup_arrivaldate,
			ndrp_cmpid,
			ndrp_cmpname,
			ndrp_ctyname,
			ndrp_state,
			ndrp_arrivaldate,
			legheader.can_cap_expires,
			legheader.lgh_startregion1,
			legheader.lgh_startregion2,
			legheader.lgh_startregion3,
			legheader.lgh_startregion4,
			legheader.lgh_endregion1,
			legheader.lgh_endregion2,
			legheader.lgh_endregion3,
			legheader.lgh_endregion4,
			legheader.lgh_feetavailable,
			orderheader.ord_fromorder,
			legheader.lgh_type1,
			legheader.lgh_type2,
			@varchar20 lgh_type1_name,
			@varchar20 lgh_type1_labelname,
			@varchar20 lgh_type2_name,
			@varchar20 lgh_type2_labelname,
			@char6 event,
			@char6 trc_prior_event,
			@varchar8 trc_prior_cmp_id,
			@int trc_prior_city,
			@varchar25 trc_prior_ctyname,
			@varchar6 trc_prior_state,
			@varchar6 trc_prior_region1,
			@varchar6 trc_prior_region2,
			@varchar6 trc_prior_region3,
			@varchar6 trc_prior_region4,
			@varchar30 trc_prior_cmp_name,
			@varchar6 trc_next_event,
			@varchar8 trc_next_cmp_id,
			@int trc_next_city,
			@varchar25 trc_next_ctyname,
			@varchar6 trc_next_state,
			@varchar6 trc_next_region1,
			@varchar6 trc_next_region2,
			@varchar6 trc_next_region3,
			@varchar6 trc_next_region4,
			@varchar30 trc_next_cmp_name,
			ISNULL(company_a.cmp_geoloc,'') o_cmp_geoloc,
			ISNULL(company_b.cmp_geoloc,'') d_cmp_geoloc,
			m.mpp_dailyhrsest,
			m.mpp_weeklyhrsest,
			m.mpp_lastlog_cmp_id,
			m.mpp_lastlog_cmp_name,
			m.mpp_lastlog_estdate,
			m.mpp_estlog_datetime,
			@varchar13 trc_trailer1,
			next_stp_event_code,
			next_stop_of_total,
			--vmj2+
			legheader.lgh_carrier evt_carrier,
			@varchar6 terminal,
			ord_completiondate,
			-- RE - 10/15/02 - PTS #15024
			CASE
				WHEN @LateWarnMode <> 'EVENT' THEN NULL
				ELSE ISNULL((SELECT	MIN(evt_latedate)
							   FROM	event e,
									stops s
							  WHERE	e.stp_number = s.stp_number AND
									s.lgh_number = legheader.lgh_number AND
									e.evt_status = 'OPN'), '20491231')
			END evt_latedate,
			@int drvpri1exp,
			@int drvpri1expsoon,
			@int drvpri2exp,
			@int drvpri2expsoon,
			@int trcpri1exp,
			@int trcpri1expsoon,
			@int trcpri2exp,
			@int trcpri2expsoon,
			@varchar20 trc_type1_t,
			@varchar20 trc_type1name,
			@varchar20 trc_type2_t,
			@varchar20 trc_type2name,
			@varchar20 trc_type3_t,
			@varchar20 trc_type3name,
			@varchar20 trc_type4_t,
			@varchar20 trc_type4name,
			--vmj6+
			legheader.lgh_etaalert1,
			--vmj6-
			@varchar20 drv_type1_t,
			@varchar20 drv_type1name,
			@varchar20 drv_type2_t,
			@varchar20 drv_type2name,
			@varchar20 drv_type3_t,
			@varchar20 drv_type3name,
			@varchar20 drv_type4_t,
			@varchar20 drv_type4name,
			@varchar20 drv_teamleader_t,
			@varchar20 drv_teamleadername,
			legheader.lgh_washplan lgh_washplan,
			legheader.lgh_nexttrailer1 lgh_nexttrailer1,
			legheader.lgh_nexttrailer2 lgh_nexttrailer2,
			legheader.lgh_detstatus lgh_detstatus,
			lgh_originzip,
			lgh_destzip,
			orderheader.ord_company,
			@varchar20 origin_servicezonename,
			@varchar20 origin_servicezone_labelname,
			@varchar20 origin_serviceareaname,
			@varchar20 origin_sericearea_labelname,
			@varchar20 origin_servicecentername,
			@varchar20 origin_servicecenter_labelname,
			@varchar20 origin_serviceregionname,
			@varchar20 origin_serviceregion_labelname ,
			@varchar20 dest_servicezonename,
			@varchar20 dest_servicezone_labelname,
			@varchar20 dest_serviceareaname,
			@varchar20 dest_sericearea_labelname,
			@varchar20 dest_servicecentername ,
			@varchar20 dest_servicecenter_labelname,
			@varchar20 dest_serviceregionname,
			@varchar20 dest_serviceregion_labelname,
			@float mpp_hours1_week,
			ROUND(isnull(company_b.cmp_latseconds,0.0000)/3600.000,4) 'dest_cmp_lat',
			ROUND(isnull(company_b.cmp_longseconds,0.0000)/3600.000,4) 'dest_cmp_long',
			0.0000 'dest_cty_lat',
			0.0000 'dest_cty_long',
			legheader.lgh_route lgh_route,
			legheader.lgh_booked_revtype1 lgh_booked_revtype1,
                        legheader.lgh_tm_status,
                        legheader.lgh_tm_statusname,
			m.mpp_alternatephone,
			legheader.lgh_comment,
			--PTS# 29650 ILB 10/07/2005
			@curr_avail_date current_avl_date,
        		@latest_avail_date latest_avl_date,
			--PTS# 29650 ILB 10/07/2005
			--PTS# 29623 ILB 11/14/2005
			lgh_trc_comment,
			--PTS# 29623 ILB 11/14/2005
			m.mpp_pta_date, --DPH PTS 32698
			orderheader.ord_billto,	-- DJM PTS 35482
-- PTS 32011 -- BL (start)
--	  FROM	@terminal_table tr inner join leheader_active legheader on legheader.trc_terminal = tr.trc_terminal
		@CompanyNameLabel,		-- SGB 37620,
		 '' trc_latest_ctyst,						-- PTS 38765
		 '' trc_latest_cmpid,
		 isNull(trcp.trc_lastpos_datetime, '1900/01/01') trc_last_mobcomm_received,
		 isNull(trcp.trc_mobcommtype,'UNKNOWN') trc_mobcomm_type,
 		 isNull(trcp.trc_lastpos_nearctynme,'UNKNOWN') trc_nearest_mobcomm_nmstct,	-- PTS 38765
		'' ord_reftype,--PTS 40883 JJF 20080212
		'' ord_refnum,  --PTS 40883 JJF 20080212
		 isNull(trcp.trc_lastpos_lat,0) trc_lastpos_lat,		-- PTS 42829 - DJM
		 isnull(trcp.trc_lastpos_long,0) trc_lastpos_long,		-- PTS 42829 - DJM
		 m.mpp_shift_start, /* 09/04/2008 MDH PTS 43538: Added */
		 m.mpp_shift_end	/* 09/04/2008 MDH PTS 43538: Added */
	  FROM	@terminal_table tr inner join legheader_active legheader on legheader.trc_terminal = tr.trc_terminal
-- PTS 32011 -- BL (end)
			inner join company company_a on legheader.cmp_id_start = company_a.cmp_id
			inner join company company_b on legheader.cmp_id_end = company_b.cmp_id
			left join orderheader on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
			inner join manpowerprofile m on legheader.lgh_driver1 = m.mpp_id
			inner join tractorprofile trcp on legheader.lgh_tractor = trcp.trc_number
			inner join trailerprofile trlp on legheader.lgh_primary_trailer = trlp.trl_id
			--legheader_active legheader,
			--company company_a,
			--orderheader,
	    		--company company_b,
			--manpowerprofile m,
			--tractorprofile trcp(index=pk_trc_number),
			--trailerprofile trlp(index=pk_id)
	 WHERE	--legheader.trc_terminal = tr.trc_terminal AND
			--cmp_id_start = company_a.cmp_id AND
			--cmp_id_end = company_b.cmp_id AND
			--change
			--legheader.ord_hdrnumber *= orderheader.ord_hdrnumber AND
			lgh_enddate >= @hoursbackdate AND
			lgh_enddate <= @hoursoutdate AND
			--lgh_driver1 = m.mpp_id AND
			(@drv_status = ',,' OR CHARINDEX(',' + m.mpp_status + ',', @drv_status) > 0) AND
			--lgh_tractor = trcp.trc_number AND
			--lgh_primary_trailer = trlp.trl_id AND
			(@city = 0 OR lgh_endcity = @city) AND
			(@driver = 'UNKNOWN' OR lgh_driver1 = @driver) AND
			(@tractor = 'UNKNOWN' OR lgh_tractor = @tractor) AND
			/*(@reg1 = 'UNK' OR lgh_endregion1 = @reg1) AND
			(@reg2 = 'UNK' OR lgh_endregion2 = @reg2) AND
			(@reg3 = 'UNK' OR lgh_endregion3 = @reg3) AND
			(@reg4 = 'UNK' OR lgh_endregion4 = @reg4) AND */
	  		(@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @reg1) > 0) AND
  			(@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @reg2) > 0) AND
  			(@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @reg3) > 0) AND
	  		(@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @reg4) > 0) AND
	  		(@cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + company_b.cmp_othertype1 + ',', @cmp_othertype1) > 0) AND   /* 02/15/2008 MDH PTS 39077: Added */
			lgh_instatus <> 'HST' AND -- PTS 14753, status can be other than UNP,PLN, or HST orig code - IN ('UNP', 'PLN') AND
			(@instatus = '' OR CHARINDEX(lgh_instatus, @instatus) > 0) AND
			lgh_outstatus IN (@avl, 'PLN', 'DSP', 'STD', 'CMP') AND
			(@status = '' OR CHARINDEX(lgh_outstatus, @status) > 0) AND
			(@states = '' OR CHARINDEX(lgh_endstate, @states) > 0) AND
			--(@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0 OR lgh_class1 IS NULL) AND
			--(@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0 OR lgh_class2 IS NULL) AND
			--(@revtype3 = ',,' OR @revtype3 = ',UNK,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0 OR lgh_class3 IS NULL) AND
			--(@revtype4 = ',,' OR @revtype4 = ',UNK,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0 OR lgh_class4 IS NULL) AND
			(@revtype1 = ',,' OR @revtype1 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class1,'UNK') + ',', @revtype1) > 0 ) AND
			(@revtype2 = ',,' OR @revtype2 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class2,'UNK') + ',', @revtype2) > 0 ) AND
			(@revtype3 = ',,' OR @revtype3 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class3,'UNK') + ',', @revtype3) > 0 ) AND
			(@revtype4 = ',,' OR @revtype4 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class4,'UNK') + ',', @revtype4) > 0 ) AND
			(@cmpids = ',,' OR CHARINDEX(',' + cmp_id_end + ',', @cmpids) > 0) AND
			(@trctype1 = ',,' OR CHARINDEX(',' + legheader.trc_type1 + ',', @trctype1) > 0) AND
			(@trctype2 = ',,' OR CHARINDEX(',' + legheader.trc_type2 + ',', @trctype2) > 0) AND
			(@trctype3 = ',,' OR CHARINDEX(',' + legheader.trc_type3 + ',', @trctype3) > 0) AND
			(@trctype4 = ',,' OR CHARINDEX(',' + legheader.trc_type4 + ',', @trctype4) > 0) AND
			(@fleet = ',,' OR CHARINDEX(',' + legheader.trc_fleet + ',', @fleet) > 0) AND
			(@division = ',,' OR CHARINDEX(',' + legheader.trc_division + ',', @division) > 0) AND
			(@company = ',,' OR CHARINDEX(',' + legheader.trc_company + ',', @company) > 0) AND
			(@mpptype1 = ',,' OR CHARINDEX(',' + legheader.mpp_type1 + ',', @mpptype1) > 0) AND
			(@mpptype2 = ',,' OR CHARINDEX(',' + legheader.mpp_type2 + ',', @mpptype2) > 0) AND
			(@mpptype3 = ',,' OR CHARINDEX(',' + legheader.mpp_type3 + ',', @mpptype3) > 0) AND
			(@mpptype4 = ',,' OR CHARINDEX(',' + legheader.mpp_type4 + ',', @mpptype4) > 0) AND
			(@teamleader = ',,' OR CHARINDEX(',' + legheader.mpp_teamleader + ',', @teamleader) > 0) AND
			(@domicile = ',,' OR CHARINDEX(',' + legheader.mpp_domicile + ',', @domicile) > 0) AND
			(@trltype1 = ',,' OR CHARINDEX(',' + legheader.trl_type1 + ',', @trltype1) > 0) AND
			(@trltype2 = ',,' OR CHARINDEX(',' + legheader.trl_type2 + ',', @trltype2) > 0) AND
			(@trltype3 = ',,' OR CHARINDEX(',' + legheader.trl_type3 + ',', @trltype3) > 0) AND
			(@trltype4 = ',,' OR CHARINDEX(',' + legheader.trl_type4 + ',', @trltype4) > 0) AND
			(@lgh_type1 = ',,' OR CHARINDEX(',' + lgh_type1 + ',', @lgh_type1) > 0 OR lgh_type1 IS NULL) AND
			(@lgh_type2 = ',,' OR CHARINDEX(',' + lgh_type2 + ',', @lgh_type2) > 0 OR lgh_type2 IS NULL or @lgh_type2 = ',UNK,') AND
			--(@lgh_type2 = ',,' OR (lgh_type2 IS not NULL and CHARINDEX(',' + lgh_type2 + ',', @lgh_type2) > 0 ))
			(@lgh_route = ',,' OR CHARINDEX(',' + lgh_route + ',', @lgh_route) > 0 OR lgh_route IS NULL) AND
			(@lgh_booked_revtype1 = ',UNK,' OR CHARINDEX(',' + lgh_booked_revtype1 + ',', @lgh_booked_revtype1) > 0  OR lgh_booked_revtype1 IS NULL )
		--vmj3+
		and	(@carrier = 'UNKNOWN'
			or lgh_carrier = @carrier) --AND
		--vmj3-
-- RE - PTS #42565 BEGIN
--		((m.mpp_qualificationlist Like @drv_qualifications) OR (@drv_qualifications = '')) AND
--		((trcp.trc_accessorylist Like @trc_accessories) OR (@trc_accessories = '')) AND
--		((trlp.trl_accessorylist Like @trl_accessories) OR (@trl_accessories = ''))
-- RE - PTS #42565
			AND (@billto = ',,' OR CHARINDEX(',' + orderheader.ord_billto + ',', @billto) > 0)
END
ELSE
BEGIN
	--Terminal values have not been passed as a criterion, use the slower select..
	--vmj1-
	INSERT INTO	@TT
	SELECT	legheader.lgh_number,
			legheader.stp_number_start,
			legheader.stp_number_end,
			company_a.cmp_id o_cmpid,
			company_a.cmp_name o_cmpname,
			lgh_startcty_nmstct o_ctyname,
			company_b.cmp_id d_cmpid,
			company_b.cmp_name d_cmpname,
			lgh_endcty_nmstct d_ctyname,
			--PTS32875 MBR 05/17/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_shipper <> ord_showshipper AND ord_showshipper <> 'UNKNOWN' and ord_showshipper IS NOT NULL THEN
                                  ord_showshipper
                             ELSE orderheader.ord_originpoint END f_cmpid,
			@varchar30 f_cmpname,
			--PTS32875 MBR 05/17/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_originpoint <> ord_showshipper AND ord_showshipper <> 'UNKNOWN' AND ord_showshipper IS NOT NULL THEN
			     (SELECT cmp_city from company where cmp_id = ord_showshipper)
			     ELSE orderheader.ord_origincity END f_ctycode,
			@varchar25 f_ctyname,
			--PTS32875 MBR 05/24/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_destpoint <> ord_showcons AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN
				  ord_showcons
			     ELSE orderheader.ord_destpoint END l_cmpid,
			@varchar30 l_cmpname,
			--PTS32875 MBR 05/24/06
			CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_destpoint <> ord_showcons AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN
			     (SELECT cmp_city FROM company WHERE cmp_id = ord_showcons)
			     ELSE orderheader.ord_destcity END l_ctycode,
			@varchar25 l_ctyname,
			legheader.lgh_startdate,
			legheader.lgh_enddate,
			lgh_startstate o_state,
			lgh_endstate d_state,
			legheader.lgh_outstatus,
			legheader.lgh_instatus,
			legheader.lgh_priority,
			legheader.lgh_schdtearliest,
			legheader.lgh_schdtlatest,
			legheader.cmd_code,
			legheader.fgt_description,
			legheader.ord_hdrnumber,
			legheader.mpp_type1 mpp_type1,
			legheader.mpp_type2 mpp_type2,
			legheader.mpp_type3 mpp_type3,
			legheader.mpp_type4 mpp_type4,
			legheader.mpp_teamleader mpp_teamleader,
			legheader.mpp_fleet mpp_fleet,
			legheader.mpp_division mpp_division,
			legheader.mpp_domicile mpp_domicile,
			legheader.mpp_company mpp_company,
			legheader.mpp_terminal mpp_terminal,
			@dt mpp_last_home,
			@dt mpp_want_home,
			legheader.lgh_class1,
			legheader.lgh_class2,
			legheader.lgh_class3,
			legheader.lgh_class4,
			legheader.trc_type1,
			legheader.trc_type2,
			legheader.trc_type3,
			legheader.trc_type4,
			legheader.trl_type1,
			legheader.trl_type2,
			legheader.trl_type3,
			legheader.trl_type4,
			legheader.trc_company,
			legheader.trc_division,
			legheader.trc_fleet,
			legheader.trc_terminal,
			lgh_driver1 evt_driver1,
			lgh_driver2 evt_driver2,
			legheader.lgh_tractor evt_tractor,
			legheader.lgh_primary_trailer,
			legheader.mov_number,
			orderheader.ord_number,
			lgh_startcity o_city,
			lgh_endcity d_city,
			'F' filtflag,
			@varchar20 outstatname ,
			@varchar20 instatname ,
			@varchar20 companyname ,
			@varchar20 trltype1name,
			@varchar20 trltype1labelname ,
			@varchar20 revclass1name ,
			@varchar20 revclass2name ,
			@varchar20 revclass3name ,
			@varchar20 revclass4name ,
			@varchar20 revclass1labelname,
			@varchar20 revclass2labelname,
			@varchar20 revclass3labelname,
			@varchar20 revclass4labelname,
			@int pri1exp,
			@int pri1expsoon,
			@int pri2exp,
			@int pri2expsoon,
			@float loghours,
			@int drvstat,
			@int trcstat,
			orderheader.ord_bookedby,
			legheader.lgh_primary_pup,
			@char6 servicerule,
			@varchar20 trltype2name,
			@varchar20 trltype2labelname ,
			@varchar20 trltype3name,
			@varchar20 trltype3labelname ,
			@varchar20 trltype4name,
			@varchar20 trltype4labelname,
			@varchar6 f_state,
			@varchar6 l_state,
			LEFT(m.mpp_lastfirst,45) mpp_lastfirst_1,
			--LEFT(m2.mpp_lastfirst,45) mpp_lastfirst_2,
			-- PTS 15524  DJM - used case so query doesn't always have overhead of extra join
			Case
				when lgh_driver2 = 'UNKNOWN' then 'UNKNOWN'
				else (select LEFT(mpp_lastfirst,45)
					from manpowerprofile
					where lgh_driver2 = manpowerprofile.mpp_id)
			End mpp_lastfirst_2,
			lgh_enddate_arrival,
			lgh_dsp_date,
			lgh_geo_date,
			@char8 trc_driver,
			@dt p_date, /*trc_pln_date*/
			@char8 p_cmpid, /*trc_pln_cmp_id*/
			@varchar30 p_cmpname,
			CONVERT(INT, 0)	p_ctycode, /*trc_pln_city*/
			@varchar25 p_ctyname,
			@char8 p_state,
			@varchar45 trc_gps_desc,
			@dt trc_gps_date,
			@dt trc_exp1_date,
			@dt trc_exp2_date,
			@dt trl_exp1_date,
			@dt trl_exp2_date,
			@dt mpp_exp1_date,
			@dt mpp_exp2_date,
			legheader.ord_totalweight tot_weight,
			legheader.tot_count tot_count,
	   		legheader.ord_totalvolume tot_volume,
			legheader.ordercount ordercount,
			npup_cmpid,
			npup_cmpname,
			npup_ctyname,
			npup_state,
			npup_arrivaldate,
			ndrp_cmpid,
			ndrp_cmpname,
			ndrp_ctyname,
			ndrp_state,
			ndrp_arrivaldate,
			legheader.can_cap_expires,
			legheader.lgh_startregion1,
			legheader.lgh_startregion2,
			legheader.lgh_startregion3,
			legheader.lgh_startregion4,
			legheader.lgh_endregion1,
			legheader.lgh_endregion2,
			legheader.lgh_endregion3,
			legheader.lgh_endregion4,
			legheader.lgh_feetavailable,
			orderheader.ord_fromorder,
			legheader.lgh_type1,
			legheader.lgh_type2,
			@varchar20 lgh_type1_name,
			@varchar20 lgh_type1_labelname,
			@varchar20 lgh_type2_name,
			@varchar20 lgh_type2_labelname,
			@char6 event,
			@char6 trc_prior_event,
			@varchar8 trc_prior_cmp_id,
			@int trc_prior_city,
			@varchar25 trc_prior_ctyname,
			@varchar6 trc_prior_state,
			@varchar6 trc_prior_region1,
			@varchar6 trc_prior_region2,
			@varchar6 trc_prior_region3,
			@varchar6 trc_prior_region4,
			@varchar30 trc_prior_cmp_name,
			@varchar6 trc_next_event,
			@varchar8 trc_next_cmp_id,
			@int trc_next_city,
			@varchar25 trc_next_ctyname,
			@varchar6 trc_next_state,
			@varchar6 trc_next_region1,
			@varchar6 trc_next_region2,
			@varchar6 trc_next_region3,
			@varchar6 trc_next_region4,
			@varchar30 trc_next_cmp_name,
			ISNULL(company_a.cmp_geoloc,'') o_cmp_geoloc,
			ISNULL(company_b.cmp_geoloc,'') d_cmp_geoloc,
			m.mpp_dailyhrsest,
			m.mpp_weeklyhrsest,
			m.mpp_lastlog_cmp_id,
			m.mpp_lastlog_cmp_name,
			m.mpp_lastlog_estdate,
			m.mpp_estlog_datetime,
			@varchar13 trc_trailer1,
			next_stp_event_code,
			next_stop_of_total,
			--vmj2+
			legheader.lgh_carrier evt_carrier,
			@varchar6 terminal,
			ord_completiondate,
			-- RE - 10/15/02 - PTS #15024
			CASE
				WHEN @LateWarnMode <> 'EVENT' THEN NULL
				ELSE ISNULL((SELECT	MIN(evt_latedate)
							   FROM	event e,
									stops s
							  WHERE	e.stp_number = s.stp_number AND
									s.lgh_number = legheader.lgh_number AND
									e.evt_status = 'OPN'), '20491231')
			END evt_latedate,
			@int drvpri1exp,
			@int drvpri1expsoon,
			@int drvpri2exp,
			@int drvpri2expsoon,
			@int trcpri1exp,
			@int trcpri1expsoon,
			@int trcpri2exp,
			@int trcpri2expsoon,
			@varchar20 trc_type1_t,
			@varchar20 trc_type1name,
			@varchar20 trc_type2_t,
			@varchar20 trc_type2name,
			@varchar20 trc_type3_t,
			@varchar20 trc_type3name,
			@varchar20 trc_type4_t,
			@varchar20 trc_type4name,
			--vmj6+
			legheader.lgh_etaalert1,
			--vmj6-
			@varchar20 drv_type1_t,
			@varchar20 drv_type1name,
			@varchar20 drv_type2_t,
			@varchar20 drv_type2name,
			@varchar20 drv_type3_t,
			@varchar20 drv_type3name,
			@varchar20 drv_type4_t,
			@varchar20 drv_type4name,
			@varchar20 drv_teamleader_t,
			@varchar20 drv_teamleadername,
			legheader.lgh_washplan lgh_washplan,
			legheader.lgh_nexttrailer1 lgh_nexttrailer1,
			legheader.lgh_nexttrailer2 lgh_nexttrailer2,
			legheader.lgh_detstatus lgh_detstatus,
			lgh_originzip,
			lgh_destzip,
			orderheader.ord_company,
			@varchar20 origin_servicezonename,
			@varchar20 origin_servicezone_labelname,
			@varchar20 origin_serviceareaname,
			@varchar20 origin_sericearea_labelname,
			@varchar20 origin_servicecentername,
			@varchar20 origin_servicecenter_labelname,
			@varchar20 origin_serviceregionname,
			@varchar20 origin_serviceregion_labelname ,
			@varchar20 dest_servicezonename,
			@varchar20 dest_servicezone_labelname,
			@varchar20 dest_serviceareaname,
			@varchar20 dest_sericearea_labelname,
			@varchar20 dest_servicecentername ,
			@varchar20 dest_servicecenter_labelname,
			@varchar20 dest_serviceregionname,
			@varchar20 dest_serviceregion_labelname,
			@float mpp_hours1_week,
			ROUND(isnull(company_b.cmp_latseconds,0.0000)/3600.000,4) 'dest_cmp_lat',
			ROUND(isnull(company_b.cmp_longseconds,0.0000)/3600.000,4) 'dest_cmp_long',
			0.0000 'dest_cty_lat',
			0.0000 'dest_cty_long',
			legheader.lgh_route lgh_route,
			legheader.lgh_booked_revtype1,
                        legheader.lgh_tm_status,
                        legheader.lgh_tm_statusname,
			m.mpp_alternatephone,
			legheader.lgh_comment,
                         --PTS# 29650 ILB 10/07/2005
			@curr_avail_date current_avl_date,
        		@latest_avail_date latest_avl_date,
			--PTS# 29650 ILB 10/07/2005
			--PTS# 29623 ILB 11/14/2005
			lgh_trc_comment,
			--PTS# 29623 ILB 11/14/2005
			m.mpp_pta_date, --DPH PTS 32698
			orderheader.ord_billto,	-- DJM PTS 35482
			@CompanyNameLabel,	  -- SGB 37620
		 '' trc_latest_ctyst,						-- PTS 38765
		 '' trc_latest_cmpid,
		 isNull(trcp.trc_lastpos_datetime, '1900/01/01') trc_last_mobcomm_received,
		 isNull(trcp.trc_mobcommtype,'UNKNOWN') trc_mobcomm_type,
		 		 isNull(trcp.trc_lastpos_nearctynme,'UNKNOWN') trc_nearest_mobcomm_nmstct,	-- PTS 38765
			'' ord_reftype,--PTS 40883 JJF 20080212
			'' ord_refnum,  --PTS 40883 JJF 20080212
		 isNull(trcp.trc_lastpos_lat,0) trc_lastpos_lat,	-- PTS 42829
		 isnull(trcp.trc_lastpos_long,0) trc_lastpos_long,	-- PTS 42829
		 m.mpp_shift_start, /* 09/04/2008 MDH PTS 43538: Added */
		 m.mpp_shift_end	/* 09/04/2008 MDH PTS 43538: Added */
	  FROM	legheader_active legheader inner join company company_a on legheader.cmp_id_start = company_a.cmp_id
			inner join company company_b on legheader.cmp_id_end = company_b.cmp_id
			left join orderheader on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
			inner join manpowerprofile m on legheader.lgh_driver1 = m.mpp_id
			inner join tractorprofile trcp on legheader.lgh_tractor = trcp.trc_number
			inner join trailerprofile trlp on legheader.lgh_primary_trailer = trlp.trl_id
			--company company_a,
			--legheader_active legheader ,
			--orderheader,
			--company company_b,
			--manpowerprofile m,
			--tractorprofile trcp(index=pk_trc_number),
			--trailerprofile trlp(index=pk_id)
	 WHERE	--cmp_id_start = company_a.cmp_id AND
			--cmp_id_end = company_b.cmp_id AND
			--change
			--legheader.ord_hdrnumber *= orderheader.ord_hdrnumber AND
			lgh_enddate >= @hoursbackdate AND
			lgh_enddate <= @hoursoutdate AND
			--lgh_driver1 = m.mpp_id AND
			(@drv_status = ',,' OR CHARINDEX(',' + m.mpp_status + ',', @drv_status) > 0) AND
			--lgh_tractor = trcp.trc_number AND
			--lgh_primary_trailer = trlp.trl_id AND
			(@city = 0 OR lgh_endcity = @city) AND
			(@driver = 'UNKNOWN' OR lgh_driver1 = @driver) AND
			(@tractor = 'UNKNOWN' OR lgh_tractor = @tractor) AND
			/*(@reg1 = 'UNK' OR lgh_endregion1 = @reg1) AND
			(@reg2 = 'UNK' OR lgh_endregion2 = @reg2) AND
			(@reg3 = 'UNK' OR lgh_endregion3 = @reg3) AND
			(@reg4 = 'UNK' OR lgh_endregion4 = @reg4) AND */
 			(@reg1 = ',UNK,' OR CHARINDEX(',' + lgh_endregion1 + ',', @reg1) > 0) AND
 	 		(@reg2 = ',UNK,' OR CHARINDEX(',' + lgh_endregion2 + ',', @reg2) > 0) AND
	 		(@reg3 = ',UNK,' OR CHARINDEX(',' + lgh_endregion3 + ',', @reg3) > 0) AND
  			(@reg4 = ',UNK,' OR CHARINDEX(',' + lgh_endregion4 + ',', @reg4) > 0)  AND
	  		(@cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + company_b.cmp_othertype1 + ',', @cmp_othertype1) > 0) AND   /* 02/15/2008 MDH PTS 39077: Added */
			lgh_instatus <> 'HST' AND -- PTS 14753, status can be other than UNP,PLN, or HST orig code - IN ('UNP', 'PLN') AND
			(@instatus = '' OR CHARINDEX(lgh_instatus, @instatus) > 0) AND
			lgh_outstatus IN (@avl, 'PLN', 'DSP', 'STD', 'CMP') AND
			(@status = '' OR CHARINDEX(lgh_outstatus, @status) > 0) AND
			(@states = '' OR CHARINDEX(lgh_endstate, @states) > 0) AND
			--(@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0 OR lgh_class1 IS NULL) AND
			--(@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0 OR lgh_class2 IS NULL) AND
			--(@revtype3 = ',,' OR @revtype3 = ',UNK,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0 OR lgh_class3 IS NULL) AND
			--(@revtype4 = ',,' OR @revtype4 = ',UNK,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0 OR lgh_class4 IS NULL) AND
			(@revtype1 = ',,' OR @revtype1 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class1,'UNK') + ',', @revtype1) > 0 ) AND
			(@revtype2 = ',,' OR @revtype2 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class2,'UNK') + ',', @revtype2) > 0 ) AND
			(@revtype3 = ',,' OR @revtype3 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class3,'UNK') + ',', @revtype3) > 0 ) AND
			(@revtype4 = ',,' OR @revtype4 = ',UNK,' OR CHARINDEX(',' + IsNull(lgh_class4,'UNK') + ',', @revtype4) > 0 ) AND
			(@cmpids = ',,' OR CHARINDEX(',' + cmp_id_end + ',', @cmpids) > 0) AND
			(@trctype1 = ',,' OR CHARINDEX(',' + legheader.trc_type1 + ',', @trctype1) > 0) AND
			(@trctype2 = ',,' OR CHARINDEX(',' + legheader.trc_type2 + ',', @trctype2) > 0) AND
			(@trctype3 = ',,' OR CHARINDEX(',' + legheader.trc_type3 + ',', @trctype3) > 0) AND
			(@trctype4 = ',,' OR CHARINDEX(',' + legheader.trc_type4 + ',', @trctype4) > 0) AND
			(@fleet = ',,' OR CHARINDEX(',' + legheader.trc_fleet + ',', @fleet) > 0) AND
			(@division = ',,' OR CHARINDEX(',' + legheader.trc_division + ',', @division) > 0) AND
			(@company = ',,' OR CHARINDEX(',' + legheader.trc_company + ',', @company) > 0) AND
			(@terminal = ',,' OR CHARINDEX(',' + legheader.trc_terminal + ',', @terminal) > 0) AND
			(@mpptype1 = ',,' OR CHARINDEX(',' + legheader.mpp_type1 + ',', @mpptype1) > 0) AND
			(@mpptype2 = ',,' OR CHARINDEX(',' + legheader.mpp_type2 + ',', @mpptype2) > 0) AND
			(@mpptype3 = ',,' OR CHARINDEX(',' + legheader.mpp_type3 + ',', @mpptype3) > 0) AND
			(@mpptype4 = ',,' OR CHARINDEX(',' + legheader.mpp_type4 + ',', @mpptype4) > 0) AND
			(@teamleader = ',,' OR CHARINDEX(',' + legheader.mpp_teamleader + ',', @teamleader) > 0) AND
			(@domicile = ',,' OR CHARINDEX(',' + legheader.mpp_domicile + ',', @domicile) > 0) AND
			(@trltype1 = ',,' OR CHARINDEX(',' + legheader.trl_type1 + ',', @trltype1) > 0) AND
			(@trltype2 = ',,' OR CHARINDEX(',' + legheader.trl_type2 + ',', @trltype2) > 0) AND
			(@trltype3 = ',,' OR CHARINDEX(',' + legheader.trl_type3 + ',', @trltype3) > 0) AND
			(@trltype4 = ',,' OR CHARINDEX(',' + legheader.trl_type4 + ',', @trltype4) > 0) AND
			(@lgh_type1 = ',,' OR CHARINDEX(',' + lgh_type1 + ',', @lgh_type1) > 0 OR lgh_type1 IS NULL) AND
			(@lgh_type2 = ',,' OR CHARINDEX(',' + lgh_type2 + ',', @lgh_type2) > 0 OR lgh_type2 IS NULL or @lgh_type2 = ',UNK,') AND
			--(@lgh_type2 = ',,' OR (lgh_type2 IS not NULL and CHARINDEX(',' + lgh_type2 + ',', @lgh_type2) > 0 ))
			(@lgh_route = ',,' OR CHARINDEX(',' + lgh_route + ',', @lgh_route) > 0 OR lgh_route IS NULL) AND
			(@lgh_booked_revtype1 = ',UNK,' OR CHARINDEX(',' + lgh_booked_revtype1 + ',', @lgh_booked_revtype1) > 0  OR lgh_booked_revtype1 IS NULL )
		--vmj3+
		and	(@carrier = 'UNKNOWN'
			or lgh_carrier = @carrier) --AND
		--vmj3-
-- RE - PTS #42565 BEGIN
--		((m.mpp_qualificationlist Like @drv_qualifications) OR (@drv_qualifications = '')) AND
--		((trcp.trc_accessorylist Like @trc_accessories) OR (@trc_accessories = '')) AND
--		((trlp.trl_accessorylist Like @trl_accessories) OR (@trl_accessories = ''))	--vmj1+
-- RE - PTS #42565 END
			AND (@billto = ',,' OR CHARINDEX(',' + orderheader.ord_billto + ',', @billto) > 0) -- PTS 35482 - DJM
END
--vmj1-

/*mf 11/12/97 added temp table for labelfile because sometimes
	it would select to do the label file first resulting in 10,000 IOs on @TT */
INSERT INTO  @l_mpp
	SELECT	name,
			abbr,
			code
	  FROM	labelfile
	 WHERE	labeldefinition = 'DrvStatus'

INSERT INTO  @l_trc
	SELECT	name,
			abbr,
			code
	  FROM	labelfile
	 WHERE	labeldefinition = 'TrcStatus'

-- LOR
INSERT INTO	@TT1
	SELECT	TT.lgh_number,
			TT.stp_number_start,
			tt.stp_number_end,
			TT.o_cmpid,
			TT.o_cmpname,
			TT.o_ctyname,
			TT.d_cmpid,
			TT.d_cmpname,
			TT.d_ctyname,
			TT.f_cmpid,
			TT.f_cmpname,
			TT.f_ctycode,
			TT.f_ctyname,
			TT.l_cmpid,
			TT.l_cmpname,
			TT.l_ctycode,
			TT.l_ctyname,
			TT.lgh_startdate,
			TT.lgh_enddate,
			TT.o_state,
			TT.d_state,
			TT.lgh_outstatus,
			TT.lgh_instatus,
			TT.lgh_priority,
			TT.lgh_schdtearliest,
			TT.lgh_schdtlatest,
			TT.cmd_code,
			TT.fgt_description,
			TT.ord_hdrnumber,
			TT.mpp_type1 mpp_type1,
			TT.mpp_type2 mpp_type2,
			TT.mpp_type3 mpp_type3,
			TT.mpp_type4 mpp_type4,
			TT.mpp_teamleader mpp_teamleader,
			TT.mpp_fleet mpp_fleet,
			TT.mpp_division mpp_division,
			TT.mpp_domicile mpp_domicile,
			TT.mpp_company mpp_company,
			TT.mpp_terminal mpp_terminal,
			TT.mpp_last_home,
			TT.mpp_want_home,
			TT.lgh_class1,
			TT.lgh_class2,
			TT.lgh_class3,
			TT.lgh_class4,
			TT.trc_type1,
			TT.trc_type2,
			TT.trc_type3,
			TT.trc_type4,
			TT.trl_type1,
			TT.trl_type2,
			TT.trl_type3,
			TT.trl_type4,
			TT.trc_company,
			TT.trc_division,
			TT.trc_fleet,
			TT.trc_terminal,
			TT.evt_driver1,
			TT.evt_driver2,
			TT.evt_tractor,
			TT.lgh_primary_trailer,
			TT.mov_number,
			TT.ord_number,
			TT.o_city,
			TT.d_city,
			TT.filtflag,
			TT.outstatname ,
			TT.instatname ,
			TT.companyname ,
			TT.trltype1name,
			TT.trltype1labelname ,
			TT.revclass1name ,
			TT.revclass2name ,
			TT.revclass3name ,
			TT.revclass4name ,
			TT.revclass1labelname,
			TT.revclass2labelname,
			TT.revclass3labelname,
			TT.revclass4labelname,
			TT.pri1exp,
			TT.pri1expsoon,
			TT.pri2exp,
			TT.pri2expsoon,
			TT.loghours,
			TT.drvstat,
			TT.trcstat,
			TT.ord_bookedby,
			TT.lgh_primary_pup,
			TT.servicerule,
			TT.trltype2name,
			TT.trltype2labelname ,
			TT.trltype3name,
			TT.trltype3labelname ,
			TT.trltype4name,
			TT.trltype4labelname,
			TT.f_state,
			TT.l_state,
			TT.mpp_lastfirst_1,
			TT.mpp_lastfirst_2,
			TT.lgh_enddate_arrival,
			TT.lgh_dsp_date,
			TT.lgh_geo_date,
			TT.trc_driver,
			TT.p_date, /*trc_pln_date*/
			TT.p_cmpid, /*trc_pln_cmp_id*/
			TT.p_cmpname,
			TT.p_ctycode, /*trc_pln_city*/
			TT.p_ctyname,
			TT.p_state,
			TT.trc_gps_desc,
			TT.trc_gps_date,
			TT.trc_exp1_date,
			TT.trc_exp2_date,
			TT.trl_exp1_date,
			TT.trl_exp2_date,
			TT.mpp_exp1_date,
			TT.mpp_exp2_date,
			TT.tot_weight,
			TT.tot_count,
	   		TT.tot_volume,
			TT.ordercount,
			TT.npup_cmpid,
			TT.npup_cmpname,
			TT.npup_ctyname,
			TT.npup_state,
			TT.npup_arrivaldate,
			TT.ndrp_cmpid,
			TT.ndrp_cmpname,
			TT.ndrp_ctyname,
			TT.ndrp_state,
			TT.ndrp_arrivaldate,
			TT.can_cap_expires,
			TT.ord_originregion1,
			TT.ord_originregion2,
			TT.ord_originregion3,
			TT.ord_originregion4,
			TT.ord_destregion1,
			TT.ord_destregion2,
			TT.ord_destregion3,
			TT.ord_destregion4,
			TT.lgh_feetavailable,
			TT.ord_fromorder,
			TT.lgh_type1,
			TT.lgh_type2,
			TT.lgh_type1_name,
			TT.lgh_type1_labelname,
			TT.lgh_type2_name,
			TT.lgh_type2_labelname,
			@char6 event,
			tractorprofile.trc_prior_event,
			tractorprofile.trc_prior_cmp_id,
			tractorprofile.trc_prior_city,
			@varchar25 trc_prior_ctyname,
			tractorprofile.trc_prior_state,
			tractorprofile.trc_prior_region1,
			tractorprofile.trc_prior_region2,
			tractorprofile.trc_prior_region3,
			tractorprofile.trc_prior_region4,
			@varchar30 trc_prior_cmp_name,
			tractorprofile.trc_next_event,
			tractorprofile.trc_next_cmp_id,
			tractorprofile.trc_next_city,
			@varchar25 trc_next_ctyname,
			tractorprofile.trc_next_state,
			tractorprofile.trc_next_region1,
			tractorprofile.trc_next_region2,
			tractorprofile.trc_next_region3,
			tractorprofile.trc_next_region4,
			@varchar30 trc_next_cmp_name,
			TT.o_cmp_geoloc,
			TT.d_cmp_geoloc,
			'' mpp_fleet_name,
			mpp_dailyhrsest,
			mpp_weeklyhrsest,
			mpp_lastlog_cmp_id,
			mpp_lastlog_cmp_name,
			mpp_lastlog_estdate,
			mpp_estlog_datetime,
			TT.trc_trailer1 ,
			@varchar6	mpp_next_exp_code,
			@varchar20	mpp_next_exp_name,
			@dt 		mpp_next_exp_date,
			@dt		mpp_next_exp_compldate,
			TT.next_stp_event_code,
			TT.next_stop_of_total,
			--vmj2+
			TT.evt_carrier,
			tractorprofile.trc_terminal,
			TT.ord_completiondate,
			@varchar6 	last_stop_dep_status,
			TT.evt_latedate,
			@varchar20	mpp_status_desc,
			TT.drvpri1exp,
			TT.drvpri1expsoon,
			TT.drvpri2exp,
			TT.drvpri2expsoon,
			TT.trcpri1exp,
			TT.trcpri1expsoon,
			TT.trcpri2exp,
			TT.trcpri2expsoon,
			trc_gps_latitude,
			trc_gps_longitude,
			tt.trc_type1_t,
			tt.trc_type1name,
			tt.trc_type2_t,
			tt.trc_type2name,
			tt.trc_type3_t,
			tt.trc_type3name,
			tt.trc_type4_t,
			tt.trc_type4name,
			--vmj6+
			tt.lgh_etaalert1,
			--vmj6-
			drv_type1_t,
			drv_type1name,
			drv_type2_t,
			drv_type2name,
			drv_type3_t,
			drv_type3name,
			drv_type4_t,
			drv_type4name,
			drv_teamleader_t,
			drv_teamleadername,
			TT.lgh_washplan,
			TT.lgh_nexttrailer1,
			TT.lgh_nexttrailer2,
			TT.lgh_detstatus,
			TT.lgh_originzip,
			TT.lgh_destzip,
			ord_company,
			tt.origin_servicezonename,
			tt.origin_servicezone_labelname,
			tt.origin_serviceareaname,
			tt.origin_sericearea_labelname,
			tt.origin_servicecentername,
			tt.origin_servicecenter_labelname,
			tt.origin_serviceregionname,
			tt.origin_serviceregion_labelname,
			tt.dest_servicezonename,
			tt.dest_servicezone_labelname,
			tt.dest_serviceareaname,
			tt.dest_sericearea_labelname,
			tt.dest_servicecentername ,
			tt.dest_servicecenter_labelname,
			tt.dest_serviceregionname,
			tt.dest_serviceregion_labelname,
			tt.mpp_hours1_week,
			tt.dest_cmp_lat,
			tt.dest_cmp_long,
			tt.dest_cty_lat,
			tt.dest_cty_long,
			tt.lgh_route,
			tt.lgh_booked_revtype1,
                        tt.lgh_tm_status,
                        tt.lgh_tm_statusname,
			tt.mpp_alternatephone,
			tt.lgh_comment,
                        --PTS# 29650 ILB 10/07/2005
			@curr_avail_date current_avl_date,
        		@latest_avail_date latest_avl_date,
			--PTS# 29650 ILB 10/07/2005
			--PTS# 29623 ILB 11/14/2005
			lgh_trc_comment,
			--PTS# 29623 ILB 11/14/2005
			tt.mpp_pta_date, --DPH PTS 32698
            'N' as exp_affects_avail_dtm,  --JLB PTS 35133
             0  TimeZoneAdjMins,  --35747
			tt.ord_billto,	-- PTS 35482 - DJM
			@CompanyNameLabel,  -- SGB 37620
			tt.trc_latest_ctyst,									-- PTS 38765
			tt.trc_latest_cmpid,
			tt.trc_last_mobcomm_received,
			tt.trc_mobcomm_type,
			tt.trc_nearest_mobcomm_nmstct,								-- PTS 38765
			tractorprofile.trc_comment1,
			TT.ord_reftype,--PTS 40883 JJF 20080212
			TT.ord_refnum,  --PTS 40883 JJF 20080212
			 isNull(tt.trc_lastpos_lat,0) trc_lastpos_lat,	-- PTS 42829
			 isnull(tt.trc_lastpos_long,0) trc_lastpos_long,	-- PTS 42829
		 	tt.drv1_shift_start, /* 09/04/2008 MDH PTS 43538: Added */
		 	tt.drv1_shift_end	/* 09/04/2008 MDH PTS 43538: Added */

	  FROM	@TT TT inner join tractorprofile on TT.evt_tractor = tractorprofile.trc_number
	 WHERE	(@last_event = '' OR CHARINDEX(@last_event, tractorprofile.trc_prior_event) > 0) AND
			(@d_states = '' OR CHARINDEX(@d_states, tractorprofile.trc_prior_state) > 0) AND
			(@d_city = 0 OR tractorprofile.trc_prior_city = @d_city) AND
			(@d_cmpids = ',,' OR CHARINDEX(',' + tractorprofile.trc_prior_cmp_id + ',', @d_cmpids) > 0) AND
			(@d_reg1 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_prior_region1 + ',', @d_reg1) > 0) AND
			(@d_reg2 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_prior_region2 + ',', @d_reg2) > 0) AND
			(@d_reg3 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_prior_region3 + ',', @d_reg3) > 0) AND
			(@d_reg4 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_prior_region4 + ',', @d_reg4) > 0) AND
			(@prior_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_prior_cmp_othertype1 + ',', @prior_cmp_othertype1) > 0) AND /* 02/22/2008 MDH PTS 39077: Added */
			---TT.trc_prior_cmp_id *= company_prior.cmp_id AND
			(@next_event = '' OR CHARINDEX(@next_event, tractorprofile.trc_next_event) > 0) AND
			(@next_state = '' OR CHARINDEX(@next_state, tractorprofile.trc_next_state) > 0) AND
			(@next_city = 0 OR tractorprofile.trc_next_city = @next_city) AND
			(@next_cmp_id = ',,' OR CHARINDEX(',' + tractorprofile.trc_next_cmp_id + ',', @next_cmp_id) > 0) AND
			(@next_region1 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_next_region1 + ',', @next_region1) > 0) AND
			(@next_region2 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_next_region2 + ',', @next_region2) > 0) AND
			(@next_region3 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_next_region3 + ',', @next_region3) > 0) AND
			(@next_region4 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_next_region4 + ',', @next_region4) > 0) AND
			(@next_cmp_othertype1 = ',UNK,' OR CHARINDEX(',' + tractorprofile.trc_next_cmp_othertype1 + ',', @next_cmp_othertype1) > 0) 	/* 02/22/2008 MDH PTS 39077: Added */
			---TT.trc_next_cmp_id *= company_next.cmp_id

/* pts 10056 DSK 5/29/01 use the trailer on the tractorprofile instead of the primary trailer on the legheader */
 UPDATE	TT1
   SET		
--TT1.mpp_last_home = manpowerprofile.mpp_last_home,
--		TT1.mpp_want_home = manpowerprofile.mpp_want_home,
--		TT1.drvstat = l_mpp.code,
--		TT1.mpp_status_desc = l_mpp.name,
	    	TT1.trcstat = l_trc.code,
--		TT1.servicerule = manpowerprofile.mpp_servicerule,
	    --	trc_gps_desc = tractorprofile.trc_gps_desc,
	--	trc_gps_date = tractorprofile.trc_gps_date,
	--	trc_driver = tractorprofile.trc_driver,
		p_date = tractorprofile.trc_pln_date,
		p_cmpid = tractorprofile.trc_pln_cmp_id,
		p_ctycode = tractorprofile.trc_pln_city,
		trc_exp1_date = tractorprofile.trc_exp1_date,
		trc_exp2_date = tractorprofile.trc_exp2_date,
		mpp_exp1_date = manpowerprofile.mpp_exp1_date,
		mpp_exp2_date = manpowerprofile.mpp_exp2_date,
		trl_exp1_date = trailerprofile.trl_exp1_date,
		trl_exp2_date = trailerprofile.trl_exp2_date,
	--	loghours =
--			case when mpp_last_log_date >= @ldt_yesterday
--				then isnull(manpowerprofile.mpp_hours1, -100)
--				else -100
--				end,
		TT1.trc_trailer1 = ISNULL(tractorprofile.trc_trailer1, 'UNKNOWN'),
		TT1.terminal = tractorprofile.trc_terminal,
		mpp_hours1_week = isnull(manpowerprofile.mpp_hours1_week, -100),
		TT1.mpp_alternatephone = manpowerprofile.mpp_alternatephone
  FROM	@TT1 TT1  LEFT OUTER JOIN  trailerprofile  ON  TT1.lgh_primary_trailer  = trailerprofile.trl_id ,
		manpowerprofile,
		tractorprofile,
		@l_mpp l_mpp,
		@l_trc l_trc
 WHERE	TT1.evt_driver1 = manpowerprofile.mpp_id AND
		TT1.evt_tractor = tractorprofile.trc_number AND
		( l_trc.abbr = trc_status ) AND
		( l_mpp.abbr = mpp_status )


/* KM  2-27-99 PTS 5191 - Use outer joins on company table to make sure */
/* company info gets set properly */
UPDATE	TT1
   SET	TT1.f_cmpname = company_c.cmp_name,
		TT1.f_ctyname = city_c.cty_nmstct,
		TT1.l_cmpname = company_d.cmp_name,
		TT1.l_ctyname = city_d.cty_nmstct,
		TT1.f_state = company_c.cmp_state,
		TT1.l_state = company_d.cmp_state,
		TT1.p_cmpname = company_p.cmp_name,
		TT1.p_ctyname = city_p.cty_nmstct,
		TT1.p_state = company_p.cmp_state,
		TT1.trc_prior_cmp_name = company_pr.cmp_name,
		TT1.trc_prior_ctyname = city_pr.cty_nmstct,
		TT1.trc_prior_state = company_pr.cmp_state,
		TT1.trc_next_cmp_name = company_n.cmp_name,
		TT1.trc_next_ctyname = city_n.cty_nmstct,
		TT1.trc_next_state = company_n.cmp_state
  FROM  @TT1 TT1  LEFT OUTER JOIN  company company_c  ON  TT1.f_cmpid  = company_c.cmp_id
		LEFT OUTER JOIN  company company_d  ON  TT1.l_cmpid  = company_d.cmp_id
		LEFT OUTER JOIN  company company_p  ON  TT1.p_cmpid  = company_p.cmp_id
		LEFT OUTER JOIN  city city_c  ON  TT1.f_ctycode  = city_c.cty_code
		LEFT OUTER JOIN  city city_p  ON  TT1.p_ctycode  = city_p.cty_code
		LEFT OUTER JOIN  city city_d  ON  TT1.l_ctycode  = city_d.cty_code
		LEFT OUTER JOIN  company company_pr  ON  TT1.trc_prior_cmp_id  = company_pr.cmp_id
		LEFT OUTER JOIN  city city_pr  ON  TT1.trc_prior_city  = city_pr.cty_code
		LEFT OUTER JOIN  company company_n  ON  TT1.trc_next_cmp_id  = company_n.cmp_id
		LEFT OUTER JOIN  city city_n  ON  TT1.trc_next_city  = city_n.cty_code
--pts40187 outer join conversion
--change
--  WHERE	( TT1.f_cmpid *= company_c.cmp_id ) and
--		( TT1.l_cmpid *= company_d.cmp_id ) and
--		( TT1.p_cmpid *= company_p.cmp_id ) and
--		( TT1.f_ctycode *= city_c.cty_code ) and
--		( TT1.p_ctycode *= city_p.cty_code ) and
--		( TT1.l_ctycode *= city_d.cty_code ) and
--		( TT1.trc_prior_cmp_id *= company_pr.cmp_id ) and
--		( TT1.trc_prior_city *= city_pr.cty_code ) and
--		( TT1.trc_next_cmp_id *= company_n.cmp_id ) and
--		( TT1.trc_next_city *= city_n.cty_code )
/* END PTS 5191  */
/* 35747 DPETE if GI specified local time xzone compute TImeZone minutes adjustment for each row */
If @v_GILocalTImeOption = 'LOCAL'
   BEGIN
     update @tt1 set TimeZoneADJMins =
       Case
         when lgh_outstatus = 'Completed' then 0  -- trip is done it cant be late
         when evt_latedate is null and lgh_outstatus = 'Started' then 0  -- dw sets flag to GREEN for this
         when evt_latedate is null then   -- dw uses lgh_startdate if htis is true
              @v_LocalCityTZAdjFactor -
			 (select ((isnull(cty_GMTDelta,5)
				   + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end))) * 60)
				   + isnull(cty_TZMins,0)
				   From city where cty_code = o_city)
         else
              @v_LocalCityTZAdjFactor -
             (select ((isnull(cty_GMTDelta,5)
				   + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end))) * 60)
				   + isnull(cty_TZMins,0)
				   From city where cty_code = (select stp_city from stops where stp_mfh_sequence =
                       (select min(stp_mfh_sequence) from stops where stops.lgh_number = lgh_number and stp_status = 'OPN' or isnull(stp_departure_status,stp_status) = 'OPN')))

         end
   END

-- RE - 4/8/03 - PTS #17284 BEGIN
IF @inctrlexps = 'Y'
BEGIN
	/*pts 6200 */
	UPDATE	@tt1
	   SET	pri1exp = CASE
						WHEN trc_exp1_date <= GetDate() or mpp_exp1_date <= GetDate() OR trl_exp1_date <= GetDate() THEN 1
						ELSE 0
					  END,
		    pri1expsoon = CASE
							WHEN trc_exp1_date <= @neardate or mpp_exp1_date <= @neardate OR trl_exp1_date <= @neardate THEN 1
							ELSE 0
						  END,
		    pri2exp = CASE
						WHEN trc_exp2_date <= GetDate() or mpp_exp2_date <= GetDate() OR trl_exp2_date <= GetDate() THEN 1
						ELSE 0
					  END,
		    pri2expsoon = CASE
							WHEN trc_exp2_date <= @neardate or mpp_exp2_date <= @neardate OR trl_exp2_date <= @neardate THEN 1
							ELSE 0
				 		  END
END
ELSE
BEGIN
	UPDATE	@tt1
	   SET	pri1exp = CASE
						WHEN trc_exp1_date <= GetDate() or mpp_exp1_date <= GetDate() THEN 1
						ELSE 0
					  END,
		    pri1expsoon = CASE
							WHEN trc_exp1_date <= @neardate or mpp_exp1_date <= @neardate THEN 1
							ELSE 0
						  END,
		    pri2exp = CASE
						WHEN trc_exp2_date <= GetDate() or mpp_exp2_date <= GetDate() THEN 1
						ELSE 0
					  END,
		    pri2expsoon = CASE
							WHEN trc_exp2_date <= @neardate or mpp_exp2_date <= @neardate THEN 1
							ELSE 0
				 		  END
END
-- RE - 4/8/03 - PTS #17284 END
-- KM PTS 15733
UPDATE	@tt1
   SET		drvpri1exp = CASE WHEN mpp_exp1_date <= GetDate() THEN 1 ELSE 0 END,
		drvpri1expsoon = CASE WHEN mpp_exp1_date <= @drvneardate THEN 1	ELSE 0 END,
		drvpri2exp = CASE WHEN mpp_exp2_date <= GetDate() THEN 1 ELSE 0 END,
		drvpri2expsoon = CASE WHEN mpp_exp2_date <= @drvneardate THEN 1 ELSE 0 END

-- KM PTS 15733
UPDATE	@tt1
   SET		trcpri1exp = CASE WHEN trc_exp1_date <= GetDate() THEN 1 ELSE 0 END,
		trcpri1expsoon = CASE WHEN trc_exp1_date <= @trcneardate THEN 1 ELSE 0 END,
		trcpri2exp = CASE WHEN trc_exp2_date <= GetDate() THEN 1 ELSE 0 END,
		trcpri2expsoon = CASE WHEN trc_exp2_date <= @trcneardate THEN 1 ELSE 0 END

/* PTS 26766 - Recode of the following changes originally made in Eagle source
	PTS 20302 - DJM - Set the Origin and Destination Localization values
 	PTS 22601 - DJM - Modified to only set codes, so we can use parameters to delete
		rows that do not meet the required criteria
 	PTS 23836 - DJM - Modified logic to get the Zip code off the appropriate Stop, instead
		of from the City table record.
   PTS 28420 - DJM - Modified to not do the Localization processing if the functionality is not ON
*/

select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'
if @localization = 'Y'
Begin
	Update tt1
	set origin_servicezonename = cz1.cz_zone ,
		origin_serviceareaname = cz1.cz_area
	from @TT1 tt1,
		city c1,
		cityzip cz1,
		stops s
	where tt1.stp_number_start = s.stp_number
		and s.stp_city = c1.cty_code
		and c1.cty_nmstct = cz1.cty_nmstct
		and s.stp_zipcode = cz1.zip

	Update tt1
	set dest_servicezonename = cz1.cz_zone ,
		dest_serviceareaname = cz1.cz_area
	from @TT1 tt1,
		city c1,
		cityzip cz1,
		stops s
	where tt1.stp_number_end = s.stp_number
		and s.stp_city = c1.cty_code
		and c1.cty_nmstct = cz1.cty_nmstct
		and s.stp_zipcode = cz1.zip

	Update tt1
	set origin_servicecentername =  svc_center ,
		origin_serviceregionname = svc_region
	from @TT1 tt1,
		serviceregion sc,
		stops s
	where tt1.stp_number_start = s.stp_number
		and sc.svc_area = tt1.origin_serviceareaname
		and sc.svc_revcode = (select Case @service_revtype
						when 'REVTYPE1' then
							(select ord_revtype1 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
						when 'REVTYPE2' then
							(select ord_revtype2 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
						when 'REVTYPE3' then
							(select ord_revtype3 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
						when 'REVTYPE4' then
							(select ord_revtype4 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
					End)
	Update tt1
	set dest_servicecentername =  svc_center ,
		dest_serviceregionname = svc_region
	from @TT1 tt1,
		serviceregion sc,
		stops s
	where tt1.stp_number_end = s.stp_number
		and sc.svc_area = tt1.dest_serviceareaname
		and sc.svc_revcode = (select Case @service_revtype
						when 'REVTYPE1' then
							(select ord_revtype1 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
						when 'REVTYPE2' then
							(select ord_revtype2 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
						when 'REVTYPE3' then
							(select ord_revtype3 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
						when 'REVTYPE4' then
							(select ord_revtype4 from orderheader where orderheader.ord_hdrnumber = tt1.ord_hdrnumber)
					End)

	/* PTS 22601 - DJM - Remove rows from the temp table that do not meet the Localization parameter requirements,
		if any			*/

	Delete from @tt1
	where CHARINDEX(',' + isnull(origin_servicezonename,'UNK') + ',', @o_servicezone) = 0
		and @o_servicezone <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(origin_serviceareaname,'UNK') + ',', @o_servicearea) = 0
		and @o_servicearea <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(origin_servicecentername,'UNK') + ',', @o_servicecenter) = 0
		and @o_servicecenter <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(origin_serviceregionname,'UNK') + ',', @o_serviceregion) = 0
		and @o_serviceregion <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(dest_servicezonename,'UNK') + ',', @dest_servicezone) = 0
		and @dest_servicezone <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(dest_serviceareaname,'UNK') + ',', @dest_servicearea) = 0
		and @dest_servicearea <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(dest_servicecentername,'UNK') + ',', @dest_servicecenter) = 0
		and @dest_servicecenter <> ',,'

	Delete from @tt1
	where CHARINDEX(',' + isnull(dest_serviceregionname,'UNK') + ',', @dest_serviceregion) = 0
		and @dest_serviceregion <> ',,'

	Update @tt1
	set origin_servicezonename = isNull((select name from labelfile where labeldefinition = 'ServiceZone' and abbr = origin_servicezonename),'UNKNOWN'),
		origin_serviceareaname = isNull((select name from labelfile where labeldefinition = 'ServiceArea' and abbr = origin_serviceareaname),'UNKNOWN'),
		origin_servicecentername = isnull((select name from labelfile where labeldefinition = 'ServiceCenter'
					and abbr = origin_servicecentername),'UNKNOWN'),
		origin_serviceregionname = isNull((select name from labelfile where labeldefinition = 'ServiceRegion'
					and abbr = origin_serviceregionname),'UNKNOWN') ,
		dest_servicezonename = isNull((select name from labelfile where labeldefinition = 'ServiceZone' and abbr = dest_servicezonename),'UNKNOWN'),
		dest_serviceareaname = isNull((select name from labelfile where labeldefinition = 'ServiceArea' and abbr = dest_serviceareaname),'UNKNOWN'),
		dest_servicecentername = isnull((select name from labelfile where labeldefinition = 'ServiceCenter'
					and abbr = dest_servicecentername),'UNKNOWN') ,
		dest_serviceregionname = isnull((select name from labelfile where labeldefinition = 'ServiceRegion'
					and abbr = dest_serviceregionname),'UNKNOWN')
End


--PTS 40883 JJF 20080402
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'FirstOrdRefNumDispinPlanner' and substring(gi_string1,1,1) = 'Y' ) BEGIN
	UPDATE	@TT1
	SET ord_reftype = ord.ord_reftype,
		ord_refnum = ord.ord_refnum
	FROM orderheader ord CROSS JOIN @TT1 TT1
	WHERE ord.ord_hdrnumber = (SELECT TOP 1 stp.ord_hdrnumber
							FROM stops stp
							WHERE  stp.mov_number = TT1.mov_number
									AND stp.ord_hdrnumber > 0
							ORDER BY stp.stp_mfh_sequence)
END
--PTS 40883 JJF 20080212


/* EXEC timerins 'INBOUND', 'FINISH' */
SELECT @revclass1labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'RevType1' )
SELECT @revclass2labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'RevType2' )
SELECT @revclass3labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'RevType3' )
SELECT @revclass4labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'RevType4' )
SELECT @lgh_type1_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'LghType1' )
SELECT @lgh_type2_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'LghType2' )
SELECT @trltype1labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrlType1' )
SELECT @trltype2labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrlType2' )
SELECT @trltype3labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrlType3' )
SELECT @trltype4labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrlType4' )
SELECT @trctype1labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrcType1' )
SELECT @trctype2labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrcType2' )
SELECT @trctype3labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrcType3' )
SELECT @trctype4labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'TrcType4' )
SELECT @drvtype1labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'DrvType1' )
SELECT @drvtype2labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'DrvType2' )
SELECT @drvtype3labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'DrvType3' )
SELECT @drvtype4labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'DrvType4' )
SELECT @drvteamleaderlabelname= ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'Teamleader' )

UPDATE	TT1
	--change
	--pts40187 jguo removed right outer join from correlated query
   SET	outstatname = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_outstatus AND labeldefinition = 'DispStatus' ),
		instatname = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_instatus AND labeldefinition = 'InStatus' ),
		companyname = ( SELECT name FROM labelfile WHERE abbr = TT1.trc_company AND labeldefinition = 'Company' ),
   		trltype1name = ( SELECT name FROM labelfile WHERE abbr = TT1.trl_type1 AND labeldefinition = 'TrlType1' ),
		trltype2name = ( SELECT name FROM labelfile WHERE abbr = TT1.trl_type2 AND labeldefinition = 'TrlType2' ),
		trltype3name = ( SELECT name FROM labelfile WHERE abbr = TT1.trl_type3 AND labeldefinition = 'TrlType3' ),
		trltype4name = ( SELECT name FROM labelfile WHERE abbr = TT1.trl_type4 AND labeldefinition = 'TrlType4' ),
		trltype1labelname = @trltype1labelname,
		trltype2labelname = @trltype2labelname,
		trltype3labelname = @trltype3labelname,
		trltype4labelname = @trltype4labelname,
		revclass1name = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_class1 AND labeldefinition = 'RevType1' ),
		revclass2name = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_class2 AND labeldefinition = 'RevType2' ),
		revclass3name = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_class3 AND labeldefinition = 'RevType3' ),
		revclass4name = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_class4 AND labeldefinition = 'RevType4' ),
		revclass1labelname = @revclass1labelname,
		revclass2labelname = @revclass2labelname,
		revclass3labelname = @revclass3labelname,
		revclass4labelname = @revclass4labelname,
   		lgh_type1_name = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_type1 AND labeldefinition = 'LghType1' ),
		lgh_type2_name = ( SELECT name FROM labelfile WHERE abbr = TT1.lgh_type2 AND labeldefinition = 'LghType2' ),
		lgh_type1_labelname = @lgh_type1_labelname,
		lgh_type2_labelname = @lgh_type2_labelname,
		mpp_fleet_name = ISNULL(( SELECT name FROM labelfile WHERE abbr = TT1.mpp_fleet AND labeldefinition = 'Fleet' ), TT1.mpp_fleet),
		trc_type1_t = @trctype1labelname,
		trc_type2_t = @trctype2labelname,
		trc_type3_t = @trctype3labelname,
		trc_type4_t = @trctype4labelname,
		trc_type1name = ( SELECT name FROM labelfile WHERE abbr = tt1.trc_type1 AND labeldefinition = 'TrcType1' ),
		trc_type2name = ( SELECT name FROM labelfile WHERE abbr = tt1.trc_type2 AND labeldefinition = 'TrcType2' ),
		trc_type3name = ( SELECT name FROM labelfile WHERE abbr = tt1.trc_type3 AND labeldefinition = 'TrcType3' ),
		trc_type4name = ( SELECT name FROM labelfile WHERE abbr = tt1.trc_type4 AND labeldefinition = 'TrcType4' ),
		drv_type1_t = @drvtype1labelname,
		drv_type2_t = @drvtype2labelname,
		drv_type3_t = @drvtype3labelname,
		drv_type4_t = @drvtype4labelname,
		drv_teamleader_t = @drvteamleaderlabelname,
		drv_type1name = ( SELECT name FROM labelfile WHERE abbr = tt1.mpp_type1 AND labeldefinition = 'DrvType1' ),
		drv_type2name = ( SELECT name FROM labelfile WHERE abbr = tt1.mpp_type2 AND labeldefinition = 'DrvType2' ),
		drv_type3name = ( SELECT name FROM labelfile WHERE abbr = tt1.mpp_type3 AND labeldefinition = 'DrvType3' ),
		drv_type4name = ( SELECT name FROM labelfile WHERE abbr = tt1.mpp_type4 AND labeldefinition = 'DrvType4' ),
		drv_teamleadername = ( SELECT name FROM labelfile WHERE abbr = tt1.mpp_teamleader AND labeldefinition = 'Teamleader' ),
		origin_servicezone_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' ),
		origin_sericearea_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' ),
		origin_servicecenter_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' ),
		origin_serviceregion_labelname = 'Origin ' + (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' ),
		dest_servicezone_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' ),
		dest_sericearea_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' ),
		dest_servicecenter_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' ),
		dest_serviceregion_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
FROM @TT1 TT1
	If exists (select * from generalinfo where gi_name = 'PlnWrkshtShowDrvExpirations' and substring(gi_string1,1,1) = 'Y' )
	BEGIN
		Update 	TT1
		set 	mpp_next_exp_code 	= 	b.exp_code,
				mpp_next_exp_name	=	substring(b.exp_description,1,20),
			    mpp_next_exp_date	=	b.exp_expirationdate,
				mpp_next_exp_compldate = b.exp_compldate
		from	@TT1 TT1, expiration b
		where	b.exp_idtype = 'DRV' and
				b.exp_id = TT1.evt_driver1 and
				b.exp_expirationdate = (select min(exp_expirationdate) from expiration d where
												d.exp_idtype = 'DRV' and
												d.exp_id = TT1.evt_driver1 and
												d.exp_expirationdate >= getdate() and
												d.exp_completed = 'N')

		-- PTS 31211 -- BL (start)
		if @AVLDTTM_ONLYSETBY_OPENEXPS = 'Y'
				Update 	TT1
				set		lgh_enddate = exp_compldate
				from 	@TT1 TT1, expiration b
				where	b.exp_idtype = 'DRV' and
						b.exp_id = TT1.evt_driver1 and
						b.exp_compldate = (select max(exp_compldate) from expiration d where
											d.exp_idtype = b.exp_idtype and
											d.exp_id	 = b.exp_id and
											d.exp_expirationdate <= getdate() and
											d.exp_compldate >= getdate() and
											d.exp_completed = 'N')
		ELSE
				Update 	TT1
				set		lgh_enddate = exp_compldate
				from 	@TT1 TT1, expiration b
				where	b.exp_idtype = 'DRV' and
						b.exp_id = TT1.evt_driver1 and
						b.exp_compldate = (select max(exp_compldate) from expiration d where
											d.exp_idtype = b.exp_idtype and
											d.exp_id	 = b.exp_id and
											d.exp_expirationdate <= getdate() and
											d.exp_compldate >= getdate())
		-- PTS 31211 -- BL (end)
	END

--JLB PTS 32387 new logic to allow starting of expirations for planning purposes only
IF exists (select * from generalinfo where gi_name = 'PlnWrkshtStartExpForPlanning' and left(gi_string1,1) = 'Y')
begin
	--Loop thru each row and update the available date if there is an expiration marked as started that has a higher end date than the current one
	--Loop by Driver
	if exists (select * from generalinfo where gi_name = 'PlnWrkshtShowDrvExpirations' and substring(gi_string1,1,1) = 'Y')
	begin
		select @vs_counter = min(evt_driver1), @vdtm_avl_date = min(lgh_enddate)
		  from @TT1 TT1
		 where evt_driver1 <> 'UNKNOWN'
		while @vs_counter is not null
        begin
			set @vdtm_exp_completiondate = NULL
			select @vdtm_exp_completiondate = exp_compldate
			  from expiration b
			 where b.exp_control_avl_date = 'Y'
			   and b.exp_id = @vs_counter
			   and b.exp_idtype = 'DRV'
			if isnull(@vdtm_exp_completiondate, '01/01/50 00:00:00.000') > @vdtm_avl_date
			begin
				update @TT1
				   set lgh_enddate = @vdtm_exp_completiondate,
                       exp_affects_avail_dtm = 'Y'
                 where evt_driver1 = @vs_counter
			end
		select @vs_counter = min(evt_driver1), @vdtm_avl_date = min(lgh_enddate)
		  from @TT1  TT1
		 where evt_driver1 <> 'UNKNOWN'
           and evt_driver1 > @vs_counter
		end
	end
	--Loop by Tractor
	else
	begin
		select @vs_counter = min(evt_tractor), @vdtm_avl_date = min(lgh_enddate)
		  from @TT1 TT1
		 where evt_tractor <> 'UNKNOWN'
		while @vs_counter is not null
        begin
			set @vdtm_exp_completiondate = NULL
			select @vdtm_exp_completiondate = exp_compldate
			  from expiration b
			 where b.exp_control_avl_date = 'Y'
			   and b.exp_id = @vs_counter
			   and b.exp_idtype = 'TRC'
			if isnull(@vdtm_exp_completiondate, '01/01/50 00:00:00.000') > @vdtm_avl_date
			begin
				update @TT1
				   set lgh_enddate = @vdtm_exp_completiondate,
					   exp_affects_avail_dtm = 'Y'
                 where evt_tractor = @vs_counter
			end
		select @vs_counter = min(evt_tractor), @vdtm_avl_date = min(lgh_enddate)
		  from @TT1  TT1
		 where evt_tractor <> 'UNKNOWN'
           and evt_tractor > @vs_counter
		end
	end
end

/* PTS15697 10/07/02 */
UPDATE TT1
   SET last_stop_dep_status = ISNULL(stops.stp_departure_status, 'OPN')
  FROM @TT1 TT1, stops
 WHERE TT1.stp_number_end = stops.stp_number


--PTS 21259 4/19/04 GK
--Need to keep this logic at the end since the driver is used extensively above
If exists (select * from generalinfo where gi_name = 'InboundTractorsDriverDesc' and UPPER (gi_string1) = UPPER ('24Hour-DriverMoveAvailable'))
BEGIN

--PTS 24066 7/27/2004 CGK. Only change driver to available if the tractor is available and the driver is assigned to a new load
/*	UPDATE #TT1
	SET evt_driver1 = 'Avl',
	mpp_lastfirst_1 = 'Available'
	FROM #TT1, tractorprofile
	WHERE #TT1.evt_tractor = tractorprofile.trc_number
	AND tractorprofile.trc_status='AVL' */

	UPDATE TT1
	SET evt_driver1 = 'Avl',
	mpp_lastfirst_1 = 'Available'
	FROM @TT1 TT1, tractorprofile, manpowerprofile
	WHERE TT1.evt_tractor = tractorprofile.trc_number
	AND TT1.evt_driver1 = manpowerprofile.mpp_id
	AND tractorprofile.trc_status='AVL'
	AND manpowerprofile.mpp_status <> 'AVL'
--End PTS 24066

	UPDATE TT1
	SET evt_driver1 = 'Avl',
	mpp_lastfirst_1 = 'Available'
	FROM @TT1 TT1
	WHERE lgh_outstatus = 'CMP'
	AND lgh_instatus = 'UNP'
	AND getdate () > DateAdd (hh, 24, lgh_enddate)

END

--PTS 21260 cgk.
-- Display code 200 (In the Shop) if AdditionalOutboundStatus generalinfo is set to 'TRC-VAC'
IF exists (select * from generalinfo where gi_name = 'AdditionalOutboundStatus' and UPPER (gi_string1) = UPPER ('TRC-VAC'))
BEGIN
	UPDATE @TT1
	SET outstatname  = ( SELECT name FROM labelfile WHERE abbr = 'VAC'  AND labeldefinition = 'TrcStatus' )
	WHERE trcstat = 200
END
--End PTS 21260

--JLB PTS 27300
update TT1
   set dest_cty_lat = isnull(cty_latitude, 0.0000),
       dest_cty_long = isnull(cty_longitude, 0.0000)
  from @TT1 TT1, city
 where city.cty_code = TT1.d_city
--end 27300

--JG - PTS #31811 In order to improve the performance, only perform this logic if the setting is on
IF EXISTS (SELECT 1 FROM generalinfo WHERE gi_name = 'RetrieveTractorAvailableDate' and substring(gi_string1,1,1) = 'Y' )
BEGIN

-- RE - PTS #31172 BEGIN
SElECT @curr_avail_date = '01/01/1950', @latest_avail_date = '12/31/2049'

SELECT	@evt_tractor = MIN(evt_tractor)
  FROM	@TT1

WHILE ISNULL(@evt_tractor, 'XXXXXXXX') <> 'XXXXXXXX'
BEGIN
	SELECT	@curr_avail_date = ISNULL(MAX(asgn_enddate), '01/01/1950')
  	  FROM	assetassignment
	 WHERE	asgn_status = 'CMP' AND
			asgn_type = 'TRC' AND
			asgn_id = @evt_tractor

	SELECT	@latest_avail_date = ISNULL(MAX(asgn_enddate), '12/31/2049')
  	  FROM	assetassignment
	 WHERE	asgn_status = 'PLN' AND
			asgn_type = 'TRC' AND
			asgn_id = @evt_tractor

	UPDATE	@TT1
	   SET	current_avl_date = @curr_avail_date,
			latest_avl_date =  @latest_avail_date
	 WHERE	evt_tractor = @evt_tractor

	SELECT @curr_avail_date = '01/01/1950', @latest_avail_date = '12/31/2049'

	SELECT	@evt_tractor = MIN(evt_tractor)
	  FROM	@TT1
	 WHERE	evt_tractor > @evt_tractor
END

END
--JG - PTS #31811 END

-- --PTS# 29650 ILB 10/07/2005
--  --Set the current_avl_date column equal to the last completed load lgh_enddate for each tractor
--  --Set the latest_avail_date column equal to the maximum lgh_enddate for each tractor
--  --for each order
--      Set @evt_tractor = ''
--      Set @curr_avail_date = '01/01/1950'
--      Set @latest_avail_date = '12/31/2049'
--
--      WHILE (SELECT COUNT(*) FROM #TT1 WHERE evt_tractor > @evt_tractor) > 0
-- 	BEGIN
--
-- 	  SELECT @evt_tractor = (SELECT MIN(evt_tractor)
--                                    FROM #TT1
--                                   WHERE evt_tractor > @evt_tractor)
--
-- 	 select @curr_avail_date = isnull(max(lgh_enddate),'01/01/1950')
--   	   from legheader
--           where lgh_outstatus = 'CMP' and
--                 lgh_tractor = @evt_tractor
--
-- 	 select @latest_avail_date =  isnull(max(lgh_enddate),'12/31/2049')
--            from legheader
--           where lgh_tractor = @evt_tractor
--
--           UPDATE #TT1
--              set current_avl_date = @curr_avail_date,
--                  latest_avl_date =  @latest_avail_date
--            where evt_tractor = @evt_tractor
--
-- 	 Set @curr_avail_date = '01/01/1950'
--      	 Set @latest_avail_date = '12/31/2049'
-- 	END
-- --PTS# 29650 ILB 10/07/2005
-- RE - PTS #31172 END

/* PTS 38765 - DJM - Added columns to display the last completed City and Company from the current Trip		*/
update t1
set t1.trc_latest_ctyst = city.cty_nmstct,
	t1.trc_latest_cmpid = stops.cmp_id
from stops, @TT1 t1 , city
where stops.lgh_number = t1.lgh_number
	and stops.stp_city = city.cty_code
	and stops.stp_status = 'DNE'
	and stops.stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where stops.lgh_number = t1.lgh_number and stp_status = 'DNE')

--PTS 40155 JJF 20071128
SELECT @rowsecurity = gi_string1
FROM generalinfo
WHERE gi_name = 'RowSecurity'

--PTS 41877
--SELECT @tmwuser = suser_sname()
exec @tmwuser = dbo.gettmwuser_fn

IF @rowsecurity = 'Y' AND EXISTS(SELECT *
				FROM UserTypeAssignment
				WHERE usr_userid = @tmwuser) BEGIN


	DELETE @TT1
	from @TT1 tp inner join orderheader oh on tp.mov_number = oh.mov_number
	where   NOT ((isnull(oh.ord_BelongsTo, 'UNK') = 'UNK'
			or EXISTS(SELECT *
						FROM UserTypeAssignment
						WHERE usr_userid = @tmwuser
								and (uta_type1 = oh.ord_BelongsTo
									or uta_type1 = 'UNK'))))

	DELETE @TT1
	from @TT1 tp inner join tractorprofile trc on tp.evt_tractor = trc.trc_number
	where   NOT ((isnull(trc.trc_terminal, 'UNK') = 'UNK'
			or EXISTS(SELECT *
						FROM UserTypeAssignment
						WHERE usr_userid = @tmwuser
								and (uta_type1 = trc.trc_terminal
									or uta_type1 = 'UNK'))))

END
--END PTS 40155 JJF 20071128

-- RE - PTS #42565 BEGIN
DECLARE @accessory_count INT

IF len(@drv_qualifications) > 0
BEGIN
	DECLARE @drvaccessories TABLE  (value VARCHAR(8))

	INSERT @drvaccessories(value) SELECT * FROM CSVStringsToTable_fn(@drv_qualifications) WHERE value NOT IN ('','%','%%')

	SELECT @accessory_count = count(*) from @drvaccessories

	IF @accessory_count > 0
	BEGIN
		DELETE	@TT1
		 WHERE	evt_driver1 NOT IN
					(SELECT	t.evt_driver1
					   FROM	(SELECT DISTINCT evt_driver1 FROM @TT1) t
								inner join driverqualifications ta on t.evt_driver1 = ta.drq_driver and ta.drq_expire_date >= getdate() and isnull(ta.drq_expire_flag, 'N') <> 'Y' and drq_source = 'DRV'
								inner join @drvaccessories tc on ta.drq_type = tc.value
					GROUP BY t.evt_driver1
					HAVING COUNT(*) = @accessory_count)
	END
END

IF len(@trc_accessories) > 0
BEGIN
	DECLARE @trcaccessories TABLE  (value VARCHAR(8))

	INSERT @trcaccessories(value) SELECT * FROM CSVStringsToTable_fn(@trc_accessories) WHERE value NOT IN ('','%','%%')

	SELECT @accessory_count = count(*) from @trcaccessories

	IF @accessory_count > 0
	BEGIN
		DELETE	@TT1
		 WHERE	evt_tractor NOT IN
					(SELECT	t.evt_tractor
					   FROM	(SELECT DISTINCT evt_tractor from @TT1) t
								inner join tractoraccesories ta on t.evt_tractor = ta.tca_tractor and ta.tca_expire_date >= getdate() and isnull(ta.tca_expire_flag, 'N') <> 'Y' and tca_source = 'TRC'
								inner join @trcaccessories tc on ta.tca_type = tc.value
					GROUP BY t.evt_tractor
					HAVING COUNT(*) = @accessory_count)
	END
END

IF len(@trl_accessories) > 0
BEGIN
	DECLARE @trlaccessories TABLE  (value VARCHAR(8))

	INSERT @trlaccessories(value) SELECT * FROM CSVStringsToTable_fn(@trl_accessories) WHERE value NOT IN ('','%','%%')

	SELECT @accessory_count = count(*) from @trlaccessories

	IF @accessory_count > 0
	BEGIN
		DELETE	@TT1
		 WHERE	lgh_primary_trailer NOT IN
					(SELECT	t.lgh_primary_trailer
					   FROM	(SELECT DISTINCT lgh_primary_trailer FROM @TT1) t
								inner join trlaccessories ta on t.lgh_primary_trailer = ta.ta_trailer and ta.ta_expire_date >= getdate() and isnull(ta.ta_expire_flag, 'N') <> 'Y' and ta_source = 'TRL'
								inner join @trlaccessories tc on ta.ta_type = tc.value
					GROUP BY t.lgh_primary_trailer
					HAVING COUNT(*) = @accessory_count)
	END
END
-- RE - PTS #42565 END

SELECT		
--lgh_number,                        -- 001
--		o_cmpid,                           -- 002
--		o_cmpname,                         -- 003
--		o_ctyname,                         -- 004
--		d_cmpid,                           -- 005
--		d_cmpname,                         -- 006
--		d_ctyname,                         -- 007
--		f_cmpid,                           -- 008
--		f_cmpname,                         -- 009
--		f_ctyname,                         -- 010
--		l_cmpid,                           -- 011
--		l_cmpname,                         -- 012
--  		l_ctyname,                         -- 013
--		lgh_startdate,                     -- 014
--		lgh_enddate,                       -- 015
--		o_state,                           -- 016
--		d_state,                           -- 017
--		lgh_outstatus,                     -- 018
--		lgh_instatus,                      -- 019
--		lgh_priority,                      -- 020
--		lgh_schdtearliest,                 -- 021
--		lgh_schdtlatest,                   -- 022
--		cmd_code,                          -- 023
		fgt_description,                   -- 024
		ord_hdrnumber,                     -- 025
		mpp_last_home,                     -- 026
		mpp_want_home,                     -- 027
		evt_driver1,                       -- 028
		evt_driver2,                       -- 029
		evt_tractor,                       -- 030
		trc_company,                       -- 031
		lgh_primary_trailer,               -- 032
		trltype1name,                      -- 033
		trltype1labelname,                 -- 034
		trltype2name,                      -- 035
		trltype2labelname,                 -- 036
		trltype3name,                      -- 037
		trltype3labelname,                 -- 038
		trltype4name,                      -- 039
		trltype4labelname,                 -- 040
		mov_number,                        -- 041
		ord_number,                        -- 042
		o_city,                            -- 043
		d_city,                            -- 044
		filtflag,                          -- 045
		outstatname,                       -- 046
		instatname ,                       -- 047
		companyname,                       -- 048
		revclass1name,                     -- 049
		revclass2name,                     -- 050
		revclass3name,                     -- 051
		revclass4name,                     -- 052
		revclass1labelname,                -- 053
		revclass2labelname,                -- 054
		revclass3labelname,                -- 055
		revclass4labelname,                -- 056
		pri1exp,                           -- 057
		pri2exp,                           -- 058
		pri1expsoon,                       -- 059
		pri2expsoon,                       -- 060
		loghours,                          -- 061
		ord_bookedby,                      -- 062
		lgh_primary_pup,                   -- 063
		f_state,                           -- 064
		l_state,                           -- 065
		mpp_lastfirst_1,                   -- 066
		mpp_lastfirst_2,		           -- 067
		lgh_enddate_arrival,               -- 068
		lgh_dsp_date,                      -- 069
		lgh_geo_date,                      -- 070
		trc_driver,                        -- 071
		p_date, /*trc_pln_date*/           -- 072
		p_cmpid, /*trc_pln_cmp_id*/        -- 073
		p_cmpname,                         -- 074
		p_ctycode, /*trc_pln_city*/        -- 075
		p_ctyname,                         -- 076
		p_state,                           -- 077
		trc_gps_desc,                      -- 078
		trc_gps_date,                      -- 079
		tot_weight,                        -- 080
		tot_count,                         -- 081
		tot_volume,                        -- 082
		ordercount,                        -- 083
		npup_cmpid,                        -- 084
		npup_cmpname,                      -- 085
		npup_ctyname,                      -- 086
		npup_state,                        -- 087
		npup_arrivaldate,                  -- 088
		ndrp_cmpid,                        -- 089
		ndrp_cmpname,                      -- 090
		ndrp_ctyname,                      -- 091
		ndrp_state,                        -- 092
		ndrp_arrivaldate,                  -- 093
		can_cap_expires,                   -- 094
		ord_originregion1,                 -- 095
		ord_originregion2,                 -- 096
		ord_originregion3,                 -- 097
		ord_originregion4,                 -- 098
		ord_destregion1,                   -- 099
		ord_destregion2,                   -- 100
		ord_destregion3,                   -- 101
		ord_destregion4,                   -- 102
		lgh_feetavailable,                 -- 103
		ord_fromorder,                     -- 104
		lgh_type1_name,                    -- 105
		lgh_type1_labelname,               -- 106
		lgh_type2_name,                    -- 107
		lgh_type2_labelname,               -- 108
		event,                             -- 109
		trc_prior_event,                   -- 110
		trc_prior_cmp_id,                  -- 111
		trc_prior_city,                    -- 112
		trc_prior_ctyname,                 -- 113
		trc_prior_state,                   -- 114
		trc_prior_region1,                 -- 115
		trc_prior_region2,                 -- 116
		trc_prior_region3,                 -- 117
		trc_prior_region4,                 -- 118
		trc_prior_cmp_name,                -- 119
		trc_next_event,                    -- 120
		trc_next_cmp_id,                   -- 121
		trc_next_city,                     -- 122
		trc_next_ctyname,                  -- 123
		trc_next_state,                    -- 124
		trc_next_region1,                  -- 125
		trc_next_region2,                  -- 126
		trc_next_region3,                  -- 127
		trc_next_region4,                  -- 128
		trc_next_cmp_name,                 -- 129
		o_cmp_geoloc,                      -- 130
		d_cmp_geoloc,                      -- 131
		mpp_fleet,                         -- 132
		mpp_fleet_name,                    -- 133
		mpp_dailyhrsest,                   -- 134
		mpp_weeklyhrsest,                  -- 135
		mpp_lastlog_cmp_id,                -- 136
		mpp_lastlog_cmp_name,              -- 137
		mpp_lastlog_estdate,               -- 138
		mpp_estlog_datetime,               -- 139
		trc_trailer1,                      -- 140
		mpp_next_exp_code,                 -- 141
		mpp_next_exp_name,                 -- 142
		mpp_next_exp_date,                 -- 143
		mpp_next_exp_compldate,            -- 144
		next_stp_event_code,               -- 145
		next_stop_of_total,                -- 146
		--vmj2+
		evt_carrier,                       -- 147
		terminal,                          -- 148
		ord_completiondate,                -- 149
		last_stop_dep_status,              -- 150
		evt_latedate,                      -- 151
		mpp_status_desc,                   -- 152
		drvpri1exp,                        -- 153
		drvpri2exp,                        -- 154
		drvpri1expsoon,                    -- 155
		drvpri2expsoon,                    -- 156
		trcpri1exp,                        -- 157
		trcpri2exp,                        -- 158
		trcpri1expsoon,                    -- 159
		trcpri2expsoon,                    -- 160
		trc_gps_latitude,                  -- 161
		trc_gps_longitude,                 -- 162
		l_ctycode,                         -- 163
		trc_type1_t,                       -- 164
		trc_type1name,                     -- 165
		trc_type2_t,                       -- 166
		trc_type2name,                     -- 167
		trc_type3_t,                       -- 168
		trc_type3name,                     -- 169
		trc_type4_t,                       -- 170
		trc_type4name,                     -- 171
		--vmj6+
		lgh_etaalert1,                     -- 172
		--vmj6-
		drv_type1_t,                       -- 173
		drv_type1name,                     -- 174
		drv_type2_t,                       -- 175
		drv_type2name,                     -- 176
		drv_type3_t,                       -- 177
		drv_type3name,                     -- 178
		drv_type4_t,                       -- 179
		drv_type4name,                     -- 180
		drv_teamleader_t,                  -- 181
		drv_teamleadername,                -- 182
		mpp_division,                      -- 183
		trc_division,                      -- 184
		lgh_washplan,                      -- 185
		lgh_nexttrailer1,                  -- 186
		lgh_nexttrailer2,                  -- 187
		lgh_detstatus,                     -- 188
		lgh_originzip,                     -- 189
		lgh_destzip,	                   -- 190
		isNull(origin_servicezonename,'UNKNOWN') origin_servicezonename,                        -- 191
		isNull(origin_servicezone_labelname,'ServiceZone') origin_servicezone_labelname,        -- 192
		isNull(origin_serviceareaname,'UNKNOWN') origin_serviceareaname,                        -- 193
		isNull(origin_sericearea_labelname,'ServiceArea') origin_sericearea_labelname,          -- 194
		isNull(origin_servicecentername,'UNKNOWN') origin_servicecentername,                    -- 195
		isNull(origin_servicecenter_labelname,'ServiceCenter') origin_servicecenter_labelname,  -- 196
		isNull(origin_serviceregionname,'UNKNOWN') origin_serviceregionname,                    -- 197
		isNull(origin_serviceregion_labelname,'ServiceRegion') origin_serviceregion_labelname,  -- 198
		isNull(dest_servicezonename,'UNKNOWN') dest_servicezonename,                            -- 199
		isNull(dest_servicezone_labelname,'ServiceZone') dest_servicezone_labelname,            -- 200
		isNull(dest_serviceareaname,'UNKNOWN')dest_serviceareaname,                             -- 201
		isNull(dest_sericearea_labelname,'ServiceArea')dest_sericearea_labelname,               -- 202
		isNull(dest_servicecentername ,'UNKNOWN') dest_servicecentername,                       -- 203
		isNull(dest_servicecenter_labelname,'ServiceCenter') dest_servicecenter_labelname,      -- 204
		isNull(dest_serviceregionname,'UNKNOWN') dest_serviceregionname,                        -- 205
		isNull(dest_serviceregion_labelname,'ServiceRegion') dest_serviceregion_labelname,      -- 206
		ord_company,                                    -- 207
		mpp_hours1_week,                                -- 208
		dest_cmp_lat,                                   -- 209
		dest_cmp_long,                                  -- 210
		dest_cty_lat,                                   -- 211
		dest_cty_long,                                  -- 212
		lgh_route,                                      -- 213
		lgh_booked_revtype1,                            -- 214
        lgh_tm_status,                          		-- 215
        lgh_tm_statusname,                      		-- 216
		mpp_alternatephone,                             -- 217
		lgh_comment,                                    -- 218
        --PTS# 29650 ILB 10/07/2005
        current_avl_date,                               -- 219
        latest_avl_date,                                -- 220
  		--PTS# 29650 ILB 10/07/2005
		--PTS# 29623 ILB 11/14/2005
		lgh_trc_comment,                                -- 221
		--PTS# 29623 ILB 11/14/2005
		ISNULL(mpp_pta_date, '12/31/2049 23:59'), 		-- 222				--DPH PTS 32698 --SLM 12/04/2006 PTS 35068 Added default value
		exp_affects_avail_dtm,  --JLB PTS 35133         -- 223
		0 TImeZoneAdjMins,     							-- 224				--35747 data returned in 200 version
		ord_billto,	-- PTS 35482 - DJM                  -- 225
		CompanyName_t,  -- SGB 37620                    -- 226
		trc_latest_ctyst,	-- PTS 38765                -- 227
		trc_latest_cmpid,                               -- 228
		trc_last_mobcomm_received,                      -- 229
		trc_mobcomm_type,                               -- 230
		trc_nearest_mobcomm_nmstct,	-- PTS 38765        -- 231
		trc_comment1,                                   -- 232
		ord_reftype,  --PTS 40883 JJF 20080212          -- 233
		ord_refnum,	--PTS 40883 JJF 20080212            -- 234
		trc_lastpos_lat,			-- PTS 42829 - DJM  -- 235
		trc_lastpos_long,			-- PTS 42829 - DJM  -- 236
		drv1_shift_start,								-- 237  /* 09/05/2008 MDH PTS 43538: Added */
		drv1_shift_end,			                        -- 238  /* 09/05/2008 MDH PTS 43538: Added */
		CASE
			WHEN drv1_shift_start > drv1_shift_end THEN
				CASE WHEN @mpp_shift_max_minutes = 0 THEN 0
					 ELSE @mpp_shift_max_minutes - datediff (minute, drv1_shift_start, GetDate ())
				END
			ELSE 0
		END drv1_shift_rem_minutes,						-- 239 /* 09/08/2008 MDH PTS 43538: Added */
		@mpp_shift_off_minutes drv1_shift_off_minutes	-- 240 /* 09/08/2008 MDH PTS 43538: Added */
	FROM	@TT1
	WHERE	trcstat NOT in (900,99999999) AND
		(@bookedby = ',ALL,' OR CHARINDEX(',' + LTRIM(RTRIM(ord_bookedby))+ ',', @bookedby) > 0) -- PTS 41931 SGB 04/18/08 + LTRIM(RTRIM(ord_bookedby))+
		AND (@orderedby = ',,' OR CHARINDEX(',' + ord_company + ',', @orderedby) > 0)





GO
