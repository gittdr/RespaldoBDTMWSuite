SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[umpp_candk_create_nbstop_214] @mov INT,@ord_hdrnumber INT
/**
 * 
 * NAME:
 * dbo.umpp_candk_create_nbstop_214
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Custom stored procedure for postprocessing of EDI inbound load tenders
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * NONE
 *
 * PARAMETERS:
 * @ord_number::varchar(12)::input - TMW order number
 * @trp_id::varchar(20)::input - Optional input parm with trading partner id from 204
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 *	01.01.2012.01 - A. Rossman(TMW) - Initial version
 */


AS

DECLARE @docid VARCHAR(30),@getdate datetime
DECLARE @loop_counter int,@stops_counter int
DECLARE @currStop INT,@currEvent VARCHAR(6),@billto VARCHAR(8),@trpID VARCHAR(20),@stp_comp VARCHAR(8),@stp_status VARCHAR(8),@stp_depstatus VARCHAR(8)
DECLARE @arvStatus VARCHAR(3),@depStatus VARCHAR(3)
DECLARE @tempStops AS TABLE (  rec_id INT IDENTITY(1,1) NOT NULL
			     ,stp_number INT NOT NULL
			     ,stp_company VARCHAR(8) NULL
			     ,stp_event VARCHAR(6) NULL
			     ,stp_status VARCHAR(6) NULL
			     ,nts_arv_status VARCHAR(6)  NULL
			     ,stp_arrivaldate DATETIME NULL
			     ,stp_departure_status VARCHAR(6)NULL
			     ,nts_dep_status VARCHAR(6)
			     ,stp_departuredate DATETIME NULL
			     ,billto	VARCHAR(8)
			   )  


SELECT @getdate = GETDATE()


--insert records into Temp table for processing
INSERT INTO @tempStops
select s1.stp_number,cmp_id,stp_event,stp_status,nts_arv_status,stp_arrivaldate
		,stp_departure_status,nts_dep_status,stp_departuredate,e1.ord_billto
FROM stops s1 with(NOLOCK)
	INNER JOIN edi_nonbillable_tender_stops e1
		ON s1.stp_number = e1.stp_number
		AND (s1.stp_status <> e1.nts_arv_status
			OR s1.stp_departure_status <> e1.nts_dep_status)
WHERE s1.mov_number = @mov	


SET @loop_counter = ISNULL((SELECT COUNT(*) FROM @tempStops),0)
SET @stops_counter = 1	

WHILE @loop_counter > 0 AND @stops_counter <= @loop_counter
BEGIN
	--get current stop info
	SELECT @currStop = stp_number
		,@currEvent = stp_event
		,@stp_status=stp_status
		,@stp_depstatus=stp_departure_status
		,@billto = billto
		,@stp_comp = stp_company
	FROM @tempStops
	WHERE rec_id =  @stops_counter

	
	 exec CROW_EDI_auto214_nonbill_preprocess @ord_hdrnumber , @currStop 
		
--process  arrival status
IF (SELECT COUNT(*) FROM @tempStops WHERE  rec_id = @stops_counter AND stp_status = 'DNE' AND nts_arv_status = 'OPN'  ) = 1
--process arrival status for stop
BEGIN
	--set docid
	  SELECT @docid =   
	  replicate('0',2-datalength(convert(varchar(2),datepart(month,@getdate))))  
	   + convert(varchar(2),datepart(month,@getdate))  
	  + replicate('0',2-datalength(convert(varchar(2),datepart(day,@getdate))))  
	   + convert(varchar(2),datepart(day,@getdate))  
	  +replicate('0',2-datalength(convert(varchar(2),datepart(hour,@getdate))))  
	   + convert(varchar(2),datepart(hour,@getdate))  
	  +replicate('0',2-datalength(convert(varchar(2),datepart(minute,@getdate))))  
	   + convert(varchar(2),datepart(minute,@getdate))  
	  +replicate('0',2-datalength(convert(varchar(2),datepart(second,@getdate))))  
	   + convert(varchar(2),datepart(second,@getdate))  
	   +replicate('0',3-datalength(convert(varchar(3),datepart(millisecond,@getdate))))  
	   + convert(varchar(3),datepart(millisecond,@getdate))  
	  + REPLICATE('0',10-DATALENGTH(RIGHT(CONVERT(varchar(20),@ord_hdrnumber),10)))  
  	  + RIGHT(CONVERT(varchar(20),@ord_hdrnumber),10)
	
	--get TPID
	select @trpID = trp_id from edi_trading_partner where cmp_id = @billto
	--get AT7 code
	select @arvStatus =  ISNULL(nse_arv_code,'')
	 from edi_nonbillable_status_events 
	where cmp_id= 'CROWLEY' 
		and evt_code = @currEvent	--should this be company or billto
	
	IF @arvStatus > ''
	BEGIN--begin 214 creation
		 EXEC edi_214_record_id_1_39_sp @ord_hdrnumber,'N',@docid,@billto
			--add status record
			INSERT edi_214 (data_col,trp_id,doc_id)
			SELECT 
			data_col = '339' +	-- Record ID/version
			UPPER(@arvStatus) +					-- StatusCode
			CONVERT(varchar(8),stp_arrivaldate,112)+	
			SUBSTRING(CONVERT(varchar(8),stp_arrivaldate,8),1,2) +
			SUBSTRING(CONVERT(varchar(8),stp_arrivaldate,8),4,2) +			-- status date AND time
			'CT' +					-- timezone
			SUBSTRING(cty_name,1,18) +	REPLICATE(' ',18-datalength(SUBSTRING(cty_name,1,18))) +		-- city
			SUBSTRING(cty_state,1,2) +	REPLICATE(' ',2-datalength(SUBSTRING(cty_state,1,2))) +			-- state
			REPLICATE(' ',29) +		--Tractor,MCUnit#,TrailerOwner	
			e.evt_trailer1 +REPLICATE(' ',13-datalength(e.evt_trailer1)) +	-- Trailer Number
			stp_reasonlate + REPLICATE(' ',3-datalength(stp_reasonlate)) +	-- StatusReason
			REPLICATE('0',3-datalength(convert(varchar(3),stp_mfh_sequence))) + convert(varchar(3),stp_mfh_sequence) +
			'000000'+ '000000' +	-- StopWeight, StopQuantity
			isnull(stp_refnum,'') +	REPLICATE(' ',15-datalength(isnull(stp_refnum,''))) +		-- StopReferenceNumber
			'000' +		--alt stop number
			replicate('0',9-datalength(convert(varchar(9),right(cty_latitude,9))))+ right(cty_latitude,9)+'N'+
			replicate('0',9-datalength(convert(varchar(9),right(cty_longitude,9))))+right(cty_longitude,9)+'W'+
			stp_event + REPLICATE(' ',6-datalength(stp_event)) +
			stp_reasonlate + REPLICATE(' ',6-datalength(stp_reasonlate)) +
			'ARV   ' +		--activity
			e.evt_trailer2 + REPLICATE(' ',13-datalength(e.evt_trailer2))+		--PTS 40837		
			'X' + '000000',		--team/single,count2	
			trp_id = @trpID, doc_id = @docid
			FROM stops s WITH(NOLOCK)
			 inner join city c ON cty_code=stp_city
			 inner join event e on e.stp_number = s.stp_number
		 WHERE s.stp_number = @currStop
		 --add stop/location record
		 exec edi_214_record_id_2_39_sp @stp_comp,'XX',@trpID,@billto,@docid
			exec edi_214_record_id_4_39_sp @ord_hdrnumber,'stops',@currStop,@trpID,@docid,@billto

		 --complete 214 record
		 exec edi_214_record_id_end_sp @trpID,@docid
		 
		 --update pending table 
		
	END
	 update edi_nonbillable_tender_stops
			set nts_arv_status =@stp_status
		 where 	stp_number = @currStop
END





--process departure status
IF ( SELECT COUNT(*) FROM @tempStops WHERE rec_id = @stops_counter AND stp_departure_status = 'DNE' and nts_dep_status = 'OPN') = 1
--process departure status for stop
BEGIN
	--set docid
	  SELECT @docid =   
	  replicate('0',2-datalength(convert(varchar(2),datepart(month,@getdate))))  
	   + convert(varchar(2),datepart(month,@getdate))  
	  + replicate('0',2-datalength(convert(varchar(2),datepart(day,@getdate))))  
	   + convert(varchar(2),datepart(day,@getdate))  
	  +replicate('0',2-datalength(convert(varchar(2),datepart(hour,@getdate))))  
	   + convert(varchar(2),datepart(hour,@getdate))  
	  +replicate('0',2-datalength(convert(varchar(2),datepart(minute,@getdate))))  
	   + convert(varchar(2),datepart(minute,@getdate))  
	  +replicate('0',2-datalength(convert(varchar(2),datepart(second,@getdate))))  
	   + convert(varchar(2),datepart(second,@getdate))  
	   +replicate('0',3-datalength(convert(varchar(3),datepart(millisecond,@getdate))))  
	   + convert(varchar(3),datepart(millisecond,@getdate))  
	  + REPLICATE('0',10-DATALENGTH(RIGHT(CONVERT(varchar(20),@ord_hdrnumber),10)))  
  + RIGHT(CONVERT(varchar(20),@ord_hdrnumber),10)

	--get TPID
	select @trpID = trp_id from edi_trading_partner where cmp_id = @billto
	--get AT7 code
	select @depStatus =  isnull(nse_dep_code,'')
	 from edi_nonbillable_status_events 
	where cmp_id= 'CROWLEY' 
		and evt_code = @currEvent 
	
	IF @depStatus > ''
		BEGIN --process 214
		--create 214 for departure
			 EXEC edi_214_record_id_1_39_sp @ord_hdrnumber,'N',@docid,@billto
			--add status record
			INSERT edi_214 (data_col,trp_id,doc_id)
			SELECT 
			data_col = '339' +	-- Record ID/version
			UPPER(@depStatus) +					-- StatusCode
			CONVERT(varchar(8),stp_departuredate,112)+	
			SUBSTRING(CONVERT(varchar(8),stp_departuredate,8),1,2) +
			SUBSTRING(CONVERT(varchar(8),stp_departuredate,8),4,2) +			-- status date AND time
			'CT' +					-- timezone
			SUBSTRING(cty_name,1,18) +	REPLICATE(' ',18-datalength(SUBSTRING(cty_name,1,18))) +		-- city
			SUBSTRING(cty_state,1,2) +	REPLICATE(' ',2-datalength(SUBSTRING(cty_state,1,2))) +			-- state
			REPLICATE(' ',29) +		--Tractor,MCUnit#,TrailerOwner	
			e.evt_trailer1 +REPLICATE(' ',13-datalength(e.evt_trailer1)) +	-- Trailer Number
			stp_reasonlate_depart + REPLICATE(' ',3-datalength(stp_reasonlate_depart)) +	-- StatusReason
			REPLICATE('0',3-datalength(convert(varchar(3),stp_mfh_sequence))) + convert(varchar(3),stp_mfh_sequence) +
			'000000'+ '000000' +	-- StopWeight, StopQuantity
			isnull(stp_refnum,'') +	REPLICATE(' ',15-datalength(isnull(stp_refnum,''))) +		-- StopReferenceNumber
			'000' +		--alt stop number
			replicate('0',9-datalength(convert(varchar(9),right(cty_latitude,9))))+ right(cty_latitude,9)+'N'+
			replicate('0',9-datalength(convert(varchar(9),right(cty_longitude,9))))+right(cty_longitude,9)+'W'+
			stp_event + REPLICATE(' ',6-datalength(stp_event)) +
			stp_reasonlate_depart + REPLICATE(' ',6-datalength(stp_reasonlate_depart)) +
			'DEP   ' +		--activity
			e.evt_trailer2 + REPLICATE(' ',13-datalength(e.evt_trailer2))+		--PTS 40837		
			'X' + '000000',		--team/single,count2	
			trp_id = @trpID, doc_id = @docid
			FROM stops s WITH(NOLOCK)
			 inner join city c ON cty_code=stp_city
			 inner join event e on e.stp_number = s.stp_number
		 WHERE s.stp_number = @currStop
		 --add stop/location record
		 exec edi_214_record_id_2_39_sp @stp_comp,'XX',@trpID,@billto,@docid
			exec edi_214_record_id_4_39_sp @ord_hdrnumber,'stops',@currStop,@trpID,@docid,@billto

		 --complete 214 record
		 exec edi_214_record_id_end_sp @trpID,@docid
		 
		 --update pending non-billable stops table
			
		END
		 update edi_nonbillable_tender_stops
			set nts_dep_status = @stp_depstatus
		 where 	stp_number = @currStop
END
	SET @stops_counter = @stops_counter + 1
END







GO
GRANT EXECUTE ON  [dbo].[umpp_candk_create_nbstop_214] TO [public]
GO
