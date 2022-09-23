SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[outbound_viewbyleg]  
@lgh_number int
--	@revtype1	varchar (254),  
--	@revtype2	varchar (254),  
--	@revtype3	varchar (254),  
--	@revtype4	varchar (254),  
--	@trltype1	varchar (254),  
--	@company	varchar (254),  
--	@states		varchar (254),  
--	@cmpids		varchar (254),  
--	@reg1		varchar (254),  
--	@reg2		varchar (254),  
--	@reg3		varchar (254),  
--	@reg4		varchar (254),  
--	@city		int,  
--	@hoursback	int,  
--	@hoursout	int,  
--	@status		char (254),  
--	@bookedby	varchar (254),  
--	@ref_type	varchar(6),  
--	@teamleader	varchar(254),   
--	@d_states	varchar (254),   
--	@d_cmpids	varchar (254),   
--	@d_reg1		varchar (254),   
--	@d_reg2		varchar (254),   
--	@d_reg3		varchar (254),   
--	@d_reg4		varchar (254),   
--	@d_city		int,  
--	@includedrvplan varchar(3),  
--	@miles_min	int,  
--	@miles_max	int,  
--	@tm_status	varchar(254),  
--	@lgh_type1	varchar(254),  
--	@lgh_type2	varchar(254),  
--	@billto		varchar(254),  
--	@lgh_hzd_cmd_classes varchar (255),   
--	@orderedby	varchar(254),  
--	@o_servicearea		varchar(256),  
--	@o_servicezone		varchar(256),  
--	@o_servicecenter	varchar(256),  
--	@o_serviceregion	varchar(256),  
--	@dest_servicearea	varchar(256),  
--	@dest_servicezone	varchar(256),  
--	@dest_servicecenter	varchar(256),  
--	@dest_serviceregion	varchar(256),   
--	@lgh_route			varchar(256),  
--	@lgh_booked_revtype1 varchar(256),  
--	@lgh_permit_status	varchar(256)  
AS  

/****** Object:  Stored Procedure dbo.outbound_view    Script Date: 6/24/98 10:15:30 AM ******/  
/* MF 11/12/97 PTS 3215 changed to use newly populated fields on LGH including lgh_active */  
/* LOR 5/12/98 PTS# 3905 add shipper/consignee states, drivers' id's */  
/* LOR 5/12/98 PTS# 3908 add ref type and number */  
/* JET 6/3/98 PTS# 3991 modified lgh_schdtearliest, lgh_schdtlatest to reflect ord_origin_earliestdate andord_origin_latestdate*/  
/* MF 10/22/98 pts 4175 add extra cols*/  
/* JET 10/20/99 PTS #6490 changed the where clause on the select */  
/* DSK 3/20/00 PTS 7566  add columns for total orders, total count, total weight, total volume */  
/* KMM 7/10/00 PTS 8339  allow MPN records to be returned */  
/* RJE 7/14/00 added ld_can_expires for CAN */  
/* DPETE 12599 add origin and dest company geoloc feilds to return set fro Gibsons SR */  
/* Vern Jewett PTS 15033 07/31/2002 (label=vmj1) Add lgh_comments column. */  
/* Vern Jewett PTS 18417 09/02/2003 (label=vmj2) Add lgh_etaalert1 column. */  
/* PTS 26776 DJM  03/30/05 Recode changes made for Eagle in PTS number 19028, 22601,20302 into main source    
    These Eagle enhancements will only work on  SQL Server 2000 specific code. The  
    SQL 7 compliant version MUST have the same columns and parameters, but nothing  
    will be done with them. I.E. View retrictions will not be applied in the SQL 7  
    version*/  
/* PTS 26791 - DJM - Corrected display of Localization values.    */  
/* BDH 9/12/06 PTS 33890  Returning next_ndrp_cmpid, next_ndrp_cmpname, next_ndrp_ctyname, next_ndrp_state, next_ndrp_arrivaldate from legheader_active */  
/* EMK 10/3/06 PTS 33913  Returning ord_bookdate */  
/* EMK 10/11/06 PTS 33913   Changed _2000 to PROVIDES statement. */  
/* vjh 02/09/07 PTS 36608 Added Manual Check Call times. */  
/* DPETE 35747 allow for GI option of alltimes in local time zone support   
       return a minutes offset in each row to apply to Today()in datawindow for comparison (see attachemnt to PTS for how this works)*/  
-- LOR PTS# 35761 added evt_earlydate and ARRIVALDEPARTURE value to @LateWarnMode  
/* BDH  36717 5/14/07  Added lockedby and sessiondate columns as part of Command recode and changed joins to ansi.  */
-- vjh 05/22/07 PTS 37626 use Apocalypse if order event or check minutes are zero
-- vjh 05/30/07 PTS 37657 make the check call time time zone aware (when based on stop time, but not when based on check calls)
-- vjh 38226 TZ shift the departure date before comparison
-- vjh 38677 redefine ord_manualeventcallminutes
-- SLM 08/31/2007 PTS 39133 Based on General Info Setting 'PWSumOrdExtraInfo' use lgh_extrainfo1 
-- DJM 38765 09/26/2007 - Added fields to planning worksheet.

DECLARE   
	@char8		varchar(8),  
	@char1		varchar(1),        
	@char30		varchar(30),  
	@char20		varchar(20),  
	@char25		varchar(25),  
	@char40		varchar(40),  
	@cmdcount	int,  
	@floa		float,  
	@hoursbackdate	datetime,  
	@hoursoutdate	datetime,  
	@gistring1	varchar(60),  
	@dttm		datetime,  
	@char2		char(2),  
	@varchar45	varchar(45),  
	@varchar6	varchar(6),   
	@runpups	char(1),   
	@rundrops	char(1),   
	@retvarchar	varchar(3),  
	@LateWarnMode				VARCHAR(60),  
	@PWExtraInfoLocation		varchar(20),  
	@o_servicezone_labelname	varchar(20),  
	@o_servicecenter_labelname	varchar(20),  
	@o_serviceregion_labelname	varchar(20),  
	@o_sericearea_labelname		varchar(20),  
	@dest_servicezone_labelname varchar(20),  
	@dest_servicecenter_labelname varchar(20),  
	@dest_serviceregion_labelname varchar(20),  
	@dest_sericearea_labelname	varchar(20),  
	@service_revtype			varchar(10),  
	@localization				char(1),  
	@pending_statuses			varchar(60),  
	@UseShowAsShipperConsignee	CHAR(1),  
	@v_LghActiveUntilDepCompNBC char(1),  
	@ManualCheckCall			char(1),  
--35747  
	@V_GILocalTImeOption		varchar(20),    
	@v_LocalCityTZAdjFactor		int,  
	@InDSTFactor				int,  
	@DSTCountryCode				int ,
	@V_LocalGMTDelta			smallint,
	@v_LocalDSTCode				smallint,
	@V_LocalAddnlMins			smallint,
--35747 end 
-- PTS 37075 SGB Added variable for column Label
	@SubCompanyLabel			varchar(20),
	@Apocalypse					datetime,
	@PlnWrkshtRefStr1			varchar(60),	--vjh pts 38986
	@PlnWrkshtRefStr2			varchar(60),	--vjh pts 38986
	@PlnWrkshtRefStr3			varchar(60),	--vjh pts 38986
   	@ud_column1 char(1), --PTS 51911 SGB
	@ud_column2 char(1),  --PTS 51911 SGB
	@ud_column3 char(1), --PTS 51911 SGB
	@ud_column4 char(1),  --PTS 51911 SGB
	@procname varchar(255), --PTS 51911 SGB
	@udheader varchar(30), --PTS 51911 SGB  	
	@citylatlongunits char(1)
--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510

--END PTS 40155 JJF 20071128


  
Declare @ttbl1 Table(
	lgh_number			int			NULL,		
	o_cmpid				varchar(12)	NULL,		
	o_cmpname			varchar(30)	NULL,		
	o_ctyname			varchar(25)	NULL,		
	d_cmpid				varchar(12)	NULL,		
	d_cmpname			varchar(30)	NULL,		
	d_ctyname			varchar(25)	NULL,		
	f_cmpid				varchar(8)	NULL,		
	f_cmpname			varchar(30)	NULL,		
	f_ctyname			varchar(25)	NULL,		
	l_cmpid				varchar(8)	NULL,		
	l_cmpname			varchar(30)	NULL,		
	l_ctyname			varchar(25)	NULL,		
	lgh_startdate		datetime	NULL,		
	lgh_enddate			datetime	NULL,		
	o_state				varchar(6)	NULL,		
	d_state				varchar(6)	NULL,		
	lgh_schdtearliest	datetime	NULL,		
	lgh_schdtlatest		datetime	NULL,		
	cmd_code			varchar(8)	NULL,		
	fgt_description		varchar(30)	NULL,		
	cmd_count			int			NULL,		
	ord_hdrnumber		int			NULL,		
	evt_driver1			varchar(45)	NULL,		
	evt_driver2			varchar(45)	NULL,		
	evt_tractor			varchar(8)	NULL,		
	lgh_primary_trailer	varchar(13)	NULL,		
	trl_type1			varchar(6)	NULL,		
	evt_carrier			varchar(8)	NULL,		
	mov_number			int			NULL,		
	ord_availabledate	datetime	NULL,		
	ord_stopcount		tinyint		NULL,		
	ord_totalcharge		float		NULL,		
	ord_totalweight		int			NULL,		
	ord_length			money		NULL,		
	ord_width			money		NULL,		
	ord_height			money		NULL,		
	ord_totalmiles		int			NULL,		
	ord_number			char(12)	NULL,		
	o_city				int			NULL,		
	d_city				int			NULL,		
	lgh_priority		varchar(6)	NULL,		
	lgh_outstatus		varchar(20)	NULL,		
	lgh_instatus		varchar(20)	NULL,		
	lgh_priority_name	varchar(20)	NULL,		
	ord_subcompany		varchar(20)	NULL,		
	trl_type1_name		varchar(20)	NULL,		
	lgh_class1			varchar(20)	NULL,		
	lgh_class2			varchar(20)	NULL,		
	lgh_class3			varchar(20)	NULL,		
	lgh_class4			varchar(20)	NULL,
	--PTS 37075 SGB changed from varchar(7) to (20) and changed name for clarification
	--Company			varchar(7)	NULL
	SubCompanyLabel		varchar(20)	NULL,		
	trllabel1			varchar(20)	NULL,		
	revlabel1			varchar(20)	NULL,		
	revlabel2			varchar(20)	NULL,		
	revlabel3			varchar(20)	NULL,		
	revlabel4			varchar(20)	NULL,		
	ord_bookedby		char(20)	NULL,		
	dw_rowstatus		char(10)	NULL,		
	lgh_primary_pup		varchar(13)	NULL,		
	triptime			float		NULL,		
	ord_totalweightunits	varchar(6)	NULL,		
	ord_lengthunit		varchar(6)	NULL,		
	ord_widthunit		varchar(6)	NULL,		
	ord_heightunit		varchar(6)	NULL,		
	loadtime			float		NULL,		
	unloadtime			float		NULL,		
	unloaddttm			datetime	NULL,		
	unloaddttm_early	datetime	NULL,		
	unloaddttm_late		datetime	NULL,		
	ord_totalvolume		int			NULL,		
	ord_totalvolumeunits	varchar(6)	NULL,		
	washstatus			varchar(1)	NULL,		
	f_state				varchar(6)	NULL,		
	l_state				varchar(6)	NULL,		
	evt_driver1_id		varchar(8)	NULL,		
	evt_driver2_id		varchar(8)	NULL,		
	ref_type			varchar(6)	NULL,		
	ref_number			varchar(30)	NULL,		
	d_address1			varchar(40)	NULL,		
	d_address2			varchar(40)	NULL,		
	ord_remark			varchar(254)	NULL,		
	mpp_teamleader		varchar(6)	NULL,		
	lgh_dsp_date		datetime	NULL,		
	lgh_geo_date		datetime	NULL,		
	ordercount			smallint	NULL,		
	npup_cmpid			varchar(8)	NULL,		
	npup_cmpname		varchar(30)	NULL,		
	npup_ctyname		varchar(25)	NULL,		
	npup_state			varchar(6)	NULL,		
	npup_arrivaldate	datetime	NULL,		
	ndrp_cmpid			varchar(8)	NULL,		
	ndrp_cmpname		varchar(30)	NULL,		
	ndrp_ctyname		varchar(25)	NULL,		
	ndrp_state			varchar(6)	NULL,		
	ndrp_arrivaldate	datetime	NULL,		
	can_ld_expires		datetime	NULL,		
	xdock				int			NULL,		
	feetavailable		smallint	NULL,		
	opt_trc_type4		varchar(6)	NULL,		
	opt_trc_type4_label	varchar(20)	NULL,		
	opt_trl_type4		varchar(6)	NULL,		
	opt_trl_type4_label	varchar(20)	NULL,		
	ord_originregion1	varchar(6)	NULL,		
	ord_originregion2	varchar(6)	NULL,		
	ord_originregion3	varchar(6)	NULL,		
	ord_originregion4	varchar(6)	NULL,		
	ord_destregion1		varchar(6)	NULL,		
	ord_destregion2		varchar(6)	NULL,		
	ord_destregion3		varchar(6)	NULL,		
	ord_destregion4		varchar(6)	NULL,		
	npup_departuredate	datetime	NULL,		
	ndrp_departuredate	datetime	NULL,		
	ord_fromorder		varchar(12)	NULL,		
	c_lgh_type1			varchar(20)	NULL,		
	lgh_type1_label		varchar(20)	NULL,		
	c_lgh_type2			varchar(20)	NULL,		
	lgh_type2_label		varchar(20)	NULL,		
	lgh_tm_status		varchar(6)	NULL,		
	lgh_tour_number		int			NULL,		
	extrainfo1			varchar(255)	NULL,		
	extrainfo2			varchar(255)	NULL,		
	extrainfo3			varchar(255)	NULL,		
	extrainfo4			varchar(255)	NULL,		
	extrainfo5			varchar(255)	NULL,		
	extrainfo6			varchar(255)	NULL,		
	extrainfo7			varchar(255)	NULL,		
	extrainfo8			varchar(255)	NULL,		
	extrainfo9			varchar(255)	NULL,		
	extrainfo10			varchar(255)	NULL,		
	extrainfo11			varchar(255)	NULL,		
	extrainfo12			varchar(255)	NULL,		
	extrainfo13			varchar(255)	NULL,		
	extrainfo14			varchar(255)	NULL,		
	extrainfo15			varchar(255)	NULL,		
	o_cmp_geoloc		varchar(50)	NULL,		
	d_cmp_geoloc		varchar(50)	NULL,		
	mpp_fleet			varchar(6)	NULL,		
	mpp_fleet_name		varchar(20)	NULL,		
	next_stp_event_code	varchar(6)	NULL,		
	next_stop_of_total	varchar(10)	NULL,		
	lgh_comment			varchar(255)	NULL,		
	lgh_earliest_pu		datetime	NULL,		
	lgh_latest_pu		datetime	NULL,		
	lgh_earliest_unl	datetime	NULL,		
	lgh_latest_unl		datetime	NULL,		
	lgh_miles			int			NULL,		
	lgh_linehaul		float		NULL,		
	evt_latedate		datetime	NULL,		
	lgh_ord_charge		float		NULL,		
	lgh_act_weight		float		NULL,		
	lgh_est_weight		float		NULL,		
	lgh_tot_weight		float		NULL,		
	lgh_outstat			varchar(6)	NULL,		
	lgh_max_weight_exceeded	char(1)	NULL,		
	lgh_reftype				varchar(6)	NULL,		
	lgh_refnum				varchar(30)	NULL,		
	trctype1				varchar(20)	NULL,		
	trc_type1name			varchar(20)	NULL,		
	trctype2				varchar(20)	NULL,		
	trc_type2name			varchar(20)	NULL,		
	trctype3				varchar(20)	NULL,		
	trc_type3name			varchar(20)	NULL,		
	trctype4				varchar(20)	NULL,		
	trc_type4name			varchar(20)	NULL,		
	lgh_etaalert1			char(1)		NULL,		
	lgh_detstatus			int			NULL,		
	lgh_tm_statusname		varchar(20)	NULL,		
	ord_billto				varchar(8)	NULL,		
	cmp_name				varchar(100)	NULL,		
	lgh_carrier				varchar(64)	NULL,		
	TotalCarrierPay			money		NULL,		
	lgh_hzd_cmd_class		varchar(8)	NULL,		
	lgh_washplan			varchar(20)	NULL,		
	fgt_length				float		NULL,		
	fgt_width				float		NULL,		
	fgt_height				float		NULL,		
	lgh_originzip			varchar(10)	NULL,		
	lgh_destzip				varchar(10)	NULL,		
	ord_company				varchar(12)	NULL,		
	origin_servicezone		varchar(20)	NULL,		
	o_servicezone_t			varchar(20)	NULL,		
	origin_servicearea		varchar(20)	NULL,		
	o_servicearea_t			varchar(20)	NULL,		
	origin_servicecenter	varchar(20)	NULL,		
	o_servicecenter_t		varchar(20)	NULL,		
	origin_serviceregion	varchar(20)	NULL,		
	o_serviceregion_t		varchar(20)	NULL,		
	dest_servicezone		varchar(20)	NULL,		
	dest_servicezone_t		varchar(20)	NULL,		
	dest_servicearea		varchar(20)	NULL,		
	dest_servicearea_t		varchar(20)	NULL,		
	dest_servicecenter		varchar(20)	NULL,		
	dest_servicecenter_t	varchar(20)	NULL,		
	dest_serviceregion		varchar(20)	NULL,		
	dest_serviceregion_t	varchar(20)	NULL,		
	lgh_204status			varchar(30)	NULL,  
 -- PTS 29347 -- BL (start)  --PTS92864
	origin_cmp_lat			decimal(14,6)	NULL,		
	origin_cmp_long			decimal(14,6)	NULL,		
	origin_cty_lat			decimal(14,6)	NULL,		
	origin_cty_long			decimal(14,6)	NULL,  
 -- PTS 29347 -- BL (end)  
	lgh_route				varchar(15)		NULL,		
	lgh_booked_revtype1		varchar(12)		NULL,		
	lgh_permit_status		varchar(6)		NULL,		
	lgh_permit_status_t		varchar(20)		NULL,		
	lgh_204date				datetime		NULL,		
 -- PTS 33890 BDH 9/13/06 start  
	next_ndrp_cmpid			varchar(8)		null,		
	next_ndrp_cmpname		varchar(30)		null,		
	next_ndrp_ctyname		varchar(25)		null,		
	next_ndrp_state			varchar(6)		null,		
	next_ndrp_arrivaldate	datetime		null,		
 -- PTS 33890 BDH 9/13/06 start  
 -- PTS 33913 EMK 10/03/06 start   
	ord_bookdate			datetime		null,	 
 -- PTS 33913 EMK 10/03/06 end  
	lgh_ace_status_name		varchar(20)		null, --PTS 35199 AROSS  
	manualcheckcalltime		datetime		null, --PTS 35708 vjh  
	evt_earlydate			datetime		null,  
	TimeZoneAdjMins			int				null,  --PTS35747  
	locked_by				varchar(20)		null,  -- 36717
	session_date			datetime		null,	-- 36717
	ord_cbp					char(1)			null,	-- PTS 38765
	lgh_ace_status			varchar(6)		null,
	trc_latest_ctyst	    varchar(30)		null,
	trc_latest_cmpid			varchar(8)	null,
	trc_last_mobcomm_received	datetime	null,
	trc_mobcomm_type			varchar(20)	null,
	trc_nearest_mobcomm_nmstct	varchar(20)	null,	-- PTS 38765
	next_stop_ref_number		varchar(30) null,   -- PTS 38138 JJF 20080122
	ord_mintemp					smallint,
	ord_maxtemp					smallint,
	ord_order_source			varchar (6) NULL,	-- 08/19/2010 MDH PTS 52714: Added --	
	ud_column1	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column1_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column2	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column2_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column3	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column3_t varchar(30),		 --	PTS 51911 SGB User Defined column header
	ud_column4	varchar(255),		 -- PTS 51911 SGB User Defined column
	ud_column4_t varchar(30))		 --	PTS 51911 SGB User Defined column header	

--PTS 50661 JJF 20100212
DECLARE @legheader_active TABLE (
	[lgh_number] [int] NOT NULL,
	[lgh_firstlegnumber] [int] NULL,
	[lgh_lastlegnumber] [int] NULL,
	[lgh_drvtripnumber] [int] NULL,
	[lgh_cost] [float] NULL,
	[lgh_revenue] [float] NULL,
	[lgh_odometerstart] [int] NULL,
	[lgh_odometerend] [int] NULL,
	[lgh_milesshortest] [smallint] NULL,
	[lgh_milespractical] [smallint] NULL,
	[lgh_allocfactor] [float] NULL,
	[lgh_startdate] [datetime] NULL,
	[lgh_enddate] [datetime] NULL,
	[lgh_startcity] [int] NULL,
	[lgh_endcity] [int] NULL,
	[lgh_startregion1] [varchar](6) NULL,
	[lgh_endregion1] [varchar](6) NULL,
	[lgh_startstate] [varchar](6) NULL,
	[lgh_endstate] [varchar](6) NULL,
	[lgh_outstatus] [varchar](6) NULL,
	[lgh_startlat] [int] NULL,
	[lgh_startlong] [int] NULL,
	[lgh_endlat] [int] NULL,
	[lgh_endlong] [int] NULL,
	[lgh_class1] [varchar](6) NULL,
	[lgh_class2] [varchar](6) NULL,
	[lgh_class3] [varchar](6) NULL,
	[lgh_class4] [varchar](6) NULL,
	[stp_number_start] [int] NULL,
	[stp_number_end] [int] NULL,
	[cmp_id_start] [varchar](12) NULL,
	[cmp_id_end] [varchar](12) NULL,
	[lgh_startregion2] [varchar](6) NULL,
	[lgh_startregion3] [varchar](6) NULL,
	[lgh_startregion4] [varchar](6) NULL,
	[lgh_endregion2] [varchar](6) NULL,
	[lgh_endregion3] [varchar](6) NULL,
	[lgh_endregion4] [varchar](6) NULL,
	[lgh_instatus] [varchar](6) NULL,
	[lgh_driver1] [varchar](8) NULL,
	[lgh_driver2] [varchar](8) NULL,
	[lgh_tractor] [varchar](8) NULL,
	[lgh_primary_trailer] [varchar](13) NULL,
	[mov_number] [int] NULL,
	[fgt_number] [int] NULL,
	[lgh_priority] [varchar](6) NULL,
	[lgh_schdtearliest] [datetime] NULL,
	[lgh_schdtlatest] [datetime] NULL,
	[cmd_code] [varchar](8) NULL,
	[fgt_description] [varchar](60) NULL,
	[mpp_teamleader] [varchar](6) NULL,
	[mpp_fleet] [varchar](6) NULL,
	[mpp_division] [varchar](6) NULL,
	[mpp_domicile] [varchar](6) NULL,
	[mpp_company] [varchar](6) NULL,
	[mpp_terminal] [varchar](6) NULL,
	[mpp_type1] [varchar](6) NULL,
	[mpp_type2] [varchar](6) NULL,
	[mpp_type3] [varchar](6) NULL,
	[mpp_type4] [varchar](6) NULL,
	[trc_company] [varchar](6) NULL,
	[trc_division] [varchar](6) NULL,
	[trc_fleet] [varchar](6) NULL,
	[trc_terminal] [varchar](6) NULL,
	[trc_type1] [varchar](6) NULL,
	[trc_type2] [varchar](6) NULL,
	[trc_type3] [varchar](6) NULL,
	[trc_type4] [varchar](6) NULL,
	[mfh_number] [int] NULL,
	[trl_company] [varchar](6) NULL,
	[trl_fleet] [varchar](6) NULL,
	[trl_division] [varchar](6) NULL,
	[trl_terminal] [varchar](6) NULL,
	[trl_type1] [varchar](6) NULL,
	[trl_type2] [varchar](6) NULL,
	[trl_type3] [varchar](6) NULL,
	[trl_type4] [varchar](6) NULL,
	[ord_hdrnumber] [int] NULL,
	--[timestamp] [timestamp] NULL,
	[lgh_fueltaxstatus] [varchar](6) NULL,
	[lgh_mtmiles] [smallint] NULL,
	[lgh_prjdate1] [datetime] NULL,
	[lgh_etaalert1] [char](1) NULL,
	[lgh_etamins1] [int] NULL,
	[lgh_outofroute_routing] [char](1) NULL,
	[lgh_type1] [varchar](6) NULL,
	[lgh_alloc_revenue] [money] NULL,
	[lgh_primary_pup] [varchar](13) NULL,
	[lgh_prod_hr] [float] NULL,
	[lgh_tot_hr] [float] NULL,
	[lgh_ld_unld_time] [float] NULL,
	[lgh_load_time] [float] NULL,
	[lgh_startcty_nmstct] [varchar](25) NULL,
	[lgh_endcty_nmstct] [varchar](25) NULL,
	[lgh_carrier] [varchar](8) NULL,
	[lgh_enddate_arrival] [datetime] NULL,
	[lgh_dsp_date] [datetime] NULL,
	[lgh_geo_date] [datetime] NULL,
	[lgh_nexttrailer1] [varchar](13) NULL,
	[lgh_nexttrailer2] [varchar](13) NULL,
	[lgh_etamilestofinal] [int] NULL,
	[lgh_etamintofinal] [int] NULL,
	[lgh_split_flag] [char](1) NULL,
	[lgh_createdby] [varchar](128) NULL,
	[lgh_createdon] [datetime] NULL,
	[lgh_createapp] [varchar](128) NULL,
	[lgh_updatedby] [varchar](128) NULL,
	[lgh_updatedon] [datetime] NULL,
	[lgh_updateapp] [varchar](128) NULL,
	[lgh_rstartdate] [datetime] NULL,
	[lgh_renddate] [datetime] NULL,
	[lgh_rstartcity] [int] NULL,
	[lgh_rendcity] [int] NULL,
	[lgh_rstartregion1] [varchar](6) NULL,
	[lgh_rendregion1] [varchar](6) NULL,
	[lgh_rstartstate] [varchar](6) NULL,
	[lgh_rendstate] [varchar](6) NULL,
	[lgh_rstartlat] [int] NULL,
	[lgh_rstartlong] [int] NULL,
	[lgh_rendlat] [int] NULL,
	[lgh_rendlong] [int] NULL,
	[stp_number_rstart] [int] NULL,
	[stp_number_rend] [int] NULL,
	[cmp_id_rstart] [varchar](12) NULL,
	[cmp_id_rend] [varchar](12) NULL,
	[lgh_rstartregion2] [varchar](6) NULL,
	[lgh_rstartregion3] [varchar](6) NULL,
	[lgh_rstartregion4] [varchar](6) NULL,
	[lgh_rendregion2] [varchar](6) NULL,
	[lgh_rendregion3] [varchar](6) NULL,
	[lgh_rendregion4] [varchar](6) NULL,
	[lgh_rstartcty_nmstct] [varchar](25) NULL,
	[lgh_rendcty_nmstct] [varchar](25) NULL,
	[lgh_feetavailable] [smallint] NULL,
	[can_cap_expires] [datetime] NULL,
	[can_ld_expires] [datetime] NULL,
	[lgh_dispatchdate] [datetime] NULL,
	[lgh_asset_lock] [char](1) NULL,
	[lgh_asset_lock_dtm] [datetime] NULL,
	[lgh_asset_lock_user] [varchar](20) NULL,
	[lgh_load_origin] [varchar](12) NULL,
	[lgh_est_lhrate] [float] NULL,
	[lgh_est_lhpay] [float] NULL,
	[lgh_est_dhrate] [float] NULL,
	[lgh_est_dhpay] [float] NULL,
	[lgh_est_accessorials] [float] NULL,
	[drvplan_number] [int] NULL,
	[next_drp_stp_number] [int] NULL,
	[next_pup_stp_number] [int] NULL,
	[ord_totalweight] [int] NULL,
	[ord_totalvolume] [int] NULL,
	[tot_count] [int] NULL,
	[cmd_count] [int] NULL,
	[ordercount] [smallint] NULL,
	[xdock] [int] NULL,
	[ord_stopcount] [tinyint] NULL,
	[washstatus] [varchar](1) NULL,
	[ref_type] [varchar](6) NULL,
	[ref_number] [varchar](30) NULL,
	[npup_cmpid] [varchar](8) NULL,
	[npup_cmpname] [varchar](30) NULL,
	[npup_ctyname] [varchar](25) NULL,
	[npup_state] [varchar](6) NULL,
	[npup_arrivaldate] [datetime] NULL,
	[ndrp_cmpid] [varchar](8) NULL,
	[ndrp_cmpname] [varchar](30) NULL,
	[ndrp_ctyname] [varchar](25) NULL,
	[ndrp_state] [varchar](6) NULL,
	[ndrp_arrivaldate] [datetime] NULL,
	[npup_departuredate] [datetime] NULL,
	[ndrp_departuredate] [datetime] NULL,
	[lgh_type2] [varchar](6) NULL,
	[lgh_extrainfo1] [varchar](255) NULL,
	[lgh_extrainfo2] [varchar](30) NULL,
	[lgh_extrainfo3] [varchar](30) NULL,
	[lgh_extrainfo4] [varchar](30) NULL,
	[lgh_extrainfo5] [varchar](30) NULL,
	[lgh_extrainfo6] [varchar](30) NULL,
	[lgh_extrainfo7] [varchar](30) NULL,
	[lgh_extrainfo8] [varchar](30) NULL,
	[lgh_extrainfo9] [varchar](30) NULL,
	[lgh_extrainfo10] [varchar](30) NULL,
	[lgh_extrainfo11] [varchar](30) NULL,
	[lgh_extrainfo12] [varchar](30) NULL,
	[lgh_extrainfo13] [varchar](30) NULL,
	[lgh_extrainfo14] [varchar](30) NULL,
	[lgh_extrainfo15] [varchar](30) NULL,
	[lgh_tm_status] [varchar](6) NULL,
	[lgh_tour_number] [int] NULL,
	[o_cmpname] [varchar](30) NULL,
	[o_state] [varchar](6) NULL,
	[d_cmpname] [varchar](30) NULL,
	[d_state] [varchar](6) NULL,
	[f_cmpid] [varchar](8) NULL,
	[f_cmpname] [varchar](30) NULL,
	[f_ctyname] [varchar](25) NULL,
	[f_state] [varchar](6) NULL,
	[l_cmpid] [varchar](8) NULL,
	[l_cmpname] [varchar](30) NULL,
	[l_ctyname] [varchar](25) NULL,
	[l_state] [varchar](6) NULL,
	[evt_driver1_name] [varchar](45) NULL,
	[evt_driver2_name] [varchar](45) NULL,
	[lgh_outstatus_name] [varchar](20) NULL,
	[lgh_instatus_name] [varchar](20) NULL,
	[lgh_priority_name] [varchar](20) NULL,
	[trl_type1_name] [varchar](20) NULL,
	[lgh_class1_name] [varchar](20) NULL,
	[lgh_class2_name] [varchar](20) NULL,
	[lgh_class3_name] [varchar](20) NULL,
	[lgh_class4_name] [varchar](20) NULL,
	[opt_trc_type4_label] [varchar](20) NULL,
	[opt_trl_type4_label] [varchar](20) NULL,
	[c_lgh_type1] [varchar](20) NULL,
	[c_lgh_type2] [varchar](20) NULL,
	[mpp_fleet_name] [varchar](20) NULL,
	[ord_ord_subcompany] [varchar](8) NULL,
	[ord_bookedby] [varchar](20) NULL,
	[ord_trl_type1] [varchar](6) NULL,
	[ord_totalmiles] [int] NULL,
	[o_cmp_geoloc] [varchar](50) NULL,
	[d_cmp_geoloc] [varchar](50) NULL,
	[d_address1] [varchar](40) NULL,
	[d_address2] [varchar](40) NULL,
	[next_stp_event_code] [varchar](6) NULL,
	[next_stop_of_total] [varchar](10) NULL,
	[lgh_comment] [varchar](255) NULL,
	[lgh_miles] [int] NULL,
	[lgh_linehaul] [float] NULL,
	[lgh_ord_charge] [float] NULL,
	[lgh_act_weight] [float] NULL,
	[lgh_est_weight] [float] NULL,
	[lgh_tot_weight] [float] NULL,
	[lgh_reftype] [varchar](6) NULL,
	[lgh_refnum] [varchar](30) NULL,
	[lgh_max_weight_exceeded] [char](1) NULL,
	[trc_type1name] [varchar](20) NULL,
	[trc_type2name] [varchar](20) NULL,
	[trc_type3name] [varchar](20) NULL,
	[trc_type4name] [varchar](20) NULL,
	[lgh_tmstatusstopnumber] [int] NULL,
	[lgh_tm_statusname] [varchar](20) NULL,
	--PTS 51955 JJF 20100415
	--[lgh_detstatus] [int] NOT NULL,
	[lgh_detstatus] [int] NULL,
	--END PTS 51955 JJF 20100415
	[ord_billto] [varchar](8) NULL,
	[lgh_washplan] [varchar](20) NULL,
	[lgh_hzd_cmd_class] [varchar](8) NULL,
	[ord_company] [varchar](8) NULL,
	[lgh_originzip] [varchar](10) NULL,
	[lgh_destzip] [varchar](10) NULL,
	[lgh_204status] [varchar](30) NULL,
	[lgh_route] [varchar](15) NULL,
	[lgh_booked_revtype1] [varchar](12) NULL,
	[lgh_order_source] [varchar](6) NULL,
	[lgh_permit_status] [varchar](6) NULL,
	[lgh_204date] [datetime] NULL,
	[lgh_trc_comment] [varchar](255) NULL,
	[lgh_ace_status] [varchar](6) NULL,
	[next_ndrp_cmpid] [varchar](8) NULL,
	[next_ndrp_cmpname] [varchar](30) NULL,
	[next_ndrp_ctyname] [varchar](25) NULL,
	[next_ndrp_state] [varchar](6) NULL,
	[next_ndrp_arrivaldate] [datetime] NULL,
	[lgh_ace_status_name] [varchar](20) NULL,
	--PTS 51955 JJF 20100415
	--[lgh_chassis] [varchar](13) NOT NULL,
	--[lgh_chassis2] [varchar](13) NOT NULL,
	[lgh_chassis] [varchar](13) NULL,
	[lgh_chassis2] [varchar](13) NULL,
	--END PTS 51955 JJF 20100415
	[lgh_204_tradingpartner] [varchar](20) NULL,
	[lgh_prev_seg_status] [varchar](6) NULL,
	[lgh_prev_seg_status_last_updated] [datetime] NULL,
	[lgh_total_mov_bill_miles] [int] NULL ,
	[lgh_total_mov_miles] int NULL,
	[ma_transaction_id] [bigint] NULL,
	[ma_tour_number] [int] NULL,
	[ma_tour_sequence] [tinyint] NULL,
	[ma_tour_max_sequence] [tinyint] NULL,
	[ma_mpp_id] [varchar](8) NULL,
	[ma_trc_number] [varchar](8) NULL,
	[ma_lgh_number] [int] NULL,
	[lgh_mile_overage_message] [varchar](64) NULL,
	[lgh_car_rate] [money] NULL,
	[lgh_car_charge] [money] NULL,
	[lgh_car_accessorials] [decimal](12, 4) NULL,
	[lgh_car_totalcharge] [money] NULL,
	[lgh_recommended_car_id] [varchar](8) NULL,
	[lgh_spot_rate_updatedby] [varchar](20) NULL,
	[lgh_spot_rate_updateddt] [datetime] NULL,
	[lgh_spot_rate] [char](1) NULL,
	[lgh_ship_status] [varchar](6) NULL,
	[lgh_protected_rate] [money] NULL,
	[lgh_avg_rate] [money] NULL,
	[lgh_edi_counter] [varchar](30) NULL,
	[lgh_faxemail_created] [char](1) NULL,
	[lgh_externalrating_miles] [int] NULL,
	[lgh_acc_fsc] [money] NULL,
	[lgh_raildispatchstatus] [varchar](6) NULL,
	[lgh_dolly] [varchar](13) NULL,
	[lgh_dolly2] [varchar](13) NULL,
	[lgh_trailer3] [varchar](13) NULL,
	[lgh_trailer4] [varchar](13) NULL
)

select @citylatlongunits = Left (LTrim (ISNull (gi_string1, 'N')), 1) from generalinfo where gi_name = 'CityLatLongUnits'

IF EXISTS(SELECT * FROM legheader_active WHERE lgh_number = @lgh_number) BEGIN
	--Pull directly from legheader_active
	INSERT	@legheader_active	(
		lgh_number,
		lgh_firstlegnumber,
		lgh_lastlegnumber,
		lgh_drvtripnumber,
		lgh_cost,
		lgh_revenue,
		lgh_odometerstart,
		lgh_odometerend,
		lgh_milesshortest,
		lgh_milespractical,
		lgh_allocfactor,
		lgh_startdate,
		lgh_enddate,
		lgh_startcity,
		lgh_endcity,
		lgh_startregion1,
		lgh_endregion1,
		lgh_startstate,
		lgh_endstate,
		lgh_outstatus,
		lgh_startlat,
		lgh_startlong,
		lgh_endlat,
		lgh_endlong,
		lgh_class1,
		lgh_class2,
		lgh_class3,
		lgh_class4,
		stp_number_start,
		stp_number_end,
		cmp_id_start,
		cmp_id_end,
		lgh_startregion2,
		lgh_startregion3,
		lgh_startregion4,
		lgh_endregion2,
		lgh_endregion3,
		lgh_endregion4,
		lgh_instatus,
		lgh_driver1,
		lgh_driver2,
		lgh_tractor,
		lgh_primary_trailer,
		mov_number,
		fgt_number,
		lgh_priority,
		lgh_schdtearliest,
		lgh_schdtlatest,
		cmd_code,
		fgt_description,
		mpp_teamleader,
		mpp_fleet,
		mpp_division,
		mpp_domicile,
		mpp_company,
		mpp_terminal,
		mpp_type1,
		mpp_type2,
		mpp_type3,
		mpp_type4,
		trc_company,
		trc_division,
		trc_fleet,
		trc_terminal,
		trc_type1,
		trc_type2,
		trc_type3,
		trc_type4,
		mfh_number,
		trl_company,
		trl_fleet,
		trl_division,
		trl_terminal,
		trl_type1,
		trl_type2,
		trl_type3,
		trl_type4,
		ord_hdrnumber,
		lgh_fueltaxstatus,
		lgh_mtmiles,
		lgh_prjdate1,
		lgh_etaalert1,
		lgh_etamins1,
		lgh_outofroute_routing,
		lgh_type1,
		lgh_alloc_revenue,
		lgh_primary_pup,
		lgh_prod_hr,
		lgh_tot_hr,
		lgh_ld_unld_time,
		lgh_load_time,
		lgh_startcty_nmstct,
		lgh_endcty_nmstct,
		lgh_carrier,
		lgh_enddate_arrival,
		lgh_dsp_date,
		lgh_geo_date,
		lgh_nexttrailer1,
		lgh_nexttrailer2,
		lgh_etamilestofinal,
		lgh_etamintofinal,
		lgh_split_flag,
		lgh_createdby,
		lgh_createdon,
		lgh_createapp,
		lgh_updatedby,
		lgh_updatedon,
		lgh_updateapp,
		lgh_rstartdate,
		lgh_renddate,
		lgh_rstartcity,
		lgh_rendcity,
		lgh_rstartregion1,
		lgh_rendregion1,
		lgh_rstartstate,
		lgh_rendstate,
		lgh_rstartlat,
		lgh_rstartlong,
		lgh_rendlat,
		lgh_rendlong,
		stp_number_rstart,
		stp_number_rend,
		cmp_id_rstart ,
		cmp_id_rend,
		lgh_rstartregion2,
		lgh_rstartregion3,
		lgh_rstartregion4,
		lgh_rendregion2,
		lgh_rendregion3,
		lgh_rendregion4,
		lgh_rstartcty_nmstct,
		lgh_rendcty_nmstct,
		lgh_feetavailable,
		can_cap_expires,
		can_ld_expires,
		lgh_dispatchdate,
		lgh_asset_lock,
		lgh_asset_lock_dtm,
		lgh_asset_lock_user,
		drvplan_number,
		next_drp_stp_number,
		next_pup_stp_number,
		ord_totalweight,
		ord_totalvolume,
		tot_count,
		cmd_count,
		ordercount,
		xdock,
		ord_stopcount,
		washstatus,
		ref_type,
		ref_number,
		ndrp_cmpid,
		ndrp_cmpname,
		ndrp_ctyname,
		ndrp_state,
		ndrp_arrivaldate,
		npup_cmpid,
		npup_cmpname,
		npup_ctyname,
		npup_state,
		npup_arrivaldate,
		npup_departuredate,
		ndrp_departuredate,
		lgh_type2,
		lgh_tm_status,
		lgh_tour_number,
		lgh_extrainfo1,
		lgh_extrainfo2,
		lgh_extrainfo3,
		lgh_extrainfo4,
		lgh_extrainfo5,
		lgh_extrainfo6,
		lgh_extrainfo7,
		lgh_extrainfo8,
		lgh_extrainfo9,
		lgh_extrainfo10,
		lgh_extrainfo11,
		lgh_extrainfo12,
		lgh_extrainfo13,
		lgh_extrainfo14,
		lgh_extrainfo15,
		o_cmpname,
		d_cmpname,
		f_cmpid,
		f_cmpname,
		f_ctyname,
		f_state,
		l_cmpid,
		l_cmpname,
		l_ctyname,
		l_state,
		evt_driver1_name,
		evt_driver2_name,
		lgh_outstatus_name,
		lgh_instatus_name,
		lgh_priority_name,
		trl_type1_name,
		lgh_class1_name,
		lgh_class2_name,
		lgh_class3_name,
		lgh_class4_name,
		opt_trc_type4_label,
		opt_trl_type4_label,
		c_lgh_type1,
		c_lgh_type2,
		mpp_fleet_name,
		ord_ord_subcompany,
		ord_bookedby,
		ord_trl_type1,
		o_cmp_geoloc,
		d_cmp_geoloc,
		d_address1,
		d_address2,
		ord_totalmiles,
		next_stp_event_code,
		next_stop_of_total,
		lgh_comment,
		lgh_miles,
		lgh_linehaul,
		lgh_ord_charge,
		lgh_act_weight,
		lgh_est_weight,
		lgh_tot_weight,
		lgh_max_weight_exceeded,
		lgh_reftype,
		lgh_refnum,
		trc_type1name,
		trc_type2name,
		trc_type3name,
		trc_type4name,
		lgh_detstatus,
		lgh_tmstatusstopnumber,
		lgh_tm_statusname,
		ord_billto,
		lgh_hzd_cmd_class,
		lgh_washplan,
		lgh_originzip,
		lgh_destzip,
		ord_company,
		lgh_204status,
		lgh_route,
		lgh_booked_revtype1,
		lgh_permit_status,
		lgh_204date,
		lgh_trc_comment,
		lgh_ace_status,
		next_ndrp_cmpid,
		next_ndrp_cmpname,
		next_ndrp_ctyname,
		next_ndrp_state,
		next_ndrp_arrivaldate,
		lgh_ace_status_name,
		lgh_prev_seg_status,
		lgh_prev_seg_status_last_updated,
		lgh_204_tradingpartner,
		lgh_chassis,
		lgh_chassis2
	)
	SELECT 
		lgh_number,
		lgh_firstlegnumber,
		lgh_lastlegnumber,
		lgh_drvtripnumber,
		lgh_cost,
		lgh_revenue,
		lgh_odometerstart,
		lgh_odometerend,
		lgh_milesshortest,
		lgh_milespractical,
		lgh_allocfactor,
		lgh_startdate,
		lgh_enddate,
		lgh_startcity,
		lgh_endcity,
		lgh_startregion1,
		lgh_endregion1,
		lgh_startstate,
		lgh_endstate,
		lgh_outstatus,
		lgh_startlat,
		lgh_startlong,
		lgh_endlat,
		lgh_endlong,
		lgh_class1,
		lgh_class2,
		lgh_class3,
		lgh_class4,
		stp_number_start,
		stp_number_end,
		cmp_id_start,
		cmp_id_end,
		lgh_startregion2,
		lgh_startregion3,
		lgh_startregion4,
		lgh_endregion2,
		lgh_endregion3,
		lgh_endregion4,
		lgh_instatus,
		lgh_driver1,
		lgh_driver2,
		lgh_tractor,
		lgh_primary_trailer,
		mov_number,
		fgt_number,
		lgh_priority,
		lgh_schdtearliest,
		lgh_schdtlatest,
		cmd_code,
		fgt_description,
		mpp_teamleader,
		mpp_fleet,
		mpp_division,
		mpp_domicile,
		mpp_company,
		mpp_terminal,
		mpp_type1,
		mpp_type2,
		mpp_type3,
		mpp_type4,
		trc_company,
		trc_division,
		trc_fleet,
		trc_terminal,
		trc_type1,
		trc_type2,
		trc_type3,
		trc_type4,
		mfh_number,
		trl_company,
		trl_fleet,
		trl_division,
		trl_terminal,
		trl_type1,
		trl_type2,
		trl_type3,
		trl_type4,
		ord_hdrnumber,
		lgh_fueltaxstatus,
		lgh_mtmiles,
		lgh_prjdate1,
		lgh_etaalert1,
		lgh_etamins1,
		lgh_outofroute_routing,
		lgh_type1,
		lgh_alloc_revenue,
		lgh_primary_pup,
		lgh_prod_hr,
		lgh_tot_hr,
		lgh_ld_unld_time,
		lgh_load_time,
		lgh_startcty_nmstct,
		lgh_endcty_nmstct,
		lgh_carrier,
		lgh_enddate_arrival,
		lgh_dsp_date,
		lgh_geo_date,
		lgh_nexttrailer1,
		lgh_nexttrailer2,
		lgh_etamilestofinal,
		lgh_etamintofinal,
		lgh_split_flag,
		lgh_createdby,
		lgh_createdon,
		lgh_createapp,
		lgh_updatedby,
		lgh_updatedon,
		lgh_updateapp,
		lgh_rstartdate,
		lgh_renddate,
		lgh_rstartcity,
		lgh_rendcity,
		lgh_rstartregion1,
		lgh_rendregion1,
		lgh_rstartstate,
		lgh_rendstate,
		lgh_rstartlat,
		lgh_rstartlong,
		lgh_rendlat,
		lgh_rendlong,
		stp_number_rstart,
		stp_number_rend,
		cmp_id_rstart ,
		cmp_id_rend,
		lgh_rstartregion2,
		lgh_rstartregion3,
		lgh_rstartregion4,
		lgh_rendregion2,
		lgh_rendregion3,
		lgh_rendregion4,
		lgh_rstartcty_nmstct,
		lgh_rendcty_nmstct,
		lgh_feetavailable,
		can_cap_expires,
		can_ld_expires,
		lgh_dispatchdate,
		lgh_asset_lock,
		lgh_asset_lock_dtm,
		lgh_asset_lock_user,
		drvplan_number,
		next_drp_stp_number,
		next_pup_stp_number,
		ord_totalweight,
		ord_totalvolume,
		tot_count,
		cmd_count,
		ordercount,
		xdock,
		ord_stopcount,
		washstatus,
		ref_type,
		ref_number,
		ndrp_cmpid,
		ndrp_cmpname,
		ndrp_ctyname,
		ndrp_state,
		ndrp_arrivaldate,
		npup_cmpid,
		npup_cmpname,
		npup_ctyname,
		npup_state,
		npup_arrivaldate,
		npup_departuredate,
		ndrp_departuredate,
		lgh_type2,
		lgh_tm_status,
		lgh_tour_number,
		lgh_extrainfo1,
		lgh_extrainfo2,
		lgh_extrainfo3,
		lgh_extrainfo4,
		lgh_extrainfo5,
		lgh_extrainfo6,
		lgh_extrainfo7,
		lgh_extrainfo8,
		lgh_extrainfo9,
		lgh_extrainfo10,
		lgh_extrainfo11,
		lgh_extrainfo12,
		lgh_extrainfo13,
		lgh_extrainfo14,
		lgh_extrainfo15,
		o_cmpname,
		d_cmpname,
		f_cmpid,
		f_cmpname,
		f_ctyname,
		f_state,
		l_cmpid,
		l_cmpname,
		l_ctyname,
		l_state,
		evt_driver1_name,
		evt_driver2_name,
		lgh_outstatus_name,
		lgh_instatus_name,
		lgh_priority_name,
		trl_type1_name,
		lgh_class1_name,
		lgh_class2_name,
		lgh_class3_name,
		lgh_class4_name,
		opt_trc_type4_label,
		opt_trl_type4_label,
		c_lgh_type1,
		c_lgh_type2,
		mpp_fleet_name,
		ord_ord_subcompany,
		ord_bookedby,
		ord_trl_type1,
		o_cmp_geoloc,
		d_cmp_geoloc,
		d_address1,
		d_address2,
		ord_totalmiles,
		next_stp_event_code,
		next_stop_of_total,
		lgh_comment,
		lgh_miles,
		lgh_linehaul,
		lgh_ord_charge,
		lgh_act_weight,
		lgh_est_weight,
		lgh_tot_weight,
		lgh_max_weight_exceeded,
		lgh_reftype,
		lgh_refnum,
		trc_type1name,
		trc_type2name,
		trc_type3name,
		trc_type4name,
		lgh_detstatus,
		lgh_tmstatusstopnumber,
		lgh_tm_statusname,
		ord_billto,
		lgh_hzd_cmd_class,
		lgh_washplan,
		lgh_originzip,
		lgh_destzip,
		ord_company,
		lgh_204status,
		lgh_route,
		lgh_booked_revtype1,
		lgh_permit_status,
		lgh_204date,
		lgh_trc_comment,
		lgh_ace_status,
		next_ndrp_cmpid,
		next_ndrp_cmpname,
		next_ndrp_ctyname,
		next_ndrp_state,
		next_ndrp_arrivaldate,
		lgh_ace_status_name,
		lgh_prev_seg_status,
		lgh_prev_seg_status_last_updated,
		lgh_204_tradingpartner,
		lgh_chassis,
		lgh_chassis2
	FROM	legheader_active
	WHERE	legheader_active.lgh_number = @lgh_number
END
ELSE BEGIN
	--Retrieve legheader_active on the fly for completed trips
	INSERT INTO @legheader_active
		SELECT * 
		FROM dbo.legheader_active_generate_row_fn(@lgh_number) 
END

select @Apocalypse = convert(datetime,'20491231 23:59:59')
  
-- RE - PTS #52017 BEGIN
DECLARE	@MatchAdviceInterface		CHAR(1)
DECLARE	@ma_transaction_id			BIGINT
DECLARE	@ma_inserted_date			DATETIME
DECLARE	@null_varchar8				VARCHAR(8)
DECLARE	@null_varchar100			VARCHAR(100)
DECLARE	@null_int					INTEGER
DECLARE	@Check						INTEGER
DECLARE @MatchAdviceMultiCompany	CHAR(1)
DECLARE @DefaultCompanyID			VARCHAR(8)
DECLARE @UserCompanyID				VARCHAR(8)
DECLARE @TMWUser					VARCHAR(255)

SELECT	@null_varchar8 = NULL, @null_int = NULL, @null_varchar100 = NULL

SELECT	@MatchAdviceInterface = LEFT(gi_string1, 1),
		@Check = gi_integer1
  FROM	generalinfo
 WHERE	gi_name = 'MatchAdviceInterface'
 
 SELECT	@MatchAdviceMultiCompany = LEFT(gi_string1, 1)
  FROM	generalinfo
 WHERE	gi_name = 'MatchAdviceMultiCompany'
 
 exec @tmwuser = dbo.gettmwuser_fn

SELECT	@MatchAdviceInterface = ISNULL(@MatchAdviceInterface, 'N'), @Check = ISNULL(@Check, 60), @MatchAdviceMultiCompany = ISNULL(@MatchAdviceMultiCompany, 'N'), @DefaultCompanyID = ISNULL(@DefaultCompanyID, '')

IF @MatchAdviceInterface = 'Y'
BEGIN
	IF @MatchAdviceMultiCompany = 'Y'
	BEGIN
		SELECT	@DefaultCompanyID = ISNULL(ttsusers.usr_type1, @DefaultCompanyID)
		  FROM	ttsusers
		 WHERE	(usr_userid = @tmwuser 
		    OR	 usr_windows_userid = @TMWUser)
  
		SELECT	TOP 1 
				@ma_transaction_id = transaction_id,
				@ma_inserted_date = inserted_date
		  FROM	LastMATransactionID
		 WHERE	company_id = @DefaultCompanyID
		ORDER BY inserted_date DESC
	END
	ELSE
	BEGIN
		SELECT	TOP 1 
				@ma_transaction_id = transaction_id,
				@ma_inserted_date = inserted_date
		  FROM	LastMATransactionID
		ORDER BY inserted_date DESC
	END

	IF ISNULL(@ma_transaction_id, -1) = -1
	BEGIN
		SET	@ma_transaction_id = NULL
	END
	ELSE
	BEGIN
		IF DATEDIFF(mi, @ma_inserted_date, GETDATE()) > @Check
		BEGIN
			SET	@ma_transaction_id = NULL
		END
	END
END
ELSE
BEGIN
	SET	@ma_transaction_id = NULL
END
-- RE - PTS #52017 END

  
-- RE - 10/15/02 - PTS #15024  
SELECT @LateWarnMode = gi_string1 FROM generalinfo WHERE gi_name = 'PlnWrkshtLateWarnMode'  
  
-- PTS 25895 JLB need to add the ability to determine where extrainfo comes from  
Select @PWExtraInfoLocation = UPPER(isnull(gi_string1,'ORDERHEADER'))  
  from generalinfo  
 where gi_name = 'PWExtraInfoLocation'  
  
-- LOR PTS# 28465  
select @pending_statuses = IsNull(Upper(RTRIM(LTRIM(gi_string2))), '')  
from generalinfo  
where gi_name = 'DisplayPendingOrders' and gi_string1 = 'Y'  
  
  
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

     exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
     select @v_LocalCityTZAdjFactor = 
       ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
  END  
/* 35747 end */ 

--PTS 37075 SGB Added select to get label name for company label
select @SubCompanyLabel = (Select DISTINCT userlabelname from labelfile where  labeldefinition = 'Company')
  
--PTS32875 MBR 05/16/06  
SELECT @UseShowAsShipperConsignee = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')  
  FROM generalinfo  
 WHERE gi_name = 'UseShowAsShipperConsignee'  

--PTS38986 vjh 09/07/07  
SELECT @PlnWrkshtRefStr1 = ISNULL(LEFT(UPPER(gi_string1), 1), 'N'), @PlnWrkshtRefStr2 = ISNULL(gi_string2, 'stops'), @PlnWrkshtRefStr3 = ISNULL(gi_string3, 'REF')
  FROM generalinfo  
 WHERE gi_name = 'PlnWrkshtRef'  

if @PlnWrkshtRefStr1 is null select @PlnWrkshtRefStr1 = 'N'
if @PlnWrkshtRefStr2 is null select @PlnWrkshtRefStr2 = 'stops'
if @PlnWrkshtRefStr3 is null select @PlnWrkshtRefStr3 = 'REF'

  
  
  
  
/* PTS 26766 - DJM - Check setting used control use of the Localization values in the Planning   
 worksheet and Tripfolder. To eliminate potential performance issues for customers  
 not using this feature - SQL 2000 ONLY  
*/  
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'  
/* PTS 36608 - vjh - Check setting used control use of the manual check call times in the Planning   
 worksheet and Tripfolder. To eliminate potential performance issues for customers  
 not using this feature - SQL 2000 ONLY  
*/  
select @ManualCheckCall = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ManualCheckCall'  
  
/* Retrieve the data  
*/  
Insert Into @ttbl1  
SELECT 
 la.lgh_number,   
 la.cmp_id_start o_cmpid,   
 la.o_cmpname,   
 la.lgh_startcty_nmstct o_ctyname,   
 la.cmp_id_end d_cmpid,   
 d_cmpname,   
 la.lgh_endcty_nmstct d_ctyname,   
 CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showshipper <> ord_shipper AND ord_showshipper <> 'UNKNOWN' AND ord_Showshipper IS NOT NULL THEN  
                  ord_showshipper  
             ELSE f_cmpid END,  
        CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showshipper <> ord_shipper AND ord_showshipper <> 'UNKNOWN' AND ord_showshipper IS NOT NULL THEN  
                  (SELECT cmp_name FROM company WHERE cmp_id = ord_showshipper)  
      ELSE f_cmpname END,  
        CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showshipper <> ord_shipper AND ord_showshipper <> 'UNKNOWN' AND ord_showshipper IS NOT NULL THEN  
                  (SELECT cty_nmstct FROM company where cmp_id = ord_showshipper)  
             ELSE f_ctyname END,  
 CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showcons <> ord_consignee AND ord_showcons <> 'UNKNOWN' AND ord_Showcons IS NOT NULL THEN  
                  ord_showcons  
             ELSE l_cmpid END,  
 CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showcons <> ord_consignee AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN  
                  (SELECT cmp_name FROM company WHERE cmp_id = ord_showcons)  
      ELSE l_cmpname END,  
 CASE WHEN @UseShowAsShipperConsignee = 'Y' AND ord_showcons <> ord_consignee AND ord_showcons <> 'UNKNOWN' AND ord_showcons IS NOT NULL THEN  
                  (SELECT cty_nmstct FROM company where cmp_id = ord_showcons)  
             ELSE l_ctyname END,  
 la.lgh_startdate,   
 la.lgh_enddate,   
 la.lgh_startstate o_state,   
 la.lgh_endstate d_state,   
 orderheader.ord_origin_earliestdate lgh_schdtearliest,   
 orderheader.ord_origin_latestdate lgh_schdtlatest,  
 la.cmd_code,  
 la.fgt_description,  
 cmd_count,  
 la.ord_hdrnumber,   
 evt_driver1_name evt_driver1,   
 evt_driver2_name evt_driver2,   
 la.lgh_tractor evt_tractor,   
 la.lgh_primary_trailer,  
 orderheader.trl_type1,  
 la.lgh_carrier evt_carrier,   
 la.mov_number,   
 orderheader.ord_availabledate,   
 la.ord_stopcount,   
 orderheader.ord_totalcharge,   
 la.ord_totalweight,   
 orderheader.ord_length,   
 orderheader.ord_width,   
 orderheader.ord_height,   
--PTS13149 MBR 1/29/02  
 la.ord_totalmiles ord_totalmiles,  
 case isnull(upper(la.lgh_split_flag),'N')  
 when 'S' then substring(rtrim(orderheader.ord_number)+'*',1,12)  
 when 'F' then substring(rtrim(orderheader.ord_number)+'*',1,12)  
 else orderheader.ord_number  
 end ord_number,   
 la.lgh_startcity o_city,   
 la.lgh_endcity d_city,  
 la.lgh_priority,   
 lgh_outstatus_name lgh_outstatus,   
 lgh_instatus_name lgh_instatus,   
        lgh_priority_name,  
 (select name from labelfile where la.ord_ord_subcompany = abbr AND labeldefinition = 'Company')  ord_subcompany,  
 trl_type1_name,  
 lgh_class1_name lgh_class1,  
 lgh_class2_name lgh_class2,  
 lgh_class3_name lgh_class3,  
 lgh_class4_name lgh_class4,
 --'Company' 'Company', PTS 37075 SGB remove hardcoded Company with variable
 @SubcompanyLabel SubCompanyLabel,
 labelfile_headers.TrlType1 trllabel1,  
 labelfile_headers.RevType1 revlabel1,  
 labelfile_headers.RevType2 revlabel2,  
 labelfile_headers.RevType3 revlabel3,  
 labelfile_headers.RevType4 revlabel4,  
 orderheader.ord_bookedby,  
 convert(char(10), '') dw_rowstatus,  
 la.lgh_primary_pup,  
 IsNull(ord_loadtime, 0) + IsNull(ord_unloadtime, 0) + IsNull(ord_drivetime, 0) triptime,  
 ord_totalweightunits,  
 ord_lengthunit,  
 ord_widthunit,  
 ord_heightunit,  
 ord_loadtime loadtime,  
 ord_unloadtime unloadtime,  
 ord_completiondate unloaddttm,  
 ord_dest_earliestdate unloaddttm_early,  
 ord_dest_latestdate unloaddttm_late,  
 la.ord_totalvolume,  
 ord_totalvolumeunits,  
 washstatus,  
 f_state,   
 l_state,  
 la.lgh_driver1 evt_driver1_id,  
 la.lgh_driver2 evt_driver2_id,  
 la.ref_type,  
 la.ref_number,  
 d_address1,  
 d_address2,  
 ord_remark,  
 la.mpp_teamleader,  
 la.lgh_dsp_date,  
 la.lgh_geo_date,  
 ordercount,  
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
 isnull(la.can_ld_expires,'19000101') can_ld_expires,  
 xdock,  
 la.lgh_feetavailable feetavailable,  
 opt_trc_type4,  
 opt_trc_type4_label,  
 opt_trl_type4,  
 opt_trl_type4_label,    
 la.lgh_startregion1 ord_originregion1,   
 la.lgh_startregion2 ord_originregion2,   
 la.lgh_startregion3 ord_originregion3,   
 la.lgh_startregion4 ord_originregion4,   
 la.lgh_endregion1 ord_destregion1,  
 la.lgh_endregion2 ord_destregion2,  
 la.lgh_endregion3 ord_destregion3,  
 la.lgh_endregion4 ord_destregion4,  
 npup_departuredate,  
 ndrp_departuredate,   
        ord_fromorder,  
 c_lgh_type1,  
 labelfile_headers.LghType1 lgh_type1_label,  
 c_lgh_type2,  
 labelfile_headers.LghType2 lgh_type2_label,  
 la.lgh_tm_status,  
 la.lgh_tour_number,  
 --JLB PTS 25895  
 -- BEGIN SLM PTS 39133 8/31/2007
 (CASE WHEN @PWExtraInfoLocation = 'ORDERHEADER' AND (select Upper(isnull(gi_string1,'N')) from generalinfo where gi_name = 'PWSumOrdExtraInfo') <> 'Y' THEN ord_extrainfo1 ELSE lgh_extrainfo1 END) extrainfo1,
 -- (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo1 ELSE lgh_extrainfo1 END) extrainfo1,  
 -- END SLM PTS 39133 8/31/2007
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo2 ELSE lgh_extrainfo2 END) extrainfo2,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo3 ELSE lgh_extrainfo3 END) extrainfo3,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo4 ELSE lgh_extrainfo4 END) extrainfo4,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo5 ELSE lgh_extrainfo5 END) extrainfo5,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo6 ELSE lgh_extrainfo6 END) extrainfo6,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo7 ELSE lgh_extrainfo7 END) extrainfo7,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo8 ELSE lgh_extrainfo8 END) extrainfo8,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo9 ELSE lgh_extrainfo9 END) extrainfo9,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo10 ELSE lgh_extrainfo10 END) extrainfo10,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo11 ELSE lgh_extrainfo11 END) extrainfo11,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo12 ELSE lgh_extrainfo12 END) extrainfo12,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo13 ELSE lgh_extrainfo13 END) extrainfo13,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo14 ELSE lgh_extrainfo14 END) extrainfo14,  
 (CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN ord_extrainfo15 ELSE lgh_extrainfo15 END) extrainfo15,  
   --end 25895  
 o_cmp_geoloc,  
 d_cmp_geoloc,  
 la.mpp_fleet,  
 mpp_fleet_name,  
 next_stp_event_code,  
 next_stop_of_total,  
 --vmj1+  
 la.lgh_comment,  
 --vmj1-  
 s1.stp_schdtearliest   lgh_earliest_pu,  
 s1.stp_schdtlatest   lgh_latest_pu,  
 s2.stp_schdtearliest   lgh_earliest_unl,  
 s2.stp_schdtlatest   lgh_latest_unl,  
 -- RE - 03/22/04 - PTS #22373  
 --lgh_miles,  
 (SELECT SUM(stp_lgh_mileage) FROM stops s WHERE s.lgh_number = la.lgh_number) lgh_miles,  
 la.lgh_linehaul,  
-- RE - 10/15/02 - PTS #15024  
-- LOR PTS# 35761 add ARRIVALDEPARTURE  
-- CASE  
--  WHEN @LateWarnMode <> 'EVENT' THEN NULL  
--  ELSE ISNULL((SELECT MIN(evt_latedate)  
--        FROM event e,  
--       stops s  
--       WHERE e.stp_number = s.stp_number AND  
--       s.lgh_number = legheader.lgh_number AND  
--       e.evt_status = 'OPN'), '20491231')  
 CASE @LateWarnMode   
  WHEN 'EVENT' THEN   
   ISNULL((SELECT MIN(evt_latedate)  
     FROM event e, stops s  
     WHERE e.stp_number = s.stp_number AND  
       s.lgh_number = la.lgh_number AND  
       e.evt_status = 'OPN'), '20491231')  
  WHEN 'ARRIVALDEPARTURE' THEN   
   ISNULL((SELECT MIN(evt_latedate)  
     FROM event e, stops s  
     WHERE e.stp_number = s.stp_number AND  
       s.lgh_number = la.lgh_number AND  
       IsNull(e.evt_departure_status, 'OPN') = 'OPN'), '20491231')  
  ELSE Null  
 END evt_latedate,  
 la.lgh_ord_charge,  
 la.lgh_act_weight,  
 la.lgh_est_weight,  
 la.lgh_tot_weight,  
 la.lgh_outstatus lgh_outstat,  
 la.lgh_max_weight_exceeded,  
 la.lgh_reftype,  
 la.lgh_refnum,  
 labelfile_headers.trctype1,  
 la.trc_type1name,  
 labelfile_headers.trctype2,  
 la.trc_type2name,  
 labelfile_headers.trctype3,  
 la.trc_type3name,  
 labelfile_headers.trctype4,  
 la.trc_type4name,  
 --vmj2+  
 la.lgh_etaalert1,  
 --vmj2-  
 isnull(la.lgh_detstatus,0) lgh_detstatus, --vjh 22914  
 la.lgh_tm_statusname  ,  
 la.ord_billto,  
 --DPH PTS 22793  
 company.cmp_name,  
 (select car_name from carrier where car_id = la.lgh_carrier) lgh_carrier,  
 IsNull((SELECT SUM(pyd_amount) FROM paydetail  
  WHERE paydetail.asgn_id = la.lgh_carrier  
  AND paydetail.asgn_type = 'CAR'  
  AND paydetail.lgh_number = la.lgh_number  
  AND paydetail.mov_number = la.mov_number),0) TotalCarrierPay,  
 --DPH PTS 22793  
 la.lgh_hzd_cmd_class, /*PTS 23162 CGK 9/1/2004*/  
 la.lgh_washplan, --MRH PTS 22661  
 (select max(fgt_length)  
  from freightdetail, stops   
   where freightdetail.stp_number = stops.stp_number  
       and la.lgh_number = stops.lgh_number) as fgt_length,  
 (select max(fgt_width)  
  from freightdetail, stops   
   where freightdetail.stp_number = stops.stp_number  
       and la.lgh_number = stops.lgh_number) as fgt_width,  
 (select max(fgt_height)  
  from freightdetail, stops   
    where freightdetail.stp_number = stops.stp_number  
        and la.lgh_number = stops.lgh_number) as fgt_height,  
 la.lgh_originzip,  
 la.lgh_destzip,  
 la.ord_company,  
 'UNKNOWN' origin_servicezone,  
 'ServiceZone' o_servicezone_t,  
 'UNKNOWN' origin_servicearea,  
 'ServiceArea' o_servicearea_t,  
 'UNKNOWN' origin_servicecenter,  
 'ServiceCenter' o_servicecenter_t,  
 'UNKNOWN' origin_serviceregion,  
 'ServiceRegion' o_serviceregion_t,  
 'UNKNOWN' dest_servicezone,  
 'ServiceZone' dest_servicezone_t,  
 'UNKNOWN' dest_servicearea,  
 'ServiceArea' dest_servicearea_t,  
 'UNKNOWN' dest_servicecenter,  
 'ServiceCenter' dest_servicecenter_t,  
 'UNKNOWN' dest_serviceregion,  
 'ServiceRegion' dest_serviceregion_t,  
 la.lgh_204status,  --DPH PTS 27644  
 round(isnull(ocomp.cmp_latseconds,0.000) / 3600.000, 6) origin_cmp_lat,  
 round(isnull(ocomp.cmp_longseconds,0.000) / 3600.000, 6) origin_cmp_long,  
 case @citylatlongunits when 'S' then round(isnull(octy.cty_latitude, 0.000) / 3600.0, 6) else round(isnull(octy.cty_latitude, 0.000), 6) end as origin_cty_lat,  
 case @citylatlongunits when 'S' then round(isnull(octy.cty_longitude,0.000) / 3600.0, 6) else round(isnull(octy.cty_longitude, 0.000), 6) end as origin_cty_long,  
 la.lgh_route,  
 la.lgh_booked_revtype1,  
 ISNULL(la.lgh_permit_status, 'UNK') lgh_permit_status,  
 labelfile_headers.LghPermitStatus lgh_permit_status_t,  
 la.lgh_204date,  
 -- 33890 BDH 9/12/06 start  
 next_ndrp_cmpid,  
 next_ndrp_cmpname,  
 next_ndrp_ctyname,  
 next_ndrp_state,  
 next_ndrp_arrivaldate,  
 -- 33890 BDH 9/12/06 end  
 -- PTS 33913 EMK 10/03/06 start   
 ord_bookdate,  
 -- PTS 33913 EMK 10/03/06 start   
 lgh_ace_status_name,  
 --PTS 35199 AROSS 1/4/07  
 null,  
-- LOR PTS# 35761   
 CASE When @LateWarnMode <> 'ARRIVALDEPARTURE' THEN Null  
  Else ISNULL((SELECT MIN(evt_earlydate)  
     FROM event e, stops s  
     WHERE e.stp_number = s.stp_number AND  
       s.lgh_number = la.lgh_number AND  
       e.evt_status = 'OPN'), '20491231')  
 END evt_earlydate,  
-- LOR  
--Into  #out_test1  
    0 TimeZoneAdjMins,   --35747  
 IsNull(recordlock.locked_by,''),  -- 36717
 IsNull(session_date, '01/01/1950 00:00:00'),  --36717
 IsNull(orderheader.ord_cbp,'N') 'CBPOrder',			-- PTS 38765
 IsNull(la.lgh_ace_status,'UNK') 'ACE_Status',	-- PTS 38765
 '' trc_latest_ctyst,									-- PTS 38765
 ''	trc_latest_cmpid,
 '' trc_last_mobcomm_received,
 '' trc_mobcomm_type,
 '' trc_nearest_mobcomm_nmstct,								-- PTS 38765
 '' next_stop_ref_number,									--PTS 38138 JJF 20080123
orderheader.ord_mintemp ord_mintemp,   
orderheader.ord_maxtemp ord_maxtemp ,
orderheader.ord_order_source
,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
,'UD Column1' 	--	PTS 51911 SGB User Defined column header
,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
,'UD Column2'		--	PTS 51911 SGB User Defined column header
,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
,'UD Column3' 	--	PTS 51911 SGB User Defined column header
,'UNKNOWN' 	-- PTS 51911 SGB User Defined column
,'UD Column4'		--	PTS 51911 SGB User Defined column header  
--PTS 49485 JJF 20100226 - Legheader has a ord_billto that isn't populated, switch to legheader_active.ord_billto
--PTS 49485 JJF 20100226 - Also, legheader_active already has all the needed values, so there is no reason it should be joined to legheader.
FROM --legheader lgh (nolock)   
-- orderheader, 
--left outer join @legheader_active la  on lgh.lgh_number = la.lgh_number
@legheader_active la -- on lgh.lgh_number = la.lgh_number
left outer join orderheader (nolock) on la.ord_hdrnumber = orderheader.ord_hdrnumber --36717
left outer join recordlock (nolock) on (la.mov_number = recordlock.ord_hdrnumber AND  
	recordlock.session_date = (SELECT MAX(rm.session_date) FROM recordlock rm (nolock) WHERE rm.ord_hdrnumber = la.mov_number)) --36717
inner join stops s1 (nolock) on la.stp_number_start = s1.stp_number 
inner join stops s2 (nolock) on la.stp_number_end = s2.stp_number 
inner join company ocomp(nolock) on la.cmp_id_start = ocomp.cmp_id 
inner join city octy (nolock) on la.lgh_startcity = octy.cty_code 
inner join company (nolock) on isnull(la.ord_billto, 'UNKNOWN') = company.cmp_id,
labelfile_headers (nolock) 
where la.lgh_number = @lgh_number
   
---- Only perform the following logic if the Feature is on.  
if @localization = 'Y'  
Begin  
   
-- /* PTS 20302 - DJM - display the localization settings for the Origin and Desitinations */  
select @o_servicezone_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )  
select @o_servicecenter_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )  
select @o_serviceregion_labelname = 'Origin ' + (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )  
select @o_sericearea_labelname = 'Origin ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )  
select @dest_servicezone_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )  
select @dest_sericearea_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )  
select @dest_servicecenter_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )  
select @dest_serviceregion_labelname = 'Dest ' + ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )  
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'  
   
 /* PTS 26766 - DJM - Set the Localization fields */  
 --select temp1.ord_hdrnumber,  
 -- orderheader.ord_origincity,  
 -- temp1.lgh_originzip,  
 Update @ttbl1  
 set origin_servicezone = isNull((select cz_zone from cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip),'UNK'),  
  o_servicezone_t = @o_servicezone_labelname,  
  origin_servicearea = isNull((select cz_area from cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip),'UNK'),  
  o_servicearea_t = @o_sericearea_labelname,  
  origin_servicecenter = isNull((select Case isNull(@service_revtype,'UNK')  
    when 'REVTYPE1' then  
     (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)  
    when 'REVTYPE2' then  
     (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)  
    when 'REVTYPE3' then  
     (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)  
    when 'REVTYPE4' then  
     (select max(svc_center) from serviceregion sc, cityzip where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)  
    else 'UNK'  
    End),'UNK'),  
  o_servicecenter_t = @o_servicecenter_labelname,  
  origin_serviceregion = isNull((select Case isNull(@service_revtype,'UNK')  
    when 'REVTYPE1' then  
     (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)  
    when 'REVTYPE2' then  
     (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)  
    when 'REVTYPE3' then  
     (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)  
    when 'REVTYPE4' then  
     (select max(svc_region) from serviceregion sc, cityzip  where o_ctyname = cityzip.cty_nmstct and lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)  
    else  
      'UNKNOWN'  
    End),'UNK') ,  
  o_serviceregion_t = @o_serviceregion_labelname,  
  dest_servicezone = isNull((select cz_zone from cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip),'UNK') ,  
  dest_servicezone_t = @dest_servicezone_labelname ,  
  dest_servicearea = isNull((select cz_area from cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip),'UNK') ,  
  dest_servicearea_t = @dest_sericearea_labelname ,  
  dest_servicecenter = isnull((select Case isNull(@service_revtype,'UNKNOWN')  
    when 'REVTYPE1' then  
     (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)  
    when 'REVTYPE2' then  
     (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)  
    when 'REVTYPE3' then  
     (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)  
    when 'REVTYPE4' then  
     (select max(svc_center) from serviceregion sc, cityzip where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)  
    else  
      'UNKNOWN'  
    End),'UNK') ,  
  dest_servicecenter_t = @dest_servicecenter_labelname ,  
  dest_serviceregion = isnull((select Case isNull(@service_revtype,'UNK')  
      when 'REVTYPE1' then  
       (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)  
      when 'REVTYPE2' then  
       (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)  
      when 'REVTYPE3' then  
       (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)  
      when 'REVTYPE4' then  
       (select max(svc_region) from serviceregion sc, cityzip  where d_ctyname = cityzip.cty_nmstct and lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)  
      else  
        'UNK'  
      End),'UNK') ,  
  dest_serviceregion_t = @dest_serviceregion_labelname   
 From Orderheader, @ttbl1 temp1  
 where orderheader.ord_hdrnumber = temp1.ord_hdrnumber  


 /* PTS 22601 - DJM - Update the table with the localization descriptions */  
   
 Update @ttbl1  
 set origin_servicezone = isNull((select name from labelfile where labeldefinition = 'ServiceZone' and abbr = origin_servicezone),'UNKNOWN'),  
  origin_servicearea = isNull((select name from labelfile where labeldefinition = 'ServiceArea' and abbr = origin_servicearea),'UNKNOWN'),  
  origin_servicecenter = isnull((select name from labelfile where labeldefinition = 'ServiceCenter'  
     and abbr = origin_servicecenter),'UNKNOWN'),  
  origin_serviceregion = isNull((select name from labelfile where labeldefinition = 'ServiceRegion'  
     and abbr = origin_serviceregion),'UNKNOWN') ,  
  dest_servicezone = isNull((select name from labelfile where labeldefinition = 'ServiceZone' and abbr = dest_servicezone),'UNKNOWN'),  
  dest_servicearea = isNull((select name from labelfile where labeldefinition = 'ServiceArea' and abbr = dest_servicearea),'UNKNOWN'),  
  dest_servicecenter = isnull((select name from labelfile where labeldefinition = 'ServiceCenter'  
     and abbr = dest_servicecenter),'UNKNOWN') ,  
  dest_serviceregion= isnull((select name from labelfile where labeldefinition = 'ServiceRegion'  
     and abbr = dest_serviceregion),'UNKNOWN')  
end

--PTS 51570 JJF 20100510
----PTS 40155 JJF 20071128
--SELECT @rowsecurity = gi_string1
--FROM generalinfo 
--WHERE gi_name = 'RowSecurity'

----PTS 41877
----SELECT @tmwuser = suser_sname()
--exec @tmwuser = dbo.gettmwuser_fn


--IF @rowsecurity = 'Y' AND EXISTS(SELECT * 
--				FROM UserTypeAssignment
--				WHERE usr_userid = @tmwuser) BEGIN 

--	DELETE  @ttbl1
--	FROM @ttbl1 tp 
--	WHERE 
--		EXISTS(SELECT * FROM orderheader oh WHERE tp.mov_number = oh.mov_number)
--		AND NOT EXISTS ((SELECT *
--				FROM orderheader oh 
--				WHERE tp.mov_number = oh.mov_number 
--						AND isnull(oh.ord_BelongsTo, 'UNK') = 'UNK') 

--			)
--		AND NOT EXISTS(SELECT *
--				FROM orderheader oh 
--				WHERE tp.mov_number = oh.mov_number
--						AND EXISTS(SELECT * 
--							FROM UserTypeAssignment
--							WHERE usr_userid = @tmwuser	
--									AND (uta_type1 = oh.ord_BelongsTo
--											OR uta_type1 = 'UNK')))

--END
----END PTS 40155 JJF 20071128

SELECT @rowsecurity = gi_string1
	FROM generalinfo
	WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	DELETE	@ttbl1
	FROM	@ttbl1 tp
	  --security only if mov has an associated order
	WHERE	EXISTS	(	SELECT	*
						FROM	orderheader oh 
						WHERE	tp.mov_number = oh.mov_number
					)
			AND NOT EXISTS	(	SELECT	*  
								FROM	orderheader oh INNER JOIN RowRestrictValidAssignments_orderheader_fn() rsva on	(	oh.rowsec_rsrv_id = rsva.rowsec_rsrv_id
																															OR rsva.rowsec_rsrv_id = 0
																														)
								WHERE	oh.mov_number = tp.mov_number
							)
END

--END PTS 51570 JJF 20100510

-- PTS 36608 vjh  
-- Only perform the following logic if the Feature is on.  
-- This assumes that all check call times are in the local dispatch TZ
--vjh 38226 TZ sift the departure date before comparison
--vjh 38677 redefine ord_manualeventcallminutes
--	0 means scheduled arrival
--	-1 means Apocalypse
if @ManualCheckCall = 'Y'  
Begin  
	update @ttbl1 set manualcheckcalltime =   
		case
--			when s1.stp_status = 'OPN' and isnull(ord_manualeventcallminutes,0) = 0 then @Apocalypse
			when s1.stp_status = 'OPN' and isnull(ord_manualeventcallminutes,0) = -1 then @Apocalypse
			when s1.stp_status = 'OPN' then dateadd(minute, -1*isnull(ord_manualeventcallminutes,0) - 
(@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0))
, stp_arrivaldate)  
			when isnull(ord_manualcheckcallminutes,0) = 0 then @Apocalypse
			when (select max(ckc_date) from checkcall where ckc_lghnumber = t.lgh_number) > 
				dateadd(minute, 0 - (@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0))
				, stp_departuredate) then  
				dateadd(minute, isnull(ord_manualcheckcallminutes,0), (select max(ckc_date) from checkcall where ckc_lghnumber = t.lgh_number))  
			else dateadd(minute, isnull(ord_manualcheckcallminutes,0) - 
(@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0))
, stp_departuredate)  
		end  
	from @ttbl1 t join legheader l (nolock) on t.lgh_number = l.lgh_number  
	join stops s1 on l.stp_number_start = s1.stp_number  
	join orderheader o on l.ord_hdrnumber = o.ord_hdrnumber
	join city c on c.cty_code = s1.stp_city
End  

/* 35747 DPETE if GI specified local time xzone compute TImeZone minutes adjustment for each row */  
If @v_GILocalTImeOption = 'LOCAL'  
   BEGIN 
     update @ttbl1 set TimeZoneADJMins =   
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
              From city where cty_code = (select stp_city from stops where stops.lgh_number = tt1.lgh_number and stp_mfh_sequence =   
                       (select min(stp_mfh_sequence) from stops where stops.lgh_number = tt1.lgh_number and (stp_status = 'OPN' or isnull(stp_departure_status,stp_status) = 'OPN'))))
             
          
         end  
      from @ttbl1 tt1
   END  
/* 35747 end */  

/* 
	PTS 38765 - DJM - trc_latest_ctyst and trc_latest_cmpid added to display the last
	completed stop from the current trip.  Only displays data once the trip is started.			*/
update t1
set t1.trc_latest_ctyst = city.cty_nmstct,
	t1.trc_latest_cmpid = stops.cmp_id
from stops, @ttbl1 t1 , city
where stops.lgh_number = t1.lgh_number
	and stops.stp_city = city.cty_code 
	and stops.stp_status = 'DNE'
	and stops.stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where stops.lgh_number = t1.lgh_number and stp_status = 'DNE')

update t1
set trc_last_mobcomm_received = isNull(trc.trc_lastpos_datetime, '1900/01/01'),
	trc_mobcomm_type = isNull(trc.trc_mobcommtype, 'UNKNOWN'),
	trc_nearest_mobcomm_nmstct = isNull(trc.trc_lastpos_nearctynme, 'UNKNOWN')
from @ttbl1 t1 inner join tractorprofile trc on t1.evt_tractor = trc.trc_number
-- End 38765

--vjh pts 38986
if @PlnWrkshtRefStr1 = 'Y' begin
	update @ttbl1 set ref_type = @PlnWrkshtRefStr3, ref_number = (select min(r.ref_number) from referencenumber r where r.ref_table=@PlnWrkshtRefStr2 and r.ref_type=@PlnWrkshtRefStr3 and r.ref_tablekey=s.stp_number)
	from @ttbl1 l join stops s on l.lgh_number = s.lgh_number
end
   
--PTS 38138 JJF 20080123
IF EXISTS(SELECT * 
			FROM generalinfo gi
			WHERE gi.gi_name = 'NextDrpRefTypeOnPlanningWst'
						and isnull(gi.gi_string1, '') <> '') BEGIN
	UPDATE @ttbl1
	SET next_stop_ref_number = ref.ref_number
	--PTS 50661 JJF 20100212
	FROM @ttbl1 t1 inner join @legheader_active lgh on t1.lgh_number = lgh.lgh_number
	--END PTS 50661 JJF 20100212
			inner join referencenumber ref on (lgh.next_drp_stp_number = ref.ref_tablekey and ref.ref_table = 'stops'),
		generalinfo gi
	WHERE ref.ref_type = gi.gi_string1
		and gi.gi_name = 'NextDrpRefTypeOnPlanningWst'
END
--END PTS 38138 JJF 20080123

--PTS 51911 SGB Only run when setting turned on 
Select @ud_column1 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column2 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column3 = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column4 = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'

IF @ud_column1 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',1)
			UPDATE @ttbl1
			set ud_column1 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',1),
			ud_column1_t = @udheader
			from @ttbl1 t

		END
 
END 

IF @ud_column2 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',2)
			UPDATE @ttbl1
			set ud_column2 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',2),
			ud_column2_t = @udheader
			from @ttbl1 t

		END
 
END 

IF @ud_column3 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string3,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',3)
			UPDATE @ttbl1
			set ud_column3 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',3),
			ud_column3_t = @udheader
			from @ttbl1 t

		END
 
END 

IF @ud_column4 = 'Y'
BEGIN
		Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string4,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
		If @procname not in ('','N')
		BEGIN 
				

			SELECT 	@udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',4)
			UPDATE @ttbl1
			set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',4),
			ud_column4_t = @udheader
			from @ttbl1 t

		END
 
END 



--Select * from @ttbl1  
SELECT 
	lgh_number,
	o_cmpid,
	o_cmpname,
	o_ctyname,
	d_cmpid,
	d_cmpname,
	d_ctyname,
	f_cmpid,
	f_cmpname,
	f_ctyname,
	l_cmpid,
	l_cmpname,
	l_ctyname,
	lgh_startdate,
	lgh_enddate,
	o_state,
	d_state,
	lgh_schdtearliest,
	lgh_schdtlatest,
	cmd_code,
	fgt_description,
	cmd_count,
	ord_hdrnumber,
	evt_driver1,
	evt_driver2,
	evt_tractor,
	lgh_primary_trailer,
	trl_type1,
	evt_carrier,
	mov_number,
	ord_availabledate,
	ord_stopcount,
	ord_totalcharge,
	ord_totalweight,
	ord_length,
	ord_width,
	ord_height,
	ord_totalmiles,
	ord_number,
	o_city,
	d_city,
	lgh_priority,
	lgh_outstatus,
	lgh_instatus,
	lgh_priority_name,
	ord_subcompany,
	trl_type1_name,
	lgh_class1,
	lgh_class2,
	lgh_class3,
	lgh_class4,
	SubCompanyLabel,
	trllabel1,
	revlabel1,
	revlabel2,
	revlabel3,
	revlabel4,
	ord_bookedby,
	dw_rowstatus,
	lgh_primary_pup,
	triptime,
	ord_totalweightunits,
	ord_lengthunit,
	ord_widthunit,
	ord_heightunit,
	loadtime,
	unloadtime,
	unloaddttm,
	unloaddttm_early,
	unloaddttm_late,
	ord_totalvolume,
	ord_totalvolumeunits,
	washstatus,
	f_state,
	l_state,
	evt_driver1_id,
	evt_driver2_id,
	ref_type,
	ref_number,
	d_address1,
	d_address2,
	ord_remark,
	mpp_teamleader,
	lgh_dsp_date,
	lgh_geo_date,
	ordercount,
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
	can_ld_expires,
	xdock,
	feetavailable,
	opt_trc_type4,
	opt_trc_type4_label,
	opt_trl_type4,
	opt_trl_type4_label,
	ord_originregion1,
	ord_originregion2,
	ord_originregion3,
	ord_originregion4,
	ord_destregion1,
	ord_destregion2,
	ord_destregion3,
	ord_destregion4,
	npup_departuredate,
	ndrp_departuredate,
	ord_fromorder,
	c_lgh_type1,
	lgh_type1_label,
	c_lgh_type2,
	lgh_type2_label,
	lgh_tm_status,
	lgh_tour_number,
	extrainfo1,
	extrainfo2,
	extrainfo3,
	extrainfo4,
	extrainfo5,
	extrainfo6,
	extrainfo7,
	extrainfo8,
	extrainfo9,
	extrainfo10,
	extrainfo11,
	extrainfo12,
	extrainfo13,
	extrainfo14,
	extrainfo15,
	o_cmp_geoloc,
	d_cmp_geoloc,
	mpp_fleet,
	mpp_fleet_name,
	next_stp_event_code,
	next_stop_of_total,
	lgh_comment,
	lgh_earliest_pu,
	lgh_latest_pu,
	lgh_earliest_unl,
	lgh_latest_unl,
	lgh_miles,
	lgh_linehaul,
	evt_latedate,
	lgh_ord_charge,
	lgh_act_weight,
	lgh_est_weight,
	lgh_tot_weight,
	lgh_outstat,
	lgh_max_weight_exceeded,
	lgh_reftype,
	lgh_refnum,
	trctype1,
	trc_type1name,
	trctype2,
	trc_type2name,
	trctype3,
	trc_type3name,
	trctype4,
	trc_type4name,
	lgh_etaalert1,
	lgh_detstatus,
	lgh_tm_statusname,
	ord_billto,
	cmp_name,
	lgh_carrier,
	TotalCarrierPay,
	lgh_hzd_cmd_class,
	lgh_washplan,
	fgt_length,
	fgt_width,
	fgt_height,
	lgh_originzip,
	lgh_destzip,
	ord_company,
	origin_servicezone,
	o_servicezone_t,
	origin_servicearea,
	o_servicearea_t,
	origin_servicecenter,
	o_servicecenter_t,
	origin_serviceregion,
	o_serviceregion_t,
	dest_servicezone,
	dest_servicezone_t,
	dest_servicearea,
	dest_servicearea_t,
	dest_servicecenter,
	dest_servicecenter_t,
	dest_serviceregion,
	dest_serviceregion_t,
	lgh_204status,
	origin_cmp_lat,
	origin_cmp_long,
	origin_cty_lat,
	origin_cty_long,
	lgh_route,
	lgh_booked_revtype1,
	lgh_permit_status,
	lgh_permit_status_t,
	lgh_204date,
	next_ndrp_cmpid,
	next_ndrp_cmpname,
	next_ndrp_ctyname,
	next_ndrp_state,
	next_ndrp_arrivaldate,
	ord_bookdate,
	lgh_ace_status_name,
	manualcheckcalltime,
	evt_earlydate,
	TimeZoneAdjMins,
	locked_by,
	session_date,
	ord_cbp,
	lgh_ace_status,
	trc_latest_ctyst,
	trc_latest_cmpid,
	trc_last_mobcomm_received,
	trc_mobcomm_type,
	trc_nearest_mobcomm_nmstct,
	next_stop_ref_number,
	ord_mintemp,
	ord_maxtemp,	--PTS 38138 JJF 20080122
	@ma_transaction_id ma_transaction_id,											-- RE - PTS #52017
	CASE																			-- RE - PTS #52017
		WHEN @ma_transaction_id IS NULL THEN @null_int								-- RE - PTS #52017
		ELSE dbo.Load_MATourNumber_fn(@DefaultCompanyID, @ma_transaction_id, lgh_number)				-- RE - PTS #52017
	END ma_tour_number,																-- RE - PTS #52017
	@null_varchar8,																	-- RE - PTS #52017
	@null_varchar8,																	-- RE - PTS #52017
	CASE																			-- RE - PTS #52017
		WHEN @ma_transaction_id IS NULL THEN @null_varchar100						-- RE - PTS #52017
		ELSE dbo.Load_MAReccomendation_fn(@DefaultCompanyID, @ma_transaction_id, lgh_number)			-- RE - PTS #52017
	END ma_advice,  																-- RE - PTS #52017
	ord_order_source
	,ud_column1			 -- PTS 51911 SGB User Defined column
	,ud_column1_t		 --	PTS 51911 SGB User Defined column header
	,ud_column2			 -- PTS 51911 SGB User Defined column
	,ud_column2_t 		 --	PTS 51911 SGB User Defined column header	
	,ud_column3			 -- PTS 51911 SGB User Defined column
	,ud_column3_t		 --	PTS 51911 SGB User Defined column header
	,ud_column4			 -- PTS 51911 SGB User Defined column
	,ud_column4_t 		 --	PTS 51911 SGB User Defined column header	
FROM @ttbl1

--PTS 50661 JJF 20100212
--DROP TABLE #legheader_active
--END PTS 50661 JJF 20100212

GO
GRANT EXECUTE ON  [dbo].[outbound_viewbyleg] TO [public]
GO
