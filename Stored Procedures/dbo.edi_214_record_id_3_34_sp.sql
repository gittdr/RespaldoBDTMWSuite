SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
pts 10311 make v3.4 edi 214 work for PSv2001 (2002)
PTS 11689 state filed on database changed to char 6 , must truncate for flat file
*/
CREATE PROCEDURE [dbo].[edi_214_record_id_3_34_sp] 
@StatusCode varchar(2),
@StatusDateTime datetime,
@TimeZone varchar(2),
@StatusCity integer,
@TractorID varchar(13),
@MCUnitNumber int,
@TrailerOwner varchar(4),
@Trailerid varchar(13),
@StatusReason varchar(3),
@StopNumber varchar(3),
@StopWeight integer,
@StopQuantity integer,
@StopReferenceNumber varchar(15),
@ordhdrnumber integer,
@stopevent varchar(6),
@stopreasonlate varchar(6),
@activity varchar(6),
@docid varchar(30)
 as


 DECLARE @TRPNbr varchar(20), @billtocmpid varchar(8)
 DECLARE @weight varchar(6), @quantity varchar(6)
 DECLARE @stopcmpid varchar(8), @n101code varchar(3), @stp_number int
 DECLARE @nextfgtnumber int, @altstopnbr varchar(6), @stp_type varchar(6)
 DECLARE @stpsequence int,@localzonenbr int, @trpzonenbr int, @diff int
 declare @localtimezone char(2), @trp_timezone char(2),@cty_lat varchar(9),@cty_long varchar(9)

-- This should be passed, but had to be determined here, because
-- v2000 cutoff makes software changes impossible. Code to call this
--is in ps_w_edi214 in VisDisp pfc_save code
 SELECT  @stp_number = stp_number,
 	@stopcmpid = cmp_id,
	@n101code = 
	   CASE stp_type
	        WHEN 'PUP' THEN 'PU'
                WHEN 'DRP' THEN 'DR'
                ELSE 'XX'
           END
 FROM stops
 WHERE ord_hdrnumber = @ordhdrnumber
 AND  stp_sequence = CONVERT(int,@StopNumber) 


 SELECT @altstopnbr = convert(varchar(6),COUNT(*))
 FROM stops 
 WHERE ord_hdrnumber = @ordhdrnumber
 AND stp_type =  @stp_type
 AND stp_sequence <= @stpsequence

SELECT @localtimezone = left(ltrim(rtrim(isnull(gi_string1,'LT'))),2)
FROM generalinfo 
WHERE gi_name = 'Localtimezone'

-- Condition parameters
SELECT @StatusCode=isnull( @StatusCode ,' ')
SELECT @TimeZone=isnull( @TimeZone ,'LT')
SELECT @TractorID=isnull( @TractorID ,' ')
SELECT @MCUnitnUMBER=ISNULL( @MCUnitNumber ,0)
SELECT @TrailerOwner=isnull( @TrailerOwner ,' ')
SELECT @Trailerid=isnull( @Trailerid ,' ')
SELECT @StatusReason = ISNULL(@StatusReason,'')
SELECT @StopNumber=isnull( @StopNumber ,' ')
SELECT @Weight=CONVERT(varchar(6),isnull( @StopWeight ,0))
SELECT @Quantity=CONVERT(varchar(6),isnull( @StopQuantity ,0))
SELECT @StopReferenceNumber=isnull( @StopReferenceNumber ,' ')
SELECT @stopreasonlate = ISNULL(@stopreasonlate,' ')
SELECT @stopevent = ISNULL(@stopevent,' ')
 SELECT @altstopnbr = ISNULL(@altstopnbr,0)

-- Find bill to company
SELECT @billtocmpid = ord_billto
FROM  orderheader
WHERE ord_hdrnumber = @ordhdrnumber

-- Find trading partner ID
SELECT @TRPNbr = trp_id
FROM	edi_trading_partner
WHERE  cmp_id = @billtocmpid

-- If none found default to bill to cmp id
SELECT @TRPNbr = ISNULL(@TRPNbr,@billtocmpid)

--set timezone base on the trp_timezone value
if @timezone = 'LT' begin
    select @timezone = @localtimezone
end 

select @cty_lat = convert(varchar(9),isnull(cty_latitude,0)),
       @cty_long = convert(varchar(9),isnull(cty_longitude,0))
from   city
WHERE cty_code=@statuscity

-- then insert results into edi_214
INSERT edi_214 (data_col, trp_id, doc_id) 
SELECT 

data_col = '3' +				-- Record ID
'34' +						-- Record Version
@StatusCode +					-- StatusCode
	REPLICATE(' ',2-datalength(@StatusCode)) +
CONVERT(varchar(8),@StatusDateTime,112)+	
SUBSTRING(CONVERT(varchar(8),@StatusDateTime,8),1,2) +
SUBSTRING(CONVERT(varchar(8),@StatusDateTime,8),4,2) +			-- status date AND time
@timezone +					-- timezone
	REPLICATE(' ',2-datalength(@timezone)) +
SUBSTRING(cty_name,1,18) +					-- city
	REPLICATE(' ',18-datalength(SUBSTRING(cty_name,1,18))) +
SUBSTRING(cty_state,1,2) +					-- state
	REPLICATE(' ',2-datalength(SUBSTRING(cty_state,1,2))) +
@tractorid +					-- Tractor
	REPLICATE(' ',13-datalength(@tractorid)) +
CONVERT(varchar(12),@MCUnitNumber) +					-- MCUnitNumber
	REPLICATE(' ',12-datalength(CONVERT(varchar(12),@MCUnitNumber))) +
@TrailerOwner +					-- TrailerOwner
	REPLICATE(' ',4-datalength(@TrailerOwner)) +
@Trailerid +					-- Trailer Number
	REPLICATE(' ',13-datalength(@Trailerid)) +
@StatusReason +					-- StatusReason
 	REPLICATE(' ',3-datalength(@StatusReason)) +
 	REPLICATE('0',3-datalength(@StopNumber)) +
@StopNumber +					-- StopNumber
	REPLICATE('0',6-datalength(@Weight)) +
@Weight +					-- StopWeight
	REPLICATE('0',6-datalength(@Quantity)) +
@Quantity +					-- StopQuantity
@StopReferenceNumber +				-- StopReferenceNumber
	REPLICATE(' ',15-datalength(@StopReferenceNumber)) +
@stopevent + REPLICATE(' ',6-datalength(@stopevent)) +
@stopreasonlate + REPLICATE(' ',6-datalength(@stopreasonlate)) +
@activity + REPLICATE(' ',6-datalength(@activity)),
trp_id = @TRPNbr, doc_id = @docid

FROM city WHERE cty_code=@statuscity


-- create #2 record for this stop

exec edi_214_record_id_2_34_sp @stopcmpid,@n101code,@TRPNbr,@billtocmpid,@docid
-- create any needed ref numbers
exec edi_214_record_id_4_34_sp @ordhdrnumber,'stops',@stp_number,@TRPNbr,@docid

-- Add any freight level ref numbers

	SELECT @nextfgtnumber = MIN(fgt_number)
        FROM freightdetail
        WHERE freightdetail.stp_number = @stp_number
	
	While @nextfgtnumber is NOT NULL
          BEGIN
             exec edi_214_record_id_4_34_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid  
             SELECT @nextfgtnumber = MIN(fgt_number)
             FROM freightdetail
             WHERE freightdetail.stp_number = @stp_number
             AND fgt_number >  @nextfgtnumber
          END





GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_3_34_sp] TO [public]
GO
