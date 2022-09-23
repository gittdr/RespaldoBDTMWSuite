SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_load_assign5_sp] 
	@order_number varchar(15),
	@move varchar(12),
	@lgh_Num varchar(12),
	@Flags varchar(22),
    @sTargetTZ varchar(3),
    @sTargetTZDSTCode varchar(2),
    @sTargetTZMin varchar(2),
	@sSeparateOnFields varchar(1000),
	@sFieldsToReturn varchar(1000)  --(System Only - not meant for Load Assignment view)

AS
-- 07/11/07 DWG: Created tmail_load_assign5_sp 
-- 04/25/08 VMS: Modified to fix invalid column name stp_mfh_sequence and
--               invalid object name #temp errors - PTS 42593
-- 11/02/09		   VMS:  PTS49699 - Adding new flag
-- 07/21/2011.01 - MIZ - PTS58026 - Fixed DontSendDeadhead flag so that it will work on legs beside the first on the order.
-- 03/14/2012	 - LB  - PTS62022 - Create the #LoadAssignmentType table to prevent constant recompile  
-- 03/14/2012    - LB    PTS59184 -  Add Nocount and transaction isolation level read uncommitted
-- 03/15/2012    - LB    PTS62085 - Add new flag for Remove EMT,EBT on a double end event
-- 09/04/2012 - JC PTS 59142 - Add Stop Company Zip
-- 09/13/2012.01 - APC - PTS63043 - change Where clause ...UPDATE #LoadAssignmentType SET ToBeDeleted = 1...
-- 03/05/2013.01 - MIZ - PTS67490 - Merge current source with fix for @sFieldsToReturn
-- 11/21/2013    - HMA - PTS69924 - new flag +1073741824 = consolidate adjacent LLDs
-- 07/07/2014    -Rwolfe PTS79813 - Add noted changes
-- 08/25/2014	 - APC - PTS81818 - SQL Server 2005 does not support setting local variable a default value in the declaration statement and "+="
-- 10/09/2014    -Rwolfe PTS82979 - move stop groups from old Pnet Poller into Load Assignment.  This change “trickled downed” various other changes related to “StopMoveSeq” because this column now must support duplicates

/***** For testing ****************
DECLARE	@order_number varchar(12), @move varchar(12), @lgh_Num varchar(12), @Flags varchar(6), @sTargetTZ varchar(2), @sTargetTZDSTCode varchar(2), @sTargetTZMin varchar(2)
SET @order_number = ''
SET @move = ''
SET @lgh_num = ''
SET @flags = '' 
SET sDestTZ = '0'
SET sDestTZDSTCode= '0'
SET sDestTZMin = '0'
**********************************/

Set nocount on
set transaction isolation level read uncommitted


CREATE TABLE #LoadAssignmentType (
	Tractor varchar(20),					--DWG PTS 69438
	OrderNumber varchar(15),
	MoveNumber bigint,
	Revenue float,
	LineHaul float,							--5
	Shipper varchar(25),
	Consignee varchar(25),
	ScheduledPickupEarliestDate datetime,
	ScheduledPickupEarliestTime	datetime,
	ScheduledPickupLatestDate datetime,		--10
	ScheduledPickupLatestTime datetime,
	ScheduledDeliveryEarliestDate datetime,
	ScheduledDeliveryEarliestTime datetime,
	ScheduledDeliveryLatestDate datetime,
	ScheduledDeliveryLatestTime datetime,	--15
	ScheduledPickupEarliestTZDate datetime,
	ScheduledPickupEarliestTZTime datetime,
	ScheduledPickupLatestTZDate datetime,
	ScheduledPickupLatestTZTime datetime,
	ScheduledDeliveryEarlTZDate datetime,	--20
	ScheduledDeliveryEarlTZTime datetime,
	ScheduledDeliveryLatestTZDate datetime,
	ScheduledDeliveryLatestTZTime datetime,	
	CommodityCode varchar(8),
	Pieces decimal (10,2),					--25
	PiecesCountUnit varchar(6),
	Weight float(53),
	WeightUnit varchar(6),
	Volume float(53),
	VolumeUnit varchar(6),					--30
	ReferenceType varchar(6),
	ReferenceNumber varchar(254),
	OrderHeaderComments varchar(254),
	Trailer1 varchar(20),
	Trailer2 varchar(20),					--35
	DispatchStatus varchar(6),
	StopCompanyID varchar(25),
	EventCode varchar(6),
	StopCommodityCode varchar(8),
	StopReferenceNumber varchar(30),		--40
	StopReferenceType varchar(6),
	StopComment varchar(254),
	StopEarliestDate datetime,
	StopEarliestTime datetime,
	StopLatestDate datetime,				--45
	StopLatestTime datetime,
	StopEarliestTZDate datetime,
	StopEarliestTZTime datetime,
	StopLatestTZDate datetime,	
	StopLatestTZTime datetime,				--50
	Mileage	int,
	StopMileage	int,
	StopMileType varchar(3),
	LoadedMiles int,
	EmptyMiles int,							--55
	StopNumber bigint,
	StopSequence int,
	StopWeight float(53),
	StopWeightUnit varchar(6),
	StopCount decimal(10,2),				--60
	StopCountUnit varchar(10),
	StopVolume float(53),
	StopVolumeUnit varchar(6),
	StopCompanyName varchar(100),
	StopAddress1 varchar(100),				--65
	StopAddress2 varchar(100),
	StopCity varchar(30),
	StopZip Varchar(10),						--PTS 72964 - Zip code to 10 Characters
	StopPhone varchar(20),
	StopContact  varchar(40),				--70
	StopCommodityName varchar(60), 
	StopDate datetime,
	StopTime datetime,
	StopTZDate datetime,
	StopTZTime datetime,					--75
	StopMoveSeq int,  
	OrdHdrNumber varchar(20),
	StopStatus varchar(6),
	departureStatus varchar(6),
	StopOrderNumber varchar(15),			--80
	MinTemp smallint,  
	MaxTemp smallint,
	NumberOfStops int,
	StopDriverLoad varchar(1),
	StopDriverUnload varchar(1),			--85
	lgh_number bigint,  
	StartDateTime datetime,
	StartTZDateTime datetime,
	TourNumber bigint,
	StopEventText varchar(50),				--90
	OrderBillTo varchar(25), 
	OrderBy varchar(25),
	CommodityName varchar(64),
	StopEventType varchar(6),
	ShipperStopNumber bigint,				--95
	ConsigneeStopNumber bigint, 
	ord_revtype1 varchar(6),
	ord_revtype2 varchar(6),
	ord_revtype3 varchar(6),
	ord_revtype4 varchar(6),				--100
	DriverID varchar(8), 
	TMSTATUS varchar(6),
	ord_trl_type1 varchar(6),
	ord_trl_type2 varchar(6),
	ord_trl_type3 varchar(6),				--105
	ord_trl_type4 varchar(6), 
	NoPickUps int,
	NoDropOffs int,
	ord_terms varchar(6),
	ToBeDeleted int,						--110
	ord_miscqty decimal(12,4), 
	First_MT_Trailer varchar(13),
	First_Trailer_on_Load varchar(13),
	LegShipper varchar(25),
	LegShipperStopNumber varchar(10),		--115
	LegConsignee varchar(25),  
	LegConsigneeStopNumber varchar(10),
	ord_hdrnumber bigint,
	count2 decimal(10,2),
	count2unit varchar(6),					--120
	ord_subcompany varchar(25), 
	lgh_driver2  varchar(8),
	StopIsFirstFromOrder int,	
	ScheduledPickupEarliestDtTm datetime,
	ScheduledPickupLatestDtTm datetime,		--125
	ScheduledDeliveryEarliestDtTm datetime,
	ScheduledDeliveryLatestDtTm datetime,
	StopEarliestDtTm datetime,
	StopLatestDtTm datetime,
	StopDtTm datetime,						--130
	StopDepartureDate datetime, 
	StopDepartureTime datetime,
	StopDepartureDtTm datetime,
	ScheduledPickupEarliestTZDtTm datetime,
	ScheduledPickupLatestTZDtTm datetime,	--135
	ScheduledDeliveryEarlTZDtTm datetime,  
	ScheduledDeliveryLatestTZDtTm datetime,
	StopEarliestTZDtTm datetime,
	StopLatestTZDtTm datetime,
	StopTZDtTm datetime,					--140
	StopDepartureTZDate datetime,  
	StopDepartureTZTime datetime,
	StopDepartureTZDtTm datetime,
	lgh_TMStatus varchar(6),
	lgh_OutStatus varchar(6),				--145
	EndDateTime datetime 
)


DECLARE @bUpdateEquip int,
		@iFlags bigint,
		@KillRTPTimeFlag varchar(20),
		@move_number bigint,
		@MoveOrderOverlaid bigint,
		@OldEarliestLatestTimes int,
		@RenumberSequence int,					-- Do not reset stp_dispatched_seq if it has already been set
		@SendDH int,
		@CountDHsWhenNumbering int,
		@ordhdr bigint,		
		@ShowDMTs int,
		@sT_1 varchar(200), 		-- Translation String
		@OrderBasedStopsOnly int,	-- flag +32768
		@SkipRTPEvents int,
		@NOSENTStopsOnly int,
		@DoNotNumberDispatchSEQ int,
		@laststop int,
		@nextstop int,
		@stpsequence int,
		@DeleteDupStops int,
		@DeleteDupXDocStops int,
		@FilterLastStop int,
		@NoDoubleEnd int,
		@DeleteDupLLDStops INT, --pts 69924
		@CombineXStopsWithRegs int

--DWG {33386} Create TimeZone variables
DECLARE @sSysTZ varchar(3),
		@iSysTZ int,
		@iSysDSTCode int,
		@iSysTZMin int,
		@iSourceTZ int,
		@iSourceTZMin int,
		@iSourceTZDSTCode int,
		@iTargetTZ int,
		@iTargetTZDSTCode int,
		@iTargetTZMin int,		
		@iStopTZ int,
		@iStopTZMin int,
		@iStopTZDSTCode int,
		@sDSTApplies varchar(1),
		@DestDate datetime,
		@ScheduledPickupEarliestTZDate datetime, 
		@ScheduledPickupEarliestTZTime datetime,
		@ScheduledPickupEarliestTZDtTm datetime,
		@ScheduledPickupLatestTZDate datetime,
		@ScheduledPickupLatestTZTime datetime,
		@ScheduledPickupLatestTZDtTm datetime,
		@ScheduledDeliveryEarlTZDate datetime,
		@ScheduledDeliveryEarlTZTime datetime,
		@ScheduledDeliveryEarlTZDtTm datetime,
		@ScheduledDeliveryLatestTZDate datetime,
		@ScheduledDeliveryLatestTZTime datetime,
		@ScheduledDeliveryLatestTZDtTm datetime,
		@StopEarliestTZDate datetime,
		@StopEarliestTZTime datetime,
		@StopEarliestTZDtTm datetime,
		@StopLatestTZDate datetime,
		@StopLatestTZTime datetime,
		@StopLatestTZDtTm datetime,
		@StopTZDate datetime, 
		@StopTZTime datetime,
		@StopTZDtTm datetime,
		@StopDepartureTZDate datetime,
		@StopDepartureTZTime datetime,
		@StopDepartureTZDtTm datetime,
		@StartTZDateTime datetime,
		@FuelMode int

DECLARE @CommaPos int, 
		@SQLToExec nvarchar(MAX), 
		@SQLCore NVARCHAR(MAX),
		@SQLSource NVARCHAR(1000),
		@SQLWhereToExec nvarchar(1000),
		@FieldName varchar(100), 
		@NotFirstTime int,
		@TableToJoin varchar(100),
		@TablesInSelect varchar(1000)
		
DECLARE @StopList TABLE (StopNumber int)

/**************************************************************
* NOTE: To add fields to #LoadAssignmentType, modify PTS67490, 
*		which declares LoadAssignmentType
**************************************************************/
--DECLARE #LoadAssignmentType LoadAssignmentType

--DWG {33386} Target Timezone, NULL converted to 0 (GMT)
SELECT @iTargetTZ = ISNULL(CONVERT(int, @sTargetTZ), 0), @iTargetTZDSTCode = ISNULL(CONVERT(int, @sTargetTZDSTCode), -1), @iTargetTZMin = ISNULL(CONVERT(int, @sTargetTZMin), 0)

-- Convert the @Flags to an int so we can do math on it
--  This is mainly for SQL Server 6.5 users
SET @iFlags = CONVERT(bigint,ISNULL(@Flags,'0'))

SET @MoveOrderOverlaid = 0
SET @ShowDMTs=0
SET @OldEarliestLatestTimes = 0
SET @RenumberSequence = 1
SET @CountDHsWhenNumbering = 0
SET @SendDH = 1
SET @OrderBasedStopsOnly = 0
SET @SkipRTPEvents = 0
SET @NOSENTStopsOnly = 0
SET @DoNotNumberDispatchSEQ = 0
SET @DeleteDupStops = 0
SET @DeleteDupXDocStops = 0
SET @FuelMode = 0
SET @NoDoubleEnd = 0
SET @DeleteDupLLDStops = 0

/******* Flag Definitions **********
	+1   = DontSendDH
	+2   = KeepSeqWhenDontSendDH
	+4   = Don't renumber unless original numbering has not yet been done
	+8   = MoveOrderOverlaid (Used in FILL and XMIT) -> First try order number, and then try the move number sent in (as the order number).
	+16  = ShowDMTs
	+32  = OldEarliestLatestTimes
	+64  = Use Driver Lookup (used in FILL and XMIT)
	+128 = Update Equipment (only used in XMIT)
	+256 thru +4096 are used by tmail_GetLoadAssignmentLeg which is used to setup for this routine.
	+8192  = Only send OPEN (OPN),or non-arrived, stops.
	+16384 = Only send COMPLETED (DNE) stops.
	+32768   Only send order based stops
	+65536   skip RTP/TRP events
	+131072  NOSENT Stops only
	+262144  Do not touch dispatched sequences (even if original numbering has not been done)
	+524288 = used by tmail_GetLoadAssignmentLeg which is used to setup for this routine.
	+1048576 = used by tmail_GetLoadAssignmentLeg which is used to setup for this routine.
	+2097152 = filter stops that are at the same company with the same event.
	+4194304 = Only send non-departed stops.
	+8388608 = Look for completed leg with no final depart, after not finding a started leg. Only applies when 256 (Prefer Started) is set
	+16777216 = filter stops that are at the same company with the same event (like +2097152), but only for XDU/XDL events.
	+33554432 = don't send notes (not code flag)
    +67108864 = Remove last stop, no matter the event.
	+134217728 = used by tmail_GetLoadAssignmentLeg3 but ignored by this proc.		-- PTS 49699
	+268435456 = Remove EMT,EBT on a double or triple end (such as a HMT,EMT)
	+536870912 = (FuelMode) Modifies +67108864 so that only EBT, IEBT, EMT, or IEMT are deleted.  Also used by tmail_GetLoadAssignmentLeg3 which is used to setup for this routine
	+1073741824 = consolidate adjacent LLDs; filter stops that are at the same company with the same event (like +2097152), but only for LLD’s -- PTS 69924
	+2147483648 = let XDL and XDU be filitered with stops as LLD and LUL   PTS79813 
************************************/

IF (@iFlags & 1) <> 0
	SET @SendDH = 0

IF (@iFlags & 2) <> 0
	SET @CountDHsWhenNumbering = 1

IF (@iFlags & 4) <> 0
	SET @RenumberSequence = 0

IF (@iFlags & 8) <> 0
	SET @MoveOrderOverlaid = 1

IF (@iFlags & 16) <> 0
	SET @ShowDMTs = 1

IF (@iFlags & 32) <> 0
	SET @OldEarliestLatestTimes = 1

IF (@iFlags & 32768) <> 0
	SET @OrderBasedStopsOnly = 1

IF (@iFlags & 65536) <> 0
	SET @SkipRTPEvents = 1

IF (@iFlags & 131072) <> 0
	SET @NOSENTStopsOnly = 1

IF (@iFlags & 262144) <> 0
	SET @DoNotNumberDispatchSEQ = 1

IF (@iFlags & 2097152) <> 0
	SET @DeleteDupStops = 1

IF (@iFlags & 16777216) <> 0
	SET @DeleteDupXDocStops = 1

IF (@iFlags & 67108864) <> 0  
	SET @FilterLastStop = 1
	
IF (@iFlags & 268435456) <> 0
	SET @NoDoubleEnd = 1

IF (@iFlags & 536870912) <> 0  
	SET @FuelMode = 1

IF (@iFlags & 1073741824) <> 0
	SET @DeleteDupLLDStops = 1

IF (@iFlags & cast(2147483648 AS bigint)) <> 0 
	SET @CombineXStopsWithRegs = 1
	
-- If no legheader number was supplied, raise error and exit
IF ISNULL(@Lgh_Num, '0') = '0' OR ISNULL(@Lgh_Num, '') = ''
  BEGIN
	SELECT @sT_1 = 'TMWERR: {Load Assign2} No LegHeader Found.'
--	EXEC tm_t_sp @sT_1 out, 1, ''
	RAISERROR (@sT_1,16,-1)
	RETURN 1
  END

-- Check if the stp_dispatched_seq is set 
IF NOT EXISTS (SELECT stp_number FROM stops (NOLOCK) WHERE lgh_number = CONVERT(bigint,@lgh_num) AND ISNULL(stp_dispatched_sequence,0) <> 0)
	-- The stp_dispatched_seq has not been set
	IF (@RenumberSequence = 0)
		-- The @RenumberSequence has been set to 0 (meaning the +4 flag is on), but we'll turn it back off since we've never numbered stp_dispatch
		SET @RenumberSequence = 1

--flag to not number or renumber the dispathed sequence
if @DoNotNumberDispatchSEQ = 1 
	SET @RenumberSequence = 0

	SET @SQLCore = N'insert into #LoadAssignmentType (
	Tractor  ,						--DWG PTS 69438
	OrderNumber  ,
	MoveNumber  ,
	Revenue ,
	LineHaul ,						--5
	Shipper  ,
	Consignee  ,
	ScheduledPickupEarliestDate  ,
	ScheduledPickupEarliestTime	 ,
	ScheduledPickupLatestDate  ,	--10
	ScheduledPickupLatestTime  ,
	ScheduledDeliveryEarliestDate  ,
	ScheduledDeliveryEarliestTime  ,
	ScheduledDeliveryLatestDate  ,
	ScheduledDeliveryLatestTime  ,	--15
	ScheduledPickupEarliestTZDate  ,
	ScheduledPickupEarliestTZTime  ,
	ScheduledPickupLatestTZDate  ,
	ScheduledPickupLatestTZTime  ,
	ScheduledDeliveryEarlTZDate  ,	--20
	ScheduledDeliveryEarlTZTime  ,
	ScheduledDeliveryLatestTZDate  ,
	ScheduledDeliveryLatestTZTime  ,	
	CommodityCode  ,
	Pieces ,						--25
	PiecesCountUnit  ,
	[Weight]  ,
	WeightUnit  ,
	Volume  ,
	VolumeUnit  ,					--30
	ReferenceType  ,
	ReferenceNumber ,
	OrderHeaderComments ,
	Trailer1  ,
	Trailer2  ,						--35
	DispatchStatus  ,
	StopCompanyID  ,
	EventCode  ,
	StopCommodityCode  ,
	StopReferenceNumber  ,			--40
	StopReferenceType  ,
	StopComment ,
	StopEarliestDate  ,
	StopEarliestTime  ,
	StopLatestDate  ,				--45
	StopLatestTime  ,
	StopEarliestTZDate  ,
	StopEarliestTZTime  ,
	StopLatestTZDate  ,	
	StopLatestTZTime  ,				--50
	Mileage	 ,
	StopMileage	 ,
	StopMileType  ,
	LoadedMiles  ,
	EmptyMiles  ,					--55
	StopNumber  ,
	StopSequence  ,
	StopWeight  ,
	StopWeightUnit  ,
	StopCount  ,					--60
	StopCountUnit  ,
	StopVolume  ,
	StopVolumeUnit  ,
	StopCompanyName  ,
	StopAddress1  ,					--65
	StopAddress2  ,
	StopCity  ,
	StopZip ,
	StopPhone  ,
	StopContact   ,					--70
	StopCommodityName  , 
	StopDate  ,
	StopTime  ,
	StopTZDate  ,
	StopTZTime  ,					--75
	StopMoveSeq  ,  
	OrdHdrNumber  ,
	StopStatus  ,
	departureStatus  ,
	StopOrderNumber  ,				--80
	MinTemp  ,  
	MaxTemp  ,
	NumberOfStops  ,
	StopDriverLoad  ,
	StopDriverUnload  ,				--85
	lgh_number  ,  
	StartDateTime  ,
	StartTZDateTime  ,
	TourNumber  ,
	StopEventText  ,				--90
	OrderBillTo  , 
	OrderBy  ,
	CommodityName  ,
	StopEventType  ,
	ShipperStopNumber  ,			--95
	ConsigneeStopNumber  , 
	ord_revtype1  ,
	ord_revtype2  ,
	ord_revtype3  ,
	ord_revtype4  ,					--100
	DriverID  , 
	TMSTATUS  ,
	ord_trl_type1  ,
	ord_trl_type2  ,
	ord_trl_type3  ,				--105
	ord_trl_type4  , 
	NoPickUps  ,
	NoDropOffs  ,
	ord_terms  ,
	ToBeDeleted  ,					--110
	ord_miscqty  , 
	First_MT_Trailer  ,
	First_Trailer_on_Load  ,
	LegShipper  ,
	LegShipperStopNumber  ,			--115
	LegConsignee  ,  
	LegConsigneeStopNumber  ,
	ord_hdrnumber  ,
	count2  ,
	count2unit  ,					--120
	ord_subcompany  , 
	lgh_driver2   ,
	StopIsFirstFromOrder  ,	
	ScheduledPickupEarliestDtTm  ,
	ScheduledPickupLatestDtTm  ,	--125
	ScheduledDeliveryEarliestDtTm  ,  
	ScheduledDeliveryLatestDtTm  ,
	StopEarliestDtTm  ,
	StopLatestDtTm  ,
	StopDtTm  ,						--130
	StopDepartureDate  ,  
	StopDepartureTime  ,
	StopDepartureDtTm  ,
	ScheduledPickupEarliestTZDtTm  ,
	ScheduledPickupLatestTZDtTm  ,	--135
	ScheduledDeliveryEarlTZDtTm  , 
	ScheduledDeliveryLatestTZDtTm  ,
	StopEarliestTZDtTm  ,
	StopLatestTZDtTm  ,
	StopTZDtTm  ,					--140
	StopDepartureTZDate  , 
	StopDepartureTZTime  ,
	StopDepartureTZDtTm  ,
	lgh_TMStatus  ,
	lgh_OutStatus  ,				--145	
	EndDateTime)	
SELECT 	event.evt_tractor Tractor,
		SPACE(12) OrderNumber,
		stops.mov_number MoveNumber,
		CONVERT(float, 0.0) Revenue,
		CONVERT(float, 0.0) LineHaul,							--5

		SPACE(8) Shipper,
		SPACE(8) Consignee,
		convert(datetime, null) ScheduledPickupEarliestDate,
		convert(datetime, null) ScheduledPickupEarliestTime,
		convert(datetime, null) ScheduledPickupLatestDate,		--10

		convert(datetime, null) ScheduledPickupLatestTime,
		convert(datetime, null) ScheduledDeliveryEarliestDate,
		convert(datetime, null) ScheduledDeliveryEarliestTime,
		convert(datetime, null) ScheduledDeliveryLatestDate,
		convert(datetime, null) ScheduledDeliveryLatestTime,	--15

		convert(datetime, null) ScheduledPickupEarliestTZDate,  --DWG {33386} Return TZ times
		convert(datetime, null) ScheduledPickupEarliestTZTime,
		convert(datetime, null) ScheduledPickupLatestTZDate,	
		convert(datetime, null) ScheduledPickupLatestTZTime,
		convert(datetime, null) ScheduledDeliveryEarlTZDate,	--20
		
		convert(datetime, null) ScheduledDeliveryEarlTZTime,
		convert(datetime, null) ScheduledDeliveryLatestTZDate,
		convert(datetime, null) ScheduledDeliveryLatestTZTime,
		SPACE(8) CommodityCode,
		CONVERT(decimal(10, 2), 0.0) Pieces,					--25
		
		SPACE(6) PiecesCountUnit,
		CONVERT(float(53), 0.0) Weight,
		SPACE(6) WeightUnit,					
		CONVERT(float(53), 0.0) Volume,
		SPACE(6) VolumeUnit,									--30
		
		SPACE(6) ReferenceType, 
		SPACE(254) ReferenceNumber,
		SPACE(254) OrderHeaderComments,			
		evt_trailer1 Trailer1,
		evt_trailer2 Trailer2,									--35
		
		lgh_outstatus DispatchStatus,
		stops.cmp_id StopCompanyID,
		stops.stp_event EventCode,			
		stops.cmd_code StopCommodityCode,
		stops.stp_refnum StopReferenceNumber,					--40
		
		stops.stp_reftype StopReferenceType,
		stops.stp_comment StopComment,
		convert(datetime, CONVERT(char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtearliest
				ELSE ISNULL(stp_arrivaldate, ''19500101'')
				END,
			 101), 101) StopEarliestDate,			
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtearliest
				ELSE ISNULL(stp_arrivaldate, ''19500101'')
				END,
			 108), 108) StopEarliestTime,
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtlatest
				ELSE ISNULL(stp_departuredate, ''20491231'')
				END,
			 101), 101) StopLatestDate,							--45
			 
		convert(datetime, CONVERT( char,
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtlatest
				ELSE ISNULL(stp_departuredate, ''20491231'')
				END,
			 108), 108) StopLatestTime,
		convert(datetime, CONVERT(char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtearliest
				ELSE ISNULL(stp_arrivaldate, ''19500101'')
				END,
			 120), 120) StopEarliestTZDate,				-- :DWG {33386} Return TZ times
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtearliest
				ELSE ISNULL(stp_arrivaldate, ''19500101'')
				END,
			 120), 120) StopEarliestTZTime,
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtlatest
				ELSE ISNULL(stp_departuredate, ''20491231'')
				END,
			 120), 120) StopLatestTZDate,
		convert(datetime, CONVERT( char,
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtlatest
				ELSE ISNULL(stp_departuredate, ''20491231'')
				END,
			 120), 120) StopLatestTZTime,						--50
			 
		stp_lgh_mileage Mileage,
		stp_lgh_mileage StopMileage,			
		stp_loadstatus StopMileType,
		stp_lgh_mileage LoadedMiles,
		ISNULL(stp_lgh_mileage,0) EmptyMiles,								--55
		
		stops.stp_number StopNumber,
		stp_dispatched_sequence StopSequence,							
		stp_weight StopWeight,
		stp_weightunit StopWeightUnit,
		stp_count StopCount,									--60
		
		stp_countunit StopCountUnit,
		stp_volume StopVolume,					
		stp_volumeunit StopVolumeUnit,
		stpcomp.cmp_name StopCompanyName,
		ISNULL(stops.stp_address, stpcomp.cmp_address1) As StopAddress1, --65					
		ISNULL(stops.stp_address2, stpcomp.cmp_address2) As StopAddress2,
		stpcity.cty_nmstct StopCity,			
		stops.stp_zipcode StopZip,
		ISNULL(stops.stp_phonenumber, stpcomp.cmp_primaryphone) As StopPhone,
		stpcomp.cmp_contact StopContact,						--70
		
		stops.stp_description StopCommodityName,
		convert(datetime, CONVERT(char, stops.stp_arrivaldate, 101), 101) StopDate,
		convert(datetime, CONVERT(char, stops.stp_arrivaldate, 108), 108) StopTime,	
		convert(datetime, CONVERT(char, stops.stp_arrivaldate, 101), 101) StopTZDate, --DWG {33386} Return TZ times
		convert(datetime, CONVERT(char, stops.stp_arrivaldate, 108), 108) StopTZTime,	--75

		stops.stp_mfh_sequence StopMoveSeq,
		stops.ord_hdrnumber OrdHdrNumber,
		stops.stp_status StopStatus,
		stops.stp_departure_status departureStatus,
		CONVERT(varchar(15),orderheader.ord_number) StopOrderNumber,  -- 80: Make big enough to hold ellipses for suppressed stops
		
		CONVERT(smallint, 0) MinTemp,			
		CONVERT(smallint, 0) MaxTemp,
		0 NumberOfStops,
		SPACE(1) StopDriverLoad,
		SPACE(1) StopDriverUnload,								--85
		
		stops.lgh_number,			
		legheader.lgh_startdate StartDateTime,
		legheader.lgh_startdate StartTZDateTime, --DWG {33386} Return TZ times
		legheader.lgh_tour_number TourNumber,
		eventcodetable.name StopEventText,						--90
		
		orderheader.ord_billto OrderBillTo,
		orderheader.ord_company OrderBy,		--VV
		SPACE(64) CommodityName,				
		stops.stp_type StopEventType,			
		SPACE(10) ShipperStopNumber,							--95
		
		SPACE(10) ConsigneeStopNumber,
		orderheader.ord_revtype1,				
		orderheader.ord_revtype2,				
		orderheader.ord_revtype3,
		orderheader.ord_revtype4,								--100
		
		legheader.lgh_driver1 DriverID,
		stops.stp_tmstatus TMSTATUS,
		orderheader.trl_type1 ord_trl_type1,	
		orderheader.ord_trl_type2,
		orderheader.ord_trl_type3,								--105
		
		orderheader.ord_trl_type4,				
		0 NoPickUps,
		0 NoDropOffs,
		orderheader.ord_terms,
		0 ToBeDeleted,											--110
		
		orderheader.ord_miscqty,
		SPACE(13) First_MT_Trailer,
		SPACE(13) First_Trailer_on_Load,			
		SPACE(8) LegShipper,
		SPACE(10) LegShipperStopNumber,							--115
		
		SPACE(8) LegConsignee,
		SPACE(10) LegConsigneeStopNumber,
        0 ord_hdrnumber,                                        
		CONVERT(decimal(10, 2), 0.0) count2, 
		SPACE(6) count2unit,									--120
		
        orderheader.ord_subcompany,
		legheader.lgh_driver2,
		1 StopIsFirstFromOrder,											
		convert(datetime, null) ScheduledPickupEarliestDtTm,			
		convert(datetime, null) ScheduledPickupLatestDtTm,		--125
		
		convert(datetime, null) ScheduledDeliveryEarliestDtTm,
		convert(datetime, null) ScheduledDeliveryLatestDtTm,
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtearliest
				ELSE ISNULL(stp_arrivaldate, ''19500101'')
				END,
			 120), 120) StopEarliestDtTm,								 
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtlatest
				ELSE ISNULL(stp_departuredate, ''20491231'')
				END,
			 120), 120) StopLatestDtTm,									
		convert(datetime, CONVERT(char, stops.stp_arrivaldate, 120), 120) StopDtTm,	--130
		
		convert(datetime, CONVERT(char, stops.stp_departuredate, 101), 101) StopDepartureDate,
		convert(datetime, CONVERT(char, stops.stp_departuredate, 108), 108) StopDepartureTime,
		convert(datetime, CONVERT(char, stops.stp_departuredate, 120), 120) StopDepartureDtTm,	
		convert(datetime, null) ScheduledPickupEarliestTZDtTm,			--DWG {33386} Return TZ times
		convert(datetime, null) ScheduledPickupLatestTZDtTm,	--135
		
		convert(datetime, null) ScheduledDeliveryEarlTZDtTm,
		convert(datetime, null) ScheduledDeliveryLatestTZDtTm,
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtearliest
				ELSE ISNULL(stp_arrivaldate, ''19500101'')
				END,
			 120), 120) StopEarliestTZDtTm,				 
		convert(datetime, CONVERT( char, 
			 CASE WHEN @OldEarliestLatestTimes <> 0 OR (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, ''19500101''), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, ''19500101''), GETDATE()))<5)
				THEN stp_schdtlatest
				ELSE ISNULL(stp_departuredate, ''20491231'')
				END,
			 120), 120) StopLatestTZDtTm,									
		convert(datetime, CONVERT(char, stops.stp_arrivaldate, 120), 120) StopTZDtTm,	--140
		
		convert(datetime, CONVERT(char, stops.stp_departuredate, 101), 101) StopDepartureTZDate,
		convert(datetime, CONVERT(char, stops.stp_departuredate, 108), 108) StopDepartureTZTime,
		convert(datetime, CONVERT(char, stops.stp_departuredate, 120), 120) StopDepartureTZDtTm,		
		legheader.lgh_tm_status AS lgh_TMStatus,
		legheader.lgh_outstatus AS lgh_OutStatus,				--145
		
		legheader.lgh_enddate AS EndDateTime					--146: JAT {55032} Cadec Routing 
		'

SET @SQLSource = ' FROM stops (NOLOCK) 
	LEFT OUTER JOIN orderheader (NOLOCK) on stops.ord_hdrnumber = orderheader.ord_hdrnumber, -- PTS 49699 begin
	event (NOLOCK),
	eventcodetable (NOLOCK), 
	company stpcomp (NOLOCK), 
	legheader (NOLOCK), 
	city stpcity (NOLOCK) '

 set @SQLWhereToExec = ' WHERE 	stops.lgh_Number = CONVERT(bigint, @lgh_num)
		  AND 	stops.stp_number = event.stp_number  
		  AND   event.evt_sequence = 1
		  AND   stops.stp_event = eventcodetable.abbr
		  AND	stops.cmp_id = stpcomp.cmp_id 
		  AND	stops.lgh_number = legheader.lgh_number 
		  AND	stops.stp_city = stpcity.cty_code '

set @SQLToExec = @SQLCore + cast(@SQLSource As varchar(max)) + cast(@SQLWhereToExec As varchar(max))

exec sp_ExecuteSQL @SQLToExec, N'@lgh_num AS bigint, @OldEarliestLatestTimes AS INT', @lgh_num = @lgh_num, @OldEarliestLatestTimes = @OldEarliestLatestTimes

IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'TMSwitchStpCmpWithinGrp' AND gi_string1 = 'Y') --PTS 82979 Stop Groups
BEGIN
	update #LoadAssignmentType set ToBeDeleted = 1  WHERE StopNumber IN (SELECT StopNumber 
								FROM #LoadAssignmentType JOIN company ON #LoadAssignmentType.StopCompanyID = company.cmp_mastercompany 
								WHERE isnull(cmp_billto,'') <> 'Y' and isnull(cmp_mastercompany,'') <> 'unknown') 

	--Transform the old SQL statment into the Group one
	SET @SQLCore = REPLACE(@SQLCore, N'stops.cmp_id StopCompanyID', N'stpcomp.cmp_id StopCompanyID')
	SET @SQLCore = REPLACE(@SQLCore, N'ISNULL(stops.stp_address, stpcomp.cmp_address1) As StopAddress1', N'ISNULL(stpcomp.cmp_address1, stops.stp_address) As StopAddress1')
	SET @SQLCore = REPLACE(@SQLCore, N'ISNULL(stops.stp_address2, stpcomp.cmp_address2) As StopAddress2', N'ISNULL(stpcomp.cmp_address2, stops.stp_address2) As StopAddress2')
	SET @SQLCore = REPLACE(@SQLCore, N'stops.stp_zipcode StopZip', N'stpcity.cty_zip StopZip')
	SET @SQLCore = REPLACE(@SQLCore, N'ISNULL(stops.stp_phonenumber, stpcomp.cmp_primaryphone) As StopPhone', N'ISNULL(stpcomp.cmp_primaryphone, stops.stp_phonenumber) As StopPhone')

	set @SQLToExec = @SQLCore + cast(@SQLSource As varchar(max)) + 
		cast(N' WHERE stops.lgh_Number = @lgh_num AND stops.stp_number = event.stp_number  
				  AND   event.evt_sequence = 1
				  AND   stops.stp_event = eventcodetable.abbr
				  AND	stpcomp.cmp_mastercompany = stops.cmp_id
				  AND   stpcomp.cmp_mastercompany <> ''UNKNOWN''
				  AND	stops.lgh_number = legheader.lgh_number 
				  AND	stpcomp.cmp_city = stpcity.cty_code  
				  AND	isnull(stpcomp.cmp_billto,'''') = ''N'' ' As varchar(max))
				  
	exec sp_ExecuteSQL @SQLToExec, N'@lgh_num AS bigint, @OldEarliestLatestTimes AS INT', @lgh_num = @lgh_num, @OldEarliestLatestTimes = @OldEarliestLatestTimes;
END


--jgf 7/28/04 {24037}
UPDATE #LoadAssignmentType SET First_MT_Trailer = 'UNKNOWN'
IF EXISTS (SELECT TOP 1 Trailer1 FROM #LoadAssignmentType t inner join eventcodetable e (NOLOCK) on t.EventCode = e.abbr
		WHERE ISNULL(e.mile_typ_from_stop,'') != 'LD' ORDER BY StopMoveSeq)
	UPDATE #LoadAssignmentType
	SET First_MT_Trailer = 
		(SELECT TOP 1 ISNULL(Trailer1, 'UNKNOWN') 
		FROM #LoadAssignmentType t inner join eventcodetable e (NOLOCK) on t.EventCode = e.abbr
		WHERE ISNULL(e.mile_typ_from_stop,'') != 'LD' 
		ORDER BY StopMoveSeq)

UPDATE #LoadAssignmentType SET First_Trailer_on_Load = 'UNKNOWN'
IF EXISTS (SELECT TOP 1 Trailer1 FROM #LoadAssignmentType t inner join eventcodetable e (NOLOCK)on t.EventCode = e.abbr
		WHERE ISNULL(e.mile_typ_from_stop,'') = 'LD' ORDER BY StopMoveSeq)
	UPDATE #LoadAssignmentType
	SET First_Trailer_on_Load = 
		(SELECT TOP 1 ISNULL(Trailer1, 'UNKNOWN') 
		FROM #LoadAssignmentType t inner join eventcodetable e (NOLOCK) on t.EventCode = e.abbr
		WHERE ISNULL(e.mile_typ_from_stop,'') = 'LD' 
		ORDER BY StopMoveSeq)

IF @FilterLastStop = 1
	UPDATE #LoadAssignmentType SET ToBeDeleted = 1 WHERE StopMoveSeq = (SELECT MAX(StopMoveSeq) FROM #LoadAssignmentType) AND (@FuelMode = 0 OR StopMileType in ('BT','MT')) --PTS63043 added line

IF @NoDoubleEnd = 1
begin
	UPDATE #LoadAssignmentType  
	SET ToBeDeleted = 1 
	WHERE stopnumber in (select stopnumber
						 from #LoadAssignmentType t
						 where t.StopMoveSeq = (SELECT MAX(StopMoveSeq) FROM #LoadAssignmentType t2)
							and StopCompanyID = (Select t2.stopcompanyid from #LoadAssignmentType t2  where t2.stopmoveseq = t.stopmoveseq - 1)
							and EventCode IN ('EMT', 'EBT') 
							)
	UPDATE #LoadAssignmentType  
	SET ToBeDeleted = 1 
	WHERE stopnumber in (select stopnumber
						 from #LoadAssignmentType t
						 where t.StopMoveSeq = (SELECT MAX(StopMoveSeq)-1 FROM #LoadAssignmentType t2)
							and StopCompanyID = (Select t2.stopcompanyid from #LoadAssignmentType t2  where t2.stopmoveseq = t.stopmoveseq - 1)
							and EventCode IN ('HMT') 
							)
	UPDATE #LoadAssignmentType
	SET ToBeDeleted = 1
	WHERE EventCode IN ('HMT') 
		AND StopMoveSeq = (SELECT MIN(StopMoveSeq) FROM #LoadAssignmentType)	
end

-- VV 19341
IF (@SkipRTPEvents = 1)
	UPDATE #LoadAssignmentType SET ToBeDeleted = 1 WHERE EventCode IN ('RTP','TRP')

IF(@CombineXStopsWithRegs <> 0 AND (@DeleteDupStops <> 0 or @DeleteDupLLDStops <> 0))
BEGIN
	--TMW DWG/ADR -- start
	UPDATE #LoadAssignmentType
	SET EventCode = 'LLD'
	WHERE EventCode = 'XDL'

	UPDATE #LoadAssignmentType
	SET  EventCode = 'LUL'
	WHERE EventCode = 'XDU'
	--TMW DWG/ADR -- end
END

-- Delete dup stops
IF (@DeleteDupStops <> 0)
	BEGIN
	IF ISNULL(@sSeparateOnFields, '') = ''
		UPDATE #LoadAssignmentType 
		SET ToBeDeleted = 5	-- Use a different value here to indicate suppressed stops, not just a stop that needs deleted.
		from (select * from #LoadAssignmentType) t
		inner join #LoadAssignmentType b ON b.StopMoveSeq = t.StopMoveSeq - 1
		WHERE t.StopCompanyId = b.StopCompanyId
			AND t.StopCity = b.StopCity
			AND t.EventCode = b.EventCode
			AND NOT t.ToBeDeleted = 1
			AND NOT b.ToBeDeleted = 1
	ELSE
		BEGIN
			SET @SQLToExec = 'UPDATE #LoadAssignmentType '
			SET @SQLToExec = @SQLToExec + 'SET ToBeDeleted = 5 '
			SET @SQLToExec = @SQLToExec + 'FROM (select * from #LoadAssignmentType) t '
			SET @SQLToExec = @SQLToExec + 'INNER JOIN #LoadAssignmentType b ON b.StopMoveSeq = t.StopMoveSeq - 1 '
			SET @SQLToExec = @SQLToExec + 'INNER JOIN OrderHeader ON t.OrdHdrNumber = OrderHeader.Ord_hdrNumber '
			SET @SQLToExec = @SQLToExec + 'INNER JOIN OrderHeader o ON b.OrdHdrNumber = o.ord_hdrnumber '
			SET @SQLWhereToExec = 'WHERE '
			SET @TablesInSelect = ''
			SET @NotFirstTime = 0
			WHILE @sSeparateOnFields > ''
				BEGIN
					--find next comma position in field list
					SET @CommaPos = CHARINDEX(',', @sSeparateOnFields)

					--if no more commas then set commapos to end of string to get last field
					IF @CommaPos =0
						SET @CommaPos = DATALENGTH(@sSeparateOnFields)+1

					--Get the field name to compare				
					SET @FieldName= substring(@sSeparateOnFields, 0, @CommaPos)
					SET @FieldName = left(@FieldName, datalength(@FieldName))
					SET @FieldName = rtrim(@FieldName)
					SET @FieldName = ltrim(@FieldName)
					
					--see if we need to add an AND for multiple compares
					IF @NotFirstTime = 1
						SET @SQLWhereToExec = @SQLWhereToExec + 'AND '

					--if we have an external table to join, field not in the #LoadAssignmentType table
					IF CHARINDEX('.', @FieldName) > 0
						BEGIN
							--get the table to join
							SET @TableToJoin = SUBSTRING(@FieldName, 1, CHARINDEX('.', @FieldName)-1)
							IF @TableToJoin = 'OrderHeader'  --set the field for the order header
								SET @SQLWhereToExec = @SQLWhereToExec + @FieldName + ' = o.' + SUBSTRING(@FieldName, CHARINDEX('.', @FieldName)+1, 8000) + ' '
							ELSE
								BEGIN
									RAISERROR('Table %s is not supported.', 16, 1, @TableToJoin)
									RETURN
								END
						END
					ELSE  -- no join table use #LoadAssignmentType fields
						SET @SQLWhereToExec = @SQLWhereToExec + 't.' + @FieldName + ' = ' + 'b.' + @FieldName + ' '
					
					--remove the field from the list
					IF @CommaPos >= DATALENGTH(@sSeparateOnFields)
						SET @sSeparateOnFields = ''
					ELSE
						SET @sSeparateOnFields = SUBSTRING(@sSeparateOnFields, @CommaPos+1, 8000)

					SET @NotFirstTime = 1  -- set that we have at least one field in the where clause
				END
			--add the where clause to the statement and go for it.
			SET @SQLToExec = @SQLToExec + @SQLWhereToExec
	
			EXEC (@SQLToExec)
		END
	END
ELSE
-- Delete dup XDoc stops
IF (@DeleteDupXDocStops <> 0)
	UPDATE #LoadAssignmentType 
		SET ToBeDeleted = 5	-- Use a different value here to indicate suppressed stops, not just a stop that needs deleted.
		from (select * from #LoadAssignmentType) t
		inner join #LoadAssignmentType b ON b.StopMoveSeq = t.StopMoveSeq - 1
		WHERE t.StopCompanyId = b.StopCompanyId
				AND t.EventCode IN (SELECT b.EventCode FROM #LoadAssignmentType b WHERE b.StopMoveSeq = t.StopMoveSeq - 1)
				AND t.EventCode IN ('XDU','XDL')
				AND NOT t.ToBeDeleted = 1
				AND NOT b.ToBeDeleted = 1

--pts 69924 Delete Duplicate LLD stops - and YES I know its running possibly for no reason if @DeleteDupStops = 1
IF (@DeleteDupLLDStops <> 0)
	UPDATE #LoadAssignmentType 
	SET ToBeDeleted = 5	-- Use a different value here to indicate suppressed stops, not just a stop that needs deleted.
	from (select * from #LoadAssignmentType) t
	inner join #LoadAssignmentType b ON b.StopMoveSeq = t.StopMoveSeq - 1
	WHERE t.StopCompanyId = b.StopCompanyId
		AND t.StopCity = b.StopCity
		AND t.EventCode = 'LLD'
		AND NOT t.ToBeDeleted = 1
		AND NOT b.ToBeDeleted = 1

-- If any stops were suppressed above, put the word 'MULTIPLE' in for the StopOrderNumber
UPDATE #LoadAssignmentType 
SET StopOrderNumber = LTRIM(RTRIM(StopOrderNumber)) + '...'
FROM #LoadAssignmentType t
	WHERE ToBeDeleted = 0
 	AND 5 IN (SELECT b.ToBeDeleted FROM #LoadAssignmentType b WHERE b.StopMoveSeq = t.StopMoveSeq - 1)

-- VV 21094
update #LoadAssignmentType set NoPickUps=(SELECT count(DISTINCT StopNumber) from #LoadAssignmentType where EventCode in ('LLD','HLT','HPL','DLD','XDL') AND ToBeDeleted = 0)
update #LoadAssignmentType set NoDropOffs=(SELECT count(DISTINCT StopNumber) from #LoadAssignmentType where EventCode in ('LUL','DLT','DRL','DUL','XDU') AND ToBeDeleted = 0)

IF @NOSENTStopsOnly = 1
	UPDATE #LoadAssignmentType SET ToBeDeleted = 1 WHERE ISNULL(TMSTATUS, 'NOSENT') <> 'NOSENT'

IF (@OrderBasedStopsOnly = 1)	
	UPDATE #LoadAssignmentType
	SET ToBeDeleted = 1
	FROM eventcodetable e (NOLOCK)
	WHERE EventCode = e.abbr
		AND e.ect_billable = 'N'

IF @SendDH = 0
	UPDATE #LoadAssignmentType
	SET ToBeDeleted = 1
	WHERE EventCode IN ('BMT', 'BBT') 
		AND StopMoveSeq = (SELECT MIN(StopMoveSeq) FROM #LoadAssignmentType)

-- Now reset Mileage Totals
UPDATE #LoadAssignmentType 
SET StopMileage = 0 
WHERE ISNULL(StopMileage, -1) = -1

UPDATE MainTmp
SET Mileage = 
	(SELECT SUM(NestTmp.StopMileage)
	 FROM #LoadAssignmentType NestTmp)
FROM #LoadAssignmentType MainTmp

UPDATE MainTmp
SET LoadedMiles = 
	(SELECT SUM(NestTmp.StopMileage) 
 	 FROM #LoadAssignmentType NestTmp
	 WHERE NestTmp.StopMileType = 'LD')
FROM #LoadAssignmentType MainTmp

UPDATE MainTmp
SET EmptyMiles = 
	ISNULL((SELECT SUM(NestTmp.StopMileage) 
	 FROM #LoadAssignmentType NestTmp
	 WHERE ISNULL(NestTmp.StopMileType,'') != 'LD'),0)
FROM #LoadAssignmentType MainTmp

-- Mark DMTs for deletion
IF @ShowDMTs = 0
	UPDATE dropmtstop SET dropmtstop.ToBeDeleted = 1
	FROM #LoadAssignmentType dropmtstop inner join #LoadAssignmentType hookloadedstop ON dropmtstop.StopMoveSeq + 1 = hookloadedstop.StopMoveSeq 
	WHERE dropmtstop.EventCode IN ('EMT', 'DMT', 'EBT' )
	AND hookloadedstop.StopCompanyID = dropmtstop.StopCompanyID
	AND hookloadedstop.StopCity = dropmtstop.StopCity

--Fix mileages around stops that will be removed.
UPDATE #LoadAssignmentType SET
	ToBeDeleted = (SELECT ISNULL(min(Nested.StopMoveSeq), -1)
					FROM #LoadAssignmentType Nested 
					WHERE Nested.StopMoveSeq > StopMoveSeq 
					AND Nested.ToBeDeleted = 0)
	WHERE ToBeDeleted <> 0

UPDATE milesrolleddownstop
	SET StopMileage = milesrolleddownstop.StopMileage + 
		(SELECT ISNULL(SUM(stoprolledin.StopMileage), 0) 
		FROM #LoadAssignmentType stoprolledin 
		WHERE milesrolleddownstop.StopMoveSeq = stoprolledin.ToBeDeleted)
	FROM #LoadAssignmentType milesrolleddownstop 
	WHERE milesrolleddownstop.ToBeDeleted = 0

-- Update the StopMileType to MT if it is not LD
UPDATE #LoadAssignmentType
SET StopMileType = 'MT'
WHERE ISNULL(StopMileType,'') <> 'LD'

/* Now Calculate the stop sequence numbers so always starts with (1) */
IF @RenumberSequence = 1
	BEGIN

	-- Do not renumber for the driver, or update stp_dispatched_seq, which happens below
		UPDATE MainTmp
		SET MainTmp.StopSequence =
			(SELECT COUNT(*) 
	 		 FROM #LoadAssignmentType NestTmp
			 WHERE NestTmp.StopMoveSeq <= MainTmp.StopMoveSeq AND 
				((@CountDHsWhenNumbering = 0 AND NestTmp.ToBeDeleted = 0) OR
				(@CountDHsWhenNumbering <> 0)) )
		FROM #LoadAssignmentType MainTmp;

	UPDATE #LoadAssignmentType
	SET StopSequence = 0 WHERE ToBeDeleted <> 0

	END

/* Now fill in the order information */
IF ISNULL(@order_number, '0') > '0'
  BEGIN
	SET @ordhdr = null

	SELECT @ordhdr = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	WHERE ord_number = @order_number

	IF ISNULL(@ordhdr, 0) = 0
	  BEGIN
		IF (@MoveOrderOverlaid = 1) 
		  BEGIN
			SELECT @ordhdr = ord_hdrnumber
			FROM legheader (NOLOCK)
			WHERE mov_number = @order_number
				AND lgh_number = @lgh_num

			IF (ISNULL(@ordhdr,0) = 0)
			  BEGIN
				SET @sT_1 = 'Unknown order/move number %s'
		--		EXEC tm_t_sp @sT_1, 1, ''
				RAISERROR (@sT_1, 16, -1, @order_number)
				RETURN 1
			  END
		  END	
		ELSE
		  BEGIN
			SET @sT_1 = 'Unknown order number %s'
	--		EXEC tm_t_sp @sT_1, 1, ''
			RAISERROR (@sT_1, 16, -1, @order_number)
			RETURN 1
		  END
	  END
  END
ELSE
	SELECT @ordhdr = ISNULL(orderheader.ord_hdrnumber, 0)
	FROM #LoadAssignmentType, orderheader (NOLOCK)
	WHERE orderheader.ord_hdrnumber = ( 
		SELECT MIN(OrdHdrNumber) 
		FROM #LoadAssignmentType 
		WHERE OrdHdrNumber > 0 AND ToBeDeleted = 0)

IF ISNULL(@ordhdr, 0) = 0
    SELECT @ordhdr = ISNULL(MIN(ord_hdrnumber),0) FROM stops (NOLOCK) WHERE ISNULL(ord_hdrnumber, 0) <> 0 AND mov_number = (SELECT MIN(MoveNumber) FROM #LoadAssignmentType WHERE ToBeDeleted = 0)

-- Update the orderheader information
IF ISNULL(@ordhdr, 0) <> 0
	UPDATE #LoadAssignmentType 
	SET	OrderNumber = LEFT(ISNULL(o.ord_number,''), 12),  
		Revenue = ISNULL(o.ord_totalcharge, CONVERT(float, 0.0)),
		LineHaul = ISNULL(o.ord_charge, CONVERT(float, 0.0)),
		Shipper = LEFT(ISNULL(o.ord_originpoint,''), 8), 
		Consignee = LEFT(ISNULL(o.ord_destpoint,''), 8), 
		ScheduledPickupEarliestDate = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 101), 101),
		ScheduledPickupEarliestTime = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 108), 108),
		ScheduledPickupEarliestDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 120), 120),
		ScheduledPickupLatestDate = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 101), 101),
		ScheduledPickupLatestTime = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 108), 108),
		ScheduledPickupLatestDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 120), 120),
		ScheduledDeliveryEarliestDate = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 101), 101),
		ScheduledDeliveryEarliestTime = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 108), 108),
		ScheduledDeliveryEarliestDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 120), 120),
		ScheduledDeliveryLatestDate = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 101), 101),
		ScheduledDeliveryLatestTime = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 108), 108),
		ScheduledDeliveryLatestDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 120), 120),

		ScheduledPickupEarliestTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 101), 101), --DWG {33386} Set TZ times to date in case no system timezone
		ScheduledPickupEarliestTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 108), 108),
		ScheduledPickupEarliestTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 120), 120),
		ScheduledPickupLatestTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 101), 101),
		ScheduledPickupLatestTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 108), 108),
		ScheduledPickupLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 120), 120),
		ScheduledDeliveryEarlTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 101), 101),
		ScheduledDeliveryEarlTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 108), 108),
		ScheduledDeliveryEarlTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 120), 120),
		ScheduledDeliveryLatestTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 101), 101),
		ScheduledDeliveryLatestTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 108), 108),
		ScheduledDeliveryLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 120), 120),
		@ScheduledPickupEarliestTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 120), 120), --DWG {33386} Return TZ times
		@ScheduledPickupEarliestTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 120), 120),
		@ScheduledPickupEarliestTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_earliestdate,''), 120), 120),
		@ScheduledPickupLatestTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 120), 120),
		@ScheduledPickupLatestTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 120), 120),
		@ScheduledPickupLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_origin_latestdate,''), 120), 120),
		@ScheduledDeliveryEarlTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 120), 120),
		@ScheduledDeliveryEarlTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 120), 120),
		@ScheduledDeliveryEarlTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_earliestdate,''), 120), 120),
		@ScheduledDeliveryLatestTZDate = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 120), 120),
		@ScheduledDeliveryLatestTZTime = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 120), 120),
		@ScheduledDeliveryLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(o.ord_dest_latestdate,''), 120), 120),

		CommodityCode = LEFT(ISNULL(o.cmd_code,''), 8), 
		Pieces = ISNULL(o.ord_totalpieces,0),
		PiecesCountUnit = LEFT(ISNULL(o.ord_totalcountunits,''), 6), 
		Weight = ISNULL(o.ord_totalweight,0),
		WeightUnit = LEFT(ISNULL(o.ord_totalweightunits,''), 6), 
		Volume = ISNULL(o.ord_totalvolume, 0),
		VolumeUnit = LEFT(ISNULL(o.ord_totalvolumeunits, ''), 6),
		ReferenceType = LEFT(ISNULL(o.ord_reftype,''), 6), 
		ReferenceNumber = LEFT(ISNULL(o.ord_refnum,''), 254),
		OrderHeaderComments = LEFT(ISNULL(o.ord_remark,''), 254),
		MinTemp = ISNULL(o.ord_mintemp, 0),
		MaxTemp = ISNULL(o.ord_maxtemp, 0),
		CommodityName = LEFT(ISNULL(o.ord_description, ''), 64),
		ShipperStopNumber = LEFT(ISNULL((SELECT TOP 1 stp_number FROM stops (NOLOCK) WHERE ord_hdrnumber = @ordhdr AND stp_type = 'PUP' ORDER BY stp_mfh_sequence ), ''), 10),
		ConsigneeStopNumber = LEFT(ISNULL((SELECT TOP 1 stp_number FROM stops (NOLOCK) WHERE ord_hdrnumber = @ordhdr AND stp_type = 'DRP' ORDER BY stp_mfh_sequence DESC), ''), 10),
		ord_revtype1 = ISNULL(o.ord_revtype1, ''),
		ord_revtype2 = ISNULL(o.ord_revtype2, ''),
		ord_revtype3 = ISNULL(o.ord_revtype3, ''),
		ord_revtype4 = ISNULL(o.ord_revtype4, ''),
		ord_trl_type1 = ISNULL(o.trl_type1, ''),
		ord_trl_type2 = ISNULL(o.ord_trl_type2, ''),
		ord_trl_type3 = ISNULL(o.ord_trl_type3, ''),
		ord_trl_type4 = ISNULL(o.ord_trl_type4, ''),
		ord_terms = ISNULL(o.ord_terms, ''),
		ord_miscqty = ISNULL(o.ord_miscqty, 0),
		LegShipper = LEFT(ISNULL((SELECT TOP 1 cmp_id FROM stops (NOLOCK) INNER JOIN eventcodetable ect (NOLOCK) ON stops.stp_event = ect.abbr WHERE lgh_number = CONVERT(bigint, @lgh_num) AND ect.mile_typ_from_stop = 'LD' ORDER BY stp_mfh_sequence),''),8),
		LegShipperStopNumber = LEFT(ISNULL((SELECT TOP 1 stp_number FROM stops (NOLOCK) INNER JOIN eventcodetable ect (NOLOCK) ON stops.stp_event = ect.abbr WHERE lgh_number = CONVERT(bigint, @lgh_num) AND ect.mile_typ_from_stop = 'LD' ORDER BY stp_mfh_sequence),''),10),
		LegConsignee = LEFT(ISNULL((SELECT TOP 1 cmp_id FROM stops (NOLOCK) INNER JOIN eventcodetable ect (NOLOCK) ON stops.stp_event = ect.abbr WHERE lgh_number = CONVERT(bigint, @lgh_num) AND ect.mile_typ_to_stop = 'LD' ORDER BY stp_mfh_sequence DESC),''),8),
		LegConsigneeStopNumber = LEFT(ISNULL((SELECT TOP 1 stp_number FROM stops (NOLOCK) INNER JOIN eventcodetable ect (NOLOCK) ON stops.stp_event = ect.abbr WHERE lgh_number = CONVERT(bigint, @lgh_num) AND ect.mile_typ_to_stop = 'LD' ORDER BY stp_mfh_sequence DESC),''),10),
		ord_hdrnumber = @ordhdr,
		ord_subcompany = ISNULL(o.ord_subcompany, '')
	FROM orderheader o (NOLOCK)
	WHERE o.ord_hdrnumber = @ordhdr

--DWG {33386} Return TZ times, adjust the times
SELECT 	@sSysTZ = gi_string1 FROM GeneralInfo (NOLOCK) WHERE gi_name = 'SysTZ'
SELECT 	@iSysDSTCode = CONVERT(int, gi_string1) FROM GeneralInfo (NOLOCK) WHERE gi_name = 'SysDSTCode'
SELECT 	@iSysTZMin = CONVERT(int, gi_string1) FROM GeneralInfo (NOLOCK) WHERE gi_name = 'SysTZMin'
SET @iSysTZ = CONVERT(int, @sSysTZ)

if ISNULL(@iSysTZ, 999) <> 999 AND ISNULL(@sSysTZ, '') <> '' --Make sure the system time zone is set
	BEGIN

	SET @DestDate =  NULL --Scheduled Pickup Earliest
	EXEC ChangeTZ_7 @ScheduledPickupEarliestTZDate, @iSysTZ, @iSysDSTCode, @iSysTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
	SELECT @ScheduledPickupEarliestTZDate = @DestDate, @ScheduledPickupEarliestTZTime = @DestDate, @ScheduledPickupEarliestTZDtTm = @DestDate
	SET @DestDate =  NULL --Scheduled Pickup Latest
	EXEC ChangeTZ_7 @ScheduledPickupLatestTZDate, @iSysTZ, @iSysDSTCode, @iSysTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
	SELECT @ScheduledPickupLatestTZDate = @DestDate, @ScheduledPickupLatestTZTime = @DestDate, @ScheduledPickupLatestTZDtTm = @DestDate
	SET @DestDate =  NULL -- Scheduled Delivery Earliest
	EXEC ChangeTZ_7 @ScheduledDeliveryEarlTZDate, @iSysTZ, @iSysDSTCode, @iSysTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
	SELECT @ScheduledDeliveryEarlTZDate = @DestDate, @ScheduledDeliveryEarlTZTime = @DestDate, @ScheduledDeliveryEarlTZDtTm = @DestDate
	SET @DestDate =  NULL --Scheduled Delivery Latest
	EXEC ChangeTZ_7 @ScheduledDeliveryLatestTZDate, @iSysTZ, @iSysDSTCode, @iSysTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
	SELECT @ScheduledDeliveryLatestTZDate = @DestDate, @ScheduledDeliveryLatestTZTime = @DestDate, @ScheduledDeliveryLatestTZDtTm = @DestDate
	SET @DestDate =  NULL --Start Date/Time
    SELECT TOP 1 @StartTZDateTime = StartTZDateTime FROM #LoadAssignmentType
	EXEC ChangeTZ_7 @StartTZDateTime, @iSysTZ, @iSysDSTCode, @iSysTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
	SELECT @StartTZDateTime = @DestDate
 	
	--update converted dates
	UPDATE #LoadAssignmentType
	SET	ScheduledPickupEarliestTZDate = convert(datetime, CONVERT( char, ISNULL(@ScheduledPickupEarliestTZDate,''), 101), 101), --DWG {33386} Return TZ times
		ScheduledPickupEarliestTZTime = convert(datetime, CONVERT( char, ISNULL(@ScheduledPickupEarliestTZTime,''), 108), 108),
		ScheduledPickupEarliestTZDtTm = convert(datetime, CONVERT( char, ISNULL(@ScheduledPickupEarliestTZDtTm,''), 120), 120),
		ScheduledPickupLatestTZDate = convert(datetime, CONVERT( char, ISNULL(@ScheduledPickupLatestTZDate,''), 101), 101),
		ScheduledPickupLatestTZTime = convert(datetime, CONVERT( char, ISNULL(@ScheduledPickupLatestTZTime,''), 108), 108),
		ScheduledPickupLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(@ScheduledPickupLatestTZDtTm,''), 120), 120),
		ScheduledDeliveryEarlTZDate = convert(datetime, CONVERT( char, ISNULL(@ScheduledDeliveryEarlTZDate,''), 101), 101),
		ScheduledDeliveryEarlTZTime = convert(datetime, CONVERT( char, ISNULL(@ScheduledDeliveryEarlTZTime,''), 108), 108),
		ScheduledDeliveryEarlTZDtTm = convert(datetime, CONVERT( char, ISNULL(@ScheduledDeliveryEarlTZDtTm,''), 120), 120),
		ScheduledDeliveryLatestTZDate = convert(datetime, CONVERT( char, ISNULL(@ScheduledDeliveryLatestTZDate,''), 101), 101),
		ScheduledDeliveryLatestTZTime = convert(datetime, CONVERT( char, ISNULL(@ScheduledDeliveryLatestTZTime,''), 108), 108),
		ScheduledDeliveryLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(@ScheduledDeliveryLatestTZDtTm,''), 120), 120),
		StartTZDateTime = convert(datetime, CONVERT( char, ISNULL(@StartTZDateTime,''), 120), 120)
END

--Convert stop datetimes
select @laststop = 0
select @nextstop = 0
WHILE 1=1 
	BEGIN	
		select 	@nextstop = min(StopNumber)
		FROM	#LoadAssignmentType
		WHERE	StopNumber > @laststop

		IF @nextstop is null BREAK

		--Get stop datetimes
		SELECT @StopEarliestTZDate = StopEarliestTZDate, 
			   @StopEarliestTZTime = StopEarliestTZTime, 
			   @StopEarliestTZDtTm = StopEarliestTZDtTm,
			   @StopLatestTZDate = StopLatestTZDate, 
			   @StopLatestTZTime = StopLatestTZTime,
			   @StopLatestTZDtTm = StopLatestTZDtTm,
			   @StopTZDate = StopTZDate, 
			   @StopTZTime = StopTZTime,
			   @StopTZDtTm = StopTZDtTm,
	   		   @StopDepartureTZDate = StopDepartureTZDate,
			   @StopDepartureTZTime = StopDepartureTZTime,
			   @StopDepartureTZDtTm = StopDepartureTZDtTm
		FROM	#LoadAssignmentType
		WHERE	StopNumber = @nextstop
		
		IF ISNULL(@sSysTZ, '') = ''
			SET @iSourceTZ = 999
		else
			--Set default to System Time Zone
			SELECT @iSourceTZ = @iSysTZ, @iSourceTZDSTCode = @iSysDSTCode, @iSourceTZMin = @iSysTZMin

		--find stop Time Zone information - if any
		--See if Timezone information is on the city attached to the stop
		SELECT 	@iStopTZ = cty_GMTdelta, 
				@iStopTZMin = cty_TZMins, 
				@sDSTApplies = ISNULL(cty_DSTApplies, 'N')
		FROM Stops (NOLOCK)
			INNER JOIN city (NOLOCK) ON city.cty_code = stops.stp_city
		WHERE stops.stp_Number = @nextstop

		if @sDSTApplies = 'Y' 
			SET @iStopTZDSTCode = 0
		else
			SET @iStopTZDSTCode = -1

		if ISNULL(@iStopTZ, 999) <> 999
			SELECT @iSourceTZ = @iStopTZ, @iSourceTZDSTCode = @iStopTZDSTCode, @iSourceTZMin = @iStopTZMin
		else
			--See if Timezone information is on the city attached to the company on the stop
			BEGIN
				SELECT 	@iStopTZ = cty_GMTDelta, 
						@iStopTZMin = cty_TZMins, 
						@sDSTApplies = ISNULL(cty_DSTApplies, 'N')
				FROM Stops (NOLOCK)
					INNER JOIN company (NOLOCK) ON company.cmp_id = stops.cmp_id
					INNER JOIN city (NOLOCK) ON city.cty_code = company.cmp_city
				WHERE stops.stp_Number = @nextstop

				if @sDSTApplies = 'Y' 
					SET @iStopTZDSTCode = 0
				else
					SET @iStopTZDSTCode = -1

				if ISNULL(@iStopTZ, 999) <> 999
					SELECT @iSourceTZ = @iStopTZ, @iSourceTZDSTCode = @iStopTZDSTCode, @iSourceTZMin = @iStopTZMin
			END

		if ISNULL(@iSourceTZ, 999) <> 999 --Make sure the system time zone is set
			BEGIN

				SET @DestDate =  NULL --Stop Earliest
				EXEC ChangeTZ_7 @StopEarliestTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
				SELECT @StopEarliestTZDate = @DestDate, @StopEarliestTZTime = @DestDate, @StopEarliestTZDtTm = @DestDate
				SET @DestDate =  NULL --Stop Latest
				EXEC ChangeTZ_7 @StopLatestTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
				SELECT @StopLatestTZDate = @DestDate, @StopLatestTZTime = @DestDate, @StopLatestTZDtTm = @DestDate
				SET @DestDate =  NULL --Stop (arrival)
				EXEC ChangeTZ_7 @StopTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
				SELECT @StopTZDate = @DestDate, @StopTZTime = @DestDate, @StopTZDtTm = @DestDate
				SET @DestDate =  NULL --Stop Departure
				EXEC ChangeTZ_7 @StopDepartureTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
				SELECT @StopDepartureTZDate = @DestDate, @StopDepartureTZTime = @DestDate, @StopDepartureTZDtTm = @DestDate
			
				--update converted dates
				UPDATE #LoadAssignmentType
				SET	StopEarliestTZDate = convert(datetime, CONVERT( char, ISNULL(@StopEarliestTZDate,''), 101), 101),
					StopEarliestTZTime = convert(datetime, CONVERT( char, ISNULL(@StopEarliestTZTime,''), 108), 108),
					StopEarliestTZDtTm = convert(datetime, CONVERT( char, ISNULL(@StopEarliestTZDtTm,''), 120), 120),
					StopLatestTZDate = convert(datetime, CONVERT( char, ISNULL(@StopLatestTZDate,''), 101), 101),
					StopLatestTZTime = convert(datetime, CONVERT( char, ISNULL(@StopLatestTZTime,''), 108), 108),
					StopLatestTZDtTm = convert(datetime, CONVERT( char, ISNULL(@StopLatestTZDtTm,''), 120), 120),
				    StopTZDate = convert(datetime, CONVERT( char, ISNULL(@StopTZDate,''), 101), 101),
					StopTZTime = convert(datetime, CONVERT( char, ISNULL(@StopTZTime,''), 108), 108),
					StopTZDtTm = convert(datetime, CONVERT( char, ISNULL(@StopTZDtTm,''), 120), 120),
					StopDepartureTZDate = convert(datetime, CONVERT( char, ISNULL(@StopDepartureTZDate,''), 101), 101),
					StopDepartureTZTime = convert(datetime, CONVERT( char, ISNULL(@StopDepartureTZTime,''), 108), 108),
					StopDepartureTZDtTm = convert(datetime, CONVERT( char, ISNULL(@StopDepartureTZDtTm,''), 120), 120)
				WHERE	StopNumber = @nextstop
		
			END

		SELECT @laststop = @nextstop
	END

IF @MoveOrderOverlaid > 0
	BEGIN
	IF ISNULL(@ordhdr, 0) <> 0
		UPDATE #LoadAssignmentType
		SET	MoveNumber = OrderNumber 
	ELSE
		UPDATE #LoadAssignmentType
		SET	OrderNumber = MoveNumber
	END

-- Fill in the Number Of Stops field
UPDATE #LoadAssignmentType
SET NumberOfStops = (SELECT COUNT(*) FROM #LoadAssignmentType WHERE ToBeDeleted = 0)

-- Set StopDriverLoad and StopDriverUnload fields
-- First default to not a driver load/unload
UPDATE #LoadAssignmentType
SET StopDriverLoad = 'N', StopDriverUnload = 'N'

-- Now update as necessary
UPDATE #LoadAssignmentType
SET StopDriverLoad = 'Y'
WHERE EventCode = 'DLD'

UPDATE #LoadAssignmentType
SET StopDriverUnload = 'Y'
WHERE EventCode = 'DUL'

IF (@RenumberSequence = 1) --PTS82979 refactored for stopgroups
BEGIN
	with CTE
		AS ( 
			Select RN = ROW_NUMBER() OVER(Order by stopMoveSeq), T.StopNumber 
			from  (select StopNumber, GN = ROW_NUMBER()OVER(Partition by StopNumber Order BY stopmoveseq), StopMoveSeq
					from #LoadAssignmentType WHERE ToBeDeleted = 0) as T where T.GN = 1
		)
	update #LoadAssignmentType set #LoadAssignmentType.StopSequence = RN  -- (RN -1)  -- ...PTS 85443 - 2014.12.17
	from #LoadAssignmentType Left Join CTE on CTE.StopNumber  = #LoadAssignmentType.StopNumber 

	--suite can't do multi line updates, so do it once at a time 
	Declare @tempStop int, @tempSeq int
	Declare @GoodStops TABLE (StopNum int)
	Declare updater Cursor READ_ONLY FORWARD_ONLY for  
	Select distinct StopNumber, StopSequence from #LoadAssignmentType 
	WHERE ToBeDeleted = 0

	Open updater
	Fetch Next From updater
	INTO @tempStop, @tempSeq

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		update stops set stops.stp_dispatched_sequence = @tempSeq
		where stp_number = @tempStop

		insert into @GoodStops
		Select @tempStop

		Fetch Next From updater
		INTO @tempStop, @tempSeq
	END
	CLOSE updater
	DEALLOCATE updater

	Declare Clearer Cursor READ_ONLY FORWARD_ONLY for
	select distinct StopNumber from #LoadAssignmentType 
	where NOT StopNumber in (Select StopNum from @GoodStops)

	Open Clearer
	Fetch Next From Clearer
	INTO @tempStop

	WHILE @@FETCH_STATUS = 0
	BEGIN
		update stops set stops.stp_dispatched_sequence = NULL
		where stp_number = @tempStop

		Fetch Next From Clearer
		INTO @tempStop
	END
	CLOSE Clearer
	DEALLOCATE Clearer
END


DELETE FROM #LoadAssignmentType
WHERE ToBeDeleted <> 0

SELECT @KillRTPTimeFlag = ISNULL(gi_string1, '') 
FROM generalinfo (NOLOCK)
WHERE gi_name = 'tm_AsnNoRPTm'

IF ISNULL(@KillRTPTimeFlag, '') = 'Y'
	UPDATE #LoadAssignmentType 
	SET	StopDate = null, 
		StopTime = null,
	 	StopEarliestDate = null, 
		StopEarliestTime = null,
	 	StopLatestDate = null, 
		StopLatestTime = null
	WHERE EventCode IN ('RTP','TRP','NBS')

--MZ28760
UPDATE #LoadAssignmentType
SET 	count2 = freightdetail.fgt_count2,
	count2unit = freightdetail.fgt_count2unit
FROM #LoadAssignmentType t, freightdetail (NOLOCK)
WHERE t.StopNumber = freightdetail.stp_number
	AND freightdetail.fgt_sequence = 1

-- If none OR all flags are set, then fall through and send all stops.
IF NOT ((@iFlags & (8192 + 16384 + 4194304) = 0) OR (@iFlags & (8192 + 16384 + 4194304) = 8192 + 16384 + 4194304)) 
  BEGIN
	IF (@iFlags & 8192 = 8192)  -- Only send OPEN (OPN),or non-arrived, stops.
		UPDATE #LoadAssignmentType SET ToBeDeleted = 1 WHERE stopStatus <> 'OPN'
	ELSE IF (@iFlags & 16384 = 16384)  -- Only send COMPLETED (DNE) stops.
		UPDATE #LoadAssignmentType SET ToBeDeleted = 1 WHERE stopStatus <> 'DNE'
	ELSE IF (@iFlags & 4194304 = 4194304)  -- Only send non-departed stops.
		UPDATE #LoadAssignmentType SET ToBeDeleted = 1 WHERE departureStatus <> 'OPN'
  END

-- Get rid of any stops we don't want to actually return
DELETE FROM #LoadAssignmentType
WHERE ToBeDeleted <> 0

-- Reset EndDateTime to match time from last stop.
UPDATE #LoadAssignmentType SET EndDateTime = (SELECT ISNULL(MAX(ISNULL(tmp2.StopDepartureDtTm, CONVERT(datetime, '19500101'))), GETDATE()) FROM #LoadAssignmentType tmp2)

-- Set the Stop Is First From Order flag (is 1 for first stop on order and 0 for other stops on order)
UPDATE #LoadAssignmentType
SET StopIsFirstFromOrder = 0
FROM #LoadAssignmentType t
WHERE EXISTS (SELECT * FROM #LoadAssignmentType a WHERE a.StopOrderNumber = t.StopOrderNumber AND t.StopMoveSeq > a.StopMoveSeq)
	OR ISNULL(StopOrderNumber,'-7') = '-7'	-- Don't include BMT/BBT/EMT/EBT type stops

-- PTS34206
UPDATE #LoadAssignmentType 
	SET StopCity = ISNULL(city.cty_name,'') + ',' + ISNULL(city.cty_state,'') + '/',
		StopPhone = '',
		StopContact = '',
		StopAddress1 = '',
		StopAddress2 = '',
		StopZip= ''
FROM #LoadAssignmentType INNER JOIN stops (NOLOCK) ON StopNumber = stops.stp_number  
		  INNER JOIN city (NOLOCK) ON city.cty_code = stops.stp_city
WHERE StopCompanyID = 'UNKNOWN' 

if RTRIM(ISNULL(@sFieldsToReturn, '')) > ''
	BEGIN
		SET @SQLToExec = N'SELECT '
		SET @SQLToExec = @SQLToExec + @sFieldsToReturn
		SET @SQLToExec = @SQLToExec + ' FROM #LoadAssignmentType ORDER BY StopMoveSeq '

		EXECUTE sp_executesql @SQLToExec --, N'@var LoadAssignmentType readonly', #LoadAssignmentType
	END
ELSE
	SELECT * 
	FROM #LoadAssignmentType 
	ORDER BY StopMoveSeq


GO
GRANT EXECUTE ON  [dbo].[tmail_load_assign5_sp] TO [public]
GO
