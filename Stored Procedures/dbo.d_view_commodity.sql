SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_view_commodity    Script Date: 6/1/99 11:54:29 AM ******/
Create Procedure [dbo].[d_view_commodity] (@stringparm varchar(13),
                                   @numberparm int, @retrieveby char(3))
As
Begin
   If (@retrieveby = "TRL")
   Begin
	SELECT	DISTINCT
		event.ord_hdrnumber,
		event.evt_enddate,
		commodity.cmd_code,
		commodity.cmd_name,
		freightdetail.fgt_weight,
		freightdetail.fgt_weightunit,
		freightdetail.fgt_count,
		freightdetail.fgt_countunit,
		freightdetail.fgt_volume,
		freightdetail.fgt_volumeunit,
		freightdetail.fgt_quantity,
		freightdetail.fgt_unit
	FROM	event,freightdetail,commodity
	WHERE	( event.stp_number = freightdetail.stp_number ) AND  
		( freightdetail.cmd_code = commodity.cmd_code ) AND
		( event.evt_trailer1 = @stringparm ) AND
		( @stringparm <> 'UNKNOWN' ) AND 
		( event.evt_eventcode = 'LUL' ) AND
		( event.evt_enddate > DATEADD(day, -90, event.evt_enddate ))
   End
   Else
   Begin
	SELECT	event.ord_hdrnumber,
		event.evt_enddate,
		commodity.cmd_code,
		commodity.cmd_name,
		freightdetail.fgt_weight,
		freightdetail.fgt_weightunit,
		freightdetail.fgt_count,
		freightdetail.fgt_countunit,
		freightdetail.fgt_volume,
		freightdetail.fgt_volumeunit,
		freightdetail.fgt_quantity,
		freightdetail.fgt_unit
	FROM	event,freightdetail,commodity  
	WHERE	( event.stp_number = freightdetail.stp_number ) and  
		( freightdetail.cmd_code = commodity.cmd_code ) and  
		( event.evt_eventcode = 'LUL' ) and
		( event.ord_hdrnumber = @numberparm )
   End
End

Return


GO
GRANT EXECUTE ON  [dbo].[d_view_commodity] TO [public]
GO
