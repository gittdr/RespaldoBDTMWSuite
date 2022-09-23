SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetIPTDetails_sp] 	
@OrderNumber Integer, 
@mode char(1)  -- 'd' means return IPT#s, freight details.
               -- not 'd' means return trlr#, from plant, to plant, date 
-- Given an order number return the freight info for the first (hook preload) stop
-- and associated IPT numbers (IPT is a freight ref num of type IPT)
-- Example:
-- estatGetIPTDetails_sp 601, 'd' -- for IPT details
-- estatGetIPTDetails_sp 601, '' -- for trlr, shipper, consignee, date
AS
SET NOCOUNT ON

Create table #Output(
	StpNumber       integer NULL, -- need for ref nums
	refnum		varchar(30) NULL, 
	reftype		varchar(30) NULL, 
        fgtnumber       int null, 
	stpseq          smallint NULL,   
        cmd_code        varchar(8) NULL,  
        [description] varchar(60) NULL, 
        weight      decimal(9)  NULL, 
        weightunit  varchar(6) NULL,
        volume 	decimal(9)  NULL,  
        volumeunit  varchar(6) NULL,
        [count]	decimal(9)  NULL, 
        countunit   varchar(6) NULL,
        fgtseq    smallint 
	)
if @mode = 'd'
begin
	/**** STOP DETAIL ****/
	create table #StopDetail (
		StpSeq		int	NULL,	--(stp_sequence)
		stpnumber       int     NULL,
	        RefNumber	varchar(30) NULL, 
		RefType         varchar(30) NULL,          
	        fgt_number      int     NULL,
	        cmd_code        varchar(8) NULL, 
	        fgt_description varchar(60) NULL, 
	        fgt_weight      decimal(9)  NULL, 
	        fgt_weightunit  varchar(6) NULL,
	        fgt_volume 	decimal(9)  NULL,  
	        fgt_volumeunit  varchar(6) NULL,
	        fgt_count	decimal(9)  NULL, 
	        fgt_countunit   varchar(6) NULL,
	        fgt_sequence    smallint
	) 
	-- now create the rows for the freight items
	insert into #StopDetail
	select	
		stops.stp_sequence AS StpSeq,
		stops.stp_number,
		'',   			-- refnum 
		'',			-- reftype
	        freightdetail.fgt_number,
		freightdetail.cmd_code, 
		fgt_description, 
		fgt_weight, fgt_weightunit, 
		fgt_volume, fgt_volumeunit,
		fgt_count, fgt_countunit,
		fgt_sequence
	        from stops, freightdetail
		where stops.stp_number = freightdetail.stp_number
		and stops.ord_hdrnumber = @ordernumber
		and stops.stp_event = 'HPL'
	-- get the freight IPT numbers (ie freight ref number)
	update #StopDetail 
		set refnumber = ref_number, reftype = ref_type 
	        from referencenumber, freightdetail 
		where ref_type = 'IPT'
		and ref_table = 'freightdetail'
		-- and freightdetail.stp_number = #stopDetail.stpnumber
		and freightdetail.fgt_number = #stopDetail.fgt_number
		and ord_hdrnumber = @ordernumber
		and freightdetail.fgt_number = referencenumber.ref_tablekey
	
	INSERT INTO #Output
	SELECT 		
	        #StopDetail.StpNumber,
		#StopDetail.RefNumber, 
		#StopDetail.RefType,   
		#StopDetail.fgt_number, 
	        #StopDetail.stpseq,
	  	cmd_code, 
		fgt_description, 
		fgt_weight, fgt_weightunit, 
		fgt_volume, fgt_volumeunit,
		fgt_count, fgt_countunit,
		fgt_sequence 
	
	FROM 	#StopDetail    
	SELECT 
		refnum IPT#, 
		-- cmd_code, 
		[DESCRIPTION], 
		WEIGHT, weightunit 'WT<br>UNIT',  
		VOLUME, volumeunit 'VOL<br>UNIT',   
		[COUNT], countunit UNIT  
		FROM #OUTPUT order by  #Output.fgtseq 
	
	drop table #StopDetail
	drop table #Output
end 
else
begin 
	declare @trailer varchar(13)
        declare @timestamp datetime
	--declare @fromplantid varchar(8)
	declare @fromplant varchar(100)
	declare @toplant varchar(100)
	declare @toplantid varchar(8)
	select @trailer = ord_trailer from orderheader where ord_hdrnumber = @ordernumber
	select @timestamp = ord_bookdate from orderheader where ord_hdrnumber = @ordernumber
	
	--select @fromplantid = cmp_id from stops where ord_hdrnumber =  @ordernumber and stp_event = 'HPL'
	select @fromplant = company.cmp_name from stops, company where 
               company.cmp_id = stops.cmp_id
               and  ord_hdrnumber =  @ordernumber and stp_event = 'HPL'
	select @toplant = company.cmp_name from stops, company where 
               company.cmp_id = stops.cmp_id
               and  ord_hdrnumber =  @ordernumber and stp_event = 'DRL'

	select isnull(@trailer,'') Trailer#, isnull(@fromplant,'') FromPlant, isnull(@toplant,'') ToPlant, isnull(@timestamp,'') [time] 
end
GO
GRANT EXECUTE ON  [dbo].[estatGetIPTDetails_sp] TO [public]
GO
