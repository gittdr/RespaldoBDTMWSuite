SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[copy_tariffheaderstlremainder] ( @oldtarnbr int, @newtarnbr int		
)
AS
	
/* PTS 66270 StoredProc Created:  gap = the tariff copy fcn does not include the new columns */

IF  IsNull(@oldtarnbr, 0) = 0   OR ISNULL(@newtarnbr, 0) = 0 
Begin		Return		End

IF ( select count(tar_number) from tariffheaderstl where tar_number = @newtarnbr ) <> 1 
Begin		Return		End


declare @tar_time_calc varchar(6) 
declare @tar_timecalc_rounding varchar(10) 
declare @tar_timecalc_increment  decimal(19,4) 
declare @tar_timecalc_free_time  decimal(19,4) 
declare @tar_timecalc_event_list varchar(200) 

declare @tar_timecalc_events_inc_excl  char(1)
declare @tar_timecalc_compid_list varchar(200) 
declare @tar_timecalc_compid_inc_excl  char(1) 
declare @tar_timecalc_free_time_multistop  decimal(19,4) 
declare @tar_use_bill_rate  char(1) 

declare @tar_timecalc_method varchar(10) 
declare @tar_timecalc_use_first_qualevent int 
declare @tar_timecalc_first_qualevent_freetime  decimal(19,4) 
declare @tar_timecalc_use_last_qualevent int 
declare @tar_timecalc_last_qualevent_freetime  decimal(19,4) 

declare @tar_timecalc_max_freetime  decimal(19,4) 
declare @tar_timecalc_min_freetime  decimal(19,4) 
declare @tar_minqty  char(1) 
declare @tar_free_qty money 
declare @tar_timecalc_stopeligible varchar(20) 

declare @tar_round_amount  smallint 
declare @tar_zerorateisnorate  char(1) 
declare @tar_timecalc_max_qty  decimal(19,4) 
declare @tar_timecalc_max_qty_timeframe varchar(6) 
declare @tar_timecalc_max_qty_timeframe_use varchar(6) 					  
									
									
select	 @tar_timecalc_increment				= tar_timecalc_increment
		,@tar_timecalc_free_time				= tar_timecalc_free_time
		,@tar_timecalc_event_list				= tar_timecalc_event_list			
		,@tar_timecalc_events_inc_excl			= tar_timecalc_events_inc_excl           
		,@tar_timecalc_compid_list				= tar_timecalc_compid_list
		,@tar_timecalc_compid_inc_excl			= tar_timecalc_compid_inc_excl
		,@tar_timecalc_free_time_multistop		= tar_timecalc_free_time_multistop           
		,@tar_use_bill_rate						= tar_use_bill_rate
		,@tar_timecalc_method					= tar_timecalc_method			
		,@tar_timecalc_use_first_qualevent		= tar_timecalc_use_first_qualevent    
		,@tar_timecalc_first_qualevent_freetime	= tar_timecalc_first_qualevent_freetime			
		,@tar_timecalc_use_last_qualevent		= tar_timecalc_use_last_qualevent
		,@tar_timecalc_last_qualevent_freetime	= tar_timecalc_last_qualevent_freetime			
		,@tar_timecalc_min_freetime				= tar_timecalc_min_freetime
		,@tar_timecalc_max_freetime				= tar_timecalc_max_freetime
		,@tar_minqty							= tar_minqty
		,@tar_free_qty							= tar_free_qty
		,@tar_timecalc_stopeligible				= tar_timecalc_stopeligible
		,@tar_round_amount						= tar_round_amount			
		,@tar_zerorateisnorate					= tar_zerorateisnorate
		,@tar_timecalc_max_qty					= tar_timecalc_max_qty
		,@tar_timecalc_max_qty_timeframe		= tar_timecalc_max_qty_timeframe
		,@tar_timecalc_max_qty_timeframe_use	= tar_timecalc_max_qty_timeframe_use
from tariffheaderstl 
where tar_number = @oldtarnbr
									
	
Update	  tariffheaderstl 
Set		  tariffheaderstl.tar_time_calc					= 	@tar_time_calc
		, tariffheaderstl.tar_timecalc_rounding			= 	@tar_timecalc_rounding
		, tariffheaderstl.tar_timecalc_increment		= 	@tar_timecalc_increment
		, tariffheaderstl.tar_timecalc_free_time		= 	@tar_timecalc_free_time
		, tariffheaderstl.tar_timecalc_event_list		= 	@tar_timecalc_event_list
		, tariffheaderstl.tar_timecalc_events_inc_excl		= 	@tar_timecalc_events_inc_excl
		, tariffheaderstl.tar_timecalc_compid_list			= 	@tar_timecalc_compid_list
		, tariffheaderstl.tar_timecalc_compid_inc_excl		= 	@tar_timecalc_compid_inc_excl
		, tariffheaderstl.tar_timecalc_free_time_multistop	= 	@tar_timecalc_free_time_multistop
		, tariffheaderstl.tar_use_bill_rate				= 	@tar_use_bill_rate
		, tariffheaderstl.tar_timecalc_method				= 	@tar_timecalc_method
		, tariffheaderstl.tar_timecalc_use_first_qualevent	= 	@tar_timecalc_use_first_qualevent
		, tariffheaderstl.tar_timecalc_first_qualevent_freetime	= 	@tar_timecalc_first_qualevent_freetime
		, tariffheaderstl.tar_timecalc_use_last_qualevent		= 	@tar_timecalc_use_last_qualevent
		, tariffheaderstl.tar_timecalc_last_qualevent_freetime	= 	@tar_timecalc_last_qualevent_freetime
		, tariffheaderstl.tar_timecalc_max_freetime				= 	@tar_timecalc_max_freetime
		, tariffheaderstl.tar_timecalc_min_freetime				= 	@tar_timecalc_min_freetime
		, tariffheaderstl.tar_minqty							= 	@tar_minqty
		, tariffheaderstl.tar_free_qty							= 	@tar_free_qty
		, tariffheaderstl.tar_timecalc_stopeligible				= 	@tar_timecalc_stopeligible
		, tariffheaderstl.tar_round_amount						= 	@tar_round_amount
		, tariffheaderstl.tar_zerorateisnorate					= 	@tar_zerorateisnorate
		, tariffheaderstl.tar_timecalc_max_qty					= 	@tar_timecalc_max_qty
		, tariffheaderstl.tar_timecalc_max_qty_timeframe		= 	@tar_timecalc_max_qty_timeframe
		, tariffheaderstl.tar_timecalc_max_qty_timeframe_use	= 	@tar_timecalc_max_qty_timeframe_use

	where tariffheaderstl.tar_number = @newtarnbr



IF OBJECT_ID(N'tempdb..#tempNewStlTarCols', N'U') IS NOT NULL 
DROP TABLE #tempNewStlTarCols
GO
GRANT EXECUTE ON  [dbo].[copy_tariffheaderstlremainder] TO [public]
GO
