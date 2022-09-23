SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create proc [dbo].[MapQ_GPSasOfHourOfDay]
	(
	@PlainDate datetime,
	@LowH int=0,
	@HighH int=24,
	@OnlyTrcIDList varchar(500)='',
	@OnlyTrcTypeList1 Varchar(255) ='',
	@OnlyTrcTypeList2 Varchar(255) ='',
	@OnlyTrcTypeList3 Varchar(255) ='',
	@OnlyTrcTypeList4 Varchar(255) ='',
	@ColorTrucksYN Char(1)='Y'
	/*
		Color Scheme: 
		Red means late. Service exception noted for the legheader-- Does not check actual dates & times
		yellow means at a planned stop. Within 25 miles
		Blue means idle. No GPS for over 2 hours or not moved for over 1 hour and not at a stop
		Green means active, on time and not a stop

	*/

	)
AS 
Declare @H int

SET NOCOUNT ON  -- PTS46367

Set @PlainDate= Convert(datetime, convert(varchar(8),@PlainDate,1) )
--select @PlainDate
Set @h=@LowH

Set	@OnlyTrcTypeList1 	= ',' + ISNULL(@OnlyTrcTypeList1,'') + ','
Set	@OnlyTrcTypeList2 	= ',' + ISNULL(@OnlyTrcTypeList2,'') + ','
Set	@OnlyTrcTypeList3 	= ',' + ISNULL(@OnlyTrcTypeList3,'') + ','
Set	@OnlyTrcTypeList4 	= ',' + ISNULL(@OnlyTrcTypeList4,'') + ','
Set	@OnlyTrcIDList 		= ',' + ISNULL(@OnlyTrcIDList,'') + ','

While @h<=@HighH
BEGIN
	
	Select 
		'GPSHistory'  Layer,
		c2.ckc_tractor ItemID,
		'1' Importance,

	Case 	WHEN @ColorTrucksYN='N'
		THEN 'GREEN TRUCK'
		WHEN exists(select *  from stops s (NOLOCK), serviceexception sn (NOLOCK)
			where s.lgh_number=ckc_lghnumber and sn.sxn_stp_number=s.stp_number)
		THEN 'RED TRUCK' 

		WHEN  ( Select dateDiff(hh,ckc_date, DateAdd(hh,@h,@PlainDate) ) ) > 2
		THEN 'BLUE TRUCK'

		WHEN 	Exists(SELECT *
				From stops (NOLOCK)
				where 	stops.lgh_number=ckc_lghnumber
					AND
					dbo.fnc_AirMilesBetweenCityCodes(ckc_city,stp_city) <25
			 	)
		then 'YELLOW TRUCK'

		WHEN 	(select sum(c3.ckc_mileage) 
			from checkcall c3 (NOLOCK) 
			where 	c3.ckc_tractor=c2.ckc_tractor
				AND
				c3.ckc_date between dateadd(hh,-1,c2.ckc_date) and c2.ckc_date
			)=0
		THEN 'BLUE TRUCK'
		
		
	ELSE 	'GREEN TRUCK'
	END Symbol,


		dbo.Fnc_ConvertLatLongSecondsToALKFormat(ckc_latseconds,ckc_Longseconds) Location, 
		c2.ckc_tractor +'|' 
		+ Convert(Varchar(5),ckc_date,1) + ' '+Convert(Varchar(5),ckc_date,8)  +'|' 
		+ISNULL( (select convert(varchar(10),mov_number) from legheader l (NOLOCK) where l.lgh_number=ckc_lghnumber),'') + '|'
	DataValue,
		'ID|gps date|Move#' DataLabels,
	Hour,
	CityRoute=dbo.fnc_StopsListForLghNumber(ckc_lghnumber) ,
	ckc_cityName,
	ckc_state,
	ckc_lghnumber

	FROM
		(
			Select  ckc_tractor,
				Max(ckc_number) Ckc_number,
				@H Hour
			From checkcall (NOLOCK)
			where ckc_date between DateAdd(hh,@h-24,@PlainDate) and DateAdd(hh,@h,@PlainDate)
			Group by ckc_tractor
		) 
		C,
		Checkcall c2,
		TractorProfile
	where 	c.ckc_number=c2.ckc_number
		and
		trc_number=c.ckc_Tractor
		AND
		trc_number<>'UNKNOWN'
			
	AND (@OnlyTrcTypeList1 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type1,'') ) + ',', @OnlyTrcTypeList1) >0)
	AND (@OnlyTrcTypeList2 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type2,'')  ) + ',', @OnlyTrcTypeList2) >0)
	AND (@OnlyTrcTypeList3 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type3,'')  ) + ',', @OnlyTrcTypeList3) >0)
	AND (@OnlyTrcTypeList4 =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_type4,'')  ) + ',', @OnlyTrcTypeList4) >0)

	AND (@OnlyTrcIDList =',,' or CHARINDEX(',' + RTRIM( ISNULL(trc_number,'')  ) + ',', @OnlyTrcIDList) >0)

	Order by trc_number			
	
	Set @h =@h+1
		


END

GO
GRANT EXECUTE ON  [dbo].[MapQ_GPSasOfHourOfDay] TO [public]
GO
