SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edi_stops_lookup] @ord_number char(12) 
as

/**
 * 
 * NAME:
 * dbo.edi_stops_lookup
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure retrieves stops data for the order number specified
 * in the create manual edi 214 window.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * All columns in the #Etemp table
 *
 * PARAMETERS:
 * 001 - @ordnumber, char(12), input, null;
 *       This parameter indicates the order number for which details are being retrieved 
 *
 * REFERENCES: (called by and calling references only, don't 
 * NONE
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *  9/11/2000.01 -PTS8848  -            - return the trading partner ID in the return set
 *	6/23/2005.02 -PTS28580 - A.Rossman  - Updated the data type for stp_count from smallint to int.
 *  9/06/2005.03 -PTS29703 - A.Rossman  - Allow nulls to column stp_type on temp table.
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 11.24.08.04 | PTS 44874 - Aross - 
 *
 **/





DECLARE @ordhdrnumber int, @TrpID varchar(30),
@ord_billto varchar(8)

DECLARE  @Etemp TABLE(
	ord_hdrnumber int NULL,   
        stp_number int NULL,   
        cmp_id varchar(8) NULL,   
         stp_city int NULL,   
         stp_state char(2) NULL,   
         stp_schdtearliest datetime NULL,   
         stp_origschdt datetime NULL,   
         stp_arrivaldate datetime NULL,   
         stp_departuredate datetime NULL,   
         stp_reasonlate varchar(6) NULL,   
         stp_schdtlatest datetime NULL,   
         stp_mfh_sequence int NULL,   
         stp_sequence int NULL,   
         stp_weight float(8) NULL,   
         stp_weightunit varchar(6) NULL,   
         cmd_code varchar(8) NULL,   
         stp_count int NULL,				--PTS 28580
         stp_countunit varchar(10) NULL,   
         cmp_name varchar(30) null,   
         stp_status varchar(6) null,   
         stp_reftype varchar(6) null,   
         stp_refnum varchar(30) null,   
         stp_reasonlate_depart varchar(6) null,   
         stp_volume float(8) null,   
         stp_volumeunit char(6) null,   
         evt_tractor varchar(8) null,   
         evt_trailer1 varchar(80) null,
	cty_nmstct varchar(25) null,
	stp_type varchar(6)null,					  --PTS 29703
	stp_event varchar(6),
	trp_id varchar(30) )
	

-- Get the ord_hdrnumber for the lookup ord_number
  SELECT @ordhdrnumber = ord_hdrnumber, 
  		 @ord_billto = ISNULL(ord_billto,'UNKNOWN')
 FROM	orderheader  		
  WHERE  ord_number = @ord_number
  
  --get trading partner from order bilto
  SELECT  @TrpID = ISNULL(trp_id,'NOVALUE')
  FROM edi_trading_partner
WHERE	cmp_id  = @ord_billto

--condition orderheader
 SELECT @ordhdrnumber = ISNULL(@ordhdrnumber,0)


If @ordhdrnumber > 0
  INSERT INTO @Etemp
  SELECT stops.ord_hdrnumber,   
         stops.stp_number,   
         stops.cmp_id,   
         stops.stp_city,   
         stops.stp_state,   
         stops.stp_schdtearliest,   
         stops.stp_origschdt,   
         stops.stp_arrivaldate,   
         stops.stp_departuredate,   
         stops.stp_reasonlate,   
         stops.stp_schdtlatest,   
         stops.stp_mfh_sequence,   
         stops.stp_sequence,   
         stops.stp_weight,   
         stops.stp_weightunit,   
         stops.cmd_code,   
         stops.stp_count,   
         stops.stp_countunit,   
         stops.cmp_name,   
         stops.stp_status,   
         stops.stp_reftype,   
         stops.stp_refnum,   
         stops.stp_reasonlate_depart,   
         stops.stp_volume,   
         stops.stp_volumeunit,   
         event.evt_tractor,   
         event.evt_trailer1,
	city.cty_nmstct,
	 ISNULL(stops.stp_type,'NONE'),
        stops.stp_event,
	trp_id = @TrpID
    FROM stops 
    		LEFT OUTER JOIN city ON stops.stp_city = city.cty_code  
      		INNER JOIN  event  ON stops.stp_number = event.stp_number
      			AND event.evt_sequence = 1--pts40187 jguo outer join conversion
   WHERE ( stops.ord_hdrnumber = @ordhdrnumber ) 
    	ORDER BY stp_mfh_sequence
ELSE
    INSERT INTO @Etemp
    SELECT stops.ord_hdrnumber,   
         stops.stp_number,   
         stops.cmp_id,   
         stops.stp_city,   
         stops.stp_state,   
         stops.stp_schdtearliest,   
         stops.stp_origschdt,   
         stops.stp_arrivaldate,   
         stops.stp_departuredate,   
         stops.stp_reasonlate,   
         stops.stp_schdtlatest,   
         stops.stp_mfh_sequence,   
         stops.stp_sequence,   
         stops.stp_weight,   
         stops.stp_weightunit,   
         stops.cmd_code,   
         stops.stp_count,   
         stops.stp_countunit,   
         stops.cmp_name,   
         stops.stp_status,   
         stops.stp_reftype,   
         stops.stp_refnum,   
         stops.stp_reasonlate_depart,   
         stops.stp_volume,   
         stops.stp_volumeunit,   
         event.evt_tractor,   
         event.evt_trailer1,
	city.cty_nmstct,
	 stops.stp_type,
        stops.stp_event,
	trp_id = @TrpID
    FROM stops,   
         event,
	 city
  	 WHERE 0 = 1

   SELECT * from @Etemp



GO
GRANT EXECUTE ON  [dbo].[edi_stops_lookup] TO [public]
GO
