SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_3_34_ckcall_sp] 
                  @e214_edi_status varchar(2),
		  @ckc_number int,
		  @statusdttm datetime,
		  @ordhdrnumber int,
		  @docid  varchar(30)
 as
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
	PTS11689 State field on database changed to 6 char, must truncate for flat file
 * 11/30/2007.01 ? PTS40464 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


 DECLARE @trpid varchar(20),
         @cityname varchar(30),
         @citynamebak varchar(20),
	 @state varchar(2),
	 @statebak varchar(2),
	 @ckc_commentlarge varchar(250),
	 @ckc_cityname varchar(25),
	 @ckc_state varchar(2),
	 @ckc_latseconds int,
	 @ckc_longseconds int,
	 @ckc_date datetime,
	 @startloc int,
	 @endloc int,
	 @tractorid varchar(8),
	 @latitude varchar(9),
	 @longitude varchar(9)

--  Get Trading partner ID. If none found default to bill to cmp id
 SELECT @TRPID = ISNULL(edi_trading_partner.trp_id,orderheader.ord_billto)
 FROM  edi_trading_partner RIGHT OUTER JOIN orderheader ON edi_trading_partner.cmp_id = orderheader.ord_billto
 WHERE ord_hdrnumber = @ordhdrnumber
 --AND edi_trading_partner.cmp_id =* orderheader.ord_billto

-- Get check call location information
 SELECT @cityname = SUBSTRING(ISNULL(ckc_cityname,''),1,18),
 	@citynamebak = SUBSTRING(ISNULL(ckc_cityname,''),1,18),
        @state = SUBSTRING(ISNULL(ckc_state,''),1,2),
	@statebak = SUBSTRING(ISNULL(ckc_state,''),1,2),
	@ckc_commentlarge = ISNULL(ckc_commentlarge,''),
	@ckc_latseconds = ISNULL(ckc_latseconds,0),
	@ckc_longseconds = ISNULL(ckc_longseconds,0),
	@ckc_date = ckc_date,
	@tractorid = ISNULL(ckc_tractor,'UNKNOWN')
 FROM checkcall
 WHERE ckc_number  = @ckc_number

-- convert lat and long to flat file format
 SELECT @latitude = 
    CASE
       WHEN  @ckc_latseconds < 0 then 
         CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),ABS(@ckc_latseconds ) / (3600 *1.0))) + 'S'
       ELSE
	 CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),@ckc_latseconds  / (3600 *1.0))) + 'N'
    END

  SELECT @longitude = 
    CASE
       WHEN  @ckc_longseconds < 0 then 
         CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),ABS(@ckc_longseconds ) / (3600 *1.0))) + 'E'
       ELSE
	 CONVERT(VARCHAR(9),CONVERT(DECIMAL(9,5),@ckc_longseconds  / (3600 *1.0))) + 'W'
    END

-- parse the comment large to get major city iff possible
 SELECT @startloc = CHARINDEX(' of ',@ckc_commentlarge)
 IF @startloc > 0 
   BEGIN
     SELECT @endloc = CHARINDEX(',',@ckc_commentlarge)
       IF @endloc > 0 and (@endloc - 1) > (@startloc + 4)
         BEGIN 
           SELECT @cityname = SUBSTRING(@ckc_commentlarge,@startloc + 4,@endloc - 1)
           SELECT @cityname = SUBSTRING(ISNULL(@cityname,@citynamebak),1,18)
           SELECT @state = SUBSTRING(@ckc_commentlarge,@endloc + 1,2)
           SELECT @state = ISNULL(@state,@statebak)
         END
   END

 

-- then insert results into edi_214
INSERT edi_214 (data_col,trp_id,doc_id)
SELECT 
 data_col = '3' +				-- Record ID
            '34' +				-- Record Version
 @e214_edi_status + REPLICATE(' ',2-datalength(@e214_edi_status)) +
 CONVERT(varchar(8),@statusdttm,112)+	
 SUBSTRING(CONVERT(varchar(8),@statusdttm,8),1,2) +
 SUBSTRING(CONVERT(varchar(8),@statusdttm,8),4,2) +			-- status date AND time
 'LT' +                                         -- time zone
 @cityname + REPLICATE(' ',18-datalength(@cityname)) +   --city
 @state + REPLICATE(' ',2-datalength(@state)) +    -- state
 @tractorid + REPLICATE(' ',13-datalength(@tractorid)) +
 REPLICATE(' ',12) +		-- MCUnitNumber
 REPLICATE(' ',4)	+       -- TrailerOwner
 REPLICATE(' ',13) +		-- Trailer Number
 'NS '+				-- StatusReason
 REPLICATE('0',3) +		-- StopNumber
 REPLICATE('0',6)  +		-- StopWeight
 REPLICATE('0',6) +		-- StopQuantity
 REPLICATE(' ',15) +            -- StopReferenceNumber         
 REPLICATE('0',3) +             -- alternate stop number
 @latitude +                    -- latitude
 @longitude +                   -- longitude
 'CKCALL' +                     -- event
 REPLICATE(' ',6) +             -- reasonlate
 'CKCALL',                      -- activity
 trp_id = @TRPID,
 doc_id = @docid


-- do not bother with #2 or ref number records for this status
SELECT @ckc_commentlarge = SUBSTRING(@ckc_commentlarge,1,79) -- make sure it fits field on #4
-- put out #4 with location
-- then insert results into edi_214
INSERT edi_214 (data_col,trp_id,doc_id)
SELECT 
 data_col = '4' +				-- Record ID
            '34' +	
            'LOC' +
             @ckc_commentlarge + REPLICATE(' ',79-DATALENGTH(@ckc_commentlarge)),  
	    trp_id = @TRPID,
	    doc_id = @docid

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_3_34_ckcall_sp] TO [public]
GO
