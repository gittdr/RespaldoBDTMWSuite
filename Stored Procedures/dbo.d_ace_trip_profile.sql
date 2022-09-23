SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_ace_trip_profile] @ord_number char(12),@p_mov_number int
as

/**
 * 
 * NAME:
 * dbo.d_ace_trip_profile
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure retrieves s data for the order number specified in the ACE EDI window
 * 
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
 * 002 - @p_mov_number int input not null;
 *	  Move number for which dhata is being retrieved.
 *
 * REFERENCES: (called by and calling references only, don't 
 * NONE
 * 
 * REVISION HISTORY:
 * 03/21/2006.01 ? PTS31886 - A. Rossman ? Initial release
 * 04/23/2006.02 - PTS32601 - A. Rossman - Added retrieve by move number option.
 * 02/07/2007.03 - PTS		- A.Rossman - Enhancements for retrieval by move number to allow for cross-docked loads.
 * 06/29/2007.04 - PTS 38048 - A.Rossman - Performance enhancements for SQL2k5
 * 02/25/2008.05 - PTS41340 - A.Rossman - Added ord_number to result set.
 **/


  
CREATE TABLE #Etemp (  
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
         stp_count int NULL,    --PTS 28580  
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
 stp_type varchar(6)null,       --PTS 29703  
 stp_event varchar(6)null,  
 mov_number int null,
 ord_number varchar(12) null)	--PTS 41340  
 
 
 CREATE TABLE #moves (
 							mov_number int)
 						     
--if there was an order number passed in and a move number of 0, get the move associated with the order.  
IF @p_mov_number =  0
	SELECT @p_mov_number = mov_number FROM orderheader where ord_number = @ord_number

--insert into the moves temp table.  All move numbers associated with this trip.
INSERT #moves 
SELECT stops.mov_number FROM stops INNER join stops stops2 ON stops.ord_hdrnumber = stops2.ord_hdrnumber
WHERE stops2.mov_number = @p_mov_number AND stops2.ord_hdrnumber > 0
GROUP BY stops.mov_number

  
  --If there are multiple movements associated with this trip use this insert
IF (SELECT COUNT(*) FROM #moves) > 1
INSERT INTO #Etemp  
 SELECT   
  stops.ord_hdrnumber,     
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
   stops.mov_number ,
   0
    FROM stops inner join legheader on stops.lgh_number = legheader.lgh_number  
inner join city on stops.stp_city = city.cty_code  
inner join [event] on stops.stp_number =  [event].stp_number  
inner join #moves on #moves.mov_number =  stops.mov_number
--WHERE    
--stops.mov_number = @mov_number  
--OR stops.ord_hdrnumber in (Select DISTINCT(stops.ord_hdrnumber) FROM stops WHERE mov_number = @mov_number and ord_hdrnumber > 0)  
     ORDER BY IsNull ((Select Case (s.stp_event)   
  When 'LLD' Then stops.mfh_number * -1  
  Else stops.mfh_number  
  End  
    from stops s  
    where s.stp_number = stops.stp_transfer_stp), stops.mfh_number) , stops.mov_number, stops.stp_mfh_sequence  
  
  
ELSE  
  
If @p_mov_number > 0  
 INSERT INTO #Etemp  
 SELECT   
  stops.ord_hdrnumber,     
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
   stops.mov_number ,
 0
    FROM stops inner join legheader on stops.lgh_number = legheader.lgh_number  
inner join city on stops.stp_city = city.cty_code  
inner join [event] on stops.stp_number =  [event].stp_number  
WHERE    
stops.mov_number = @p_mov_number  
     ORDER BY IsNull ((Select Case (s.stp_event)   
  When 'LLD' Then stops.mfh_number * -1  
  Else stops.mfh_number  
  End  
    from stops s  
    where s.stp_number = stops.stp_transfer_stp), stops.mfh_number) , stops.mov_number, stops.stp_mfh_sequence  
  
---------------------  
UPDATE #ETemp
SET	#ETemp.ord_number = orderheader.ord_number
FROM	orderheader
WHERE	#ETemp.ord_hdrnumber = orderheader.ord_hdrnumber
		AND #ETemp.ord_hdrnumber > 0
  
   SELECT    
    ord_hdrnumber,  
        stp_number,  
        cmp_id,  
         stp_city,  
         stp_state,  
         stp_schdtearliest,  
         stp_origschdt,  
         stp_arrivaldate,  
         stp_departuredate,  
         stp_reasonlate,  
         stp_schdtlatest,  
         stp_mfh_sequence,  
         stp_sequence,  
         stp_weight,  
         stp_weightunit,  
         cmd_code,  
         stp_count,  
         stp_countunit,  
         cmp_name,  
         stp_status,  
         stp_reftype,  
         stp_refnum,  
         stp_reasonlate_depart,  
         stp_volume,  
         stp_volumeunit,  
         evt_tractor,  
         evt_trailer1,  
 cty_nmstct,  
 stp_type,  
 stp_event,  
 mov_number ,
 ord_number		--41340
FROM #Etemp  


GO
GRANT EXECUTE ON  [dbo].[d_ace_trip_profile] TO [public]
GO
