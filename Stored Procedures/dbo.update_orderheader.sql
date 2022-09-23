SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_orderheader    Script Date: 6/1/99 11:54:06 AM ******/
Create procedure [dbo].[update_orderheader] (@ordnum int) as
Declare		@wt			float,
		@wt_unit_fr		varchar(6),		
		@wt_unit_to		varchar(6),		
		@tot_wt			float,
		@vol			float,
		@vol_unit_fr		varchar(6),
		@vol_unit_to		varchar(6),
		@tot_vol		float,
		@count			int,
		@count_unit_fr		varchar(6),
		@count_unit_to		varchar(6),
		@tot_count		int,
		@row_ptr		int
		
/*
 select 	@wt_unit_to 	=	ord_totalweightunits,
	@vol_unit_to	=	ord_totalvolumeunits,
	@count_unit_to	=	ord_totalcountunits
from	orderheader
where	ord_hdrnumber = @ordnum

Create table #temp ( 	 row_id int not null  identity,
			 fgt_weight float null,   
		         fgt_weightunit varchar(6) null,   
		         fgt_count int null,   
		         fgt_countunit varchar(6) null,   
		         fgt_volume float null,   
		         fgt_volumeunit varchar(6) null  
		     )
INSERT INTO #temp ( 	 fgt_weight,   
		         fgt_weightunit,   
		         fgt_count,   
		         fgt_countunit,   
		         fgt_volume,   
		         fgt_volumeunit  
		   ) 
			(  SELECT freightdetail.fgt_weight,   
			         freightdetail.fgt_weightunit,   
			         freightdetail.fgt_count,   
			         freightdetail.fgt_countunit,   
			         freightdetail.fgt_volume,   
			         freightdetail.fgt_volumeunit  
			    FROM freightdetail,stops
			   WHERE stops.ord_hdrnumber = @ordnum and
				 stops.stp_number    = freightdetail.stp_number	and
				 stops.stp_type	     = 'DRP'	   
			)	   
	

Select @row_ptr = 0
Select @tot_wt =0,@tot_vol = 0 , @tot_count = 0

While  ( select count(row_id) from #temp where row_id > @row_ptr ) > 0 
begin
	select @row_ptr = min(row_id) from #temp where row_id > @row_ptr

	select 	@wt 		= 	fgt_weight,
	       	@wt_unit_fr	= 	fgt_weightunit,
	       	@count		=       fgt_count,   
       		@count_unit_fr	=	fgt_countunit,   
	 	@vol		=      	fgt_volume,   
		@vol_unit_fr 	=   	fgt_volumeunit  
	from  	#temp
	where	#temp.row_id 	= 	@row_ptr
        
	exec @conv_factor_wt 	= get_unit_conv_factor_sp(@wt_unit_fr,@wt_unit_to,'Q')
	exec @conv_factor_vol 	= get_unit_conv_factor_sp(@vol_unit_fr,@vol_unit_to,'Q')
	exec @conv_factor_count = get_unit_conv_factor_sp(@count_unit_fr,@count_unit_to,'Q')
	
	select @wt 	= @wt 	* @conv_factor_wt	
	select @vol 	= @vol 	* @conv_factor_vol	
	select @count 	= @wt 	* @conv_factor_count
	
	update #temp set @fgt_weight = @wt,
			 @fgt_volume = @vol,
			 @fgt_count  = @count
		where    row_id = @row_ptr

end
*/


return
	
	






GO
GRANT EXECUTE ON  [dbo].[update_orderheader] TO [public]
GO
