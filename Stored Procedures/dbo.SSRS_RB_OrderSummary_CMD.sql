SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [SSRS_RB_OrderSummary_CMD]10149
--exec [SSRS_RB_OrderSummary_CMD]10012,4646


create  Procedure [dbo].[SSRS_RB_OrderSummary_CMD]
		
		(@ord_hdrnumber int,
		@stp_number int)
	 
AS

SELECT	
stops.stp_number,
--commodity.cmd_code,
----dbo.fcn_Commodities_CRLF(orderheader.ord_hdrnumber,stops.stp_number) as 'cmd_name',
freightdetail.fgt_description,
freightdetail.fgt_reftype,
freightdetail.fgt_refnum,
freightdetail.fgt_quantity,
freightdetail.fgt_unit,
freightdetail.fgt_sequence,
freightdetail.fgt_weight, 
freightdetail.fgt_weightunit,
freightdetail.fgt_count,
freightdetail.fgt_countunit,
freightdetail.fgt_volume,
freightdetail.fgt_volumeunit

FROM stops  with (nolock)	
join freightdetail with (nolock) on stops.stp_number = freightdetail.stp_number

WHERE ord_hdrnumber = @ord_hdrnumber and stops.stp_number = @Stp_number 
ORDER BY	stops.stp_sequence


GO
