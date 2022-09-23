SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[MapQ_CurrentGPS]
	(
	@LayerName Varchar(40) ='View1:Current GPS',
	@OnlyTrcTypeList1 Varchar(255) ='',
	@OnlyTrcTypeList2 Varchar(255) ='',
	@OnlyTrcTypeList3 Varchar(255) ='',
	@OnlyTrcTypeList4 Varchar(255) ='',
	@OnlyTrc_avl_statusList Varchar(255) ='',
	@OnlyTrc_trc_ownerList Varchar(255) ='',
	@Onlytrc_companyList Varchar(255) ='',
	@Onlytrc_divisionList Varchar(255) ='',
	@Onlytrc_fleetList Varchar(255) ='',
	@Onlytrc_terminalList Varchar(255) ='',
	@Onlytrc_exp1_dateGreaterThan_N_HoursFromNow Float =-1,
	@Onlytrc_exp2_dateGreaterThan_N_HoursFromNow Float =-1
	)
AS

Declare @trc_exp1_dateMustBeGreaterThan DateTime
Declare @trc_exp2_dateMustBeGreaterThan DateTime

Declare @MaxDate Datetime

SET NOCOUNT ON  -- PTS46367

Set @MaxDate='12/31/2050 23:59'

Set	@OnlyTrcTypeList1 = ',' + ISNULL(@OnlyTrcTypeList1,'') + ','
Set	@OnlyTrcTypeList2 = ',' + ISNULL(@OnlyTrcTypeList2,'') + ','
Set	@OnlyTrcTypeList3 = ',' + ISNULL(@OnlyTrcTypeList3,'') + ','
Set	@OnlyTrcTypeList4 = ',' + ISNULL(@OnlyTrcTypeList4,'') + ','

Set	@OnlyTrc_avl_statusList = ',' + ISNULL(@OnlyTrc_avl_statusList,'') + ','
Set	@OnlyTrc_trc_ownerList = ',' + ISNULL(@OnlyTrc_trc_ownerList,'') + ','
Set	@Onlytrc_companyList = ',' + ISNULL(@Onlytrc_companyList,'') + ','
Set	@Onlytrc_divisionList = ',' + ISNULL(@Onlytrc_divisionList,'') + ','
Set	@Onlytrc_fleetList = ',' + ISNULL(@Onlytrc_fleetList,'') + ','
Set	@Onlytrc_terminalList = ',' + ISNULL(@Onlytrc_terminalList,'') + ','

Set @trc_exp1_dateMustBeGreaterThan= @MaxDate
IF @Onlytrc_exp1_dateGreaterThan_N_HoursFromNow>=0
BEGIN
	Set @trc_exp1_dateMustBeGreaterThan=DateAdd(n, Convert(int,60.0* @Onlytrc_exp1_dateGreaterThan_N_HoursFromNow),GetDate())
END
Set @trc_exp2_dateMustBeGreaterThan= @MaxDate
IF @Onlytrc_exp2_dateGreaterThan_N_HoursFromNow>=0
BEGIN
	Set @trc_exp2_dateMustBeGreaterThan=DateAdd(n, Convert(int,60.0* @Onlytrc_exp2_dateGreaterThan_N_HoursFromNow),GetDate())
END
	

Select 
	@LayerName Layer,
	trc_Number ItemID,
	'1' Importance,
	(CASE WHEN Trc_avl_status ='AVL' then 'GREEN TRUCK' ELSE 'RED TRUCK' END) Symbol,
	dbo.Fnc_ConvertLatLongSecondsToALKFormat(trc_gps_latitude,trc_gps_longitude) Location, 
	trc_Number +'|' + Trc_type1 + '|' + Trc_type2 + '|' + Trc_type3 + '|' + Trc_type4 + '|' + Trc_owner +'|'
		+ Convert(Varchar(5),trc_gps_date,1) + ' '+Convert(Varchar(5),trc_gps_date,8)  +'|' +
		+ ISNULL((select cty_name +',' + cty_state from city (NOLOCK) where trc_avl_city=cty_code),'UNK') 
	DataValue,
	'ID|TrcType1|TrcType2|TrcType3|TrcType4|TrcOwner|trc_gps_date|AvlCity' DataLabels,

	trc_gps_latitude,
	trc_gps_longitude,
	trc_gps_date,
	trc_avl_date,
	AvlCity=(select cty_name from city (NOLOCK) where trc_avl_city=cty_code),
	AvlState=(select cty_state from city (NOLOCK) where trc_avl_city=cty_code)
from tractorprofile (NOLOCK) 
where 	
	trc_retiredate>Getdate()
	AND (@OnlyTrcTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type1,'') ) + ',', @OnlyTrcTypeList1) >0)
	AND (@OnlyTrcTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type2,'')  ) + ',', @OnlyTrcTypeList2) >0)
	AND (@OnlyTrcTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type3,'')  ) + ',', @OnlyTrcTypeList3) >0)
	AND (@OnlyTrcTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type4,'')  ) + ',', @OnlyTrcTypeList4) >0)
	AND (@OnlyTrc_avl_statusList =',,' or CHARINDEX(',' + RTRIM( ISNULL(Trc_avl_status,'')  ) + ',', @OnlyTrc_avl_statusList) >0)
	AND (@OnlyTrc_trc_ownerList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_owner,'')  ) + ',', @OnlyTrc_trc_ownerList) >0)
	AND (@Onlytrc_companyList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_company,'')  ) + ',', @Onlytrc_companyList) >0)
	AND (@Onlytrc_divisionList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_division,'')  ) + ',', @Onlytrc_divisionList) >0)
	AND (@Onlytrc_fleetList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_fleet,'')  ) + ',', @Onlytrc_fleetList) >0)
	AND (@Onlytrc_terminalList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_terminal,'')  ) + ',', @Onlytrc_terminalList) >0)
	
	AND ISNULL(@trc_exp1_dateMustBeGreaterThan,@MaxDate) > trc_exp1_date
	AND ISNULL(@trc_exp2_dateMustBeGreaterThan,@MaxDate) > trc_exp2_date

GO
GRANT EXECUTE ON  [dbo].[MapQ_CurrentGPS] TO [public]
GO
