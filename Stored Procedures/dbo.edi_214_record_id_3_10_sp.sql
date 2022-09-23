SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*

   MODIFICATION LOG

pts 11689 state field on database changed to char 6, must truncate for flat file
*/
CREATE PROCEDURE [dbo].[edi_214_record_id_3_10_sp] 
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
@ordhdrnumber integer
 as

declare @yyyy varchar(4), @datetimeformat varchar(12)
declare @mm varchar(2), @dd varchar(2), @hh varchar(2), @mi varchar(2)
declare @TRPNbr varchar(20), @billtocmpid varchar(8)
declare @weight varchar(6), @quantity varchar(6)


-- condition status date
select @yyyy=convert( varchar(4),datepart(yy,@StatusDateTime))
select @mm=convert( varchar(2),datepart(mm,@StatusDateTime))
select @dd=convert( varchar(2),datepart(dd,@StatusDateTime))
select @hh=convert( varchar(2),datepart(hh,@StatusDateTime))
select @mi=convert( varchar(2),datepart(mi,@StatusDateTime))
select @datetimeformat=

replicate('0',4-datalength(@yyyy)) + @yyyy +
replicate('0',2-datalength(@mm)) + @mm +
replicate('0',2-datalength(@dd)) + @dd +
replicate('0',2-datalength(@hh)) + @hh +
replicate('0',2-datalength(@mi)) + @mi

-- Condition parameters
select @StatusCode=isnull( @StatusCode ,' ')
select @TimeZone=isnull( @TimeZone ,'LT')
select @TractorID=isnull( @TractorID ,' ')
select @MCUnitnUMBER=ISNULL( @MCUnitNumber ,0)
select @TrailerOwner=isnull( @TrailerOwner ,' ')
select @Trailerid=isnull( @Trailerid ,' ')
select @StatusReason=isnull( @StatusReason ,' ')
select @StopNumber=isnull( @StopNumber ,' ')
select @Weight=CONVERT(varchar(6),isnull( @StopWeight ,0))
select @Quantity=CONVERT(varchar(6),isnull( @StopQuantity ,0))
select @StopReferenceNumber=isnull( @StopReferenceNumber ,' ')

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

-- then insert results into edi_214
INSERT edi_214 (data_col, trp_id) 
SELECT 
data_col = '3' +				-- Record ID
'10' +						-- Record Version
@StatusCode +					-- StatusCode
	replicate(' ',2-datalength(@StatusCode)) +
@datetimeformat +				-- status date and time
@timezone +					-- timezone
	replicate(' ',2-datalength(@timezone)) +
SUBSTRING(cty_name,1,18) +					-- city
	replicate(' ',18-datalength(SUBSTRING(cty_name,1,18))) +
SUBSTRING(cty_state,1,2) +					-- state
	replicate(' ',2-datalength(SUBSTRING(cty_state,1,2))) +
@tractorid +					-- Tractor
	replicate(' ',13-datalength(@tractorid)) +
convert(varchar(12),@MCUnitNumber) +					-- MCUnitNumber
	replicate(' ',12-datalength(convert(varchar(12),@MCUnitNumber))) +
@TrailerOwner +					-- TrailerOwner
	replicate(' ',4-datalength(@TrailerOwner)) +
@Trailerid +					-- Trailer Number
	replicate(' ',13-datalength(@Trailerid)) +
@StatusReason +					-- StatusReason
 	replicate(' ',3-datalength(@StatusReason)) +
 	replicate('0',3-datalength(@StopNumber)) +
@StopNumber +					-- StopNumber
	replicate('0',6-datalength(@Weight)) +
@Weight +					-- StopWeight
	replicate('0',6-datalength(@Quantity)) +
@Quantity +					-- StopQuantity
@StopReferenceNumber +				-- StopReferenceNumber
 	replicate(' ',15-datalength(@StopReferenceNumber)),
trp_id = @TRPNbr

FROM city where cty_code=@statuscity





GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_3_10_sp] TO [public]
GO
