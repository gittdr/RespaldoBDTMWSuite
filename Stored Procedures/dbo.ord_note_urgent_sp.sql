SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ord_note_urgent_sp] 
(	@Regarding varchar(8),
@order int,
@Invoice			varchar(12),
@NOTE char(1) OUTPUT
)
AS

--PTS 53511
--Designed to check all note sources from an order to determine if there are NOTES for the passed in regarding code 
--This stored proc will return 'A' for an ALERT, 'N' for a note and 'Z' for no notes or alerts.


DECLARE 
@key						char(18), 
@table					char(18) , 
@movement	int,
@Billto					varchar(8),
@Shipper			varchar(8),
@Consignee	varchar(8),
@CmdCode   varchar(8),
@Commodity varchar(8),
@Tractor      varchar(8), 
@Trailer1			varchar(13),
@Trailer2			varchar(13),
@Driver1				varchar(8),
@Driver2				varchar(8),
@Carrier				varchar(8)



Select 
@movement	= isnull(mov_number,0),
@Billto					= isnull(ord_Billto,'UNKNOWN'),
@Shipper			= isnull(ord_shipper,'UNKNOWN'),
@Consignee	= isnull(ord_consignee,'UNKNOWN'),
@Tractor      = isnull(ord_tractor,'UNKNOWN'),
@Trailer1				= isnull(ord_trailer,'UNKNOWN'),
@Trailer2			= isnull(ord_trailer2,'UNKNOWN'),
@Driver1				= isnull(ord_driver1,'UNKNOWN'),
@Driver2				= isnull(ord_driver2,'UNKNOWN'),
@Carrier				= isnull(ord_carrier,'UNKNOWN'),
@CmdCode   = isnull(cmd_code,'UNKNOWN')
From orderheader where ord_hdrnumber = @Order



-- SET DEFAULTS
Select  @Note = 'Z'

--INVOICE

	If @Note <> 'A' and isnull(@Invoice, '') <> ''
	BEGIN 
		select @table = 'invoiceheader'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Invoice
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, 'ALL FREIGHT'	
	END

-- ORDER
	
	If @Note <> 'A'
	BEGIN 
		select @key = CAST(@order as char(18)), @table = 'orderheader'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @order 
	END
	
	
-- MOVEMENT
	If @Note <> 'A'
	BEGIN 
		select @key = CAST(@Movement as char(18)), @table = 'movement'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @movement
	END

-- BILLTO
	
	If @Note <> 'A' and @Billto <> 'UNKNOWN'
	BEGIN 
		select @key = @Billto, @table = 'company'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Billto	
	END
	
	-- SHIPPER
	
	If @Note <> 'A' and @Shipper <> 'UNKNOWN'
	BEGIN 
		select @key = @Shipper, @table = 'company'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Shipper	
	END
	
-- CONSIGNEE
	
	If @Note <> 'A' and @Consignee <> 'UNKNOWN'
	BEGIN 
		select @key = @Consignee, @table = 'company'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Consignee	
	END
	
-- TRACTOR
	
	If @Note <> 'A' and @Tractor <> 'UNKNOWN'
	BEGIN 
		select @key = @Tractor, @table = 'tractorprofile'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Tractor	
	END
	
	-- TRAILER1
	
	If @Note <> 'A' and @Trailer1 <> 'UNKNOWN'
	BEGIN 
		select @key = @Trailer1, @table = 'trailerprofile'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Trailer1	
	END
	
		-- TRAILER2
	
	If @Note <> 'A' and @Trailer2 <> 'UNKNOWN'
	BEGIN 
		select @key = @Trailer1, @table = 'trailerprofile'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Trailer2	
	END
	
-- DRIVER1
	
	If @Note <> 'A' and @Driver1 <> 'UNKNOWN'
	BEGIN 
		select @key = @Trailer1, @table = 'manpowerprofile'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Driver1	
	END
	
	-- DRIVER2
	
	If @Note <> 'A' and @Driver2 <> 'UNKNOWN'
	BEGIN 
		select @key = @Trailer1, @table = 'manpowerprofile'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @Driver2	
	END
	
-- CARRIER
	
	If @Note <> 'A' and @Carrier <> 'UNKNOWN'
	BEGIN 
		select @key = @Carrier, @table = 'carrier'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @carrier	
	END
	
--COMMODITY ON ORDER
	If @Note <> 'A' and @CmdCode <> 'UNKNOWN'
	BEGIN 
		select @key = @Carrier, @table = 'commodity'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey = @Key
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, @CmdCode	
	END
	
	-- ALL COMMODITIES 
	
	
	
	If @Note <> 'A' 
	BEGIN 
		select @table = 'commodity'
		select top 1 @note =  isnull(not_urgent, 'N') from notes 
		where not_type = @Regarding
		and nre_tablekey in (select f.cmd_code 
																from freightdetail f 
																where f.stp_number in (select s.stp_number 
																															from stops s
																															where s.ord_hdrnumber = @order ))
		and  ntb_table = @table
		order by not_urgent asc
		--Select @note, 'ALL FREIGHT'	
	END
	

GO
GRANT EXECUTE ON  [dbo].[ord_note_urgent_sp] TO [public]
GO
