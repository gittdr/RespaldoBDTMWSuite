SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_cached_route_response] @ord_number varchar(12) = null,
						 @cmp_from varchar(25) = null, -- PTS 61189 change cmp_id fields to 25 length
						 @cmp_to varchar(25) = null -- PTS 61189 change cmp_id fields to 25 length
AS

SET NOCOUNT ON 

DECLARE @mov_number int,
	 @stp_seq_from int,
	 @stp_seq_to int,
	 @tmp varchar(2000),
	 @route varchar(4000),
	 @cumdist decimal(9,2),
	 @cumtime decimal(9,2),
	 @mt_identity int

CREATE TABLE #stops(
		stp_seq 	int,
		rt_seq		int,
		stp_mtid	int,
		route		varchar(2000),
		miles		decimal(9,2),
		hours		decimal(9,2)
)

CREATE TABLE #route(
		LocationName      varchar(10)    
		,Distance         varchar(10) 
		,TollFlag         varchar(10) 
		,RollingTime      varchar(10) 
		,Latitude         varchar(10) 
		,Logitude         varchar(10) 
		,FromState        varchar(10) 
		,ToCity           varchar(10) 
		,FromCity         varchar(10)
		,ToState          varchar(10)   
		,ShowAllRouteInfo varchar(10)    
		,TotalDistance    varchar(15)    
		,TotalMiles       varchar(15)
		,TotalHours       varchar(10)
		,DistanceIn       varchar(10)
		,VehicleType      varchar(10)
		,Options          varchar(10)
		,FromStreet       varchar(10)
		,ToStreet         varchar(10)
		,PageOnly         varchar(10)
		,NotMainView      varchar(10)
		,Route            varchar(4000)
		,Direction        varchar(10)
		,RoutingMethod    varchar(10)
		,State            varchar(10)
		,Miles            varchar(10)
		,Hours            varchar(10)
		,FromCompany      varchar(25) --PTS 67926 RS: Changed size to 25
		,ToCompany        varchar(25) --PTS 67926 RS: Changed size to 25
		,MTIdentity       varchar(10)
		,OrderNumber      varchar(12)
)

SELECT @route=''

SELECT @mov_number=mov_number 
FROM orderheader (NOLOCK)
WHERE ord_number=@ord_number

SELECT @stp_seq_from=stp_sequence 
FROM stops (NOLOCK)
WHERE mov_number=@mov_number and cmp_id = @cmp_from

SELECT @stp_seq_to=stp_sequence 
FROM stops (NOLOCK)
WHERE mov_number=@mov_number and cmp_id = @cmp_to

INSERT #stops(stp_seq, rt_seq, stp_mtid, route, miles, hours)
	SELECT s.stp_sequence, -1, s.stp_lgh_mileage_mtid, m.mt_route, m.mt_miles, m.mt_hours 
	FROM stops s (NOLOCK)
	LEFT JOIN mileagetable m (NOLOCK) ON s.stp_lgh_mileage_mtid = m.mt_identity  
	where s.mov_number=@mov_number 
	  AND s.stp_sequence > @stp_seq_from and s.stp_sequence <= @stp_seq_to

INSERT #stops(stp_seq, rt_seq, stp_mtid, route, miles, hours)
	SELECT s.stp_sequence, r.rd_sequence, s.stp_lgh_mileage_mtid, ISNULL(r.rd_route,'') + ' ' + ISNULL(r.rd_direction,'') +
	 ' ' + ISNULL(r.rd_interchange,'') + ' ' + ISNULL(convert(varchar(10),r.rd_distance),''), r.rd_cumdist, r.rd_cumtime
	FROM stops s (NOLOCK) 
	LEFT JOIN routingdirections r (NOLOCK) ON s.stp_lgh_mileage_mtid = r.mt_identity 
	where s.mov_number=@mov_number
	  AND s.stp_sequence > @stp_seq_from and s.stp_sequence <= @stp_seq_to
	 

DELETE FROM #stops WHERE LEN(ISNULL(route,''))=0

DELETE FROM #stops WHERE rt_seq>0 AND stp_mtid IN (SELECT stp_mtid FROM #stops WHERE rt_seq=-1)

-- this is not correct calculations. Needs to be corrected if requested.
-- It was done for Pauls Hauling and they didn't require this data. If someone needs full functionality
-- of this view, sp needs to be extended.
SELECT @cumdist = max(miles), @cumtime = max(hours) FROM #stops

--print @stp_seq_from
--print @stp_seq_to
--SELECT route,* FROM #stops ORDER BY stp_seq, rt_seq

DECLARE route_cur CURSOR FOR
	SELECT route FROM #stops ORDER BY stp_seq, rt_seq
OPEN route_cur
	FETCH NEXT FROM route_cur INTO @tmp
	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT @route = @route + @tmp + ' '
		FETCH NEXT FROM route_cur INTO @tmp
	END
CLOSE route_cur
DEALLOCATE route_cur

SELECT @route=REPLACE(@route,char(9),' ')
SELECT @route=REPLACE(@route,char(10),'')
SELECT @route=REPLACE(@route,char(13),' ')


INSERT INTO #route (Route,  MTIdentity,   TotalMiles, TotalHours, FromCompany, ToCompany, OrderNumber, Miles, Hours)
             SELECT @route, @mt_identity, @cumdist,   @cumtime,   @cmp_from,   @cmp_to,   @ord_number, @cumdist, @cumtime

SELECT	LocationName     
	,Distance     
	,TollFlag     
	,RollingTime  
	,Latitude     
	,Logitude     
	,FromState    
	,ToCity     
	,FromCity   
	,ToState    
	,ShowAllRouteInfo     
	,TotalDistance     
	,TotalMiles     
	,TotalHours     
	,DistanceIn     
	,VehicleType    
	,Options     
	,FromStreet  
	,ToStreet    
	,PageOnly    
	,NotMainView 
	,ltrim(Route) Route
	,Direction 
	,RoutingMethod     
	,State   
	,Miles   
	,Hours   
	,FromCompany     
	,ToCompany     
	,MTIdentity    
	,OrderNumber
FROM #route

DROP TABLE #route


DROP TABLE #stops

GO
GRANT EXECUTE ON  [dbo].[tm_cached_route_response] TO [public]
GO
