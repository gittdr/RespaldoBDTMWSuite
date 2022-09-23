SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
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
	--PTS11689 state filed on database changed to char 6, must truncate for flat file
	-- pts 12279 populate trailer ID field
	DPETE PTS 14433 if general info setting for loca time zone is missint, record does not get produced
	04.23.2007.04 -PTS 37166 - A.Rossman - Updated to use checkcall city by default and closest major city as secondary for checkcalls.
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 * 05/12/2008.02 - PTS 42315 - A.Rossman - Added parameter for trading partner to handle leg  based check call location reports.
 * 07/24/2008.03 - PTS 43834 - A.Rossman - Use next available stop sequence in output
 * 11/06/2009.04 - PTS 49755 - A.Rossman - Use city and state from city table for output records.
 * 10/21/2010.05 - PTS 54483 - A. Rossman - Add reference with stp_number to support inbound 214 compatibililty.
 * 11/14/2011.06 - PTS 60146 - P.Liu - Fixed city/state programming so PTS 37166 and PTS 49755 would work correctly with MobileComm sourced and manual checkcalls.
 * 12/17/2012.07 - PTS 66285 - A. Rossman - Use stp_sequence for next open billable(order) stop in status record.
 * 04/30/2013.08 - PTS 66307 - A. Rossman - Allow for adjustment of time when using CI in Localtimezone setting.
 * 05/16/2014.09 - PTS 77687 - A. Rossman - fix output of LOC record to be type 2 misc record.
 * 06/27/2016.10 - PTS 100986 - Chet Insolia - Empty string large comment fix.
 **/

CREATE  PROCEDURE [dbo].[edi_214_record_id_3_39_ckcall_sp]
                  @e214_edi_status varchar(2),
		  @ckc_number int,
		  @statusdttm datetime,
		  @ordhdrnumber int,
		  @docid  varchar(30),
		  @tradingPartner	varchar(20)	--PTS# 42315
 as


 DECLARE @trpid varchar(20),
         @cityname varchar(18),
         @citynamebak varchar(18),
	 @state varchar(2),
	 @statebak varchar(2),
	 @ckc_commentlarge varchar(250),
	 @ckc_cityname varchar(18),
	 @ckc_state varchar(2),
	 @ckc_latseconds int,
	 @ckc_longseconds int,
	 @ckc_date datetime,
	 @startloc int,
	 @endloc int,
	 @tractorid varchar(8),
	 @latitude varchar(10),
	 @longitude varchar(10),
	 @trailerid varchar(13),
	 @localtimezone char(2),
	 @timezonecode int, --DPH PTS 24878
	 @zero_lat varchar(1),
 	 @zero_long varchar(1),
 	 @majorcityname varchar(18),		--PTS 37166
 	 @majorcity_state	varchar(2),
 	 @cmp_id			varchar(8),	--PTS# - 42315
 	 @stp_sequence	varchar(3),	--PTS 43834
 	 @stp_number int,
 	 @stp_ref varchar(30)

DECLARE @offset_local INT, @offset_city INT, @allowTimeAdj VARCHAR(10)	--66307

-- determine the trailer 
SELECT @trailerid = lgh_primary_trailer from legheader
WHERE lgh_number = (SELECT ckc_lghnumber FROM checkcall WHERE ckc_number = @ckc_number)

IF @ordhdrnumber  <= 0 
	SELECT @ordhdrnumber =  ord_hdrnumber FROM edi_214_locationtracking WHERE eloc_lastckcall = @ckc_number

SELECT @trailerid = ISNULL(@trailerid,'')

--  Get Trading partner ID. If none found default to bill to cmp id
 SELECT @TRPID = ISNULL(edi_trading_partner.trp_id,orderheader.ord_billto),
 		    @cmp_id = orderheader.ord_billto
 FROM  edi_trading_partner RIGHT OUTER JOIN orderheader ON edi_trading_partner.cmp_id = orderheader.ord_billto
 WHERE ord_hdrnumber = @ordhdrnumber
 --AND edi_trading_partner.cmp_id =* orderheader.ord_billto

-- Get check call location information
 SELECT --@cityname = SUBSTRING(ISNULL(ci.cty_name,''),1,18),
	@cityname = SUBSTRING(UPPER(ISNULL(ch.ckc_cityname,ISNULL(ci.cty_name,''))),1,18),	--PSL 11/14 Change 06
 	@citynamebak = SUBSTRING(ISNULL(ckc_cityname,''),1,18),
   @state = SUBSTRING(UPPER(ISNULL(ch.ckc_state,ISNULL(ci.cty_state,''))),1,2),	--PSL 11/14 Change 06
	@statebak = SUBSTRING(ISNULL(ckc_state,''),1,2),
	@ckc_commentlarge = case when ISNULL(ckc_commentlarge, ' ') > ' ' then ckc_commentlarge else ISNULL(ckc_comment,' ') end,
	@ckc_latseconds = ISNULL(ckc_latseconds,0),
	@ckc_longseconds = ISNULL(ckc_longseconds,0),
	@ckc_date = ckc_date,
	@tractorid = ISNULL(ckc_tractor,'UNKNOWN')
 FROM checkcall ch
	--INNER JOIN city ci
	LEFT JOIN city ci	--PSL 11/14 Change 06
		ON ch.ckc_city = ci.cty_code
 WHERE ckc_number  = @ckc_number
-- get time zone from general info

SELECT @localtimezone = left(ltrim(rtrim(isnull(gi_string1,'LT'))),2),
		@allowTimeAdj = ISNULL(UPPER(LEFT(gi_string2,1)),'N')	--66307
FROM generalinfo 
WHERE gi_name = 'Localtimezone'

Select @localtimezone = Isnull(@localtimezone,'LT')

If @localtimezone = '' Select @localtimezone = 'LT'
--DPH PTS 24878
IF @localtimezone = 'CI'

BEGIN

	select @timezonecode = ISNULL(min(cty_GMTDelta),0)
	from city
	where cty_name = @cityname
        and cty_state = @state
        
     --66307 offset for GMT   	
	SELECT @offset_local = ABS(DATEDIFF(HH,getutcdate(),getdate()))
		
	--66307  adjust time to status city timezone if GI setting allows it
	IF @allowTimeAdj = 'Y' AND @timezonecode > 0
		SELECT @statusdttm = DATEADD(HH,(@offset_local - @timezonecode),@statusdttm)
	

	SELECT @localtimezone = 
      	CASE @timezonecode
        	WHEN 4 THEN 'AT'
         	WHEN 5 THEN 'ET'
         	WHEN 6 THEN 'CT'
         	WHEN 7 THEN 'MT'
         	WHEN 8 THEN 'PT'
         	ELSE 'LT'
        END
END
--DPH PTS 24878
-- convert lat and long to flat file format (DPH PTS 26057)
If @ckc_latseconds < 360000 and @ckc_latseconds > -360000
        select @zero_lat = '0' 
Else 
        select @zero_lat = '' 
 
If @ckc_longseconds < 360000 and @ckc_longseconds > -360000
        select @zero_long = '0' 
Else 
        select @zero_long = '' 
 
 SELECT @latitude = 
    CASE
       WHEN  @ckc_latseconds < 0 then 
         CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),ABS(@ckc_latseconds ) / (3600 *1.0))) + 
  @zero_lat + 'S'
       ELSE
  CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),@ckc_latseconds  / (3600 *1.0))) + 
  @zero_lat + 'N'
    END
 
  SELECT @longitude = 
    CASE
       WHEN  @ckc_longseconds < 0 then 
         CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),ABS(@ckc_longseconds ) / (3600 *1.0))) + 
  @zero_long + 'E'
       ELSE
  CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),@ckc_longseconds  / (3600 *1.0))) + 
  @zero_long + 'W'
    END


-- parse the comment large to get major city iff possible
 SELECT @startloc = CHARINDEX(' of ',@ckc_commentlarge)
 IF @startloc > 0 
   BEGIN
     SELECT @endloc = CHARINDEX(',',@ckc_commentlarge)
       IF @endloc > 0 and (@endloc - 1) > (@startloc + 4)
         BEGIN 
	   --DPH PTS 24349 8/19/04
	   SELECT @majorcityname = SUBSTRING(UPPER(@ckc_commentlarge),@startloc + 4,@endloc - (@startloc + 4))  --PTS 37166
          -- SELECT @cityname = SUBSTRING(@ckc_commentlarge,@startloc + 4,@endloc - (@startloc + 4)) --1)
           --SELECT @cityname = SUBSTRING(ISNULL(@cityname,@majorcityname),1,18)
           SELECT @cityname = CASE WHEN (ISNULL(@cityname,'') = '' OR ISNULL(@cityname,'') = (select cty_name from city where cty_code = 0)) 
											AND ISNULL(@majorcityname,'') <> ''
									THEN @majorcityname
									ELSE @cityname 
								END	--PSL 11/14 Change 06
           SELECT @majorcity_state = SUBSTRING(UPPER(@ckc_commentlarge),@endloc + 2,2)	--PTS 37166
           --SELECT @state = SUBSTRING(@ckc_commentlarge,@endloc + 2,2) --1,2)
           --SELECT @state = ISNULL(@state,@majorcity_state)	
           SELECT @state = CASE WHEN (ISNULL(@state,'') = '' OR ISNULL(@state,'') = (select cty_state from city where cty_code = 0))
										AND ISNULL(@majorcity_state,'') <> '' 
								THEN @majorcity_state
								ELSE @state 
								END --PSL 11/14 Change 06
	   --DPH PTS 24239 8/19/04
         END
   END

IF (SELECT ISNULL(@ckc_number,0)) = 0
	SELECT @cityname = ISNULL(@cityname,' '),
		   @state = ISNULL(@state,' '),
		   @tractorid = ISNULL(@tractorid,' '),
		   @trailerid = ISNULL(@trailerid,' '),
		   @latitude = ISNULL(@latitude,'000000000N'),
		   @longitude = ISNULL(@longitude,'000000000W')
		   
--PTS 43834 Get next stop sequence
SELECT 	@stp_sequence = CAST(REPLICATE('0',3-LEN(stp_sequence))
 			+ CAST(stp_sequence AS VARCHAR(3)) AS VARCHAR(3)),
 			@stp_number = stp_number
FROM Stops with(nolock)
WHERE ord_hdrnumber = @ordhdrnumber
AND stp_sequence =(select min(stp_sequence) FROM  stops with(nolock) WHERE ord_hdrnumber = @ordhdrnumber AND stp_status = 'OPN')
	
--END PTS 43834		   
		   
-- then insert results into edi_214
INSERT edi_214 (data_col,trp_id,doc_id)
SELECT 
 data_col = '3' +				-- Record ID
            '39' +				-- Record Version
 @e214_edi_status + REPLICATE(' ',2-datalength(@e214_edi_status)) +
 CONVERT(varchar(8),@statusdttm,112)+	
 SUBSTRING(CONVERT(varchar(8),@statusdttm,8),1,2) +
 SUBSTRING(CONVERT(varchar(8),@statusdttm,8),4,2) +			-- status date AND time
@localtimezone +					-- timezone
	REPLICATE(' ',2-datalength(@localtimezone)) +
 @cityname + REPLICATE(' ',18-datalength(@cityname)) +   --city
 @state + REPLICATE(' ',2-datalength(@state)) +    -- state
 @tractorid + REPLICATE(' ',13-datalength(@tractorid)) +
 REPLICATE(' ',12) +		-- MCUnitNumber
 REPLICATE(' ',4)	+       -- TrailerOwner
 @trailerid + REPLICATE(' ',13-datalength(@trailerid)) +		-- Trailer Number added 10/18/01
 'NS '+				-- StatusReason
 ISNULL(@stp_sequence,'000') + 		--REPLICATE('0',3) +		-- StopNumber
 REPLICATE('0',6)  +		-- StopWeight
 REPLICATE('0',6) +		-- StopQuantity
 REPLICATE(' ',15) +            -- StopReferenceNumber         
 REPLICATE('0',3) +             -- alternate stop number
 @latitude +                    -- latitude
 @longitude +                   -- longitude
 'CKCALL' +                     -- event
 REPLICATE(' ',6) +             -- reasonlate
 'CKCALL',                      -- activity
 trp_id = @tradingPartner,
 doc_id = @docid


-- do not bother with #2 or ref number records for this status
SELECT @ckc_commentlarge = SUBSTRING(@ckc_commentlarge,1,76) -- make sure it fits field on #4
-- put out #4 with location
-- then insert results into edi_214
IF (SELECT ISNULL(@ckc_number,0)) <> 0
INSERT edi_214 (data_col,trp_id,doc_id)
SELECT 
 data_col = '4' +				-- Record ID
            '39' +	
            'LOC   ' +
             @ckc_commentlarge + REPLICATE(' ',76-DATALENGTH(@ckc_commentlarge)),  
	    trp_id = @tradingPartner,
	    doc_id = @docid
--PTS 54483
IF(SELECT ISNULL(@stp_number,0)) > 0
  INSERT INTO edi_214(data_col,trp_id,doc_id)
    SELECT data_col = '439REFSTP' + CAST(@stp_number as varchar(30)),
    	   trp_id = @tradingPartner,
    	   doc_id = @docid
GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_3_39_ckcall_sp] TO [public]
GO
